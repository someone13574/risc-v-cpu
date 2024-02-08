module risc_v_core(
	input clk,
	output [7:0] out
);

reg [2:0] cnt;
always @(posedge clk) cnt <= cnt + 3'd1;

rom microcode(
				.addr(cnt),
				.clk(clk),
				.data(out)
			);

endmodule