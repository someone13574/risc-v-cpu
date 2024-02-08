module instruction_decoder(
	input clk,
	input [31:0] instruction,
	output [15:0] microcode,
	output [4:0] rd_addr,
	output [4:0] rs1_addr,
	output [4:0] rs2_addr,
	output [11:0] i_imm_11_0,
	output [11:0] s_imm_11_0,
	output [19:0] u_imm_31_12
);

reg [8:0] microcode_lookup;
rom microcode_rom(
				.addr(microcode_lookup[5:0]),
				.clk(clk),
				.data(microcode)
			 );

always @(instruction) begin
	// Get opcode data: wxyzzzzzz. w = env-func, x = use func-7, y = use func-3, z = offset
	// Some func3's are missing values, weave in single opcode vals
	case(instruction[6:2])
		5'b01101: microcode_lookup = 9'h002; // LUI, addr = 0x2
		5'b00101: microcode_lookup = 9'h003; // AUIPC, addr = 0x3
		5'b11011: microcode_lookup = 9'h00b; // JAL, addr = 0xb
		5'b11001: microcode_lookup = 9'h023; // JALR, addr = 0x24
		5'b11000: microcode_lookup = 9'h040; // branching, offset = 0x0
		5'b00000: microcode_lookup = 9'h048; // loading, offset = 0x8
		5'b01000: microcode_lookup = 9'h04e; // storing, offset = 0xe
		5'b00100: microcode_lookup = 9'h051; // immediate ops, offset = 0x11
		5'b01100: microcode_lookup = 9'h05a; // ops, offset = 0x1a
		5'b00011: microcode_lookup = 9'h024; // FENCE, addr = 0x24
		5'b11100: microcode_lookup = 9'h025; // environment, offset = 0x25
		default : microcode_lookup = 9'b0;
	endcase
	
	microcode_lookup[5:0] = microcode_lookup[5:0] + {3'b0, instruction[14:12] & {3{microcode_lookup[6]}}} + {2'b0, instruction[30] & microcode_lookup[7], 3'b0} + {5'b0, instruction[20] & microcode_lookup[8]};
end

assign rd_addr = instruction[11:7];
assign rs1_addr = instruction[19:15];
assign rs2_addr = instruction[24:20];
assign i_imm_11_0 = instruction[31:20];
assign s_imm_11_0 = {instruction[31:25], instruction[11:7]};
assign u_imm_31_12 = instruction[31:12];

endmodule

// Microcode format
// fedcba9876543210
// 0 = has rd
// 1 = has rs1
// 2 = has rs2


// Instructions

//     01101 u-type LUI   (load upper immediate)
//     00101 u-type AUIPC (add upper immediate to pc)
//     11011 j-type JAL (jump variant-1)
// 000 11001 i-type JALR (jump variant-2)

// 000 11000 b-type BEQ  (branch equal)
// 001 11000 b-type BNE  (branch not equal)
// 100 11000 b-type BLT  (branch less than)
// 101 11000 b-type BGE  (branch greater-equal)
// 110 11000 b-type BLTU (branch less than unsigned)
// 111 11000 b-type BGEU (branch greater-equal unsigned)

// 000 00000 i-type LB (load byte)
// 001 00000 i-type LH (load half)
// 010 00000 i-type LW (load word)
// 100 00000 i-type LBU (load byte, zero-extend)
// 101 00000 i-type LHU (load half, zero-extend)

// 000 01000 s-type SB (store byte)
// 001 01000 s-type SH (store half)
// 010 01000 s-type SW (store word)

// 000 00100 i-type ADDI  (add sign-extneded 12-bit immediate)
// 010 00100 i-type SLTI  (set less than immedate)
// 011 00100 i-type SLTIU
// 100 00100 i-type XORI
// 110 00100 i-type ORI
// 111 00100 i-type ANDI

// 001 00100 r-type SLLI (shift logical left immediate)
// 101 00100 r-type SRLI (shift logical right immedate)
//*101 00100 r-type SRAI (right shift retain sign bit immedate)

// 000 01100 r-type ADD
//*000 01100 r-type SUB
// 001 01100 r-type SLL (shift logical left)
// 010 01100 r-type SLT (set if less than)
// 011 01100 r-type SLTU
// 100 01100 r-type XOR
// 101 01100 r-type SRL (arithmetic left shift)
//*101 01100 r-type SRA (arithmetic right shift)
// 110 01100 r-type OR
// 111 01100 r-type AND

//     00011 ?-type FENCE

//     11100 ?-type ECALL
//*    11100 ?-type EBREAK