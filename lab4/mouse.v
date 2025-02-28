module mouse_basys3_FPGA(
    input clock_100Mhz, // 100 MHz clock source on Basys 3 FPGA
    input reset, // Reset signal
    input Mouse_Data, // Mouse PS/2 Data
    input Mouse_Clk, // Mouse PS/2 Clock
    output reg [3:0] Anode_Activate, // Anode signals for 7-segment display
    output reg [6:0] LED_out // Cathode patterns for 7-segment display
);

    reg [4:0] Mouse_bits; // Counter for received bits
    reg [10:0] shift_reg; // Shift register for PS/2 word
    reg [7:0] Mouse_byte[2:0]; // Stores the three PS/2 data bytes
    reg signed [15:0] X_accum; // Accumulates raw X movement
    reg signed [15:0] Y_accum; // Accumulates raw Y movement
    reg [7:0] X_pos; // X coordinate (in cm)
    reg [7:0] Y_pos; // Y coordinate (in cm)
    reg [3:0] LED_BCD; // Current digit to display

    reg [20:0] refresh_counter; // Refresh counter for display multiplexing
    wire [1:0] LED_activating_counter;

    // Shift register to receive 11-bit PS/2 words
    always @(negedge Mouse_Clk or posedge reset) begin
        if (reset) begin
            Mouse_bits <= 0;
            shift_reg <= 0;
        end else begin
            if (Mouse_bits < 11) begin
                shift_reg <= {Mouse_Data, shift_reg[10:1]}; // Shift in data LSB-first
                Mouse_bits <= Mouse_bits + 1;
            end else begin
                Mouse_bits <= 0;
            end
        end
    end

    // Extract 8-bit data from 11-bit PS/2 word
    always @(posedge clock_100Mhz or posedge reset) begin
        if (reset) begin
            Mouse_byte[0] <= 0;
            Mouse_byte[1] <= 0;
            Mouse_byte[2] <= 0;
            X_accum <= 0;
            Y_accum <= 0;
            X_pos <= 0;
            Y_pos <= 0;
        end else if (Mouse_bits == 11) begin
            case (Mouse_bits / 11)
                0: Mouse_byte[0] <= shift_reg[8:1]; // Status byte
                1: Mouse_byte[1] <= shift_reg[8:1]; // X movement
                2: Mouse_byte[2] <= shift_reg[8:1]; // Y movement
            endcase
        end
    end

    // Process mouse movement when all bytes are received
    always @(posedge clock_100Mhz or posedge reset) begin
        if (reset) begin
            X_accum <= 0;
            Y_accum <= 0;
            X_pos <= 0;
            Y_pos <= 0;
        end else if (Mouse_bits == 33) begin
            // Correctly handle signed 2's complement values
            if (Mouse_byte[0][3]) // X sign bit
                X_accum <= X_accum + { {8{Mouse_byte[1][7]}}, Mouse_byte[1] };
            else
                X_accum <= X_accum + Mouse_byte[1];

            if (Mouse_byte[0][4]) // Y sign bit
                Y_accum <= Y_accum + { {8{Mouse_byte[2][7]}}, Mouse_byte[2] };
            else
                Y_accum <= Y_accum + Mouse_byte[2];

            // Convert movement to cm and prevent overflow
            if (X_accum >= 10) begin
                if (X_pos < 99) X_pos <= X_pos + 1;
                X_accum <= 0;
            end else if (X_accum <= -10) begin
                if (X_pos > 0) X_pos <= X_pos - 1;
                X_accum <= 0;
            end

            if (Y_accum >= 10) begin
                if (Y_pos < 99) Y_pos <= Y_pos + 1;
                Y_accum <= 0;
            end else if (Y_accum <= -10) begin
                if (Y_pos > 0) Y_pos <= Y_pos - 1;
                Y_accum <= 0;
            end
        end
    end

    // Refresh counter for 7-segment display
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
