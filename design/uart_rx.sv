module uart_rx #(
    parameter CLOCK_RATE = 25175000,
    parameter BAUD_RATE = 9600,
    parameter COUNTER_SIZE = 12
) (
    input logic clk,
    input logic rx,
    output logic update,
    output logic [7:0] last_byte
);

localparam COUNTER_MAX = CLOCK_RATE / BAUD_RATE - 1;
localparam COUNTER_HALF = CLOCK_RATE / (BAUD_RATE * 2) - 1;

logic [2:0] rx_shift;
logic active;
logic [COUNTER_SIZE - 1:0] rx_counter;
logic [9:0] shift;

always_ff @(posedge clk) begin
    rx_shift = {rx_shift[1:0], rx};
    rx_counter <= rx_counter + {{COUNTER_SIZE-1{1'b0}}, 1'b1};

    // Start detection
    if (~rx_shift[1] & rx_shift[2] & ~active) begin
        active <= 1;
        shift <= 10'b1000000000;
    end

    // Synchronize using edge
    if (rx_shift[1] ^ rx_shift[2]) begin
        rx_counter <= COUNTER_HALF[COUNTER_SIZE - 1:0];
    end

    // Trigger read
    if ((rx_counter == COUNTER_MAX) & active) begin
        rx_counter <= 0;
        shift <= {rx_shift[1], shift[9:1]};
    end

    // Byte complete
    if (shift[0] & active) begin
        active <= 0;
        update <= ~update;
        last_byte <= shift[9:2];
    end
end

endmodule
