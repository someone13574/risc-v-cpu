`include "microcode.sv"
`include "instruction_data.sv"

module registers (
    input logic clk,
    input logic clk_enable,
    input logic [microcode::WIDTH - 1:0] microcode_s3,
    input logic [instruction_data::WIDTH - 1:0] instruction_data_si,
    input logic [instruction_data::WIDTH - 1:0] instruction_data_s3,
    input logic [31:0] data_in,
    output logic [31:0] data_out_a,
    output logic [31:0] data_out_b
);

    logic write_enable;

    always_comb begin
        write_enable = microcode::mcs3_reg_we(microcode_s3);
    end

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    always_comb begin
        rs1 = instruction_data::rs1(instruction_data_si);
        rs2 = instruction_data::rs2(instruction_data_si);
        rd  = instruction_data::rd(instruction_data_s3);
    end

    // memory
    logic [31:0] mem[16];

    always_ff @(posedge clk) begin
        if (clk_enable) begin
            if (write_enable & rd != 0) begin
                mem[rd[3:0]] <= data_in;
            end

            data_out_a <= mem[rs1[3:0]];
            data_out_b <= mem[rs2[3:0]];
        end
    end

endmodule
