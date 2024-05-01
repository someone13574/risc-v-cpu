module alu(
    input logic clk,
    input logic clk_enable,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [24:0] microcode_s1,
    output logic [31:0] out,
    output logic [31:0] offset_mem_addr
);

logic [3:0] alu_op_select;
microcode_s1_decoder mc_s1_decode(
    .microcode(microcode_s1),
    .alu_op_select(alu_op_select)
);

typedef enum bit[3:0] {
    ADD_ALU_OP  = 4'b0000,
    SUB_ALU_OP  = 4'b0001,
    SLT_ALU_OP  = 4'b0010, // set less than
    SLTU_ALU_OP = 4'b0011, // set less than unsigned,
    XOR_ALU_OP  = 4'b0100,
    OR_ALU_OP   = 4'b0101,
    AND_ALU_OP  = 4'b0110,
    SLU_ALU_OP  = 4'b0111, // shift left unsigned
    SRU_ALU_OP  = 4'b1000, // shift right unsigned
    SRA_ALU_OP  = 4'b1001  // shift right arithmetic
} alu_ops_e;

always_ff @(posedge clk) begin
    if (clk_enable) begin
        case (alu_op_select)
            ADD_ALU_OP:  out <= a + b;
            SUB_ALU_OP:  out <= a - b;
            SLT_ALU_OP:  out <= ($signed(a) < $signed(b)) ? a : 32'b0;
            SLTU_ALU_OP: out <= (a < b) ? a : 32'b0;
            XOR_ALU_OP:  out <= a ^ b;
            OR_ALU_OP:   out <= a | b;
            AND_ALU_OP:  out <= a & b;
            SLU_ALU_OP:  out <= a << b[4:0];
            SRU_ALU_OP:  out <= a >> b[4:0];
            SRA_ALU_OP:  out <= a >>> b[4:0];
            default:     out <= 32'b0;
        endcase

        if (alu_op_select == ADD_ALU_OP) begin
            offset_mem_addr <= a + b + 32'h4; // we will need a different mem addr for some eab's if misaligned
        end else begin
            offset_mem_addr <= 32'b0;
        end
    end
end

endmodule
