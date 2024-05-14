`include "microcode.sv"
`include "instruction_data.sv"

module data_dep_detector (
    input logic [microcode::WIDTH - 1:0] microcode_s0,
    input logic [microcode::WIDTH - 1:0] microcode_s1,
    input logic [microcode::WIDTH - 1:0] microcode_s2,
    input logic [microcode::WIDTH - 1:0] microcode_s3,
    input logic [instruction_data::WIDTH - 1:0] instruction_data_s0,
    input logic [instruction_data::WIDTH - 1:0] instruction_data_s1,
    input logic [instruction_data::WIDTH - 1:0] instruction_data_s2,
    input logic [instruction_data::WIDTH - 1:0] instruction_data_s3,
    input logic currently_blocked,
    output logic data_dependency
);

    logic check_rs1;
    logic check_rs2;
    logic reg_we_s1;
    logic reg_we_s2;
    logic reg_we_s3;

    always_comb begin
        check_rs1 = microcode::mcs0_check_rs1_dep(microcode_s0);
        check_rs2 = microcode::mcs0_check_rs2_dep(microcode_s0);
        reg_we_s1 = microcode::mcs3_reg_we(microcode_s1);
        reg_we_s2 = microcode::mcs3_reg_we(microcode_s2);
        reg_we_s3 = microcode::mcs3_reg_we(microcode_s3);
    end

    logic [4:0] rs1_s0;
    logic [4:0] rs2_s0;
    logic [4:0] rd_s1;
    logic [4:0] rd_s2;
    logic [4:0] rd_s3;

    always_comb begin
        rs1_s0 = instruction_data::rs1(instruction_data_s0);
        rs2_s0 = instruction_data::rs2(instruction_data_s0);
        rd_s1  = instruction_data::rd(instruction_data_s1);
        rd_s2  = instruction_data::rd(instruction_data_s2);
        rd_s3  = instruction_data::rd(instruction_data_s3);
    end

    logic rs1_s1_collision;
    logic rs1_s2_collision;
    logic rs1_s3_collision;
    logic rs2_s1_collision;
    logic rs2_s2_collision;
    logic rs2_s3_collision;

    logic s1_dep;
    logic s2_dep;
    logic s3_dep;

    always_comb begin
        rs1_s1_collision = rs1_s0 == rd_s1 & check_rs1;
        rs1_s2_collision = rs1_s0 == rd_s2 & check_rs1;
        rs1_s3_collision = rs1_s0 == rd_s3 & check_rs1;
        rs2_s1_collision = rs2_s0 == rd_s1 & check_rs2;
        rs2_s2_collision = rs2_s0 == rd_s2 & check_rs2;
        rs2_s3_collision = rs2_s0 == rd_s3 & check_rs2;

        s1_dep = (rs1_s1_collision | rs2_s1_collision) & reg_we_s1;
        s2_dep = (rs1_s2_collision | rs2_s2_collision) & reg_we_s2;
        s3_dep = (rs1_s3_collision | rs2_s3_collision) & reg_we_s3;

        data_dependency = (s1_dep | s2_dep | s3_dep) & ~currently_blocked;
    end

endmodule
