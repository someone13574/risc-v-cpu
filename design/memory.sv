`include "microcode.sv"

module memory (
    input logic clk,
    input logic clk_enable,
    input logic [microcode::WIDTH - 1:0] microcode_s2,
    input logic [microcode::WIDTH - 1:0] microcode_s3,
    input logic [31:0] addr,
    input logic [31:0] next_addr,
    input logic [31:0] data_in,
    input logic uart_tx_sending,
    output logic [31:0] data_out,
    output logic [15:0] seven_segment_out,
    output logic [8:0] uart_tx_data
);

    localparam logic [31:0] BlockAddrWidth = 9;
    localparam logic [31:0] MmioAddrStartBit = 11;

    logic [3:0] physical_we;
    logic [BlockAddrWidth - 1:0] physical_addrs[4];
    logic [31:0] physical_data_in;

    // convert address used by the cpu to the addresses used by the eab's (so that misaligned write work)
    mmu_encode #(
        .BLOCK_ADDR_WIDTH(BlockAddrWidth),
        .MMIO_ADDR_START_BIT(MmioAddrStartBit)
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

    // swizzle & truncate / sign-extend the outputs of the eab's into a proper output signal
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

    // handle mmio addresses (they don't live in the main memory)
    mmio #(
        .MMIO_ADDR_START_BIT(MmioAddrStartBit)
    ) mmio (
        .clk(clk),
        .clk_enable(clk_enable),
        .microcode_s2(microcode_s2),
        .addr(addr),
        .data_in(data_in),
        .uart_tx_sending(uart_tx_sending),
        .data_out(mmio_data_out),
        .is_mmio(is_mmio),
        .seven_segment_out(seven_segment_out),
        .uart_tx_data(uart_tx_data)
    );

    // delay the `is_mmio` signal one cycle because the memory read takes a cycle
    logic prev_is_mmio;
    always_ff @(posedge clk) begin
        if (clk_enable) begin
            prev_is_mmio <= is_mmio;
        end
    end

    // switch between outputting from memory and from mmio registers
    always_comb begin
        data_out = prev_is_mmio ? mmio_data_out : mmu_data_out;
    end

    lpm_ram_dq #(
        .LPM_WIDTH  (4),
        .LPM_WIDTHAD(9)
    ) mem_block_0 (
        .inclock(clk),
        .outclock(clk),
        .we(physical_we[0]),
        .address(physical_addrs[0]),
        .data(physical_data_in[0*4+3:0*4]),
        .q(physical_data_out[0*4+3:0*4])
    );

    lpm_ram_dq #(
        .LPM_WIDTH  (4),
        .LPM_WIDTHAD(9)
    ) mem_block_1 (
        .inclock(clk),
        .outclock(clk),
        .we(physical_we[0]),
        .address(physical_addrs[0]),
        .data(physical_data_in[1*4+3:1*4]),
        .q(physical_data_out[1*4+3:1*4])
    );

    lpm_ram_dq #(
        .LPM_WIDTH  (4),
        .LPM_WIDTHAD(9)
    ) mem_block_2 (
        .inclock(clk),
        .outclock(clk),
        .we(physical_we[1]),
        .address(physical_addrs[1]),
        .data(physical_data_in[2*4+3:2*4]),
        .q(physical_data_out[2*4+3:2*4])
    );

    lpm_ram_dq #(
        .LPM_WIDTH  (4),
        .LPM_WIDTHAD(9)
    ) mem_block_3 (
        .inclock(clk),
        .outclock(clk),
        .we(physical_we[1]),
        .address(physical_addrs[1]),
        .data(physical_data_in[3*4+3:3*4]),
        .q(physical_data_out[3*4+3:3*4])
    );

    lpm_ram_dq #(
        .LPM_WIDTH  (4),
        .LPM_WIDTHAD(9)
    ) mem_block_4 (
        .inclock(clk),
        .outclock(clk),
        .we(physical_we[2]),
        .address(physical_addrs[2]),
        .data(physical_data_in[4*4+3:4*4]),
        .q(physical_data_out[4*4+3:4*4])
    );

    lpm_ram_dq #(
        .LPM_WIDTH  (4),
        .LPM_WIDTHAD(9)
    ) mem_block_5 (
        .inclock(clk),
        .outclock(clk),
        .we(physical_we[2]),
        .address(physical_addrs[2]),
        .data(physical_data_in[5*4+3:5*4]),
        .q(physical_data_out[5*4+3:5*4])
    );

    lpm_ram_dq #(
        .LPM_WIDTH  (4),
        .LPM_WIDTHAD(9)
    ) mem_block_6 (
        .inclock(clk),
        .outclock(clk),
        .we(physical_we[3]),
        .address(physical_addrs[3]),
        .data(physical_data_in[6*4+3:6*4]),
        .q(physical_data_out[6*4+3:6*4])
    );

    lpm_ram_dq #(
        .LPM_WIDTH  (4),
        .LPM_WIDTHAD(9)
    ) mem_block_7 (
        .inclock(clk),
        .outclock(clk),
        .we(physical_we[3]),
        .address(physical_addrs[3]),
        .data(physical_data_in[7*4+3:7*4]),
        .q(physical_data_out[7*4+3:7*4])
    );

endmodule
