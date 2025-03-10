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
    reg [25:0] blink_counter; // Slow down the blink rate
    reg blink_enable;

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
            displayed_number <= 0;
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
        else if(displayed_number == 9999) // Activate blink when displayed_number is 9999
            blink_counter <= blink_counter + 1;
        else
            blink_counter <= 0;
    end

    always @(posedge clock_100Mhz or posedge reset) begin
        if(reset)
            blink_enable <= 1;
        else if(displayed_number == 9999) // Toggle blink_enable
            blink_enable <= blink_counter[25]; // Slow blink
        else
            blink_enable <= 1; // Always enable when not at 9999
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
            Anode_Activate = 4'b1111; // Turn off all digits during blink-off phase
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
            LED_out = 7'b1111111; // Turn off display during blink-off phase
        end
    end

endmodule
