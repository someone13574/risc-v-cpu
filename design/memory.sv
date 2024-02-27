module memory(
    input clk,
    input write_enable,
    input [31:0] addr,
    inout [31:0] data
);

reg [31:0] mem [0:255];
initial $readmemh("memory_init.mem", mem, 0, 255);

reg [31:0] data_out;
assign data = (write_enable) ? 32'hZZZZZZZZ : data_out;

always @(posedge clk) begin
    if (write_enable) begin
        mem[addr[31:2]] <= data;
    end

    data_out <= mem[addr[31:2]];
end

endmodule
