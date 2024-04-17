module pre_alu (
    input logic clk,
    input logic clk_enable,
    input logic [21:0] microcode_s0,
    input logic [24:0] instruction_data_s0,
    input logic [29:0] pc_s0,
    input logic [31:0] reg_out_a,
    input logic [31:0] reg_out_b,
    output logic [31:0] pre_alu_a,
    output logic [31:0] pre_alu_b
);

logic [1:0] pre_alu_a_select;
logic [2:0] pre_alu_b_select;

microcode_s0_decoder mc_s0_decode(
    .microcode(microcode_s0),
    .pre_alu_a_select(pre_alu_a_select),
    .pre_alu_b_select(pre_alu_b_select)
);

logic [4:0] rs2;
logic [31:0] upper_immediate;
logic [31:0] lower_immediate;
logic [31:0] j_type_immediate;
logic [31:0] b_type_immediate;
logic [31:0] s_type_immediate;

instruction_data_decoder inst_data_decode(
    .instruction_data(instruction_data_s0),
    .rs2(rs2),
    .upper_immediate(upper_immediate),
    .lower_immediate(lower_immediate),
    .j_type_immediate(j_type_immediate),
    .b_type_immediate(b_type_immediate),
    .s_type_immediate(s_type_immediate)
);

typedef enum bit[1:0] {
    UP = 2'b00,
    JT = 2'b01,
    BT = 2'b10,
    REGA = 2'b11
} pre_alu_a_select_e;

typedef enum bit[2:0] {
    LI  = 3'b000,
    ST  = 3'b001,
    PC  = 3'b010,
    RS2 = 3'b011,
    REGB = 3'b100
} pre_alu_b_select_e;

always_ff @(posedge clk) begin
    if (clk_enable) begin
        case (pre_alu_a_select)
            UP:   pre_alu_a <= upper_immediate;
            JT:   pre_alu_a <= j_type_immediate;
            BT:   pre_alu_a <= b_type_immediate;
            REGA: pre_alu_a <= reg_out_a;
            default: pre_alu_a <= 32'b0;
        endcase

        case (pre_alu_b_select)
            LI:   pre_alu_b <= lower_immediate;
            ST:   pre_alu_b <= s_type_immediate;
            PC:   pre_alu_b <= {pc_s0, 2'b0};
            RS2:  pre_alu_b <= {27'b0, rs2};
            REGB: pre_alu_b <= reg_out_b;
            default: pre_alu_b <= 32'b0;
        endcase
    end
end

endmodule
