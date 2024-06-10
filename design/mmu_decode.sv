`include "microcode.sv"

module mmu_decode (
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
            2'b00:   data_out_pre_trunc = physical_data_out;
            2'b01:   data_out_pre_trunc = {physical_data_out[7:0], physical_data_out[31:8]};
            2'b10:   data_out_pre_trunc = {physical_data_out[15:0], physical_data_out[31:16]};
            2'b11:   data_out_pre_trunc = {physical_data_out[23:0], physical_data_out[31:24]};
            default: data_out_pre_trunc = 32'd0;
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
