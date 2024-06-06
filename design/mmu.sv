`include "microcode.sv"

module mmu_encode #(
    parameter BLOCK_ADDR_WIDTH,
    parameter MMIO_ADDR_START_BIT
) (
    input logic [microcode::WIDTH - 1:0] microcode_s2,
    input logic [31:0] addr,
    input logic [31:0] next_addr,
    input logic [31:0] data_in,
    output logic [3:0] physical_per_byte_we,
    output logic [BLOCK_ADDR_WIDTH - 1:0] physical_byte_addrs [0:3],
    output logic [31:0] physical_data_in
);

logic is_mmio;
logic we;
logic we_byte1;
logic we_upper_half;

logic [3:0] per_byte_we;

logic [1:0] addr_align;
logic [BLOCK_ADDR_WIDTH - 1:0] trunc_addr;
logic [BLOCK_ADDR_WIDTH - 1:0] trunc_next_addr;

always_comb begin
    is_mmio = addr[MMIO_ADDR_START_BIT];
    we = microcode::mcs2_mem_we(microcode_s2);
    we_byte1 = microcode::mcs2_enable_byte1(microcode_s2);
    we_upper_half = microcode::mcs2_enable_upper_half(microcode_s2);

    per_byte_we = {we_upper_half, we_upper_half, we_byte1, 1'b1} & {4{we & ~is_mmio}};

    addr_align = addr[1:0];
    trunc_addr = addr[BLOCK_ADDR_WIDTH + 1:2];
    trunc_next_addr = next_addr[BLOCK_ADDR_WIDTH + 1:2];

    case (addr_align)
        2'b00: physical_per_byte_we = per_byte_we;
        2'b01: physical_per_byte_we = {per_byte_we[2:0], per_byte_we[3]};
        2'b10: physical_per_byte_we = {per_byte_we[1:0], per_byte_we[3:2]};
        2'b11: physical_per_byte_we = {per_byte_we[0],   per_byte_we[3:1]};
    endcase

    case (addr_align)
        2'b00: physical_data_in = data_in;
        2'b01: physical_data_in = {data_in[23:0], data_in[31:24]};
        2'b10: physical_data_in = {data_in[15:0], data_in[31:16]};
        2'b11: physical_data_in = {data_in[ 7:0], data_in[31: 8]};
    endcase

    case (addr_align)
        2'b00: begin
            physical_byte_addrs[0] = trunc_addr;
            physical_byte_addrs[1] = trunc_addr;
            physical_byte_addrs[2] = trunc_addr;
            physical_byte_addrs[3] = trunc_addr;
        end
        2'b01: begin
            physical_byte_addrs[0] = trunc_next_addr;
            physical_byte_addrs[1] = trunc_addr;
            physical_byte_addrs[2] = trunc_addr;
            physical_byte_addrs[3] = trunc_addr;
        end
        2'b10: begin
            physical_byte_addrs[0] = trunc_next_addr;
            physical_byte_addrs[1] = trunc_next_addr;
            physical_byte_addrs[2] = trunc_addr;
            physical_byte_addrs[3] = trunc_addr;
        end
        2'b11: begin
            physical_byte_addrs[0] = trunc_next_addr;
            physical_byte_addrs[1] = trunc_next_addr;
            physical_byte_addrs[2] = trunc_next_addr;
            physical_byte_addrs[3] = trunc_addr;
        end
    endcase
end

endmodule

module mmu_decode(
    input logic clk,
    input logic clk_enable,
    input logic [microcode::WIDTH - 1:0] microcode_s3,
    input logic [1:0] addr_align,
    input logic [31:0] physical_data_out,
    output logic [31:0] data_out
);

logic [1:0] prev_addr_align;

always_ff @(posedge clk) begin
    if (clk_enable) begin
        prev_addr_align <= addr_align;
    end
end

logic keep_byte1;
logic keep_upper_half;
logic sext_data_out;
logic enable_trunc;

logic [31:0] data_out_pre_trunc;
logic [31:0] trunc_data_out;
logic ext_bit;

always_comb begin
    enable_trunc    = microcode::mcs2_alu_out_over_pc(microcode_s3);
    keep_byte1      = microcode::mcs2_enable_byte1(microcode_s3) | ~enable_trunc;
    keep_upper_half = microcode::mcs2_enable_upper_half(microcode_s3) | ~enable_trunc;
    sext_data_out   = microcode::mcs3_sext_mem_out(microcode_s3);

    case (prev_addr_align)
        2'b00: data_out_pre_trunc = physical_data_out;
        2'b01: data_out_pre_trunc = {physical_data_out[ 7:0], physical_data_out[31: 8]};
        2'b10: data_out_pre_trunc = {physical_data_out[15:0], physical_data_out[31:16]};
        2'b11: data_out_pre_trunc = {physical_data_out[23:0], physical_data_out[31:24]};
    endcase

    trunc_data_out = {
        data_out_pre_trunc[31:16] & {16{keep_upper_half}},
        data_out_pre_trunc[15:8] & {8{keep_byte1}},
        data_out_pre_trunc[7:0]
    };

    ext_bit = sext_data_out & (keep_byte1 ? data_out_pre_trunc[15] : data_out_pre_trunc[7]);
    data_out = trunc_data_out | {
        {16{ext_bit & ~keep_upper_half}},
        {8{ext_bit & ~keep_byte1}},
        8'b0
    };
end

endmodule
