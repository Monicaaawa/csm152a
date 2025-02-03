module FloatingPointConverter (
    input [11:0] D,   // Input number
    output S,         // Sign bit
    output [2:0] E,   // Exponent
    output [3:0] F    // Fraction
);
    // Intermediate variables for magnitude and processing
    reg [10:0] magnitude;
    reg [11:0] tempBits;
    reg [10:0] temp;
    reg [3:0] leading_zeros;

    // Variables for exponent and significand calculation
    reg [2:0] exponent;
    reg [3:0] significand;
    reg fifth_bit;

    // Variables for final result
    reg sign;
    reg [2:0] final_exponent;
    reg [3:0] final_significand;

    // Convert to 2's complement
    always @(*) begin
        // Sign bit and 2's complement conversion
        sign = D[11];
        if (sign == 1'b1) begin
            tempBits = ~D + 1'b1;
        end
        else begin
            tempBits = D;
        end
        if (tempBits >= 1920) begin
            magnitude = 1920;
        end
        else begin
            magnitude = tempBits[10:0];
        end   

        // Leading zeros calculation
        temp = magnitude;
        leading_zeros = 4'b0001;
        if (temp != 0) begin
            while (temp[10] == 0) begin
                leading_zeros = leading_zeros + 1'b1;
                temp = temp << 1;
            end

            // Exponent determination based on leading zeros
            case (leading_zeros)
                4'b0001: exponent = 3'b111;
                4'b0010: exponent = 3'b110;
                4'b0011: exponent = 3'b101;
                4'b0100: exponent = 3'b100;
                4'b0101: exponent = 3'b011;
                4'b0110: exponent = 3'b010;
                4'b0111: exponent = 3'b001;
                default: exponent = 3'b000;
            endcase

            // Significand and fifth bit determination
            if (exponent == 3'b000) begin
                significand = magnitude[3:0];
                fifth_bit = 1'b0;
            end
            else begin
                significand = temp[10:7];
                fifth_bit = temp[6];
            end
        end
        else begin
            exponent = 3'b000;
            significand = 3'b000;
            fifth_bit = 1'b0;
        end

        // Adjust final significand and exponent based on fifth bit
        if (fifth_bit == 1) begin
            if (significand == 4'b1111) begin
                if (exponent == 3'b111) begin
                    final_exponent = exponent;
                    final_significand = 4'b1111;
                end else begin
                    final_exponent = exponent + 1'b1;
                    final_significand = 4'b1000;
                end
            end else begin
                final_exponent = exponent;
                final_significand = significand + 1'b1;
            end
        end
        else begin
            final_exponent = exponent;            
            final_significand = significand;
        end        
    end

    // Output assignments
    assign S = sign;
    assign E = final_exponent;
    assign F = final_significand;
endmodule


module tb_FloatingPointConverter;

    // Inputs
    reg [11:0] D;

    // Outputs
    wire S;
    wire [2:0] E;
    wire [3:0] F;

    // Instantiate the FloatingPointConverter module
    FloatingPointConverter uut (
        .D(D),
        .S(S),
        .E(E),
        .F(F)
    );

    // Testbench logic
    initial begin
        D = 12'b000000000001; // Just above 0
        #10; // Wait for 10 time units
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);

        D = 12'b100000000001; // Negative number
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);

        D = 12'b000000111111; // Large positive number
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);

        D = 12'b100000111111; // Large negative number
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);

        D = 12'b000000000000; // Zero
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);
        $display("Expected output: 00000000");  

        D = 12'b011111111111; // Maximum positive number
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);

        D = 12'b111111111111; // Maximum negative number
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);

        D = 12'b000001000000; // Mid-range positive number
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);

        D = 12'b000001111101;
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);

        D = 12'b000000101100;
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);
        
        D = 12'b000000101101;
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);
        
        D = 12'b000000101110;
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);  

        D = 12'b000000101111;
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);  
        
        D = 12'b101001110010; // Random negative number
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);  
        $display("Expected output: 11111011");  
        #10        
        
        // Test 3: Positive number with rounding
        D = 12'b010101011111;
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);  
        $display("Expected output: 01111011");  
        #10

        D = 12'b001111100000;
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);  
        $display("Expected output: 01111000");  
        #10

        D = 12'b100000000000;
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);  
        $display("Expected output: 11111111");  
        #10        
        
        D = 12'b000000001111;
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);  
        $display("Expected output: 00001111");  
        #10           

        D = 12'b000110100110;
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);  
        $display("Expected output: 01011101");  
        #10   

        D = 12'b111001011010;
        #10;
        $display("D = %b, S = %b, E = %b, F = %b", D, S, E, F);  
        $display("Expected output: 11011101");  
        #10   
        // End of testbench
        $finish;
    end

endmodule
