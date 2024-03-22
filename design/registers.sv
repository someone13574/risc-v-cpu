module registers(
    input clk,
    input write_enable,
    input [4:0] read_addr_a,
    input [4:0] read_addr_b,
    input [4:0] write_addr,
    input [31:0] data,
    output reg [31:0] out_a,
    output reg [31:0] out_b
);

reg [31:0] mem [0:15];

always @(posedge clk) begin
    if (write_enable & write_addr != 0) begin
        mem[write_addr[3:0]] <= data;
    end

    out_a <= mem[read_addr_a[3:0]];
    out_b <= mem[read_addr_b[3:0]];
end

endmodule
