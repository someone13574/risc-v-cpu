`ifndef INST_DATA_SIGNALS_GUARD
`define INST_DATA_SIGNALS_GUARD

package instruction_data;

    localparam logic [31:0] WIDTH = 25;

    // verilator lint_off UNUSED
    function automatic logic [4:0] rs1(input logic [WIDTH - 1:0] inst_data);
        return inst_data[12:8];
    endfunction

    function automatic logic [4:0] rs2(input logic [WIDTH - 1:0] inst_data);
        return inst_data[17:13];
    endfunction

    function automatic logic [4:0] rd(input logic [WIDTH - 1:0] inst_data);
        return inst_data[4:0];
    endfunction

    function automatic logic [31:0] upper_immediate(input logic [WIDTH - 1:0] inst_data);
        return {inst_data[24:5], 12'b0};
    endfunction

    function automatic logic [31:0] lower_immediate(input logic [WIDTH - 1:0] inst_data);
        return {{21{inst_data[24]}}, inst_data[23:13]};
    endfunction

    function automatic logic [31:0] j_type_immediate(input logic [WIDTH - 1:0] inst_data);
        return {{12{inst_data[24]}}, inst_data[12:5], inst_data[13], inst_data[23:14], 1'b0};
    endfunction

    function automatic logic [31:0] b_type_immediate(input logic [WIDTH - 1:0] inst_data);
        return {{20{inst_data[24]}}, inst_data[0], inst_data[23:18], inst_data[4:1], 1'b0};
    endfunction

    function automatic logic [31:0] s_type_immediate(input logic [WIDTH - 1:0] inst_data);
        return {{21{inst_data[24]}}, inst_data[23:18], inst_data[4:0]};
    endfunction
    // verilator lint_on UNUSED

endpackage

`endif
