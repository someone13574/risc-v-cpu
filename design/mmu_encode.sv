`include "microcode.sv"

module mmu_encode #(
    parameter logic [31:0] BLOCK_ADDR_WIDTH,
    parameter logic [31:0] MMIO_ADDR_START_BIT
) (
    input logic [microcode::WIDTH - 1:0] microcode_s2,
    input logic [31:0] addr,
    input logic [31:0] next_addr,
    input logic [31:0] data_in,
    output logic [3:0] physical_per_byte_we,
    output logic [BLOCK_ADDR_WIDTH - 1:0] physical_byte_addrs[4],
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
        trunc_addr = addr[BLOCK_ADDR_WIDTH+1:2];
        trunc_next_addr = next_addr[BLOCK_ADDR_WIDTH+1:2];

        case (addr_align)
            2'b00:   physical_per_byte_we = per_byte_we;
            2'b01:   physical_per_byte_we = {per_byte_we[2:0], per_byte_we[3]};
            2'b10:   physical_per_byte_we = {per_byte_we[1:0], per_byte_we[3:2]};
            2'b11:   physical_per_byte_we = {per_byte_we[0], per_byte_we[3:1]};
            default: physical_per_byte_we = 4'd0;
        endcase

        case (addr_align)
            2'b00:   physical_data_in = data_in;
            2'b01:   physical_data_in = {data_in[23:0], data_in[31:24]};
            2'b10:   physical_data_in = {data_in[15:0], data_in[31:16]};
            2'b11:   physical_data_in = {data_in[7:0], data_in[31:8]};
            default: physical_data_in = 32'd0;
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
            default: begin
                physical_byte_addrs[0] = 32'd0;
                physical_byte_addrs[1] = 32'd0;
                physical_byte_addrs[2] = 32'd0;
                physical_byte_addrs[3] = 32'd0;
            end
        endcase
    end

endmodule
