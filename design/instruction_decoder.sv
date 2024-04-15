module instruction_decoder(
    input logic clk,
    input logic clk_enable,
    input logic [31:0] instruction,
    output logic [21:0] microcode_s0,
    output logic [24:0] instruction_data_si
);

logic [5:0] microcode_lookup;

rom microcode_rom(
    .clk(clk),
    .clk_enable(clk_enable),
    .addr(microcode_lookup),
    .data(microcode_s0)
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


logic imm_func7_enable;
always_comb begin
    imm_func7_enable = instruction[30] & (instruction[14:12] == 3'b101);
    instruction_data_si = instruction[31:7];
end

always_ff @(*) begin
    if (clk_enable) begin
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
    end else begin
        microcode_lookup = 6'b0;
    end
end

endmodule
