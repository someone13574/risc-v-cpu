module cpu(
    input clk,
    output logic clk_enable,
    output [15:0] display_out,
    output [31:0] mem_addr,
    output [31:0] mem_data_out,
    output [31:0] microcode_s0,
    output [31:0] microcode_s1,
    output [31:0] microcode_s2,
    output [31:0] microcode_s3,
    output [31:0] alu_out,
    output [29:0] pc,
    output [31:0] alu_a,
    output [31:0] alu_b,
    output mem_we,
    output reg [31:0] reg_out_b_s2
);

// logic clk_enable;
always_ff @(posedge clk) begin
    clk_enable <= ~clk_enable;
end

// register module and connections
wire reg_we;
wire up_to_reg_data_in;
wire alu_out_to_reg_data_in;
wire ret_addr_to_reg_data_in;
wire mem_data_to_reg_data_in;

wire [31:0] reg_out_a;
wire [31:0] reg_out_b;
wire [31:0] reg_in;
//reg [31:0] reg_out_b_s2;

assign reg_in = (up_to_reg_data_in)       ? upper_immediate_s3 :
                (alu_out_to_reg_data_in)  ? alu_out_s3         :
                (ret_addr_to_reg_data_in) ? {pc_s2, 2'b0}      :
                (mem_data_to_reg_data_in) ? mem_data_out       : 32'b00000000;

wire [4:0] rs1_s0;
wire [4:0] rs2_s0;
wire [4:0] rd_s3;

registers regs(
    .clk(clk),
    .clk_enable(clk_enable),
    .write_enable(reg_we),
    .read_addr_a(rs1_s0),
    .read_addr_b(rs2_s0),
    .write_addr(rd_s3),
    .data(reg_in),
    .out_a(reg_out_a),
    .out_b(reg_out_b)
);

// memory module and connections
//wire mem_we;
wire alu_out_to_mem_addr;

// wire [29:0] pc;

// wire [31:0] mem_addr;
// wire [31:0] mem_data_out;

assign mem_addr = (alu_out_to_mem_addr) ? alu_out : {pc, 2'b0};

memory ram(
    .clk(clk),
    .clk_enable(clk_enable),
    .write_enable(mem_we),
    .addr(mem_addr),
    .data_in(reg_out_b),
    .data_out(mem_data_out),
    .display_out(display_out)
);

// alu module and connections
wire pre_alu_a_to_alu_a;
wire pre_alu_b_to_alu_b;

reg [31:0] pre_alu_a;
reg [31:0] pre_alu_b;

// wire [31:0] alu_a;
// wire [31:0] alu_b;
wire [3:0] alu_op_select;
// wire [31:0] alu_out;

assign alu_a = (pre_alu_a_to_alu_a) ? pre_alu_a : reg_out_a;
assign alu_b = (pre_alu_b_to_alu_b) ? pre_alu_b : reg_out_b;

alu alu(
    .clk(clk),
    .clk_enable(clk_enable),
    .a(alu_a),
    .b(alu_b),
    .alu_op_select(alu_op_select),
    .out(alu_out)
);

// instruction decoder module and connections
wire block_inst;

wire [31:0] instruction;
// wire [31:0] microcode_s0;
wire [24:0] instruction_data_s0;

assign instruction = (block_inst) ? 32'b00000000 : mem_data_out;

instruction_decoder decoder(
    .clk(clk),
    .clk_enable(clk_enable),
    .instruction(instruction),
    .microcode(microcode_s0),
    .instruction_data(instruction_data_s0)
);

// control unit
wire [29:0] pc_s0;
wire [29:0] pc_s2;
wire [24:0] instruction_data_s3;

wire [1:0] pre_alu_a_select;
wire [1:0] pre_alu_b_select;

control_unit cu(
    .clk(clk),
    .clk_enable(clk_enable),
    .microcode_s0(microcode_s0),
    .instruction_data_s0(instruction_data_s0),
    .jump_location(alu_out[31:2]),
    .reg_out_a(reg_out_a),
    .reg_out_b(reg_out_b),
    .pc(pc),
    .pc_s0(pc_s0),
    .pc_s2(pc_s2),
    .instruction_data_s3(instruction_data_s3),
    .alu_op_select(alu_op_select),
    .pre_alu_a_to_alu_a(pre_alu_a_to_alu_a),
    .pre_alu_a_select(pre_alu_a_select),
    .pre_alu_b_to_alu_b(pre_alu_b_to_alu_b),
    .pre_alu_b_select(pre_alu_b_select),
    .mem_we(mem_we),
    .alu_out_to_mem_addr(alu_out_to_mem_addr),
    .reg_we(reg_we),
    .up_to_reg_data_in(up_to_reg_data_in),
    .alu_out_to_reg_data_in(alu_out_to_reg_data_in),
    .ret_addr_to_reg_data_in(ret_addr_to_reg_data_in),
    .mem_data_to_reg_data_in(mem_data_to_reg_data_in),
    .microcode_s1(microcode_s1),
    .microcode_s2(microcode_s2),
    .microcode_s3(microcode_s3),
    .block_inst(block_inst));

// decode instruction data
assign rs1_s0 = instruction_data_s0[12:8];
assign rs2_s0 = instruction_data_s0[17:13];
assign rd_s3  = instruction_data_s3[4:0];

wire [31:0] upper_immediate_s0 = {instruction_data_s0[24:5], 12'b0};
wire [31:0] upper_immediate_s3 = {instruction_data_s3[24:5], 12'b0};

wire [31:0] lower_immediate  = {{21{instruction_data_s0[24]}}, instruction_data_s0[23:13]};
wire [31:0] j_type_immediate = {{12{instruction_data_s0[24]}}, instruction_data_s0[12:5], instruction_data_s0[13], instruction_data_s0[23:14], 1'b0};
wire [31:0] b_type_immediate = {{20{instruction_data_s0[24]}}, instruction_data_s0[7], instruction_data_s0[23:18], instruction_data_s0[11:8], 1'b0};
wire [31:0] s_type_immediate = {{21{instruction_data_s0[24]}}, instruction_data_s0[23:18], instruction_data_s0[4:0]};

// buffer signals
reg [31:0] alu_out_s3;

typedef enum bit[1:0] {
    UP = 2'b00,
    JT = 2'b01,
    BT = 2'b10
} pre_alu_a_select_e;

typedef enum bit[1:0] {
    LI  = 2'b00,
    ST  = 2'b01,
    PC  = 2'b10,
    RS2 = 2'b11
} pre_alu_b_select_e;

always @(posedge clk) begin
    if (clk_enable) begin
        case (pre_alu_a_select)
            UP: pre_alu_a <= upper_immediate_s0;
            JT: pre_alu_a <= j_type_immediate;
            BT: pre_alu_a <= b_type_immediate;
            default: pre_alu_a <= 32'b0;
        endcase

        case (pre_alu_b_select)
            LI: pre_alu_b  <= lower_immediate;
            ST: pre_alu_b  <= s_type_immediate;
            PC: pre_alu_b  <= {pc_s0, 2'b0};
            RS2: pre_alu_b <= {27'b0, rs2_s0};
            default: pre_alu_a <= 32'b0;
        endcase

        alu_out_s3 <= alu_out;
        reg_out_b_s2 <= reg_out_b;
    end
end
endmodule
