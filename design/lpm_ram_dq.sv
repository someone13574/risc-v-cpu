module lpm_ram_dq #(
    parameter LPM_WIDTH,
    parameter LPM_WIDTHAD,
    parameter LPM_OUTDATA,
    parameter LPM_FILE
) (
    input logic inclock,
    input logic we,
    input logic [LPM_WIDTHAD - 1:0] address,
    input logic [LPM_WIDTH - 1:0] data,
    output logic [LPM_WIDTH - 1:0] q
);

logic [LPM_WIDTH - 1:0] mem [0:LPM_WIDTHAD ** 2 - 1];

initial $readmemh(LPM_FILE, mem);

always_ff @(posedge inclock) begin
    if (we) begin
        mem[address] <= data;
    end

    q <= mem[address];
end

endmodule