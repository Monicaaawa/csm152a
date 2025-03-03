module game_logic(
    input clock_100Mhz,
    input reset,
    input [15:0] displayed_number,
    input [15:0] entered_code,
    input code_entered,
    output reg [1:0] game_status, // 0: normal, 1: blinking, 2: PASS, 3: FAIL
    output reg [15:0] secret_code
    );

    reg [26:0] blink_counter;
    reg [1:0] game_state;

    always @(posedge clock_100Mhz or posedge reset)
    begin
        if (reset) begin
            secret_code <= 16'd1234; // Replace with a proper random number generator
            game_status <= 0;
        end
        else begin
            if (displayed_number == secret_code)
                game_status <= 1; // Blink when correct number is found
            
            if (game_status == 1) begin
                blink_counter <= blink_counter + 1;
                if (blink_counter > 50000000) // ~1 second blink time
                    game_status <= 0;
            end
            
            if (code_entered) begin
                if (entered_code == secret_code)
                    game_status <= 2; // PASS
                else
                    game_status <= 3; // FAIL
            end
        end
    end
endmodule
