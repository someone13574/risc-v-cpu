`include "microcode.sv"

module memory (
    input logic clk,
    input logic clk_enable,
    input logic [microcode::WIDTH - 1:0] microcode_s2,
    input logic [microcode::WIDTH - 1:0] microcode_s3,
    input logic [31:0] addr,
    input logic [31:0] next_addr,
    input logic [31:0] data_in,
    output logic [31:0] data_out,
    mmio_outputs_if mmio_outputs
);

    localparam int BlockAddrWidth = 9;
    localparam int MMIOAddrStartBit = 11;

    logic [3:0] physical_we;
    logic [BlockAddrWidth - 1:0] physical_addrs[4];
    logic [31:0] physical_data_in;

    mmu_encode #(
        .BLOCK_ADDR_WIDTH(BlockAddrWidth),
        .MMIO_ADDR_START_BIT(MMIOAddrStartBit)
    ) mmu_encode (
        .microcode_s2(microcode_s2),
        .addr(addr),
        .next_addr(next_addr),
        .data_in(data_in),
        .physical_per_byte_we(physical_we),
        .physical_byte_addrs(physical_addrs),
        .physical_data_in(physical_data_in)
    );

    logic [31:0] physical_data_out;
    logic [31:0] mmu_data_out;

    mmu_decode mmu_decode (
        .clk(clk),
        .clk_enable(clk_enable),
        .microcode_s3(microcode_s3),
        .addr_align(addr[1:0]),
        .physical_data_out(physical_data_out),
        .data_out(mmu_data_out)
    );

    logic [31:0] mmio_data_out;
    logic is_mmio;

    mmio #(
        .MMIO_ADDR_START_BIT(MMIOAddrStartBit)
    ) mmio (
        .clk(clk),
        .clk_enable(clk_enable),
        .microcode_s2(microcode_s2),
        .addr(addr),
        .data_in(data_in),
        .data_out(mmio_data_out),
        .is_mmio(is_mmio),
        .mmio_outputs(mmio_outputs)
    );

    always_comb begin
        data_out = is_mmio ? mmio_data_out : mmu_data_out;
    end

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : g_mem
            lpm_ram_dq #(
                .LPM_WIDTH  (4),
                .LPM_WIDTHAD(9)
            ) mem_block (
                .inclock(clk),
                .outclock(clk),
                .we(physical_we[i>>1]),
                .address(physical_addrs[i>>1]),
                .data(physical_data_in[i>>1]),
                .q(physical_data_out[i*4+3:i*4])
            );
        end
    endgenerate

endmodule
