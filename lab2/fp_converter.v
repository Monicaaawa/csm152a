module PriorityEncoder (
    input [11:0] magnitude,
    output reg [3:0] leading_zeros
);
    always @(*) begin
        casez (magnitude)
            12'b1???????????: leading_zeros = 4'd0;
            12'b01??????????: leading_zeros = 4'd1;
            12'b001?????????: leading_zeros = 4'd2;
            12'b0001????????: leading_zeros = 4'd3;
            12'b00001???????: leading_zeros = 4'd4;
            12'b000001??????: leading_zeros = 4'd5;
            12'b0000001?????: leading_zeros = 4'd6;
            12'b00000001????: leading_zeros = 4'd7;
            12'b000000001???: leading_zeros = 4'd8;
            12'b0000000001??: leading_zeros = 4'd9;
            12'b00000000001?: leading_zeros = 4'd10;
            12'b000000000001: leading_zeros = 4'd11;
            default:          leading_zeros = 4'd12;
        endcase
    end
endmodule

module FloatingPointConverter (
    input [11:0] D,   // Input number
    output S,         // Sign bit
    output [2:0] E,   // Exponent
    output [3:0] F    // Fraction
);

    wire [11:0] magnitude;
    wire [3:0] leading_zeros;
    reg [2:0] exponent;
    reg [3:0] rounded_fraction;
    wire [3:0] leading_bits;
    wire fifth_bit;

    // Convert to 2's complement
    assign S = D[11]; // Sign bit
    assign magnitude = S ? (~D[11:0] + 1) : D[11:0];

    // Count leading zeros
    PriorityEncoder pe (
        .magnitude(magnitude),
        .leading_zeros(leading_zeros)
    );

    always @(*) begin
        if (leading_zeros < 8)
            exponent = 3'b111 - leading_zeros + 1;
        else
            exponent = 3'b000;
    end

    assign leading_bits = magnitude[11 - leading_zeros -: 4];
    assign fifth_bit = magnitude[11 - leading_zeros - 4];

    always @(*) begin
        if (fifth_bit) begin
            if (leading_bits == 4'b1111) begin
                if (exponent == 3'b111) begin
                    exponent = 3'b111;
                    rounded_fraction = 4'b1111;
                end else begin
                    exponent = exponent + 1;
                    rounded_fraction = 4'b1000;
                end
            end else begin
                rounded_fraction = leading_bits + 1;
            end
        end else begin
            rounded_fraction = leading_bits;
        end
    end

    assign E = exponent;
    assign F = rounded_fraction;
endmodule


`timescale 1ns / 1ps
module FloatingPointConverter_tb;
    reg [11:0] D;             // Test input number
    wire S;                   // Output sign bit
    wire [2:0] E;             // Output exponent
    wire [3:0] F;             // Output fraction

    // Instantiate the FloatingPointConverter module
    FloatingPointConverter uut (
        .D(D),
        .S(S),
        .E(E),
        .F(F)
    );

    initial begin
        $display("Time\t\tD\t\tS\tE\tF");
        $monitor("%0t\t%0d\t%b\t%b\t%b", $time, D, S, E, F);

        // Test Cases
        D = 12'b000000000001; // Smallest positive number
        #10;
        D = 12'b111111111111; // Largest negative number (2's complement)
        #10;
        D = 12'b011111111111; // Largest positive number
        #10;
        D = 12'b000000000000; // Zero
        #10;
        D = 12'b000000101100;
        #10;
        D = 12'b000000101101;
        #10;
        D = 12'b000000101110;
        #10;
        D = 12'b000000101111;
        #10;

        // Test Overflow Handling
        D = 12'b011111111111; // Should produce the largest floating-point representation
        #10;

        // End Simulation
        $finish;
    end
endmodule