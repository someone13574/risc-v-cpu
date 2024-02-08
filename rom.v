module rom(
	input [7:0] addr,
	input clk,
	output reg [7:0] data
);

reg [7:0] rom[0:255];
initial $readmemh("microcode.mem", rom, 0, 255);

always @(posedge clk) begin
	data <= rom[addr];
end

endmodule
