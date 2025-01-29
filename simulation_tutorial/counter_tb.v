`timescale 10ns/1ns

module counter_tb;
    reg clk;
    reg rst;
    wire a0;
    wire a1;
    wire a2;
    wire a3;

    counter my_counter(clk, rst, a0, a1, a2, a3);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, counter_tb);

        clk = 0;
        rst = 1;
        #1
        rst = 0;

        #20 $finish;
    end

    always begin
        #0.5 clk = ~clk;
    end
endmodule
