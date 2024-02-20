module alu(
	input clk,
	input [31:0] a,
	input [31:0] b,
	output reg [31:0] out
);

always @(posedge clk) begin
	out <= a + b;
end

endmodule
