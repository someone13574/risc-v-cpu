`include "microcode.sv"

module mmio #(
    parameter MMIO_ADDR_START_BIT
) (
    input logic clk,
    input logic clk_enable,
    input logic [microcode::WIDTH - 1:0] microcode_s2,
    input logic [31:0] addr,
    input logic [31:0] data_in,
    output logic [31:0] data_out,
    output logic is_mmio,
    output logic [15:0] seven_segment_out
);

logic we;
logic [15:0] mmio_addr;

always_comb begin
    we = microcode::mcs2_mem_we(microcode_s2);

    is_mmio = addr[MMIO_ADDR_START_BIT];
    mmio_addr = addr[MMIO_ADDR_START_BIT - 2:2];
end

typedef enum bit[15:0] {
    SEVEN_SEGMENT = 16'h0
} mmio_addrs_e;

always_ff @(posedge clk) begin
    if (clk_enable & is_mmio) begin
        case (mmio_addr)
            SEVEN_SEGMENT: begin
                if (we) begin seven_segment_out <= ~data_in[15:0]; end
                data_out <= {16'b0, ~seven_segment_out};
            end
            default: data_out <= 32'b0;
        endcase
    end
end

endmodule
