module instruction_decoder(
    input clk,
    input [31:0] instruction,
    output [31:0] microcode,
    output reg [24:0] instruction_data
);

reg [5:0] microcode_lookup;

rom microcode_rom(
    .clk(clk),
    .addr(microcode_lookup),
    .data(microcode)
);

typedef enum bit[5:0] { // Include redundent bit to avoid confusing nop and load
    LUI    = 6'b011011,
    AUIPC  = 6'b001011,
    JAL    = 6'b110111,
    JALR   = 6'b110011,
    BRANCH = 6'b110001,
    LOAD   = 6'b000001,
    STORE  = 6'b010001,
    IMM    = 6'b001001,
    REG    = 6'b011010
} opcode_lookup_groups_e;

wire imm_func7_enable = instruction[30] & instruction[14:12] == 3'b101;

always @(instruction, imm_func7_enable) begin
    case(instruction[6:1])
        LUI:     microcode_lookup = 6'h01;
        AUIPC:   microcode_lookup = 6'h02;
        JAL:     microcode_lookup = 6'h03;
        JALR:    microcode_lookup = 6'h04;
        BRANCH:  microcode_lookup = {3'b001, instruction[14:12]};
        LOAD:    microcode_lookup = {3'b010, instruction[14:12]};
        STORE:   microcode_lookup = {3'b011, instruction[14:12]};
        IMM:     microcode_lookup = {1'b1, imm_func7_enable, 1'b0, instruction[14:12]};
        REG:     microcode_lookup = {1'b1, instruction[30], 1'b1, instruction[14:12]};
        default: microcode_lookup = 6'b0;
    endcase
end

always @(posedge clk) begin
    instruction_data <= instruction[31:7];
end

endmodule
