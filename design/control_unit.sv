`include "microcode.sv"
`include "instruction_data.sv"

module control_unit (
    input logic clk,
    input logic clk_enable,
    input logic [microcode::WIDTH - 1:0] microcode_s0,
    input logic [instruction_data::WIDTH - 1:0] instruction_data_si,
    input logic [31:0] reg_out_a,
    input logic [31:0] reg_out_b,
    input logic [29:0] jmp_addr,
    output logic [microcode::WIDTH - 1:0] microcode_s1,
    output logic [microcode::WIDTH - 1:0] microcode_s2,
    output logic [microcode::WIDTH - 1:0] microcode_s3,
    output logic [instruction_data::WIDTH - 1:0] instruction_data_s0,
    output logic [instruction_data::WIDTH - 1:0] instruction_data_s2,
    output logic [instruction_data::WIDTH - 1:0] instruction_data_s3,
    output logic [29:0] ret_addr,
    output logic [29:0] pc,
    output logic [29:0] pc_s0
);

    // Branch condition enumeration
    typedef enum bit [2:0] {
        NULL_CMP_OP        = 3'b000,
        EQ_CMP_OP          = 3'b001,
        NOT_EQ_CMP_OP      = 3'b010,
        LESS_THAN_CMP_OP   = 3'b011,
        GREATER_EQ_CMP_OP  = 3'b100,
        LESS_THAN_U_CMP_OP = 3'b101,
        GREATER_EQ_U_CM_OP = 3'b110,
        TRUE_CMP_OP        = 3'b111
    } cmp_ops_e;

    // Program counters which aren't exposed as outputs
    logic [29:0] pc_si;
    logic [29:0] pc_s1;

    // branch logic (see `docs/branching.md`)
    logic [2:0] cmp_op_select; // branch condition selector
    logic jump_if_branch_s1; // if this is 1 and the condition is true, execute a branch
    logic raw_branch; // the output of the branch condition
    logic branch; // raw_branch & jump_if_branch_s1

    logic data_dep;
    logic mem_in_use;
    logic mem_in_use_s3;

    // shift registers (these are used to shall the pipeline while branching & mem operations are taking place)
    logic [2:0] branch_shift;
    logic [2:0] data_dep_shift;
    logic mem_in_use_s4;

    // blocks propagation of instructions from s0 to s1 because s1 is the first critical stage (a stage which has side-effects)
    logic blk_s0;
    logic prev_blk_s0;

    logic [instruction_data::WIDTH - 1:0] instruction_data_s1;
    data_dep_detector data_dep_detect (
        .microcode_s0(microcode_s0),
        .microcode_s1(microcode_s1),
        .microcode_s2(microcode_s2),
        .microcode_s3(microcode_s3),
        .instruction_data_s0(instruction_data_s0),
        .instruction_data_s1(instruction_data_s1),
        .instruction_data_s2(instruction_data_s2),
        .instruction_data_s3(instruction_data_s3),
        .currently_blocked(prev_blk_s0),
        .data_dependency(data_dep)
    );

    always_comb begin
        branch = raw_branch & jump_if_branch_s1;
        blk_s0 = data_dep
               | data_dep_shift[0]
               | data_dep_shift[1]
               | data_dep_shift[2]
               | branch
               | branch_shift[0]
               | branch_shift[1]
               | branch_shift[2]
               | mem_in_use_s4;
        ret_addr = pc_s1;
    end

    always_ff @(posedge clk) begin
        if (clk_enable) begin
            // program counter logic. See `branching.md`, `data-dependency.md`, and `memory-fetch-conflict.md`
            if (branch_shift[0]) begin  // jump_if_branch filtering already done
                pc <= jmp_addr;
            end else if (data_dep_shift[0]) begin
                pc <= data_dep_shift[2] ? pc_si : data_dep_shift[1] ? pc : pc_s1;
            end else if (mem_in_use) begin
                pc <= pc;
            end else begin
                pc <= pc + 30'd1;
            end

            // Evaluate branch condition
            case (cmp_op_select)
                NULL_CMP_OP:        raw_branch <= 1'b0;
                EQ_CMP_OP:          raw_branch <= reg_out_a == reg_out_b;
                NOT_EQ_CMP_OP:      raw_branch <= reg_out_a != reg_out_b;
                LESS_THAN_CMP_OP:   raw_branch <= $signed(reg_out_a) < $signed(reg_out_b);
                GREATER_EQ_CMP_OP:  raw_branch <= $signed(reg_out_a) >= $signed(reg_out_b);
                LESS_THAN_U_CMP_OP: raw_branch <= reg_out_a < reg_out_b;
                GREATER_EQ_U_CM_OP: raw_branch <= reg_out_a >= reg_out_b;
                TRUE_CMP_OP:        raw_branch <= 1'b1;
                default:            raw_branch <= 1'b0;
            endcase

            // Move shift registers
            branch_shift <= {branch_shift[1:0], branch};
            data_dep_shift <= {data_dep_shift[1:0], data_dep};
            mem_in_use_s4 <= mem_in_use_s3;

            prev_blk_s0 <= blk_s0;

            // Move program counters up a stage
            pc_si <= pc;
            pc_s0 <= pc_si;
            pc_s1 <= pc_s0;

            // Move micrococe up a stage (and block incoming s0)
            microcode_s1 <= blk_s0 ? 25'b0 : microcode_s0;
            microcode_s2 <= microcode_s1;
            microcode_s3 <= microcode_s2;

            // Move instruction data up a stage (and block incoming s0)
            instruction_data_s0 <= instruction_data_si;
            instruction_data_s1 <= blk_s0 ? 25'b0 : instruction_data_s0;
            instruction_data_s2 <= instruction_data_s1;
            instruction_data_s3 <= instruction_data_s2;
        end
    end

    // Get microcode signals
    always_comb begin
        cmp_op_select     = microcode::mcs0_cmp_op_select(microcode_s0);
        mem_in_use        = microcode::mcs1_mem_in_use(microcode_s1);
        jump_if_branch_s1 = microcode::mcs2_jump_if_cmp(microcode_s1);
        mem_in_use_s3     = microcode::mcs1_mem_in_use(microcode_s3);
    end

endmodule
