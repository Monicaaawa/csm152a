module Decoder(
    input clock_100Mhz,             // 100MHz onboard clock
    input [3:0] Row,       // Rows on Keypad
    output reg [3:0] Col,  // Columns on Keypad
    output reg [3:0] DecodeOut // Output decoded key
);

    reg [19:0] scan_clk; // Counter for timing column scan

    always @(posedge clock_100Mhz) begin
        case (scan_clk[19:18]) // Scan each column every ~1ms
            2'b00: Col <= 4'b0111; // Activate column 1
            2'b01: Col <= 4'b1011; // Activate column 2
            2'b10: Col <= 4'b1101; // Activate column 3
            2'b11: Col <= 4'b1110; // Activate column 4
        endcase

        // Decode key based on active column and detected row
        case (Col)
            4'b0111: begin // Column 1
                case (Row)
                    4'b0111: DecodeOut <= 4'h1; // 1
                    4'b1011: DecodeOut <= 4'h4; // 4
                    4'b1101: DecodeOut <= 4'h7; // 7
                    4'b1110: DecodeOut <= 4'h0; // 0
                    default: DecodeOut <= 4'hF; // No key
                endcase
            end
            4'b1011: begin // Column 2
                case (Row)
                    4'b0111: DecodeOut <= 4'h2; // 2
                    4'b1011: DecodeOut <= 4'h5; // 5
                    4'b1101: DecodeOut <= 4'h8; // 8
                    4'b1110: DecodeOut <= 4'hF; // F
                    default: DecodeOut <= 4'hF;
                endcase
            end
            4'b1101: begin // Column 3
                case (Row)
                    4'b0111: DecodeOut <= 4'h3; // 3
                    4'b1011: DecodeOut <= 4'h6; // 6
                    4'b1101: DecodeOut <= 4'h9; // 9
                    4'b1110: DecodeOut <= 4'hE; // E
                    default: DecodeOut <= 4'hF;
                endcase
            end
            4'b1110: begin // Column 4
                case (Row)
                    4'b0111: DecodeOut <= 4'hA; // A
                    4'b1011: DecodeOut <= 4'hB; // B
                    4'b1101: DecodeOut <= 4'hC; // C
                    4'b1110: DecodeOut <= 4'hD; // D
                    default: DecodeOut <= 4'hF;
                endcase
            end
            default: DecodeOut <= 4'hF;
        endcase

        scan_clk <= scan_clk + 1; // Increment scan clock
    end

endmodule
