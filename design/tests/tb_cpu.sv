module tb_cpu;

    logic clk;
    logic rx;
    logic [15:0] seven_segment_mmio;

    cpu cpu (
        .clk(clk),
        .rx(rx),
        .seven_segment_mmio(seven_segment_mmio)
    );

    initial begin
        $dumpfile("build/tb_cpu.vcd");
        $dumpvars(0, tb_cpu);

        forever begin
            clk = 0;
            #10 clk = ~clk;
        end
    end

    initial begin
        #1000;

        $finish();
    end

endmodule
