module microcode_s0_decoder (
    input logic [22:0] microcode,
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
    input logic [22:0] microcode,
    output logic jump_if_branch,
    output logic mem_in_use,
    output logic [3:0] alu_op_select
);

always_comb begin
    jump_if_branch             = microcode[10];
    mem_in_use                 = microcode[11];
    alu_op_select              = microcode[15:12];
end

endmodule

module microcode_s2_decoder (
    input logic [22:0] microcode,
    output logic mem_write_enable,
    output logic alu_out_to_mem_addr,
    output logic [1:0] pre_writeback_select
);

always_comb begin
    mem_write_enable     = microcode[16];
    alu_out_to_mem_addr  = microcode[17];
    pre_writeback_select = microcode[19:18];
end

endmodule

module micorcode_s3_decoder (
    input logic [22:0] microcode,
    output logic reg_write_enable,
    output logic use_pre_wb_over_mem_data
);

always_comb begin
    reg_write_enable         = microcode[20];
    use_pre_wb_over_mem_data = microcode[21];
end

endmodule
