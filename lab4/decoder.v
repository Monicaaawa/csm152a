module decoder(
    input clock_100Mhz,             // 100MHz onboard clock
    input [3:0] row,       // rows on Keypad
    output reg [3:0] col,  // columns on Keypad
    output reg [3:0] dec_out // Output decoded key
);

    reg [19:0] scan_clk; // Counter for timing column scan

    always @(posedge clock_100Mhz) begin
        case (scan_clk[19:18]) // Scan each column every ~1ms
            2'b00: col <= 4'b0111; // Activate column 1
            2'b01: col <= 4'b1011; // Activate column 2
            2'b10: col <= 4'b1101; // Activate column 3
            2'b11: col <= 4'b1110; // Activate column 4
        endcase

        // Decode key based on active column and detected row
        case (col)
            4'b0111: begin // column 1
                case (row)
                    4'b0111: dec_out <= 4'h1; // 1
                    4'b1011: dec_out <= 4'h4; // 4
                    4'b1101: dec_out <= 4'h7; // 7
                    4'b1110: dec_out <= 4'h0; // 0
                    default: dec_out <= 4'hF; // No key
                endcase
            end
            4'b1011: begin // column 2
                case (row)
                    4'b0111: dec_out <= 4'h2; // 2
                    4'b1011: dec_out <= 4'h5; // 5
                    4'b1101: dec_out <= 4'h8; // 8
                    default: dec_out <= 4'hF;
                endcase
            end
            4'b1101: begin // column 3
                case (row)
                    4'b0111: dec_out <= 4'h3; // 3
                    4'b1011: dec_out <= 4'h6; // 6
                    4'b1101: dec_out <= 4'h9; // 9
                    default: dec_out <= 4'hF;
                endcase
            end
            default: dec_out <= 4'hF;
        endcase

        scan_clk <= scan_clk + 1; // Increment scan clock
    end

endmodule