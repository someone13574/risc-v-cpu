module risc_v_core(
	input clk,
	output mem_write_enable,
	output [31:0] mem_addr,
	output [31:0] mem_data,
	output reg [29:0] pc,
	output hold,
	output reg not_branch,
	output [31:0] instruction,
	output [23:0] microcode_s0,
	output reg [23:0] microcode_s1,
	output reg [23:0] microcode_s2,
	output reg [23:0] microcode_s3,
	output reg_write_enable,
	output [31:0] reg_lock,
	output [4:0] reg_read_addr_a,
	output [4:0] reg_read_addr_b,
	output [4:0] reg_write_addr,
	output [31:0] reg_data_in,
	output [31:0] reg_data_out_a,
	output [31:0] reg_data_out_b,
	output [31:0] alu_a,
	output [31:0] alu_b,
	output [31:0] alu_out,
	output [31:0] sext_b_type_immediate_s1
);

// wire reg_write_enable;
// wire [4:0] reg_read_addr_a;
// wire [4:0] reg_read_addr_b;
// wire [4:0] reg_write_addr;
// wire [31:0] reg_data_in;
// wire [31:0] reg_data_out_a;
// wire [31:0] reg_data_out_b;

assign reg_write_enable = microcode_s3[1];
assign reg_read_addr_a = rs1_s0;
assign reg_read_addr_b = rs2_s0;
assign reg_write_addr = rd_s3;
assign reg_data_in = (microcode_s3[0]) ? upper_immediate_s3 :
					 (microcode_s3[4]) ? buffered_alu_out : 
					 (microcode_s3[9]) ? mem_data :
					 (microcode_s3[15]) ? {return_addr, 2'b0} :
					 32'hZZZZZZZZ;

registers regs(
	.clk(clk),
	.write_enable(reg_write_enable),
	.read_addr_a(reg_read_addr_a),
	.read_addr_b(reg_read_addr_b),
	.write_addr(reg_write_addr),
	.data(reg_data_in),
	.out_a(reg_data_out_a),
	.out_b(reg_data_out_b)
);

// wire mem_write_enable;
// wire [31:0] mem_addr;
// wire [31:0] mem_data;

assign mem_write_enable = microcode_s2[10];
assign mem_addr = (microcode_s2[6]) ? alu_out : {pc, 2'b0};
assign mem_data = (microcode_s2[11]) ? reg_data_out_b_buffer : 32'hZZZZZZZZ;

memory ram(
	.clk(clk),
	.write_enable(mem_write_enable),
	.addr(mem_addr),
	.data(mem_data)
);

// wire [31:0] alu_a;
// wire [31:0] alu_b;
// wire [31:0] alu_out;

assign alu_a = (microcode_s1[2]) ? reg_data_out_a :
			   (microcode_s1[13]) ? upper_immediate_s1 :
			   (microcode_s1[16]) ? sext_j_type_immediate_s1 :
			   (microcode_s1[18]) ? sext_b_type_immediate_s1 : 32'h00000000;
assign alu_b = (microcode_s1[3]) ? sext_lower_immediate_s1 :
			   (microcode_s1[12]) ? sext_lower_split_immediate_s1 :
			   (microcode_s1[8]) ? reg_data_out_b :
			   (microcode_s1[14]) ? {inst_pc, 2'b0} : 32'h00000000;

alu alu(
	.clk(clk),
	.a(alu_a),
	.b(alu_b),
	.out(alu_out)
);

// wire [23:0] microcode_s0; // Microcode for reg read stage
// wire [31:0] instruction;

wire [24:0] instruction_data_s0;
reg [24:0] instruction_data_s1;
reg [24:0] instruction_data_s2;
reg [24:0] instruction_data_s3;

wire [4:0] rs1_s0 = instruction_data_s0[12:8];
wire [4:0] rs2_s0 = instruction_data_s0[17:13];
wire [31:0] sext_lower_immediate_s1 = {{21{instruction_data_s1[24]}}, instruction_data_s1[23:13]};
wire [31:0] sext_lower_split_immediate_s1 = {{21{instruction_data_s1[24]}}, instruction_data_s1[23:18], instruction_data_s1[4:0]};
wire [4:0] rd_s1 = instruction_data_s1[4:0];
wire [4:0] rd_s2 = instruction_data_s2[4:0];
wire [4:0] rd_s3 = instruction_data_s3[4:0];
wire [31:0] upper_immediate_s1 = {instruction_data_s1[24:5], 12'b0};
wire [31:0] upper_immediate_s3 = {instruction_data_s3[24:5], 12'b0};
wire [31:0] sext_j_type_immediate_s1 = {{12{instruction_data_s1[24]}}, instruction_data_s1[12:5], instruction_data_s1[13], instruction_data_s1[23:14], 1'b0};
// wire [31:0] sext_b_type_immediate_s1 = {{20{instruction_data_s1[24]}}, instruction_data_s1[7], instruction_data_s1[23:18], instruction_data_s1[11:8], 1'b0};
assign sext_b_type_immediate_s1 = {{20{instruction_data_s1[24]}}, instruction_data_s1[7], instruction_data_s1[23:18], instruction_data_s1[11:8], 1'b0};

wire [23:0] microcode_s0_direct;
assign microcode_s0 = (hold | prev_hold) ? 16'h0000 : microcode_s0_direct;
assign instruction = (microcode_s0[17] | microcode_s1[17] | microcode_s2[17] | microcode_s3[17] | microcode_s3[6] | prev_hold) ? 32'b0 : mem_data;

instruction_decoder decoder(
	.clk(clk),
	.instruction(instruction),
	.microcode(microcode_s0_direct),
	.instruction_data(instruction_data_s0)
);

// reg [29:0] pc;
reg prev_hold;
reg [31:0] buffered_alu_out;
reg [31:0] reg_data_out_b_buffer;
reg [29:0] inst_pc;
reg [29:0] return_addr;

// reg [23:0] microcode_s1;
// reg [23:0] microcode_s2;
// reg [23:0] microcode_s3;

// reg not_branch;
reg prev_not_branch;

always @(posedge clk) begin
	if (microcode_s3[17]) begin
		if (prev_not_branch) begin
			pc <= return_addr;
		end else begin
			pc <= buffered_alu_out[31:2];
		end
	end else begin
		if (hold) begin
			pc <= pc - 30'd2;
		end else begin
			if (microcode_s2[6]) begin
				pc <= pc - 30'd1;
			end else begin
				pc <= pc + 30'd1;
			end
		end
	end
	
	not_branch <= reg_data_out_a != reg_data_out_b;
	prev_not_branch <= not_branch;
	
	inst_pc <= pc - 30'd2;
	return_addr <= pc - 30'd3;
	
	prev_hold <= hold;
	
	buffered_alu_out <= alu_out;
	reg_data_out_b_buffer <= reg_data_out_b;
	
	microcode_s1 <= microcode_s0;
	microcode_s2 <= microcode_s1;
	microcode_s3 <= microcode_s2;
	instruction_data_s1 <= instruction_data_s0;
	instruction_data_s2 <= instruction_data_s1;
	instruction_data_s3 <= instruction_data_s2;
end

// wire [31:0] reg_lock;

assign hold = (reg_lock[rs1_s0] & microcode_s0_direct[5]) | (reg_lock[rs2_s0] & microcode_s0_direct[7]);

genvar i;
generate
	for (i = 0; i < 32; i = i + 1) begin:reg_lock_generate
		assign reg_lock[i] = (rd_s1 == i & microcode_s1[1]) | (rd_s2 == i & microcode_s2[1]) |  | (rd_s3 == i & microcode_s3[1]);
	end
endgenerate

endmodule

// microcode_s0 = read
// microcode_s1 = execute
// microcode_s2 = read/write memory
// microcode_s3 = write regs & pc

// microcode format
//  0 (0):  connect upper immediate to reg data in (s3)
//  1 (1):  reg write enable (s3)
//  2 (2):  connect reg_data_out_a to alu_a (s1)
//  3 (3):  connect sext lower immediate to alu_b (s1)
//  4 (4):  connect buffered_alu_out to reg data in (s3)
//  5 (5):  check rs1 reg lock (s0)
//  6 (6):  connect alu_out to mem_addr (s2)
//  7 (7):  check rs2 reg lock (s0)
//  8 (8):  connect reg_data_out_b to alu_b (s1)
//  9 (9):  connect mem_data to reg_data_in (s3)
//  a (10): mem write enable (s2)
//  b (11): connect reg_data_out_b_buffer to mem_data (s2)
//  c (12): connect sext lower split immediate to alu_b (s1)
//  d (13): connect upper immediate to alu_a (s1)
//  e (14): connect inst_pc to alu_b (s1)
//  f (15): connect return_addr to reg_data_in (s3)
// 00 (16): connect sext_j_type_immediate_s1 to alu_a (s1)
// 01 (17): pc write buffered_alu_out if ~prev_not_branch
// 02 (18): connect sext_b_type_immediate_s1 to alu_a (s1)
// 03 (19):
// 04 (20): 
// 05 (21): 
// 06 (22): 
// 07 (23): 

// 0x42 = 1000010

//     76543210 fedcba9876543210
//     00001000 0000000000100110
//
// [*] 00000000 0000000000000011 = LUI    (example: 000420b7)
// [*] 00000000 0110000000010010 = AUIPC  (example: 00042097)
// [*] 00000011 1100000000000010 = JAL    (example: 042000ef)
// [*] 00000010 1000000000101110 = JALR   (example: 000420b7, 04208167)
// [*] 00000110 0100000010100000 = BEQ    (example: 000420b7, 00042137, 04208163)
// [ ] 00000000 0000000000000000 = BNE    (example: )
// [ ] 00000000 0000000000000000 = BLT    (example: )
// [ ] 00000000 0000000000000000 = BGE    (example: )
// [ ] 00000000 0000000000000000 = BLTU   (example: )
// [ ] 00000000 0000000000000000 = BGEU   (example: )
// [ ] 00000000 0000000000000000 = LB     (example: )
// [ ] 00000000 0000000000000000 = LH     (example: )
// [*] 00000000 0000001001101110 = LW     (example: 01C02083 and 00000042 at 0b111)
// [ ] 00000000 0000000000000000 = LBU    (example: )
// [ ] 00000000 0000000000000000 = LHU    (example: )
// [ ] 00000000 0000000000000000 = SB     (example: )
// [ ] 00000000 0000000000000000 = SH     (example: )
// [*] 00000000 0001110011100100 = SW     (example: 000420b7, 001023a3)
// [*] 00000000 0000000000111110 = ADDI   (example: 000420b7, 04208113)
// [ ] 00000000 0000000000000000 = SLTI   (example: )
// [ ] 00000000 0000000000000000 = SLTIU  (example: )
// [ ] 00000000 0000000000000000 = XORI   (example: )
// [ ] 00000000 0000000000000000 = ORI    (example: )
// [ ] 00000000 0000000000000000 = ANDI   (example: )
// [ ] 00000000 0000000000000000 = SLLI   (example: )
// [ ] 00000000 0000000000000000 = SRLI   (example: )
// [ ] 00000000 0000000000000000 = SRAI   (example: )
// [*] 00000000 0000000110110110 = ADD    (example: 00042037, 0000e0b7, 001001b3)
// [ ] 00000000 0000000000000000 = SUB    (example: )
// [ ] 00000000 0000000000000000 = SLL    (example: )
// [ ] 00000000 0000000000000000 = SLT    (example: )
// [ ] 00000000 0000000000000000 = SLTU   (example: )
// [ ] 00000000 0000000000000000 = XOR    (example: )
// [ ] 00000000 0000000000000000 = SRL    (example: )
// [ ] 00000000 0000000000000000 = SRA    (example: )
// [ ] 00000000 0000000000000000 = OR     (example: )
// [ ] 00000000 0000000000000000 = AND    (example: )
// [ ] 00000000 0000000000000000 = FENCE  (example: )
// [ ] 00000000 0000000000000000 = ECALL  (example: )
// [ ] 00000000 0000000000000000 = EBREAK (example: )

// [9/40] total ops
// [9/10] unique ops (shift)