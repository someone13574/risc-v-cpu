`include "microcode.sv"

module memory(
    input logic clk,
    input logic clk_enable,
    input logic [31:0] addr,
    input logic [31:0] offset_addr,
    input logic [31:0] data_in,
    input logic [microcode::WIDTH - 1:0] microcode_s2,
    input logic [microcode::WIDTH - 1:0] microcode_s3,
    input logic use_truncation,
    output logic [31:0] data_out,
    output logic [15:0] display_out
);

logic write_enable;
logic enable_upper_half_s2;
logic enable_byte_1_s2;

logic enable_upper_half_s3_raw;
logic enable_byte_1_s3_raw;
logic sext_mem_data_out;

always_comb begin
    write_enable         = microcode::mcs2_mem_we(microcode_s2);
    enable_upper_half_s2 = microcode::mcs2_enable_upper_half(microcode_s2);
    enable_byte_1_s2     = microcode::mcs2_enable_byte1(microcode_s2);

    enable_upper_half_s3_raw = microcode::mcs2_enable_upper_half(microcode_s3);
    enable_byte_1_s3_raw     = microcode::mcs2_enable_byte1(microcode_s3);
    sext_mem_data_out        = microcode::mcs3_sext_mem_out(microcode_s3);
end

logic [7:0] eab_01;
logic [7:0] eab_23;
logic [7:0] eab_45;
logic [7:0] eab_67;

logic [8:0] eab_01_addr;
logic [8:0] eab_23_addr;
logic [8:0] eab_45_addr;
logic [8:0] eab_67_addr;

logic [3:0] eab_we;

always_comb begin
    case (addr[1:0])
        2'b00: begin
            eab_01_addr = addr[10:2];
            eab_23_addr = addr[10:2];
            eab_45_addr = addr[10:2];
            eab_67_addr = addr[10:2];
            eab_we = {enable_upper_half_s2, enable_upper_half_s2, enable_byte_1_s2, 1'b1} & {4{write_enable}};
        end
        2'b01: begin
            eab_01_addr = addr[10:2];
            eab_23_addr = addr[10:2];
            eab_45_addr = addr[10:2];
            eab_67_addr = offset_addr[10:2];
            eab_we = {enable_upper_half_s2, enable_byte_1_s2, 1'b1, enable_upper_half_s2} & {4{write_enable}};
        end
        2'b10: begin
            eab_01_addr = addr[10:2];
            eab_23_addr = addr[10:2];
            eab_45_addr = offset_addr[10:2];
            eab_67_addr = offset_addr[10:2];
            eab_we = {enable_byte_1_s2, 1'b1, enable_upper_half_s2, enable_upper_half_s2} & {4{write_enable}};
        end
        2'b11: begin
            eab_01_addr = addr[10:2];
            eab_23_addr = offset_addr[10:2];
            eab_45_addr = offset_addr[10:2];
            eab_67_addr = offset_addr[10:2];
            eab_we = {1'b1, enable_upper_half_s2, enable_upper_half_s2, enable_byte_1_s2} & {4{write_enable}};
        end
    endcase
end

logic [1:0] prev_swizzle_case;
always_ff @(posedge clk) begin
    if (clk_enable) begin
        prev_swizzle_case <= addr[1:0];
    end
end

logic [31:0] out_swizzled;
logic enable_byte_1_s3;
logic enable_upper_half_s3;
logic ext_bit;
always_comb begin
    case (prev_swizzle_case)
        2'b00: out_swizzled = {eab_01, eab_23, eab_45, eab_67};
        2'b01: out_swizzled = {eab_67, eab_01, eab_23, eab_45};
        2'b10: out_swizzled = {eab_45, eab_67, eab_01, eab_23};
        2'b11: out_swizzled = {eab_23, eab_45, eab_67, eab_01};
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

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-0.mif")) mem0(
    .inclock(clk),
    .outclock(clk),
    .we(eab_we[0]),
    .address(eab_01_addr),
    .data(data_in[3:0]),
    .q(eab_01[7:4])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-1.mif")) mem1(
    .inclock(clk),
    .outclock(clk),
    .we(eab_we[0]),
    .address(eab_01_addr),
    .data(data_in[7:4]),
    .q(eab_01[3:0])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-2.mif")) mem2(
    .inclock(clk),
    .outclock(clk),
    .we(eab_we[1]),
    .address(eab_23_addr),
    .data(data_in[11:8]),
    .q(eab_23[7:4])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-3.mif")) mem3(
    .inclock(clk),
    .outclock(clk),
    .we(eab_we[1]),
    .address(eab_23_addr),
    .data(data_in[15:12]),
    .q(eab_23[3:0])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-4.mif")) mem4(
    .inclock(clk),
    .outclock(clk),
    .we(eab_we[2]),
    .address(eab_45_addr),
    .data(data_in[19:16]),
    .q(eab_45[7:4])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-5.mif")) mem5(
    .inclock(clk),
    .outclock(clk),
    .we(eab_we[2]),
    .address(eab_45_addr),
    .data(data_in[23:20]),
    .q(eab_45[3:0])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-6.mif")) mem6(
    .inclock(clk),
    .outclock(clk),
    .we(eab_we[3]),
    .address(eab_67_addr),
    .data(data_in[27:24]),
    .q(eab_67[7:4])
);


lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-7.mif")) mem7(
    .inclock(clk),
    .outclock(clk),
    .we(eab_we[3]),
    .address(eab_67_addr),
    .data(data_in[31:28]),
    .q(eab_67[3:0])
);

endmodule
