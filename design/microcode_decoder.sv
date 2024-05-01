module microcode_s0_decoder (
    input logic [24:0] microcode,
    output logic check_rs1_dep,
    output logic check_rs2_dep,
    output logic [1:0] pre_alu_a_select,
    output logic [2:0] pre_alu_b_select,
    output logic [2:0] cmp_op_select
);

always_comb begin
    check_rs1_dep    = microcode[0];
    check_rs2_dep    = microcode[1];
    pre_alu_a_select = microcode[3:2];
    pre_alu_b_select = microcode[6:4];
    cmp_op_select    = microcode[9:7];
end

endmodule

module microcode_s1_decoder (
    input logic [24:0] microcode,
    output logic mem_in_use,
    output logic [3:0] alu_op_select
);

always_comb begin
    mem_in_use                 = microcode[10];
    alu_op_select              = microcode[14:11];
end

endmodule

module microcode_s2_decoder (
    input logic [24:0] microcode,
    output logic mem_write_enable,
    output logic enable_upper_half,
    output logic enable_byte_1,
    output logic alu_out_to_mem_addr,
    output logic jump_if_branch,
    output logic [1:0] pre_writeback_select
);

always_comb begin
    mem_write_enable     = microcode[15];
    enable_upper_half     = microcode[16];
    enable_byte_1         = microcode[17];
    alu_out_to_mem_addr  = microcode[18];
    jump_if_branch       = microcode[19];
    pre_writeback_select = microcode[21:20];
end

endmodule

module microcode_s3_decoder (
    input logic [24:0] microcode,
    output logic reg_write_enable,
    output logic use_pre_wb_over_mem_data,
    output logic sext_mem_data_out
);

always_comb begin
    reg_write_enable         = microcode[22];
    use_pre_wb_over_mem_data = microcode[23];
    sext_mem_data_out        = microcode[24];
end

endmodule
