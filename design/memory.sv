module memory(
    input clk,
    input write_enable,
    input [31:0] addr,
    input [31:0] data_in,
    output [31:0] data_out
);

genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : generate_eabs
        lpm_ram_dq #(.LPM_WIDTH(4), .LPM_WIDTHAD(9)) mem(
            .inclock(clk),
            .outclock(clk),
            .we(write_enable),
            .address(addr[8:0]),
            .data(data_in[i * 4 + 3:i * 4]),
            .q(data_out[i * 4 + 3: i * 4])
        );
    end
endgenerate

endmodule
