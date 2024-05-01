module rom(
    input logic clk,
    input logic clk_enable,
    input logic [5:0] addr,
    output logic [24:0] data
);

logic [27:0] rom[0:63];
initial $readmemh("microcode.mem", rom, 0, 63);

always_ff @(posedge clk) begin
    if (clk_enable) begin
        data <= rom[addr][24:0];
    end
end

endmodule
