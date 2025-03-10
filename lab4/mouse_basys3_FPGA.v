module mouse_basys3_FPGA(
    input clock_100Mhz,
    input reset,
    input Mouse_Data,
    input Mouse_Clk,
    output reg [3:0] Anode_Activate,
    output reg [6:0] LED_out
);
    reg [5:0] Mouse_bits;
    reg [26:0] one_second_counter;
    wire one_second_enable;
    reg [15:0] displayed_number;
    reg [3:0] LED_BCD;
    reg [20:0] refresh_counter; 
    wire [1:0] LED_activating_counter; 
    
    // Blinking registers
    reg [25:0] blink_counter;
    reg blink_enable;

    // LFSR for Pseudo-Random Number Generation
    reg [13:0] lfsr = 14'b10110111000011; // Initial seed
    
    // Generate a new random number upon reset
    always @(posedge clock_100Mhz or posedge reset) begin
        if (reset) begin
            // LFSR-based pseudo-random number generator
            lfsr <= {lfsr[12:0], lfsr[13] ^ lfsr[4] ^ lfsr[3] ^ lfsr[1]}; 
            displayed_number <= (lfsr % 9999) + 1; // Ensure range is 1-9999
        end else begin
            lfsr <= {lfsr[12:0], lfsr[13] ^ lfsr[4] ^ lfsr[3] ^ lfsr[1]};
        end
    end

    // Mouse data handling
    always @(posedge Mouse_Clk or posedge reset) begin
        if(reset)
            Mouse_bits <= 0;
        else if(Mouse_bits <= 31) 
            Mouse_bits <= Mouse_bits + 1;
        else 
            Mouse_bits <= 0;
    end

    always @(negedge Mouse_Clk or posedge reset) begin
        if(reset)
            displayed_number <= (lfsr % 9999) + 1; // Set random number at reset
        else begin
            if(Mouse_bits == 1) begin
                if(Mouse_Data == 1)
                   displayed_number <= displayed_number + 1;
            end
            else if(Mouse_bits == 2) begin
               if(Mouse_Data == 1 && displayed_number > 0)
                   displayed_number <= displayed_number - 1;
            end
        end 
    end    

    // Refresh counter
    always @(posedge clock_100Mhz or posedge reset) begin 
        if(reset)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
    assign LED_activating_counter = refresh_counter[20:19];

    // Blinking counter
    always @(posedge clock_100Mhz or posedge reset) begin
        if(reset)
            blink_counter <= 0;
        else if(displayed_number == lfsr) // Blink when displayed_number == PRNG value
            blink_counter <= blink_counter + 1;
        else
            blink_counter <= 0;
    end

    always @(posedge clock_100Mhz or posedge reset) begin
        if(reset)
            blink_enable <= 1;
        else if(displayed_number == lfsr)
            blink_enable <= blink_counter[25]; // Toggle blinking
        else
            blink_enable <= 1;
    end

    always @(*) begin
        if (blink_enable) begin
            case(LED_activating_counter)
                2'b00: begin
                    Anode_Activate = 4'b0111; 
                    LED_BCD = displayed_number / 1000;
                end
                2'b01: begin
                    Anode_Activate = 4'b1011; 
                    LED_BCD = (displayed_number % 1000) / 100;
                end
                2'b10: begin
                    Anode_Activate = 4'b1101; 
                    LED_BCD = ((displayed_number % 1000) % 100) / 10;
                end
                2'b11: begin
                    Anode_Activate = 4'b1110; 
                    LED_BCD = ((displayed_number % 1000) % 100) % 10;
                end
            endcase
        end else begin
            Anode_Activate = 4'b1111;
        end
    end

    // Cathode patterns of the 7-segment LED display
    always @(*) begin
        if (blink_enable) begin
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
                default: LED_out = 7'b0000001; // "0"
            endcase
        end else begin
            LED_out = 7'b1111111;
        end
    end
endmodule
