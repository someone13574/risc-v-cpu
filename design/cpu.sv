`include "microcode.sv"
`include "instruction_data.sv"

module cpu(
    input logic clk,
    input logic n_reset,
    input logic rx,
    output logic tx,
    output logic [15:0] display_out
);

logic reset;
logic clk_enable;
logic ungated_clk_enable;
always_ff @(posedge clk) begin
    ungated_clk_enable <= ~ungated_clk_enable;
    reset <= ~n_reset;
end

// shared signals
logic [microcode::WIDTH - 1:0] microcode_s0;
logic [microcode::WIDTH - 1:0] microcode_s1;
logic [microcode::WIDTH - 1:0] microcode_s2;
logic [microcode::WIDTH - 1:0] microcode_s3;

logic [instruction_data::WIDTH - 1:0] instruction_data_si;
logic [instruction_data::WIDTH - 1:0] instruction_data_s0;
logic [instruction_data::WIDTH - 1:0] instruction_data_s2;
logic [instruction_data::WIDTH - 1:0] instruction_data_s3;

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

always_comb begin
    alu_out_to_mem_addr = microcode::mcs2_alu_out_over_pc(microcode_s2);
    use_pre_wb_over_mem_data = microcode::mcs3_pre_wb_over_mem_data(microcode_s3);
end

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

// transmitter
logic [8:0] uart_tx_data;
logic uart_tx_sending;
uart_tx #(.BAUD_RATE(9600)) uart_tx(
    .clk(clk),
    .data_in(uart_tx_data[7:0]),
    .send(uart_tx_data[8]),
    .sending(uart_tx_sending),
    .tx(tx)
);

// upload receiver
logic upload_we;
logic [31:0] upload_addr;
logic [7:0] upload_out;
logic upload_complete;
logic [2:0] upload_stage;

upload_rx #(.BAUD_RATE(9600)) upload_rx(
    .clk(clk),
    .clk_enable(ungated_clk_enable),
    .rx(rx),
    .reset(reset),
    .we(upload_we),
    .addr(upload_addr),
    .uart_out(upload_out),
    .complete(upload_complete),
    .stage(upload_stage)
);

always_comb begin
    clk_enable = ungated_clk_enable & upload_complete;
end

logic [15:0] tmp_display_out;

// ram
logic [31:0] mem_addr;
logic [31:0] offset_mem_addr;
logic [microcode::WIDTH - 1:0] mem_mc_s2;
logic [31:0] mem_data_in;
always_comb begin
    display_out = {7'b0, uart_tx_data[8], tmp_display_out[15:8]};

    mem_data_in = (upload_we)           ? {24'b0, upload_out} : reg_out_b_s2;
    mem_mc_s2   = (upload_we)           ? 25'h8000            : microcode_s2;
    mem_addr    = (upload_we)           ? upload_addr         :
                  (alu_out_to_mem_addr) ? alu_out             : {pc, 2'b0};
end

memory mem(
    .clk(clk),
    .clk_enable(clk_enable),
    .addr(mem_addr),
    .next_addr(32'h4),
    .data_in(mem_data_in),
    .microcode_s2(mem_mc_s2),
    .microcode_s3(microcode_s3),
    .uart_tx_sending(uart_tx_sending),
    .data_out(mem_data_out),
    .seven_segment_out(tmp_display_out),
    .uart_tx_data(uart_tx_data)
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
    .out(alu_out),
    .offset_mem_addr(offset_mem_addr)
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
