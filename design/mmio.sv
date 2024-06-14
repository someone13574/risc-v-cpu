`include "microcode.sv"

module mmio #(
    parameter logic [31:0] MMIO_ADDR_START_BIT
) (
    input logic clk,
    input logic clk_enable,
    input logic [microcode::WIDTH - 1:0] microcode_s2,
    input logic [31:0] addr,
    input logic [31:0] data_in,
    input logic uart_tx_sending,
    output logic [31:0] data_out,
    output logic is_mmio,
    output logic [15:0] seven_segment_out,
    output logic [8:0] uart_tx_data
);

    // initialize registers
    initial begin
        uart_tx_data <= {9{0'b1}};
    end

    logic we;
    logic [15:0] mmio_addr;

    always_comb begin
        we = microcode::mcs2_mem_we(microcode_s2);

        is_mmio = addr[MMIO_ADDR_START_BIT]; // this bit is used to select between normal memory and mmio registers
        mmio_addr = addr[MMIO_ADDR_START_BIT-1:0]; // slice the addr to only contain the relevant part
    end

    // addresses of mmio addrs
    typedef enum bit [15:0] {
        SEVEN_SEGMENT = 16'h0,
        UART_TX_DATA  = 16'h4
    } mmio_addrs_e;

    always_ff @(posedge clk) begin
        if (clk_enable & is_mmio) begin
            case (mmio_addr)
                SEVEN_SEGMENT: begin
                    if (we) begin
                        seven_segment_out <= ~data_in[15:0];
                    end
                    data_out <= {16'b0, seven_segment_out};
                end
                UART_TX_DATA: begin
                    if (we) begin
                        // Alternate bit 8 to signal that it has changed
                        uart_tx_data <= {~uart_tx_data[8], data_in[7:0]};
                    end
                    data_out <= {24'b0, uart_tx_data[7:0]};
                end
                default: data_out <= 32'b0;
            endcase
        end
    end

endmodule
