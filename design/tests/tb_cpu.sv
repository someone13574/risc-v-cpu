module tb_cpu;

reg clk;

cpu cpu(
    .clk(clk)
);

initial begin
    $dumpfile("build/tb_cpu.vcd");
    $dumpvars(0, tb_cpu);
end

always #10 clk = ~clk;

initial begin
    clk = 0;
    #1000;

    $finish();
end

endmodule
