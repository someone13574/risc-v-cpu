module instruction_data_decoder (
    input logic [24:0] instruction_data,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    output logic [31:0] upper_immediate,
    output logic [31:0] lower_immediate,
    output logic [31:0] j_type_immediate,
    output logic [31:0] b_type_immediate,
    output logic [31:0] s_type_immediate
);

always_comb begin
    rs1 = instruction_data[12:8];
    rs2 = instruction_data[17:13];
    rd  = instruction_data[4:0];

    upper_immediate = {instruction_data[24:5], 12'b0};
    lower_immediate = {{21{instruction_data[24]}}, instruction_data[23:13]};
    j_type_immediate = {{12{instruction_data[24]}}, instruction_data[12:5], instruction_data[13], instruction_data[23:14], 1'b0};
    b_type_immediate = {{20{instruction_data[24]}}, instruction_data[7], instruction_data[23:18], instruction_data[11:8], 1'b0};
    s_type_immediate = {{21{instruction_data[24]}}, instruction_data[23:18], instruction_data[4:0]};
end

endmodule
