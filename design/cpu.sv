module cpu(
    input clk,
    output [31:0] mem_addr,
    output [31:0] mem_data,
    output block_inst,
    output [29:0] pc,
    output [31:0] instruction,
    output [31:0] microcode_s0,
    output [31:0] microcode_s1,
    output [31:0] microcode_s2,
    output [31:0] microcode_s3,
    output reg_we,
    output [31:0] reg_out_a,
    output [31:0] reg_out_b,
    output [31:0] reg_in,
    output [31:0] alu_a,
    output [31:0] alu_b,
    output [31:0] alu_out,
    output branch,
    output hold
);

// register module and connections
// wire reg_we;
wire up_to_reg_data_in;
wire alu_out_to_reg_data_in;
wire ret_addr_to_reg_data_in;
wire mem_data_to_reg_data_in;

// wire [31:0] reg_out_a;
// wire [31:0] reg_out_b;
// wire [31:0] reg_in;

assign reg_in = (up_to_reg_data_in)       ? upper_immediate_s3 :
                (alu_out_to_reg_data_in)  ? alu_out_s3         :
                (ret_addr_to_reg_data_in) ? {pc_s2, 2'b0}      :
                (mem_data_to_reg_data_in) ? mem_data           : 32'b00000000;

registers regs(
    .clk(clk),
    .write_enable(reg_we),
    .read_addr_a(rs1_s0),
    .read_addr_b(rs2_s0),
    .write_addr(rd_s3),
    .data(reg_in),
    .out_a(reg_out_a),
    .out_b(reg_out_b)
);

// memory module and connections
wire mem_we;
wire alu_out_to_mem_addr;
wire reg_out_b_to_mem_data;

// wire [31:0] mem_addr;
// wire [31:0] mem_data;

assign mem_addr = (alu_out_to_mem_addr)   ? alu_out   : {pc, 2'b0};
assign mem_data = (reg_out_b_to_mem_data) ? reg_out_b : 32'hZZZZZZZZ;

memory ram(
    .clk(clk),
    .write_enable(mem_we),
    .addr(mem_addr),
    .data(mem_data)
);

// alu module and connections
wire reg_out_a_to_alu_a;
wire up_to_alu_a;
wire jt_to_alu_a;
wire bt_to_alu_a;
wire reg_out_b_to_alu_b;
wire li_to_alu_b;
wire st_to_alu_b;
wire pc_to_alu_b;
wire rs2_to_alu_b;

//wire [31:0] alu_a;
//wire [31:0] alu_b;
wire [3:0] alu_op_select;
//wire [31:0] alu_out;

assign alu_a = (reg_out_a_to_alu_a) ? reg_out_a          :
               (up_to_alu_a)        ? upper_immediate_s1 :
               (jt_to_alu_a)        ? j_type_immediate   :
               (bt_to_alu_a)        ? b_type_immediate   : 32'b00000000;
assign alu_b = (reg_out_b_to_alu_b) ? reg_out_b        :
               (li_to_alu_b)        ? lower_immediate  :
               (st_to_alu_b)        ? s_type_immediate :
               (pc_to_alu_b)        ? {pc_s1, 2'b0}    :
               (rs2_to_alu_b)       ? {27'b0, rs2_s1}  : 32'b00000000;

alu alu(
    .clk(clk),
    .a(alu_a),
    .b(alu_b),
    .alu_op_select(alu_op_select),
    .out(alu_out)
);

// instruction decoder module and connections
// wire mem_in_use;

// wire [31:0] instruction;
// wire [31:0] microcode_s0;
wire [24:0] instruction_data_s0;

assign instruction = (block_inst) ? 32'b00000000 : mem_data;

instruction_decoder decoder(
    .clk(clk),
    .instruction(instruction),
    .microcode(microcode_s0),
    .instruction_data(instruction_data_s0)
);

// control unit
// wire [29:0] pc;
wire [29:0] pc_s1;
wire [29:0] pc_s2;
//wire [31:0] microcode_s1;
//wire [31:0] microcode_s2;
//wire [31:0] microcode_s3;
wire [24:0] instruction_data_s1;
wire [24:0] instruction_data_s3;

control_unit cu(
    .clk(clk),
    .microcode_s0(microcode_s0),
    .instruction_data_s0(instruction_data_s0),
    .jump_location(alu_out),
    .reg_out_a(reg_out_a),
    .reg_out_b(reg_out_b),
    .pc(pc),
    .pc_s1(pc_s1),
    .pc_s2(pc_s2),
    .microcode_s1(microcode_s1),
    .microcode_s2(microcode_s2),
    .microcode_s3(microcode_s3),
    .instruction_data_s1(instruction_data_s1),
    .instruction_data_s3(instruction_data_s3),
    .alu_op_select(alu_op_select),
    .reg_out_a_to_alu_a(reg_out_a_to_alu_a),
    .up_to_alu_a(up_to_alu_a),
    .jt_to_alu_a(jt_to_alu_a),
    .bt_to_alu_a(bt_to_alu_a),
    .reg_out_b_to_alu_b(reg_out_b_to_alu_b),
    .li_to_alu_b(li_to_alu_b),
    .st_to_alu_b(st_to_alu_b),
    .pc_to_alu_b(pc_to_alu_b),
    .rs2_to_alu_b(rs2_to_alu_b),
    .mem_we(mem_we),
    .alu_out_to_mem_addr(alu_out_to_mem_addr),
    .reg_out_b_to_mem_data(reg_out_b_to_mem_data),
    .reg_we(reg_we),
    .up_to_reg_data_in(up_to_reg_data_in),
    .alu_out_to_reg_data_in(alu_out_to_reg_data_in),
    .ret_addr_to_reg_data_in(ret_addr_to_reg_data_in),
    .mem_data_to_reg_data_in(mem_data_to_reg_data_in),
    .block_inst(block_inst),
    .branch(branch),
    .hold(hold)
);

// decode instruction data
wire [4:0] rs1_s0 = instruction_data_s0[12:8];
wire [4:0] rs2_s0 = instruction_data_s0[17:13];
wire [4:0] rs2_s1 = instruction_data_s1[17:13];
wire [4:0] rd_s3  = instruction_data_s3[4:0];

wire [31:0] upper_immediate_s1 = {instruction_data_s1[24:5], 12'b0};
wire [31:0] upper_immediate_s3 = {instruction_data_s3[24:5], 12'b0};

wire [31:0] lower_immediate  = {{21{instruction_data_s1[24]}}, instruction_data_s1[23:13]};
wire [31:0] j_type_immediate = {{12{instruction_data_s1[24]}}, instruction_data_s1[12:5], instruction_data_s1[13], instruction_data_s1[23:14], 1'b0};
wire [31:0] b_type_immediate = {{20{instruction_data_s1[24]}}, instruction_data_s1[7], instruction_data_s1[23:18], instruction_data_s1[11:8], 1'b0};
wire [31:0] s_type_immediate = {{21{instruction_data_s1[24]}}, instruction_data_s1[23:18], instruction_data_s1[4:0]};


// buffer signals
reg [31:0] alu_out_s3;

always @(posedge clk) begin
    alu_out_s3 <= alu_out;
end
endmodule
