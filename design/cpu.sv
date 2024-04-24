module cpu(
    input logic clk,
    output logic clk_enable,
    output logic [15:0] display_out
);

// clk enable generator
// logic clk_enable;
always_ff @(posedge clk) begin
    clk_enable <= ~clk_enable;
end

// shared signals
logic [21:0] microcode_s0;
logic [21:0] microcode_s1;
logic [21:0] microcode_s2;
logic [21:0] microcode_s3;

logic [24:0] instruction_data_si;
logic [24:0] instruction_data_s0;
logic [24:0] instruction_data_s2;
logic [24:0] instruction_data_s3;

logic [29:0] pc;
logic [29:0] pc_s0;
logic [29:0] ret_addr;

logic [31:0] reg_out_a;
logic [31:0] reg_out_b;
logic [31:0] reg_out_b_s1;
logic [31:0] reg_out_b_s2;

always_ff @(posedge clk) begin
    if (clk_enable) begin
        reg_out_b_s1 <= reg_out_b;
        reg_out_b_s2 <= reg_out_b_s1;
    end
end

logic [31:0] alu_out;
logic [31:0] mem_data_out;

// microcode signals
logic alu_out_to_mem_addr;
logic use_pre_wb_over_mem_data;

microcode_s2_decoder mc_s2_decode(
    .microcode(microcode_s2),
    .alu_out_to_mem_addr(alu_out_to_mem_addr)
);

microcode_s3_decoder mc_s3_decode(
    .microcode(microcode_s3),
    .use_pre_wb_over_mem_data(use_pre_wb_over_mem_data)
);

// instruction decoder
instruction_decoder inst_decode(
    .clk(clk),
    .clk_enable(clk_enable),
    .instruction(mem_data_out),
    .microcode_s0(microcode_s0),
    .instruction_data_si(instruction_data_si)
);

// registers
logic [31:0] pre_wb;

pre_writeback pre_writeback_mux(
    .clk(clk),
    .clk_enable(clk_enable),
    .microcode_s2(microcode_s2),
    .instruction_data_s2(instruction_data_s2),
    .alu_out(alu_out),
    .return_addr(ret_addr),
    .pre_wb(pre_wb)
);

logic [31:0] reg_data_in;
always_comb begin
    reg_data_in = (use_pre_wb_over_mem_data) ? pre_wb : mem_data_out;
end

registers regs(
    .clk(clk),
    .clk_enable(clk_enable),
    .microcode_s3(microcode_s3),
    .instruction_data_si(instruction_data_si),
    .instruction_data_s3(instruction_data_s3),
    .data_in(reg_data_in),
    .data_out_a(reg_out_a),
    .data_out_b(reg_out_b)
);

// ram
logic [31:0] mem_addr;
always_comb begin
    mem_addr = (alu_out_to_mem_addr) ? alu_out : {pc, 2'b0};
end

memory mem(
    .clk(clk),
    .clk_enable(clk_enable),
    .addr(mem_addr),
    .data_in(reg_out_b_s2),
    .microcode_s2(microcode_s2),
    .data_out(mem_data_out),
    .display_out(display_out)
);

// alu
logic [31:0] alu_a;
logic [31:0] alu_b;

pre_alu pre_alu_mux(
    .clk(clk),
    .clk_enable(clk_enable),
    .microcode_s0(microcode_s0),
    .instruction_data_s0(instruction_data_s0),
    .pc_s0(pc_s0),
    .reg_out_a(reg_out_a),
    .reg_out_b(reg_out_b),
    .pre_alu_a(alu_a),
    .pre_alu_b(alu_b)
);

alu alu(
    .clk(clk),
    .clk_enable(clk_enable),
    .a(alu_a),
    .b(alu_b),
    .microcode_s1(microcode_s1),
    .out(alu_out)
);

// control unit
control_unit cu(
    .clk(clk),
    .clk_enable(clk_enable),
    .microcode_s0(microcode_s0),
    .instruction_data_si(instruction_data_si),
    .reg_out_a(reg_out_a),
    .reg_out_b(reg_out_b),
    .jmp_addr(alu_out[31:2]),
    .microcode_s1(microcode_s1),
    .microcode_s2(microcode_s2),
    .microcode_s3(microcode_s3),
    .instruction_data_s0(instruction_data_s0),
    .instruction_data_s2(instruction_data_s2),
    .instruction_data_s3(instruction_data_s3),
    .pc(pc),
    .pc_s0(pc_s0),
    .ret_addr(ret_addr)
);

endmodule

// |    | mc available | start                     | available                    |
// |----|--------------|---------------------------|------------------------------|
// | sf | no           | mc decode & regs          | instruction                  |
// | s0 | yes          | pre-alu & dep check & cmp | microcode & regs & inst_data |
// | s1 | yes          | alu                       | pre-alu & dep check & cmp    |
// | s2 | yes          | mem                       | alu out                      |
// | s3 | yes          | writeback                 | mem                          |
