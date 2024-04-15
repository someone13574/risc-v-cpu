module pre_writeback (
    input logic clk,
    input logic clk_enable,
    input logic [21:0] microcode_s2,
    input logic [24:0] instruction_data_s2,
    input logic [31:0] alu_out,
    input logic [29:0] return_addr,
    output logic [31:0] pre_wb
);

logic [1:0] pre_writeback_select;
logic [31:0] upper_immediate;

microcode_s2_decoder mc_s2_decode(
    .microcode(microcode_s2),
    .pre_writeback_select(pre_writeback_select)
);

instruction_data_decoder inst_data_decode(
    .instruction_data(instruction_data_s2),
    .upper_immediate(upper_immediate)
);

typedef enum bit[1:0] {
    UP = 2'b00,
    ALU = 2'b01,
    RET_ADDR = 2'b10
} pre_wb_select_e;

always_ff @(posedge clk) begin
    if (clk_enable) begin
        case (pre_writeback_select)
            UP:  pre_wb <= upper_immediate;
            ALU: pre_wb <= alu_out;
            RET_ADDR: pre_wb <= {return_addr, 2'b0};
            default: pre_wb <= 32'b0;
        endcase
    end
end

endmodule
