module rom(
	input [5:0] addr,
	input clk,
	output reg [15:0] data
);

reg [15:0] rom[0:63];
initial $readmemh("microcode.mem", rom, 0, 63);

always @(posedge clk) begin
	data <= rom[addr];
end

endmodule
