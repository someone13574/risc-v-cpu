module memory(
    input logic clk,
    input logic clk_enable,
    input logic [31:0] addr,
    input logic [31:0] data_in,
    input logic [22:0] microcode_s2,
    output logic [31:0] data_out,
    output logic [15:0] display_out
);

logic write_enable;
microcode_s2_decoder mc_s2_decode(
    .microcode(microcode_s2),
    .mem_write_enable(write_enable)
);

always_ff @(posedge clk) begin
    if (clk_enable) begin
        if (addr == 32'h7fe) begin
            if (write_enable) begin
                display_out <= ~data_in[15:0];
            end
        end
    end
end

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-7")) mem7(
    .inclock(clk),
    .outclock(clk),
    .we(write_enable),
    .address(addr[10:2]),
    .data(data_in[3:0]),
    .q(data_out[3:0])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-6")) mem6(
    .inclock(clk),
    .outclock(clk),
    .we(write_enable),
    .address(addr[10:2]),
    .data(data_in[7:4]),
    .q(data_out[7:4])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-5")) mem5(
    .inclock(clk),
    .outclock(clk),
    .we(write_enable),
    .address(addr[10:2]),
    .data(data_in[11:8]),
    .q(data_out[11:8])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-4")) mem4(
    .inclock(clk),
    .outclock(clk),
    .we(write_enable),
    .address(addr[10:2]),
    .data(data_in[15:12]),
    .q(data_out[15:12])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-3")) mem3(
    .inclock(clk),
    .outclock(clk),
    .we(write_enable),
    .address(addr[10:2]),
    .data(data_in[19:16]),
    .q(data_out[19:16])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-2")) mem2(
    .inclock(clk),
    .outclock(clk),
    .we(write_enable),
    .address(addr[10:2]),
    .data(data_in[23:20]),
    .q(data_out[23:20])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-1")) mem1(
    .inclock(clk),
    .outclock(clk),
    .we(write_enable),
    .address(addr[10:2]),
    .data(data_in[27:24]),
    .q(data_out[27:24])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-0")) mem0(
    .inclock(clk),
    .outclock(clk),
    .we(write_enable),
    .address(addr[10:2]),
    .data(data_in[31:28]),
    .q(data_out[31:28])
);

endmodule
