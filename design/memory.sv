`include "microcode.sv"

module memory(
    input logic clk,
    input logic clk_enable,
    input logic [microcode::WIDTH - 1:0] microcode_s2,
    input logic [microcode::WIDTH - 1:0] microcode_s3,
    input logic [31:0] addr,
    input logic [31:0] next_addr,
    input logic [31:0] data_in,
    output logic [31:0] data_out,
    output logic [15:0] seven_segment_out
);

localparam BLOCK_ADDR_WIDTH = 9;
localparam MMIO_ADDR_START_BIT = 11;

logic [3:0] physical_we;
logic [BLOCK_ADDR_WIDTH - 1:0] physical_addrs [0:3];
logic [31:0] physical_data_in;

mmu_encode #(.BLOCK_ADDR_WIDTH(BLOCK_ADDR_WIDTH), .MMIO_ADDR_START_BIT(MMIO_ADDR_START_BIT)) mmu_encode(
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

mmu_decode mmu_decode(
    .clk(clk),
    .clk_enable(clk_enable),
    .microcode_s3(microcode_s3),
    .addr_align(addr[1:0]),
    .physical_data_out(physical_data_out),
    .data_out(mmu_data_out)
);

logic [31:0] mmio_data_out;
logic is_mmio;

mmio #(.MMIO_ADDR_START_BIT(MMIO_ADDR_START_BIT)) mmio(
    .clk(clk),
    .clk_enable(clk_enable),
    .microcode_s2(microcode_s2),
    .addr(addr),
    .data_in(data_in),
    .data_out(mmio_data_out),
    .is_mmio(is_mmio),
    .seven_segment_out(seven_segment_out)
);

always_comb begin
    data_out = is_mmio ? mmio_data_out : mmu_data_out;
end

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-0.mif")) mem_block_0(
    .inclock(clk),
    .outclock(clk),
    .we(physical_we[0]),
    .address(physical_addrs[0]),
    .data(physical_data_in[0 * 4 + 3:0 * 4]),
    .q(physical_data_out[0 * 4 + 3:0 * 4])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-1.mif")) mem_block_1(
    .inclock(clk),
    .outclock(clk),
    .we(physical_we[0]),
    .address(physical_addrs[0]),
    .data(physical_data_in[1 * 4 + 3:1 * 4]),
    .q(physical_data_out[1 * 4 + 3:1 * 4])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-2.mif")) mem_block_2(
    .inclock(clk),
    .outclock(clk),
    .we(physical_we[1]),
    .address(physical_addrs[1]),
    .data(physical_data_in[2 * 4 + 3:2 * 4]),
    .q(physical_data_out[2 * 4 + 3:2 * 4])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-3.mif")) mem_block_3(
    .inclock(clk),
    .outclock(clk),
    .we(physical_we[1]),
    .address(physical_addrs[1]),
    .data(physical_data_in[3 * 4 + 3:3 * 4]),
    .q(physical_data_out[3 * 4 + 3:3 * 4])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-4.mif")) mem_block_4(
    .inclock(clk),
    .outclock(clk),
    .we(physical_we[2]),
    .address(physical_addrs[2]),
    .data(physical_data_in[4 * 4 + 3:4 * 4]),
    .q(physical_data_out[4 * 4 + 3:4 * 4])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-5.mif")) mem_block_5(
    .inclock(clk),
    .outclock(clk),
    .we(physical_we[2]),
    .address(physical_addrs[2]),
    .data(physical_data_in[5 * 4 + 3:5 * 4]),
    .q(physical_data_out[5 * 4 + 3:5 * 4])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-6.mif")) mem_block_6(
    .inclock(clk),
    .outclock(clk),
    .we(physical_we[3]),
    .address(physical_addrs[3]),
    .data(physical_data_in[6 * 4 + 3:6 * 4]),
    .q(physical_data_out[6 * 4 + 3:6 * 4])
);

lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9), .LPM_FILE("memory_init/eab-init-7.mif")) mem_block_7(
    .inclock(clk),
    .outclock(clk),
    .we(physical_we[3]),
    .address(physical_addrs[3]),
    .data(physical_data_in[7 * 4 + 3:7 * 4]),
    .q(physical_data_out[7 * 4 + 3:7 * 4])
);

endmodule
