module alu(
    input clk,
    input [31:0] a,
    input [31:0] b,
    input [3:0] alu_op_select,
    output reg [31:0] out
);

always @(posedge clk) begin
    case (alu_op_select)
        4'b0000: out <= a + b;                                 // add
        4'b0001: out <= a - b;                                 // subtract
        4'b0010: out <= ($signed(a) < $signed(b)) ? a : 32'b0; // set less than signed
        4'b0011: out <= (a < b) ? a : 32'b0;                   // set less than unsigned
        4'b0100: out <= a ^ b;                                 // xor
        4'b0101: out <= a | b;                                 // or
        4'b0110: out <= a & b;                                 // and
        4'b0111: out <= a << b;                                // shift left unsigned
        4'b1000: out <= a >> b;                                // shift right unsigned
        4'b1001: out <= a >>> b;                               // shift right signed
    endcase
end

endmodule
