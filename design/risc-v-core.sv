module risc_v_core(
    input clk,
    output reg [29:0] pc,
    output [31:0] instruction,
    output reg_write_enable_s3,
    output [31:0] reg_data_in_s3,
    output [31:0] alu_a_s1,
    output [31:0] alu_b_s1,
    output [31:0] alu_out_s2,
    output [31:0] microcode_s0,
    output reg [31:0] microcode_s1,
    output reg [31:0] microcode_s2,
    output reg [31:0] microcode_s3,
    output s1_data_dependency,
    output s2_data_dependency,
    output s3_data_dependency,
    output [4:0] rs1_s0,
    output [4:0] rd_s1,
    output [4:0] rd_s2,
    output [4:0] rd_s3,
    output reg branch_s2,
    output reg branch_s3,
    output [31:0] reg_data_out_a_s1,
    output [31:0] reg_data_out_b_s1,
    output [31:0] mem_data,
    output [31:0] mem_addr,
    output reg [31:0] alu_out_s3
);

// wire reg_write_enable_s3;
wire [4:0] reg_read_addr_a_s0;
wire [4:0] reg_read_addr_b_s0;
wire [4:0] reg_write_addr_s3;
// wire [31:0] reg_data_in_s3;
//wire [31:0] reg_data_out_a_s1;
//wire [31:0] reg_data_out_b_s1;

