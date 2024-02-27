module control_unit(
    input clk,
    input [31:0] microcode_s0,
    input [24:0] instruction_data_s0,
    input [31:0] jump_location,
    input [31:0] reg_out_a,
    input [31:0] reg_out_b,
    output reg [29:0] pc,
    output reg [29:0] pc_s1,
    output reg [29:0] pc_s2,
    output reg [31:0] microcode_s1,
    output reg [31:0] microcode_s2,
    output reg [31:0] microcode_s3,
    output reg [24:0] instruction_data_s1,
    output reg [24:0] instruction_data_s3,
    output [3:0] alu_op_select,
    output reg_out_a_to_alu_a,
    output up_to_alu_a,
    output jt_to_alu_a,
    output bt_to_alu_a,
    output reg_out_b_to_alu_b,
    output li_to_alu_b,
    output st_to_alu_b,
    output pc_to_alu_b,
    output rs2_to_alu_b,
    output mem_we,
    output alu_out_to_mem_addr,
    output reg_out_b_to_mem_data,
    output jump_if_branch,
    output store_trunc_byte,
    output store_trunc_half,
    output reg_we,
    output up_to_reg_data_in,
    output alu_out_to_reg_data_in,
    output ret_addr_to_reg_data_in,
    output mem_data_to_reg_data_in,
    output load_trunc_ubyte,
    output load_trunc_uhalf,
    output load_trunc_sbyte,
    output load_trunc_shalf,
    output block_inst,
    output reg branch,
    output reg hold
);

reg [29:0] pc_si;
reg [29:0] pc_s0;

// reg [31:0] microcode_s1;
// reg [31:0] microcode_s2;
// reg [31:0] microcode_s3;

reg [24:0] instruction_data_s2;

// reg branch;
wire data_dep_with_s1;
wire data_dep_with_s2;
wire data_dep_with_s3;
wire data_dep;

// reg hold;
reg [31:0] held_microcode;
reg [24:0] held_instruction_data;

assign data_dep_with_s1 = (((rs1_s0 == rd_s1) & check_rs1_dep) | ((rs2_s0 == rd_s1) & check_rs2_dep)) & reg_we_s1;
assign data_dep_with_s2 = (((rs1_s0 == rd_s2) & check_rs1_dep) | ((rs2_s0 == rd_s2) & check_rs2_dep)) & reg_we_s2;
assign data_dep_with_s3 = (((rs1_s0 == rd_s3) & check_rs1_dep) | ((rs2_s0 == rd_s3) & check_rs2_dep)) & reg_we;
assign data_dep = data_dep_with_s1 | data_dep_with_s2 | data_dep_with_s3;

wire block_for_branch = microcode_s0[14] | microcode_s1[14] | microcode_s2[14] | microcode_s3[14];
assign block_inst = mem_in_use | data_dep | hold | block_for_branch;

always @(posedge clk) begin
    if (jump_if_branch & branch) begin
        pc <= jump_location[31:2];
    end else if (data_dep_with_s1 & mem_in_use_s1) begin
        pc_si <= pc_s0;
    end else if (data_dep) begin
        pc <= pc_s0;
    end else if (mem_in_use_s2) begin
        pc <= pc_si;
    end else begin
        pc <= pc + 30'b1;
    end

    if (~(data_dep_with_s1 | mem_in_use_s1)) begin
        pc_si <= pc;
    end

    if (data_dep) begin
        hold <= 1'b1;
    end else begin
        hold <= 1'b0;
    end

    case (branch_cond_select)
        3'b000: branch <= 1'b0;
        3'b001: branch <= reg_out_a          == reg_out_b;          // equal
        3'b010: branch <= reg_out_a          != reg_out_b;          // not equal
        3'b011: branch <= $signed(reg_out_a) <  $signed(reg_out_b); // less than signed
        3'b100: branch <= $signed(reg_out_a) >= $signed(reg_out_b); // greater equal signed
        3'b101: branch <= reg_out_a          <  reg_out_b;          // less than unsigned
        3'b110: branch <= reg_out_a          >= reg_out_b;          // greater equal signed
        3'b111: branch <= 1'b1;                                     // true
    endcase

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

// inst of interest: 3

// addr : 0   1   2   3   4   5   3   4   5
// inst :     0   1   2   3           3   4   5
// s0   :         0   1   2   3           3   4   5
// s1   :             0   1   2               3   4   5
// s2   :                 0   1   2               3   4   5
// s3   :                     0   1   2               3   4   5
// hold :                         1
// dep  :                     1
// wheld:

// if s1 dep, write pc_s0 for next clk. Block current and next

// addr : 0   1   2   3   4   3   4   5
// inst :     0   1   2   3       3   4   5
// s0   :         0   1   2   3       3   4   5
// s1   :             0   1   2           3   4   5
// s2   :                 0   1   2           3   4   5
// s3   :                     0   1   2           3   4   5
// hold :
// dep  :                     1
// wheld:                         1

// if s2 dep, write pc_si for next clk. Block current. Set wheld to 2 and write at 1

// s0 signals
wire check_rs1_dep = microcode_s0[0];
wire check_rs2_dep = microcode_s0[1];

// s1 signals
assign reg_out_a_to_alu_a = microcode_s1[2];
assign up_to_alu_a =        microcode_s1[3];
assign jt_to_alu_a =        microcode_s1[4];
assign bt_to_alu_a =        microcode_s1[5];
assign reg_out_b_to_alu_b = microcode_s1[6];
assign li_to_alu_b =        microcode_s1[7];
assign st_to_alu_b =        microcode_s1[8];
assign pc_to_alu_b =        microcode_s1[9];
assign rs2_to_alu_b =       microcode_s1[10];

// s2 signals
assign mem_we =                microcode_s2[11];
assign alu_out_to_mem_addr =   microcode_s2[12];
assign reg_out_b_to_mem_data = microcode_s2[13];
assign jump_if_branch =        microcode_s2[14]; // update block_for_branch
assign store_trunc_byte =      microcode_s2[21];
assign store_trunc_half =      microcode_s2[22];

// s3 signals
wire   mem_in_use =              microcode_s3[15];
wire   mem_in_use_s2 =           microcode_s2[15];
wire   mem_in_use_s1 =           microcode_s1[15];

assign reg_we =                  microcode_s3[16];
assign up_to_reg_data_in =       microcode_s3[17];
assign alu_out_to_reg_data_in =  microcode_s3[18];
assign ret_addr_to_reg_data_in = microcode_s3[19];
assign mem_data_to_reg_data_in = microcode_s3[20];
assign load_trunc_ubyte =        microcode_s3[21];
assign load_trunc_uhalf =        microcode_s3[22];
assign load_trunc_sbyte =        microcode_s3[23];
assign load_trunc_shalf =        microcode_s3[24];

// selection signals (s1)
assign alu_op_select = microcode_s1[28:25];
wire [2:0] branch_cond_select = microcode_s1[31:29];

// data dep signals (s1, s2)
wire reg_we_s1 = microcode_s1[16];
wire reg_we_s2 = microcode_s2[16];

wire [4:0] rs1_s0 = instruction_data_s0[12:8];
wire [4:0] rs2_s0 = instruction_data_s0[17:13];

wire [4:0] rd_s1 = instruction_data_s1[4:0];
wire [4:0] rd_s2 = instruction_data_s2[4:0];
wire [4:0] rd_s3 = instruction_data_s3[4:0];

endmodule

// microcode_s0 = read
// microcode_s1 = execute
// microcode_s2 = read/write memory & pc
// microcode_s3 = write regs
