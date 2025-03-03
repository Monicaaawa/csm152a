module safe_cracker(
    input clock_100Mhz,
    input reset,
    input Mouse_Data,
    input Mouse_Clk,
    input [15:0] entered_code, // PMOD keypad input
    input code_entered, // Signal when the user enters a code
    output [3:0] Anode_Activate,
    output [6:0] LED_out
    );

    wire [15:0] displayed_number, secret_code;
    wire [1:0] game_status;

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
        .blink(game_status == 1),
        .game_status(game_status),
        .Anode_Activate(Anode_Activate),
        .LED_out(LED_out)
    );

endmodule
