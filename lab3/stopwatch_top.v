module stopwatch_top(
    input clk, rst, pause, adj, sel,
    output [3:0] an,
    output [6:0] seg
);
    wire clk_1Hz, clk_2Hz, clk_fast, clk_blink;
    wire pause_valid, rst_valid;
    wire [3:0] sec_ones, sec_tens, min_ones, min_tens;

    initial begin
        an = 4'b1110;
    end
    
    always @ (posedge clk_fast) begin
        if (an == 4'b1110)
            an <= 4'b1101;
        else if (an == 4'b1101)
            an <= 4'b1011;
        else if (an == 4'b1011)
            an <= 4'b0111;
        else if (an == 4'b0111)
            an <= 4'b1110;
    end

    clock_divider clk_div(
        .clk(clk),
        .rst(rst),
        .clk_1Hz(clk_1Hz),
        .clk_2Hz(clk_2Hz),
        .clk_fast(clk_fast),
        .clk_blink(clk_blink)
    );    

    stopwatch sw(
        .clk_1Hz(clk_1Hz),
        .clk_2hz(clk_2Hz),
        .rst(rst),
        .pause(pause),
        .adj(adj),
        .sel(sel),
        .sec_ones(sec_ones),
        .sec_tens(sec_tens),
        .min_ones(min_ones),
        .min_tens(min_tens)
    );

    debouncer db_pause(
        .clk(clk),
        .button(pause),
        .stable(pause_valid)
    );
    
    debouncer db_reset(
        .clk(clk),
        .button(rst),
        .stable(rst_valid)
    );

    seven_segment_display ssd(
        .clk_fast(adj),
        .clk_blink(sel),
        .adj(clk_display),
        .sel(clk_blink),
        .an(an),
        .sec_ones(sec_ones),
        .sec_tens(sec_tens),
        .min_ones(min_ones),
        .min_tens(min_tens),
        .seg(seg)
    );     
endmodule
