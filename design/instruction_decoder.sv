module instruction_decoder(
	input clk,
	input [31:0] instruction,
	output [31:0] microcode,
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
		6'b000111: microcode_lookup = 9'h025; // fence, addr = 0x25
		6'b111001: microcode_lookup = 9'h026; // environment, offset = 0x26
		default : microcode_lookup = 9'b0;    // null, offset = 0x0
	endcase

	microcode_lookup[5:0] <= microcode_lookup[5:0] + {3'b0, instruction[14:12] & {3{microcode_lookup[6]}}} + {2'b0, instruction[30] & microcode_lookup[7], 3'b0} + {5'b0, instruction[20] & microcode_lookup[8]};
end

always @(posedge clk) begin
	instruction_data <= instruction[31:7];
end

endmodule
