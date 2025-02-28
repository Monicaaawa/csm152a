module mouse_basys3_FPGA(
    input clock_100Mhz, // 100 MHz clock source on Basys 3 FPGA
    input reset, // Reset signal
    input Mouse_Data, // Mouse PS2 data
    input Mouse_Clk, // Mouse PS2 Clock
    output reg [3:0] Anode_Activate, // Anode signals of the 7-segment LED display
    output reg [6:0] LED_out // Cathode patterns of the 7-segment LED display
);
    
    reg [5:0] Mouse_bits; // Count number of bits received from the PS/2 mouse
    reg [7:0] Mouse_byte[2:0]; // Stores 3 bytes from PS/2 mouse
    reg signed [15:0] X_accum; // Accumulates raw X movement
    reg signed [15:0] Y_accum; // Accumulates raw Y movement
    reg [7:0] X_pos; // Displayed X coordinate (in cm)
    reg [7:0] Y_pos; // Displayed Y coordinate (in cm)
    reg [3:0] LED_BCD; // Current digit to display
    
    reg [20:0] refresh_counter; // Counter for refreshing display
    wire [1:0] LED_activating_counter;
    
    // Mouse data reception
    always @(posedge Mouse_Clk or posedge reset) begin
        if (reset) begin
            Mouse_bits <= 0;
        end else if (Mouse_bits < 33) begin
            Mouse_bits <= Mouse_bits + 1;
        end else begin
            Mouse_bits <= 0;
        end
    end

    // Storing Mouse Data (Extract X and Y movement)
    always @(negedge Mouse_Clk or posedge reset) begin
        if (reset) begin
            Mouse_byte[0] <= 0;
            Mouse_byte[1] <= 0;
            Mouse_byte[2] <= 0;
            X_accum <= 0;
            Y_accum <= 0;
            X_pos <= 0;
            Y_pos <= 0;
        end else begin
            if (Mouse_bits >= 1 && Mouse_bits <= 8)
                Mouse_byte[0] <= {Mouse_Data, Mouse_byte[0][7:1]}; // First byte (Status byte, contains button states)
            else if (Mouse_bits >= 9 && Mouse_bits <= 16)
                Mouse_byte[1] <= {Mouse_Data, Mouse_byte[1][7:1]}; // X movement
            else if (Mouse_bits >= 17 && Mouse_bits <= 24)
                Mouse_byte[2] <= {Mouse_Data, Mouse_byte[2][7:1]}; // Y movement
            else if (Mouse_bits == 33) begin
                if (Mouse_byte[0][4]) // X sign bit
                    // X_accum <= X_accum + {8'b0, ~Mouse_byte[1] + 1};
                    X_accum <= -99;
                else
                    X_accum <= X_accum + Mouse_byte[1];

                if (Mouse_byte[0][5]) // Y sign bit
                    // Y_accum <= Y_accum + {8'b0, ~Mouse_byte[2] + 1};
                    Y_accum <= -99;
                else
                    Y_accum <= Y_accum + Mouse_byte[2];

                if (X_accum >= 99) begin
                    if (X_pos < 99) X_pos <= X_pos + 1; // Prevent overflow
                    X_accum <= 0; 
                end else if (X_accum <= -99) begin
                    if (X_pos > 0) X_pos <= X_pos - 1;
                    X_accum <= 0;
                end

                if (Y_accum >= 99) begin
                    if (Y_pos < 99) Y_pos <= Y_pos + 1; // Prevent overflow
                    Y_accum <= 0; 
                end else if (Y_accum <= -99) begin
                    if (Y_pos > 0) Y_pos <= Y_pos - 1;
                    Y_accum <= 0;
                end
            end
        end
    end

    // Refresh counter to multiplex 7-segment display
    always @(posedge clock_100Mhz or posedge reset) begin 
        if (reset) 
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
    
    assign LED_activating_counter = refresh_counter[20:19];

    // Anode activation for 7-segment display
    always @(*) begin
        case (LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b0111; 
            LED_BCD = X_pos / 10; // First digit of X-coordinate
        end
        2'b01: begin
            Anode_Activate = 4'b1011; 
            LED_BCD = X_pos % 10; // Second digit of X-coordinate
        end
        2'b10: begin
            Anode_Activate = 4'b1101; 
            LED_BCD = Y_pos / 10; // First digit of Y-coordinate
        end
        2'b11: begin
            Anode_Activate = 4'b1110; 
            LED_BCD = Y_pos % 10; // Second digit of Y-coordinate
        end
        endcase
    end

    // Cathode patterns for the 7-segment display
    always @(*) begin
        case (LED_BCD)
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
    end
endmodule
