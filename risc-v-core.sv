module risc_v_core(
	input clk
);

wire [7:0] addr_bus;
wire write_enable;
wire [31:0] data_bus;
assign addr_bus = (not_inc_head) ? 8'hZZ : pc;
assign write_enable = microcode[0];

memory ram(
	.clk(clk),
	.addr(addr_bus),
	.write_enable(write_enable),
	.data(data_bus)
);

wire [15:0] head_microcode;

instruction_decoder decoder(
	.clk(clk),
	.instruction(data_bus),
	.microcode(head_microcode)
);

wire [7:0] pc;
wire [15:0] microcode;

microcode_buffer buffer(
	.clk(clk),
	.head_microcode(head_microcode),
	.pc(pc),
	.active_microcode(microcode)
);

wire not_inc_head;
assign not_inc_head = microcode[1];

endmodule

// Microcode format
// 0 = ram write enable
// 1 = don't increment head
// 2 = retire