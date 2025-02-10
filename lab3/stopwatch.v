module stopwatch(
    input clk_1Hz, clk_2Hz, rst, pause, adj, sel,
    output reg [3:0] sec_ones, sec_tens, min_ones, min_tens
);
    reg paused = 0;

    always @(posedge clk_1Hz or posedge rst) begin
        if (rst) begin
            sec_ones <= 0; sec_tens <= 0;
            min_ones <= 0; min_tens <= 0;
            paused <= 0;
        end else if (!pause) begin
            if (!adj) begin
                sec_ones <= sec_ones + 1;
                if (sec_ones == 9) begin
                    sec_ones <= 0;
                    sec_tens <= sec_tens + 1;
                    if (sec_tens == 5) begin
                        sec_tens <= 0;
                        min_ones <= min_ones + 1;
                        if (min_ones == 9) begin
                            min_ones <= 0;
                            min_tens <= min_tens + 1;
                            if (min_tens == 5) min_tens <= 0;
                        end
                    end
                end
            end
        end
    end

    always @(posedge clk_2Hz) begin
        if (adj) begin
            if (sel) begin
                sec_ones <= sec_ones + 1;
                if (sec_ones == 9) begin
                    sec_ones <= 0;
                    sec_tens <= sec_tens + 1;
                    if (sec_tens == 5) sec_tens <= 0;
                end
            end else begin
                min_ones <= min_ones + 1;
                if (min_ones == 9) begin
                    min_ones <= 0;
                    min_tens <= min_tens + 1;
                    if (min_tens == 5) min_tens <= 0;
                end
            end
        end
    end
endmodule
