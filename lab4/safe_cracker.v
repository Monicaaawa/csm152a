module safe_cracker(
    input clock_100Mhz,
    input reset,
    input Mouse_Data,
    input Mouse_Clk,
    inout [7:0] JB,
    output [3:0] Anode_Activate,
    output [6:0] LED_out
    );

    wire [15:0] displayed_number, secret_code;
    wire [3:0] decode;
    reg [15:0] entered_code;
    reg [2:0] digit_count;
    reg code_entered;
    wire [1:0] game_status;

    // Keypad Decoder
    decoder decoder(
        .clock_100Mhz(clock_100Mhz),
        .row(JB[7:4]),
        .col(JB[3:0]),
        .dec_out(decode)
    );

    reg prev_key_pressed;
    always @(posedge clock_100Mhz or posedge reset) begin
        if (reset) begin
            entered_code <= 16'h0000;
            digit_count <= 0;
            code_entered <= 0;
            prev_key_pressed <= 0;
        end
        else if (decode != 4'hF) begin  // If a valid key is pressed
            if (digit_count < 4) begin  // Only store up to 4 digits
                entered_code <= {entered_code[11:0], decode}; // Shift new digit in
                digit_count <= digit_count + 1;
            end
            if (digit_count == 3) // After entering the 4th digit
                code_entered <= 1;
            prev_key_pressed <= 1;
        end
        else begin
            prev_key_pressed <= 0;
        end        
    end

    // Mouse Controller
    mouse_controller mouse_ctrl (
        .clock_100Mhz(clock_100Mhz),
        .reset(reset),
        .Mouse_Data(Mouse_Data),
        .Mouse_Clk(Mouse_Clk),
        .displayed_number(displayed_number)
    );

    game_logic game_ctrl (
        .clock_100Mhz(clock_100Mhz),
        .reset(reset),
        .displayed_number(displayed_number),
        .entered_code(entered_code),
        .code_entered(code_entered),
        .game_status(game_status),
        .secret_code(secret_code)
    );

    seven_seg_display display_ctrl (
        .clock_100Mhz(clock_100Mhz),
        .reset(reset),
        .number(displayed_number),
        .game_status(game_status),
        .Anode_Activate(Anode_Activate),
        .LED_out(LED_out)
    );

endmodule
