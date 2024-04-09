module control_unit(
    input logic clk,
    input logic clk_enable,
    input logic [31:0] microcode_s0,
    input logic [24:0] instruction_data_s0,
    input logic [29:0] jump_location,
    input logic [31:0] reg_out_a,
    input logic [31:0] reg_out_b,
    output logic [29:0] pc,
    output logic [29:0] pc_s0,
    output logic [29:0] pc_s2,
    output logic [24:0] instruction_data_s3,
    output logic [3:0] alu_op_select,
    output logic pre_alu_a_to_alu_a,
    output logic [1:0] pre_alu_a_select,
    output logic pre_alu_b_to_alu_b,
    output logic [1:0] pre_alu_b_select,
    output logic mem_we,
    output logic alu_out_to_mem_addr,
    output logic reg_we,
    output logic up_to_reg_data_in,
    output logic alu_out_to_reg_data_in,
    output logic ret_addr_to_reg_data_in,
    output logic mem_data_to_reg_data_in,
    output logic block_inst
);

typedef enum bit[2:0] {
    NULL_CMP_OP        = 3'b000,
    EQ_CMP_OP          = 3'b001,
    NOT_EQ_CMP_OP      = 3'b010,
    LESS_THAN_CMP_OP   = 3'b011,
    GREATER_EQ_CMP_OP  = 3'b100,
    LESS_THAN_U_CMP_OP = 3'b101,
    GREATER_EQ_U_CM_OP = 3'b110,
    TRUE_CMP_OP        = 3'b111
} cmp_ops_e;

logic [29:0] pc_si;
// reg [29:0] pc_s0;
logic [29:0] pc_s1;

reg [31:0] microcode_s1;
reg [31:0] microcode_s2;
reg [31:0] microcode_s3;

logic [24:0] instruction_data_s1;
logic [24:0] instruction_data_s2;

logic branch;
logic jump_if_branch;
logic data_dep_with_s1;
logic data_dep_with_s2;
logic data_dep_with_s3;
logic data_dep;

logic hold;
logic [24:0] held_instruction_data;

logic check_rs1_dep;
logic check_rs2_dep;

assign data_dep_with_s1 = (((rs1_s0 == rd_s1) & check_rs1_dep) | ((rs2_s0 == rd_s1) & check_rs2_dep)) & reg_we_s1;
assign data_dep_with_s2 = (((rs1_s0 == rd_s2) & check_rs1_dep) | ((rs2_s0 == rd_s2) & check_rs2_dep)) & reg_we_s2;
assign data_dep_with_s3 = (((rs1_s0 == rd_s3) & check_rs1_dep) | ((rs2_s0 == rd_s3) & check_rs2_dep)) & reg_we;
assign data_dep = data_dep_with_s1 | data_dep_with_s2 | data_dep_with_s3;

logic block_for_branch;
assign block_for_branch = microcode_s0[17] | microcode_s1[17] | microcode_s2[17] | microcode_s3[17]; // jump if branch mc
logic mem_in_use;
logic mem_in_use_s3;
assign block_inst = mem_in_use_s3 | data_dep | hold | block_for_branch;

logic [2:0] branch_cond_select;
always_ff @(posedge clk) begin
    if (clk_enable) begin
        if (jump_if_branch & branch) begin
            pc <= jump_location;
        end else if (data_dep) begin
            pc <= pc_s0;
        end else if (hold & mem_in_use) begin
            pc <= pc_s1;
        end else if (mem_in_use) begin
            pc <= pc_si;
        end else begin
            pc <= pc + 30'b1;
        end

        hold <= data_dep;

        case (branch_cond_select)
            NULL_CMP_OP:        branch <= 1'b0;
            EQ_CMP_OP:          branch <= reg_out_a          == reg_out_b;
            NOT_EQ_CMP_OP:      branch <= reg_out_a          != reg_out_b;
            LESS_THAN_CMP_OP:   branch <= $signed(reg_out_a) <  $signed(reg_out_b);
            GREATER_EQ_CMP_OP:  branch <= $signed(reg_out_a) >= $signed(reg_out_b);
            LESS_THAN_U_CMP_OP: branch <= reg_out_a          <  reg_out_b;
            GREATER_EQ_U_CM_OP: branch <= reg_out_a          >= reg_out_b;
            TRUE_CMP_OP:        branch <= 1'b1;
        endcase

        pc_si <= pc;
        pc_s0 <= pc_si;
        pc_s1 <= pc_s0;
        pc_s2 <= pc_s1;

        microcode_s1 <= (data_dep) ? 32'b00000000 : microcode_s0;
        microcode_s2 <= microcode_s1;
        microcode_s3 <= microcode_s2;

        instruction_data_s1 <= instruction_data_s0;
        instruction_data_s2 <= instruction_data_s1;
        instruction_data_s3 <= instruction_data_s2;
    end
end

always_comb begin : s0_signals
    check_rs1_dep    = microcode_s0[0];
    check_rs2_dep    = microcode_s0[1];
    pre_alu_a_select = microcode_s0[3:2];
    pre_alu_b_select = microcode_s0[5:4];
end

always_comb begin : s1_signals
    pre_alu_a_to_alu_a = microcode_s1[6];
    pre_alu_b_to_alu_b = microcode_s1[7];
    alu_op_select      = microcode_s1[11:8];
    branch_cond_select = microcode_s1[14:12];
end

always_comb begin : s2_signals
    mem_we              = microcode_s2[15];
    alu_out_to_mem_addr = microcode_s2[16];
    jump_if_branch      = microcode_s2[17];
    mem_in_use          = microcode_s2[18];
end

// s3 signals
always_comb begin : s3_signals
    mem_in_use_s3           = microcode_s3[18];
    reg_we                  = microcode_s3[19]; // update reg_we_s1 & reg_we_s2 as well
    up_to_reg_data_in       = microcode_s3[20];
    alu_out_to_reg_data_in  = microcode_s3[21];
    ret_addr_to_reg_data_in = microcode_s3[22];
    mem_data_to_reg_data_in = microcode_s3[23];
end

// data dep signals (s1, s2)
wire reg_we_s1 = microcode_s1[19];
wire reg_we_s2 = microcode_s2[19];

wire [4:0] rs1_s0 = instruction_data_s0[12:8];
wire [4:0] rs2_s0 = instruction_data_s0[17:13];

wire [4:0] rd_s1 = instruction_data_s1[4:0];
wire [4:0] rd_s2 = instruction_data_s2[4:0];
wire [4:0] rd_s3 = instruction_data_s3[4:0];

endmodule

// si = first stage with decoded instruction
// s0 = read
// s1 = execute
// s2 = read/write memory & pc
// s3 = write regs
