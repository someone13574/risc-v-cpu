// NOTE: This file is a stub for letting verilator work. If you are running on
// an EPF10K70, do not include this file so it will instead use the builtin EABs.

module lpm_ram_dq #(
    parameter LPM_WIDTH,
    parameter LPM_WIDTHAD,
    parameter LPM_FILE
) (
    input logic inclock,
    input logic outclock,
    input logic we,
    input logic [LPM_WIDTHAD - 1:0] address,
    input logic [LPM_WIDTH - 1:0] data,
    output logic [LPM_WIDTH - 1:0] q
);

logic [LPM_WIDTH - 1:0] mem [0:2 ** LPM_WIDTHAD - 1];

initial $readmemh(LPM_FILE, mem);

always_ff @(posedge inclock) begin
    if (we) begin
        mem[address] <= data;
    end

    q <= mem[address];
end

endmodule
