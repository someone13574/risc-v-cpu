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

logic prev_rx;
logic active;
logic [COUNTER_SIZE - 1:0] rx_counter;
logic [9:0] shift;

always_ff @(posedge clk) begin
    prev_rx <= rx;
    rx_counter <= rx_counter + {{COUNTER_SIZE-1{1'b0}}, 1'b1};

    // Start detection
    if (~rx & prev_rx & ~active) begin
        active <= 1;
        shift <= 10'b1000000000;
    end

    // Synchronize using edge
    if (rx ^ prev_rx) begin
        rx_counter <= COUNTER_HALF[COUNTER_SIZE - 1:0];
    end

    // Trigger read
    if ((rx_counter == COUNTER_MAX[COUNTER_SIZE - 1:0]) & active) begin
        rx_counter <= 0;
        shift <= {rx, shift[9:1]};
    end

    // Byte complete
    if (shift[0] & active) begin
        active <= 0;
        update <= ~update;
        last_byte <= shift[9:2];
    end
end

endmodule
