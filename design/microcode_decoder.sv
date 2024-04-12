module microcode_s0_decoder (
    input logic [22:0] microcode,
    output logic check_rs1_dep,
    output logic check_rs2_dep,
    output logic [1:0] pre_alu_a_select,
    output logic [1:0] pre_alu_b_select,
    output logic [2:0] cmp_op_select
);

always_comb begin
    check_rs1_dep    = microcode[0];
    check_rs2_dep    = microcode[1];
    pre_alu_a_select = microcode[3:2];
    pre_alu_b_select = microcode[5:4];
    cmp_op_select    = microcode[8:6];
end

endmodule

module microcode_s1_decoder (
    input logic [22:0] microcode,
    output logic use_pre_alu_a_over_reg_out,
    output logic use_pre_alu_b_over_reg_out,
    output logic jump_if_branch,
    output logic mem_in_use,
    output logic [3:0] alu_op_select
);

always_comb begin
    use_pre_alu_a_over_reg_out = microcode[9];
    use_pre_alu_b_over_reg_out = microcode[10];
    jump_if_branch             = microcode[11];
    mem_in_use                 = microcode[12];
    alu_op_select              = microcode[16:13];
end

endmodule

module microcode_s2_decoder (
    input logic [22:0] microcode,
    output logic mem_write_enable,
    output logic alu_out_to_mem_addr,
    output logic [1:0] pre_writeback_select
);

always_comb begin
    mem_write_enable     = microcode[17];
    alu_out_to_mem_addr  = microcode[18];
    pre_writeback_select = microcode[20:19];
end

endmodule

module micorcode_s3_decoder (
    input logic [22:0] microcode,
    output logic reg_write_enable,
    output logic use_pre_wb_over_mem_data
);

always_comb begin
    reg_write_enable         = microcode[21];
    use_pre_wb_over_mem_data = microcode[22];
end

endmodule
