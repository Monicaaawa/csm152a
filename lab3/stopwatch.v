module stopwatch(
    input clk_1Hz, clk_2Hz, rst, pause, adj, sel,
    output reg [3:0] sec_ones, sec_tens, min_ones, min_tens
);
    reg paused = 0;
    wire selected_clk = adj ? clk_2Hz : clk_1Hz;

    // Toggle pause state on rising edge of pause signal
    always @(posedge pause) begin
        paused <= ~paused;
    end

    // Main stopwatch logic
    always @(posedge selected_clk or posedge rst) begin
        if (rst) begin
            sec_ones <= 0;
            sec_tens <= 0;
            min_ones <= 0;
            min_tens <= 0;
            paused <= 0;  // Ensure the stopwatch is running after reset
        end else if (!paused) begin
            if (adj) begin
                if (sel) 
                    increment_seconds();  // Adjusting seconds
                else 
                    increment_minutes();  // Adjusting minutes
            end else begin
                increment_seconds();  // Normal time counting
            end
        end
    end    

    // Increment seconds logic
    task increment_seconds;
    begin
        if (sec_ones == 9) begin
            sec_ones <= 0;
            if (sec_tens == 5) begin
                sec_tens <= 0;
                increment_minutes();  // Carry over to minutes
            end else begin
                sec_tens <= sec_tens + 1;
            end
        end else begin
            sec_ones <= sec_ones + 1;
        end
    end
    endtask

    // Increment minutes logic
    task increment_minutes;
    begin
        if (min_ones == 9) begin
            min_ones <= 0;
            if (min_tens == 5) begin
                min_tens <= 0;  // Reset to 00 after 59 minutes
            end else begin
                min_tens <= min_tens + 1;
            end
        end else begin
            min_ones <= min_ones + 1;
        end
    end    
    endtask
endmodule
