`ifndef MC_SIGNALS_GUARD
`define MC_SIGNALS_GUARD

package microcode;

localparam WIDTH = 25;

// verilator lint_off UNUSED
function logic mcs0_check_rs1_dep          (input logic [WIDTH - 1:0] mc); return mc[0];     endfunction
function logic mcs0_check_rs2_dep          (input logic [WIDTH - 1:0] mc); return mc[1];     endfunction
function logic[1:0] mcs0_alu_a_mux         (input logic [WIDTH - 1:0] mc); return mc[3:2];   endfunction
function logic[2:0] mcs0_alu_b_mux         (input logic [WIDTH - 1:0] mc); return mc[6:4];   endfunction
function logic[2:0] mcs0_cmp_op_select     (input logic [WIDTH - 1:0] mc); return mc[9:7];   endfunction

function logic mcs1_mem_in_use             (input logic [WIDTH - 1:0] mc); return mc[10];    endfunction
function logic[3:0] mcs1_alu_op_select     (input logic [WIDTH - 1:0] mc); return mc[14:11]; endfunction

function logic mcs2_mem_we                 (input logic [WIDTH - 1:0] mc); return mc[15];    endfunction
function logic mcs2_enable_upper_half      (input logic [WIDTH - 1:0] mc); return mc[16];    endfunction
function logic mcs2_enable_byte1           (input logic [WIDTH - 1:0] mc); return mc[17];    endfunction
function logic mcs2_alu_out_over_pc        (input logic [WIDTH - 1:0] mc); return mc[18];    endfunction
function logic mcs2_jump_if_cmp            (input logic [WIDTH - 1:0] mc); return mc[19];    endfunction
function logic[1:0] mcs2_pre_writeback_mux (input logic [WIDTH - 1:0] mc); return mc[21:20]; endfunction

function logic mcs3_reg_we                 (input logic [WIDTH - 1:0] mc); return mc[22];    endfunction
function logic mcs3_pre_wb_over_mem_data   (input logic [WIDTH - 1:0] mc); return mc[23];    endfunction
function logic mcs3_sext_mem_out           (input logic [WIDTH - 1:0] mc); return mc[24];    endfunction
// verilator lint_on UNUSED

endpackage

`endif
