module memory(
    input logic clk,
    input logic clk_enable,
    input logic [31:0] addr,
    input logic [31:0] offset_addr,
    input logic [31:0] data_in,
    input logic [24:0] microcode_s2,
    input logic [24:0] microcode_s3,
    input logic use_truncation,
    output logic [31:0] data_out,
    output logic [15:0] display_out
);

logic write_enable;
logic enable_upper_half_s2;
logic enable_byte_1_s2;
microcode_s2_decoder mc_s2_decode(
    .microcode(microcode_s2),
    .mem_write_enable(write_enable),
    .enable_upper_half(enable_upper_half_s2),
    .enable_byte_1(enable_byte_1_s2)
);

logic enable_upper_half_s3_raw;
logic enable_byte_1_s3_raw;
microcode_s2_decoder mc_s2_decode_s3_in(
    .microcode(microcode_s3),
    .enable_upper_half(enable_upper_half_s3_raw),
    .enable_byte_1(enable_byte_1_s3_raw)
);

logic sext_mem_data_out;
microcode_s3_decoder mc_s3_decode(
    .microcode(microcode_s3),
    .sext_mem_data_out(sext_mem_data_out)
);


logic [3:0] unsquizzled_eab_we;
logic [3:0] squizzled_eab_we;

logic [31:0] squizzled_data_in;

logic [8:0] eab_10_addr;
logic [8:0] eab_32_addr;
logic [8:0] eab_54_addr;
logic [8:0] eab_76_addr;

always_comb begin
    unsquizzled_eab_we <= {enable_upper_half_s2, enable_upper_half_s2, enable_byte_1_s2, 1'b1} & {4{write_enable}};

    case (addr[1:0])
        2'b00: begin
            eab_10_addr = addr[10:2];
            eab_32_addr = addr[10:2];
            eab_54_addr = addr[10:2];
            eab_76_addr = addr[10:2];
            squizzled_eab_we = unsquizzled_eab_we;
            squizzled_data_in = data_in;
        end
        2'b01: begin
            eab_10_addr = offset_addr[10:2];
            eab_32_addr = addr[10:2];
            eab_54_addr = addr[10:2];
            eab_76_addr = addr[10:2];
            squizzled_eab_we = {unsquizzled_eab_we[2:0], unsquizzled_eab_we[3]};
            squizzled_data_in = {data_in[23:0], data_in[31:24]};
        end
        2'b10: begin
            eab_10_addr = offset_addr[10:2];
            eab_32_addr = offset_addr[10:2];
            eab_54_addr = addr[10:2];
            eab_76_addr = addr[10:2];
            squizzled_eab_we = {unsquizzled_eab_we[1:0], unsquizzled_eab_we[3:2]};
            squizzled_data_in = {data_in[15:0], data_in[31:16]};
        end
        2'b11: begin
            eab_10_addr = offset_addr[10:2];
            eab_32_addr = offset_addr[10:2];
            eab_54_addr = offset_addr[10:2];
            eab_76_addr = addr[10:2];
            squizzled_eab_we = {unsquizzled_eab_we[0], unsquizzled_eab_we[3:1]};
            squizzled_data_in = {data_in[7:0], data_in[31:8]};
        end
    endcase
end

logic [1:0] prev_addr_align;
always_ff @(posedge clk) begin
    if (clk_enable) begin
        prev_addr_align <= addr[1:0];
    end
end

logic [31:0] out_raw;
logic [31:0] out_swizzled;
logic [31:0] out_truncated;

logic enable_byte_1_s3;
logic enable_upper_half_s3;
logic ext_bit;
always_comb begin
    case (prev_addr_align)
        2'b00: out_swizzled = {out_raw[31:0]};
        2'b01: out_swizzled = {out_raw[ 7:0], out_raw[31: 8]};
        2'b10: out_swizzled = {out_raw[15:0], out_raw[31:16]};
        2'b11: out_swizzled = {out_raw[23:0], out_raw[31:24]};
    endcase

    enable_byte_1_s3 = enable_byte_1_s3_raw | ~use_truncation;
    enable_upper_half_s3 = enable_upper_half_s3_raw | ~use_truncation;

    ext_bit = sext_mem_data_out & (enable_byte_1_s3 ? out_swizzled[15] : out_swizzled[7]);
    data_out = {
        out_swizzled[31:16] & {16{enable_upper_half_s3}},
        out_swizzled[15:8] & {8{enable_byte_1_s3}},
        out_swizzled[7:0]
    } | {
        {16{ext_bit & ~enable_upper_half_s3}},
        {8{ext_bit & ~enable_byte_1_s3}},
        8'b0
    };
end

always_ff @(posedge clk) begin
    if (clk_enable) begin
        if (addr == 32'h7fe) begin
            if (write_enable) begin
                display_out <= ~data_in[15:0];
            end
        end
    end
end

// 0000000x
lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9)) mem0(
    .inclock(clk),
    .outclock(clk),
    .we(squizzled_eab_we[0]),
    .address(eab_10_addr),
    .data(squizzled_data_in[3:0]),
    .q(out_raw[3:0])
);

// 000000x0
lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9)) mem1(
    .inclock(clk),
    .outclock(clk),
    .we(squizzled_eab_we[0]),
    .address(eab_10_addr),
    .data(squizzled_data_in[7:4]),
    .q(out_raw[7:4])
);

// 00000x00
lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9)) mem2(
    .inclock(clk),
    .outclock(clk),
    .we(squizzled_eab_we[1]),
    .address(eab_32_addr),
    .data(squizzled_data_in[11:8]),
    .q(out_raw[11:8])
);

// 0000x000
lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9)) mem3(
    .inclock(clk),
    .outclock(clk),
    .we(squizzled_eab_we[1]),
    .address(eab_32_addr),
    .data(squizzled_data_in[15:12]),
    .q(out_raw[15:12])
);

// 000x0000
lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9)) mem4(
    .inclock(clk),
    .outclock(clk),
    .we(squizzled_eab_we[2]),
    .address(eab_54_addr),
    .data(squizzled_data_in[19:16]),
    .q(out_raw[19:16])
);

// 00x00000
lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9)) mem5(
    .inclock(clk),
    .outclock(clk),
    .we(squizzled_eab_we[2]),
    .address(eab_54_addr),
    .data(squizzled_data_in[23:20]),
    .q(out_raw[23:20])
);

// 0x000000
lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9)) mem6(
    .inclock(clk),
    .outclock(clk),
    .we(squizzled_eab_we[3]),
    .address(eab_76_addr),
    .data(squizzled_data_in[27:24]),
    .q(out_raw[27:24])
);

// x0000000
lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9)) mem7(
    .inclock(clk),
    .outclock(clk),
    .we(squizzled_eab_we[3]),
    .address(eab_76_addr),
    .data(squizzled_data_in[31:28]),
    .q(out_raw[31:28])
);

endmodule