assign reg_write_enable_s3 = microcode_s3[12];
assign reg_read_addr_a_s0 = rs1_s0;
assign reg_read_addr_b_s0 = rs2_s0;
assign reg_write_addr_s3 = rd_s3;
assign reg_data_in_s3 = (microcode_s3[13]) ? upper_immediate_s3 :
                        (microcode_s3[14]) ? alu_out_s3 :
                        (microcode_s3[15]) ? {ret_addr_s3, 2'b0} :
                        (microcode_s3[16]) ? mem_data : 32'h00000000;

registers regs(
    .clk(clk),
    .write_enable(reg_write_enable_s3),
    .read_addr_a(reg_read_addr_a_s0),
    .read_addr_b(reg_read_addr_b_s0),
    .write_addr(reg_write_addr_s3),
    .data(reg_data_in_s3),
    .out_a(reg_data_out_a_s1),
    .out_b(reg_data_out_b_s1)
);

wire mem_write_enable_s2;
// wire [31:0] mem_addr;
// wire [31:0] mem_data;

assign mem_write_enable_s2 = microcode_s2[9];
assign mem_addr = (microcode_s2[10]) ? alu_out_s2 : {pc, 2'b0};
assign mem_data = (microcode_s2[11]) ? reg_data_out_b_s2 : 32'hZZZZZZZZ;

memory ram(
    .clk(clk),
    .write_enable(mem_write_enable_s2),
    .addr(mem_addr),
    .data(mem_data)
);

// wire [31:0] alu_a_s1;
// wire [31:0] alu_b_s1;
// wire [31:0] alu_out_s2;

assign alu_a_s1 = (microcode_s1[0]) ? reg_data_out_a_s1 :
                  (microcode_s1[1]) ? upper_immediate_s1 :
                  (microcode_s1[2]) ? sext_j_type_immediate_s1 :
                  (microcode_s1[3]) ? sext_b_type_immediate_s1 : 32'h00000000;
assign alu_b_s1 = (microcode_s1[4]) ? reg_data_out_b_s1 :
                  (microcode_s1[5]) ? sext_lower_immediate_s1 :
                  (microcode_s1[6]) ? sext_s_type_immediate_s1 :
                  (microcode_s1[7]) ? {inst_pc_s1, 2'b0} :
                  (microcode_s1[8]) ? {27'b0, rs1_s1} : 32'h00000000;

alu alu(
    .clk(clk),
    .a(alu_a_s1),
    .b(alu_b_s1),
    .out(alu_out_s2)
);

// wire [4:0] rs1_s0 = instruction_data_s0[12:8];
assign rs1_s0 = instruction_data_s0[12:8];
wire [4:0] rs1_s1 = instruction_data_s0[12:8];

wire [4:0] rs2_s0 = instruction_data_s0[12:8];

// wire [4:0] rd_s1 = instruction_data_s1[4:0];
// wire [4:0] rd_s2 = instruction_data_s2[4:0];
// wire [4:0] rd_s3 = instruction_data_s3[4:0];
assign rd_s1 = instruction_data_s1[4:0];
assign rd_s2 = instruction_data_s2[4:0];
assign rd_s3 = instruction_data_s3[4:0];

wire [31:0] upper_immediate_s1 = {instruction_data_s1[24:5], 12'b0};
wire [31:0] upper_immediate_s3 = {instruction_data_s3[24:5], 12'b0};

wire [31:0] sext_lower_immediate_s1 = {{21{instruction_data_s1[24]}}, instruction_data_s1[23:13]};
wire [31:0] sext_j_type_immediate_s1 = {{12{instruction_data_s1[24]}}, instruction_data_s1[12:5], instruction_data_s1[13], instruction_data_s1[23:14], 1'b0};
wire [31:0] sext_b_type_immediate_s1 = {{20{instruction_data_s1[24]}}, instruction_data_s1[7], instruction_data_s1[23:18], instruction_data_s1[11:8], 1'b0};
wire [31:0] sext_s_type_immediate_s1 = {{21{instruction_data_s1[24]}}, instruction_data_s1[23:18], instruction_data_s1[4:0]};

// wire [31:0] microcode_s0;
// wire [31:0] instruction = (microcode_s2[9] | microcode_s2[16]) ? 32'b00000000 : mem_data;
assign instruction = (microcode_s2[9] | microcode_s2[16] | microcode_s0[17] | branch_pause_pc) ? 32'b00000000 : mem_data;
wire [24:0] instruction_data_s0;

instruction_decoder decoder(
    .clk(clk),
    .instruction(instruction),
    .microcode(microcode_s0),
    .instruction_data(instruction_data_s0)
);

wire rs1_read = microcode_s0[0];
wire rs2_read = microcode_s0[4] | microcode_s0[11];

assign s1_data_dependency = (((rs1_s0 == rd_s1) & rs1_read) | ((rs2_s0 == rd_s1) & rs2_read)) & microcode_s1[12];
assign s2_data_dependency = (((rs1_s0 == rd_s2) & rs1_read) | ((rs2_s0 == rd_s2) & rs2_read)) & microcode_s2[12];
assign s3_data_dependency = (((rs1_s0 == rd_s3) & rs1_read) | ((rs2_s0 == rd_s3) & rs2_read)) & microcode_s3[12];

reg [2:0] reg_hold;

wire branch_pause_pc = microcode_s1[17] | microcode_s2[17] | microcode_s3[17];
//reg branch_s2;
//reg branch_s3;

// reg [29:0] pc;
// reg [31:0] microcode_s1;
// reg [31:0] microcode_s2;
// reg [31:0] microcode_s3;
reg [24:0] instruction_data_s1;
reg [24:0] instruction_data_s2;
reg [24:0] instruction_data_s3;

reg [29:0] inst_pc_s1;
reg [29:0] ret_addr_s3;

// reg [31:0] alu_out_s3;
reg [31:0] reg_data_out_b_s2;

always @(posedge clk) begin
    if (branch_pause_pc) begin
        if (microcode_s3[17] & branch_s3) begin
            pc <= alu_out_s3[31:2];
        end
    end else begin
        if (s1_data_dependency) begin
            pc <= pc - 30'd3;
        end else if (s2_data_dependency) begin
            pc <= pc - 30'd2;
        end else if (s3_data_dependency) begin
            pc <= pc - 30'd1;
        end else if (~(microcode_s1[9] | microcode_s1[16])) begin
            pc <= pc + 30'b1;
        end
    end

    if (s1_data_dependency) begin
        reg_hold <= 3'b111;
    end else if (s2_data_dependency) begin
        reg_hold <= 3'b11;
    end else begin
        reg_hold <= reg_hold >> 1;
    end

    case (microcode_s1[28:26])
        3'b000: branch_s2 <= 1'b0;
        3'b001: branch_s2 <= reg_data_out_a_s1 == reg_data_out_b_s1;                   // equal
        3'b010: branch_s2 <= reg_data_out_a_s1 != reg_data_out_b_s1;                   // not equal
        3'b011: branch_s2 <= $signed(reg_data_out_a_s1) < $signed(reg_data_out_b_s1);  // less than signed
        3'b100: branch_s2 <= $signed(reg_data_out_a_s1) >= $signed(reg_data_out_b_s1); // greater equal signed
        3'b101: branch_s2 <= reg_data_out_a_s1 < reg_data_out_b_s1;                    // less than unsigned
        3'b110: branch_s2 <= reg_data_out_a_s1 >= reg_data_out_b_s1;                   // greater equal signed
        3'b111: branch_s2 <= 1'b1;                                                     // true
    endcase
    branch_s3 <= branch_s2;

    microcode_s1 <= (s1_data_dependency | s2_data_dependency | s3_data_dependency | reg_hold[0]) ? 32'b00000000 : microcode_s0;
    microcode_s2 <= microcode_s1;
    microcode_s3 <= microcode_s2;
    instruction_data_s1 <= instruction_data_s0;
    instruction_data_s2 <= instruction_data_s1;
    instruction_data_s3 <= instruction_data_s2;

    inst_pc_s1 <= pc;
    ret_addr_s3 <= pc - 30'd2;

    alu_out_s3 <= alu_out_s2;
    reg_data_out_b_s2 <= reg_data_out_b_s1;
end

endmodule

// microcode_s0 = read
// microcode_s1 = execute
// microcode_s2 = read/write memory
// microcode_s3 = write regs & pc

//  0 (0):  connect reg_data_out_a to alu_a             (s1)
//  1 (1):  connect upper_immediate_s1 to alu_a         (s1)
//  2 (2):  connect sext_j_type_immediate_s1 to alu_a   (s1)
//  3 (3):  connect sext_b_type_immediate_s1 to alu_a   (s1)
//  4 (4):  connect reg_data_out_b to alu_b             (s1)
//  5 (5):  connect sext_lower_immediate to alu_b       (s1)
//  6 (6):  connect sext_s_type_immediate to alu_b      (s1)
//  7 (7):  connect inst_pc to alu_b                    (s1)
//  8 (8):  connect rs2 (shamt) to alu_b                (s1)
//  9 (9):  memory write enable                         (s2)
//  A (10): connect alu_out to mem_addr                 (s2)
//  B (11): connect reg_data_out_b_buf to mem_data      (s2) <trunc>
//  C (12): register write enable                       (s3)
//  D (13): connect upper_immediate to reg_data_in      (s3)
//  E (14): connect alu_out_buf to reg_data_in          (s3)
//  F (15): connect ret_addr to reg_data_in             (s3)
// 10 (16): connect mem_data to reg_data_in             (s3) <trunc>
// 11 (17): write alu_out_buf to pc if branch condition (s3)
// 12 (18): truncate <trunc> to unsigned byte           (s2 | s3)
// 13 (19): truncate <trunc> to unsigned half           (s2 | s3)
// 14 (20): truncate <trunc> to signed byte             (s2 | s3)
// 15 (21): truncate <trunc> to signed half             (s2 | s3)
// 16 (22): alu select bit 0                            (s1)
// 17 (23): alu select bit 1                            (s1)
// 18 (24): alu select bit 2                            (s1)
// 19 (25): alu select bit 3                            (s1)
// 1a (26): branch cmp select bit 0
// 1b (27): branch cmp select bit 1
// 1c (28): branch cmp select bit 2

// LUI    (example: 000420b7)
// AUIPC  (example: 00042097)
// JAL    (example: 042000ef)
// JALR   (example: 000420b7, 04208167)
// BEQ    (example: 000420b7, 00042137, 04208163)
// BNE    (example: )
// BLT    (example: )
// BGE    (example: )
// BLTU   (example: )
// BGEU   (example: )
// LB     (example: )
// LH     (example: )
// LW     (example: 01C02083 and 00000042 at 0b111)
// LBU    (example: )
// LHU    (example: )
// SB     (example: )
// SH     (example: )
// SW     (example: 000420b7, 001023a3)
// ADDI   (example: 000420b7, 04208113)
// SLTI   (example: )
// SLTIU  (example: )
// XORI   (example: )
// ORI    (example: )
// ANDI   (example: )
// SLLI   (example: )
// SRLI   (example: )
// SRAI   (example: )
// ADD    (example: 00042037, 0000e0b7, 001001b3)
// SUB    (example: )
// SLL    (example: )
// SLT    (example: )
// SLTU   (example: )
// XOR    (example: )
// SRL    (example: )
// SRA    (example: )
// OR     (example: )
// AND    (example: )
// FENCE  (example: )
// ECALL  (example: )
// EBREAK (example: )
