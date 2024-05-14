// NOTE: This file is a stub for letting verilator work. If you are running on
// an EPF10K70, do not include this file so it will instead use the builtin EABs.

module lpm_ram_dq #(
    parameter int LPM_WIDTH,
    parameter int LPM_WIDTHAD,
    parameter string LPM_FILE = "memory_init/eab-init-0"
) (
    input logic inclock,
    input logic outclock,
    input logic we,
    input logic [LPM_WIDTHAD - 1:0] address,
    input logic [LPM_WIDTH - 1:0] data,
    output logic [LPM_WIDTH - 1:0] q
);

    logic [LPM_WIDTH - 1:0] mem[2 ** LPM_WIDTHAD - 1];

    initial $readmemh(LPM_FILE, mem);

    logic [LPM_WIDTH - 1:0] q_inner;
    always_ff @(posedge outclock) begin
        q <= q_inner;
    end

    always_ff @(posedge inclock) begin
        if (we) begin
            mem[address] <= data;
        end

        q_inner <= mem[address];
    end

endmodule
