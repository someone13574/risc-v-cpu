module memory(
	input clk,
	input enable,
	input write_enable,
	input [7:0] addr,
	input [1:0] byte_enable, // x1 = upper part of half, 1x = upper half of word, always first byte
	inout [31:0] data,
);

reg [7:0] mem [0:255];
initial $readmemh("memory_init.mem", rom, 0, 255);

reg [31:0] data_reg;

always @(posedge clk) begin
	if enable & !write_enable begin
		data_reg[31:0] <= {mem[addr + 3], mem[addr + 2], mem[addr + 1], mem[addr]};
	end
end

always @(posedge clk) begin
	if enable & write_enable begin
		mem[addr] <= data[7:0];
		
		if (byte_enable[0]) begin
			mem[addr + 1] <= data[15:8];
		end
		
		if (byte_enable[1]) begin
			mem[addr + 2] <= data[23:16];
			mem[addr + 3] <= data[31:24]'
		end
	end
end

endmodule
