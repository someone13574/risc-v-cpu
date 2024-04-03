module registers(
    input logic clk,
    input logic clk_enable,
    input logic write_enable,
    input logic [4:0] read_addr_a,
    input logic [4:0] read_addr_b,
    input logic [4:0] write_addr,
    input logic [31:0] data,
    output logic [31:0] out_a,
    output logic [31:0] out_b
);

logic [31:0] mem [0:15];

always_ff @(posedge clk) begin
    if (clk_enable) begin
        if (write_enable & write_addr != 0) begin
            mem[write_addr[3:0]] <= data;
        end

        out_a <= mem[read_addr_a[3:0]];
        out_b <= mem[read_addr_b[3:0]];
    end
end

endmodule
