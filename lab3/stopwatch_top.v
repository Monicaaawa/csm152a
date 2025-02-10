module stopwatch_top(
    input clk, rst, pause, adj, sel,
    output [3:0] an,
    output [6:0] seg
);
    wire clk_1Hz, clk_2Hz, clk_fast;
    wire [3:0] sec_ones, sec_tens, min_ones, min_tens;

    clock_divider clk_div(clk, rst, clk_1Hz, clk_2Hz, clk_fast);
    stopwatch sw(clk_1Hz, clk_2Hz, rst, pause, adj, sel, sec_ones, sec_tens, min_ones, min_tens);
    seven_seg_display ssd(clk_fast, sec_ones, sec_tens, min_ones, min_tens, an, seg);
endmodule
