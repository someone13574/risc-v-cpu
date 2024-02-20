module instruction_decoder(
	input clk,
	input [31:0] instruction,
	output [23:0] microcode,
	output reg [24:0] instruction_data
);

reg [8:0] microcode_lookup;

rom microcode_rom(
	.clk(clk),
	.addr(microcode_lookup[5:0]),
	.data(microcode)
);

always @(instruction) begin
	// Get opcode data: wxyzzzzzz. w = env-func, x = use func-7, y = use func-3, z = offset
	// Some func3's are missing values, weave in single opcode vals
	case(instruction[6:1])
		6'b011011: microcode_lookup = 9'h003; // LUI, addr = 0x3
		6'b001011: microcode_lookup = 9'h004; // AUIPC, addr = 0x4
		6'b110111: microcode_lookup = 9'h00c; // JAL, addr = 0xc
		6'b110011: microcode_lookup = 9'h024; // JALR, addr = 0x25
		6'b110001: microcode_lookup = 9'h041; // branching, offset = 0x1
		6'b000001: microcode_lookup = 9'h049; // loading, offset = 0x9
		6'b010001: microcode_lookup = 9'h04f; // storing, offset = 0xf
		6'b001001: microcode_lookup = 9'h052; // immediate ops, offset = 0x12
		6'b011001: microcode_lookup = 9'h05b; // ops, offset = 0x1b
		6'b000111: microcode_lookup = 9'h025; // FENCE, addr = 0x25
		6'b111001: microcode_lookup = 9'h026; // environment, offset = 0x26
		default : microcode_lookup = 9'b0; // null, offset = 0x0
	endcase
	
	microcode_lookup[5:0] <= microcode_lookup[5:0] + {3'b0, instruction[14:12] & {3{microcode_lookup[6]}}} + {2'b0, instruction[30] & microcode_lookup[7], 3'b0} + {5'b0, instruction[20] & microcode_lookup[8]};
end

always @(posedge clk) begin
	instruction_data <= instruction[31:7];
end

endmodule

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