module uart_tx #(
    parameter logic [31:0] CLOCK_RATE = 25175000,
    parameter logic [31:0] BAUD_RATE = 9600,
    parameter logic [31:0] COUNTER_SIZE = 12
) (
    input logic clk,
    input logic [7:0] data_in,
    input logic send,
    output logic sending,
    output logic tx
);

    localparam logic [31:0] CounterMax = CLOCK_RATE / BAUD_RATE - 1;

    logic [7:0] send_buf;
    logic [3:0] bit_count;
    logic [COUNTER_SIZE - 1:0] counter;

    logic n_tx;
    logic prev_send;
    always_comb begin
        tx = ~n_tx;
    end

    always_ff @(posedge clk) begin
        // Start symbol
        prev_send <= send;
        if ((send ^ prev_send) & ~sending) begin
            sending <= 1'b1;
            send_buf <= data_in;
            bit_count <= 4'b0;
            n_tx <= 1'b1;
            counter <= 1'b0;
        end

        if (sending) begin
            counter <= counter + {{COUNTER_SIZE - 1{1'b0}}, 1'b1};

            if (counter == CounterMax) begin
                if (bit_count[3]) begin
                    // End symbol
                    sending <= 1'b0;
                    n_tx <= 1'b0;
                end else begin
                    // Send signal
                    n_tx <= ~send_buf[0];
                    send_buf <= {1'b0, send_buf[7:1]};
                    bit_count <= bit_count + 4'd1;
                    counter <= {{COUNTER_SIZE{1'b0}}};
                end
            end
        end
    end

endmodule
