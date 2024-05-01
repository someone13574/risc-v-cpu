module registers(
    input logic clk,
    input logic clk_enable,
    input logic [24:0] microcode_s3,
    input logic [24:0] instruction_data_si,
    input logic [24:0] instruction_data_s3,
    input logic [31:0] data_in,
    output logic [31:0] data_out_a,
    output logic [31:0] data_out_b
);

// decode microcode
logic write_enable;

microcode_s3_decoder mc_s3_decode(
    .microcode(microcode_s3),
    .reg_write_enable(write_enable)
);

// decode read addresses
logic [4:0] rs1;
logic [4:0] rs2;

instruction_data_decoder inst_data_si_decode(
    .instruction_data(instruction_data_si),
    .rs1(rs1),
    .rs2(rs2)
);

// decode write address
logic [4:0] rd;

instruction_data_decoder inst_data_s3_decode(
    .instruction_data(instruction_data_s3),
    .rd(rd)
);

// memory
logic [31:0] mem [0:15];

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
