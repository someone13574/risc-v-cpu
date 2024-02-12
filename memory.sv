module memory(
	input clk,
	input [7:0] addr,
	input write_enable,
	inout [31:0] data
);

reg [31:0] mem [0:255];
initial $readmemh("memory_init.mem", mem, 0, 255);

reg [31:0] data_reg;
assign data = (write_enable) ? 8'hZZZZ : data_reg;

always @(posedge clk) begin
	if (write_enable) begin
		mem[addr] <= data;
	end else begin
		data_reg <= mem[addr];
	end
end

endmodule
