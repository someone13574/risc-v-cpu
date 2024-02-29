module memory(
    input clk,
    input write_enable,
    input [31:0] addr,
    input [31:0] data_in,
    output reg [31:0] data_out
);

reg [31:0] mem [0:255];
initial $readmemh("memory_init.mem", mem, 0, 255);

always @(posedge clk) begin
    if (write_enable) begin
        mem[addr[31:2]] <= data_in;
    end

    data_out <= mem[addr[31:2]];
end

endmodule
