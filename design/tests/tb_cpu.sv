module tb_cpu;

    logic clk;

    cpu cpu (.clk(clk));

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
