module upload_rx #(
    parameter int BAUD_RATE = 9600
) (
    input logic clk,
    input logic clk_enable,
    input logic rx,
    input logic reset,
    output logic we,
    output logic [31:0] addr,
    output logic [7:0] uart_out,
    output logic [2:0] stage,
    output logic complete
);

    logic uart_update;

    uart_rx #(
        .CLOCK_RATE(25175000),
        .BAUD_RATE(BAUD_RATE),
        .COUNTER_SIZE(12)
    ) uart (
        .clk(clk),
        .rx(rx),
        .update(uart_update),
        .last_byte(uart_out)
    );

    // logic [2:0] stage;
    logic [15:0] bytes_remaining;
    logic prev_update;

    logic updated;
    logic received_header;
    logic can_inc_addr;

    always_comb begin
        received_header = stage[1];
        can_inc_addr = stage[2];

        updated = (uart_update ^ prev_update) & ~complete;
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            stage <= 3'b0;
            complete <= 1'b0;
            bytes_remaining <= 'b0;
            addr <= 'b0;
            we <= 1'b0;
        end else begin
            if (clk_enable) begin
                prev_update <= uart_update;
                we <= updated & received_header;

                if (updated) begin
                    stage <= {stage[1:0], 1'b1};

                    if (received_header) begin
                        bytes_remaining <= bytes_remaining - 16'd1;
                    end else begin
                        bytes_remaining <= {bytes_remaining[7:0], uart_out};
                    end

                    if (can_inc_addr) begin
                        addr <= addr + 32'd1;
                    end
                end

                if ((bytes_remaining == 16'b0) & received_header) begin
                    complete <= 1'b1;
                end
            end
        end
    end

endmodule
