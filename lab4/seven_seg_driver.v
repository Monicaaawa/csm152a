module seven_seg_display(
    input clock_100Mhz,
    input reset,
    input [15:0] number,
    input [1:0] game_status, // 0: normal, 1: blinking, 2: PASS, 3: FAIL
    output reg [3:0] Anode_Activate,
    output reg [6:0] LED_out
    );

    reg [3:0] LED_BCD;
    reg [20:0] refresh_counter;
    wire [1:0] LED_activating_counter;
    reg blink_enable;

    always @(posedge clock_100Mhz or posedge reset)
    begin 
        if (reset)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 

    assign LED_activating_counter = refresh_counter[20:19];

    // Blinking Effect Logic
    always @(posedge clock_100Mhz or posedge reset)
    begin
        if (reset)
            blink_enable <= 1;
        else if (game_status == 1)
            blink_enable <= refresh_counter[18]; // Blinking effect
        else
            blink_enable <= 1;
    end

    always @(*)
    begin
        if (!blink_enable)
            LED_out = 7'b1111111; // Blank the display when blinking
        else begin
            case (game_status)
                2'b10: LED_out = 7'b0001100; // "P" for PASS
                2'b11: LED_out = 7'b0001110; // "F" for FAIL
                default: begin
                    case(LED_activating_counter)
                        2'b00: begin Anode_Activate = 4'b0111; LED_BCD = number / 1000; end
                        2'b01: begin Anode_Activate = 4'b1011; LED_BCD = (number % 1000) / 100; end
                        2'b10: begin Anode_Activate = 4'b1101; LED_BCD = ((number % 1000) % 100) / 10; end
                        2'b11: begin Anode_Activate = 4'b1110; LED_BCD = ((number % 1000) % 100) % 10; end
                    endcase
                    case(LED_BCD)
                        4'b0000: LED_out = 7'b0000001; // "0"
                        4'b0001: LED_out = 7'b1001111; // "1"
                        4'b0010: LED_out = 7'b0010010; // "2"
                        4'b0011: LED_out = 7'b0000110; // "3"
                        4'b0100: LED_out = 7'b1001100; // "4"
                        4'b0101: LED_out = 7'b0100100; // "5"
                        4'b0110: LED_out = 7'b0100000; // "6"
                        4'b0111: LED_out = 7'b0001111; // "7"
                        4'b1000: LED_out = 7'b0000000; // "8"
                        4'b1001: LED_out = 7'b0000100; // "9"
                        default: LED_out = 7'b1111111; // Blank
                    endcase
                end
            endcase
        end
    end
endmodule
