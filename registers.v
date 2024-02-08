module registers(
    input clk,
    input [4:0] rd_addr,
    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input [15:0] microcode,
    output reg [31:0] rd,
    output reg [31:0] rs1,
    output reg [31:0] rs2
);

reg [31:0] regs [0:30];
wire [31:0] reg_wires [0:31];

assign reg_wires[0] = 32'b0;

genvar i;
generate
	for (i = 1; i <= 31; i = i + 1) begin : generate_reg_wires
		assign reg_wires[i] = regs[i - 1];
	end
endgenerate

always @(posedge clk) begin
    rd <= microcode[0] ? reg_wires[rd_addr] : 32'b0;
end

always @(posedge clk) begin
    rs1 <= microcode[1] ? reg_wires[rs1_addr] : 32'b0;
end

always @(posedge clk) begin
    rs2 <= microcode[2] ? reg_wires[rs2_addr] : 32'b0;
end

endmodule
