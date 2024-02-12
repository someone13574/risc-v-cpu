module microcode_buffer(
    input clk,
    input [15:0] head_microcode;
    output reg [7:0] pc,
    output [15:0] active_microcode
);

wire [15:0] next_microcode;
assign active_microcode = buffer[tail];
assign next_microcode = buffer[tail + 3'b1];

reg [15:0] buffer [0:7];
reg [2:0] head;
reg [2:0] tail;

always @(posedge clk) begin
    if (~(next_microcode[0] | next_microcode[1] | buffer_full)) begin
        head <= head + 3'b1;
        pc <= pc + 8'd4;
        buffer[head] <= head_microcode;
    end

    if (next_microcode[2] & ~buffer_empty) begin
        tail <= tail + 3'b1;
    end
end

wire buffer_full;
wire buffer_empty;
assign buffer_full = tail + 3'd2 == head;
assign buffer_empty = tail == head;

endmodule