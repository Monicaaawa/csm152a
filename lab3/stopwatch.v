module stopwatch(
    input clk_1Hz, clk_2Hz, rst, pause, adj, sel,
    output reg [3:0] sec_ones, sec_tens, min_ones, min_tens
);
    reg paused = 0;
    wire selected_clk = adj ? clk_2Hz : clk_1Hz;

    // Toggle pause state on rising edge of pause signal
    always @(posedge pause) begin
        paused <= !paused;
    end

    // Main stopwatch logic
    always @(posedge selected_clk or posedge rst) begin
        if (rst) begin
            sec_ones <= 0;
            sec_tens <= 0;
            min_ones <= 0;
            min_tens <= 0;
        end 
        else if (!paused) begin
            if (adj) begin
                if (sel) 
                    increment_seconds();  // Adjusting seconds
                else 
                    increment_minutes();  // Adjusting minutes
            end 
            else begin
                increment_seconds();  // Normal time counting
            end
        end
    end    

    // Increment seconds logic
    task increment_seconds;
        reg [3:0] temp_sec_ones;
        reg [3:0] temp_sec_tens;
        reg [3:0] temp_min_ones;
        reg [3:0] temp_min_tens;
    begin
        // Copy current values to temporary registers
        temp_sec_ones = sec_ones;
        temp_sec_tens = sec_tens;
        temp_min_ones = min_ones;
        temp_min_tens = min_tens;

        // Increment logic
        if (temp_sec_ones == 9) begin
            temp_sec_ones = 0;
            if (temp_sec_tens == 5) begin
                temp_sec_tens = 0;
                if (temp_min_ones == 9) begin
                    temp_min_ones = 0;
                    if (temp_min_tens == 5) begin
                        temp_min_tens = 0; // Reset after 59:59
                    end else begin
                        temp_min_tens = temp_min_tens + 1;
                    end
                end else begin
                    temp_min_ones = temp_min_ones + 1;
                end
            end else begin
                temp_sec_tens = temp_sec_tens + 1;
            end
        end else begin
            temp_sec_ones = temp_sec_ones + 1;
        end

        // Update registers after all calculations are done
        sec_ones <= temp_sec_ones;
        sec_tens <= temp_sec_tens;
        min_ones <= temp_min_ones;
        min_tens <= temp_min_tens;
    end
    endtask

    // Increment minutes logic
    task increment_minutes;
        reg [3:0] temp_min_ones;
        reg [3:0] temp_min_tens;
    begin
        // Copy current values to temporary registers
        temp_min_ones = min_ones;
        temp_min_tens = min_tens;

        // Increment logic
        if (temp_min_ones == 9) begin
            temp_min_ones = 0;
            if (temp_min_tens == 5) begin
                temp_min_tens = 0;  // Reset to 00 after 59 minutes
            end else begin
                temp_min_tens = temp_min_tens + 1;
            end
        end else begin
            temp_min_ones = temp_min_ones + 1;
        end    

        // Update registers after all calculations are done
        min_ones <= temp_min_ones;
        min_tens <= temp_min_tens;
    end    
    endtask

endmodule
