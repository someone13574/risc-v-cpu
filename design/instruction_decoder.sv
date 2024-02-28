module instruction_decoder(
    input clk,
    input [31:0] instruction,
    output [31:0] microcode,
    output reg [24:0] instruction_data
);

reg [7:0] microcode_lookup;

rom microcode_rom(
    .clk(clk),
    .addr(microcode_lookup[5:0]),
    .data(microcode)
);

typedef enum bit[5:0] {
    LUI    = 6'b011011,
    AUIPC  = 6'b001011,
    JAL    = 6'b110111,
    JALR   = 6'b110011,
    BRANCH = 6'b110001,
    LOAD   = 6'b000001,
    STORE  = 6'b010001,
    IMM    = 6'b001001,
    REG    = 6'b011001} opcode_lookup_groups_e;

always @(instruction) begin
    // Get opcode data: xyzzzzzz. x = use func-7, y = use func-3, z = offset
    // Some func3's are missing values, weave in single opcode vals to gaps
    case(instruction[6:1])
        LUI:     microcode_lookup = 8'h03;
        AUIPC:   microcode_lookup = 8'h04;
        JAL:     microcode_lookup = 8'h0c;
        JALR:    microcode_lookup = 8'h24;
        BRANCH:  microcode_lookup = 8'h01 | 8'h40; // offset by func-3
        LOAD:    microcode_lookup = 8'h09 | 8'h40;
        STORE:   microcode_lookup = 8'h0f | 8'h40;
        IMM:     microcode_lookup = 8'h12 | 8'h40;
        REG:     microcode_lookup = 8'h1b | 8'hc0; // offset by func-3 and func-7
        default: microcode_lookup = 8'b0;          // no-op
    endcase

    microcode_lookup[5:0] <= microcode_lookup[5:0] + {3'b0, instruction[14:12] & {3{microcode_lookup[6]}}} + {2'b0, instruction[30] & microcode_lookup[7], 3'b0};
end

always @(posedge clk) begin
    instruction_data <= instruction[31:7];
end

endmodule
