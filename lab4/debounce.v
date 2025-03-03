module debounce(
    input clk, // Clock signal
    input reset, // Reset signal
    input noisy_signal, // Noisy input signal (Mouse_Data)
    output reg debounced_signal // Clean debounced output
    );

    reg [19:0] counter; // Counter for debounce delay
    reg stable_state; // Holds the stable value of input

    always @(posedge clk or posedge reset)
    begin
        if (reset) begin
            counter <= 0;
            stable_state <= 0;
            debounced_signal <= 0;
        end
        else begin
            if (noisy_signal == stable_state) begin
                counter <= 0; // Reset counter if stable
            end 
            else begin
                counter <= counter + 1;
                if (counter == 20'd1000000) begin // Adjust the counter for the required delay
                    stable_state <= noisy_signal;
                    debounced_signal <= noisy_signal;
                    counter <= 0;
                end
            end
        end
    end
endmodule
