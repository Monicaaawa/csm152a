module clock_divider(
    input clk,       // 100 MHz clock
    input rst,       // Reset signal
    output reg clk_1Hz,  
    output reg clk_2Hz,
    output reg clk_fast,  
    output reg clk_blink  
);
    reg [26:0] counter_1Hz = 0;
    reg [25:0] counter_2Hz = 0;
    reg [16:0] counter_fast = 0;
    reg [23:0] counter_blink = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_1Hz = 0;
            counter_2Hz = 0;
            counter_fast = 0;
            counter_blink = 0;
            clk_1Hz = 0;
            clk_2Hz = 0;
            clk_fast = 0;
            clk_blink = 0;
        end else begin
            // 1Hz Clock
            if (counter_1Hz >= 50000000) begin
                counter_1Hz <= 0;
                clk_1Hz <= ~clk_1Hz;
            end else counter_1Hz <= counter_1Hz + 1;

            // 2Hz Clock
            if (counter_2Hz >= 25000000) begin
                counter_2Hz <= 0;
                clk_2Hz <= ~clk_2Hz;
            end else counter_2Hz <= counter_2Hz + 1;

            // Fast Clock (500 Hz for multiplexing)
            if (counter_fast >= 100000) begin
                counter_fast <= 0;
                clk_fast <= ~clk_fast;
            end else counter_fast <= counter_fast + 1;

            // Blinking Clock
            if (counter_blink >= 12500000) begin
                counter_blink <= 0;
                clk_blink <= ~clk_blink;
            end else counter_blink <= counter_blink + 1;
        end
    end
endmodule
