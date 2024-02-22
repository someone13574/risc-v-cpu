module rom(
    input clk,
    input [5:0] addr,
    output reg [31:0] data
);

reg [31:0] rom[0:63];
initial $readmemh("microcode.mem", rom, 0, 63);

always @(posedge clk) begin
    data <= rom[addr];
end

endmodule
