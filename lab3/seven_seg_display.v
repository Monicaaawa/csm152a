module seven_seg_display(
    input clk_fast, clk_blink,
    input adj, sel,
    input [3:0] an,    
    input [3:0] sec_ones, sec_tens, min_ones, min_tens,
    output reg [6:0] seg
);
    reg blink = 0; 
    reg [3:0] digit;

    always @(posedge clk_blink) begin
        if (adj) begin
            blink <= ~blink;
        end else begin
            blink <= 0;
        end
    end

    always @ (posedge clk_fast) begin
        if (an == 4'b1110)
            digit <= sec_ones;
        else if (an == 4'b1101)
            digit <= sec_tens;
        else if (an == 4'b1011)
            digit <= min_ones;
        else if (an == 4'b0111)
            digit <= min_tens;

        if (adj && blink) begin
            seg = 7'b111_1111;
        end else begin
            case (digit)
                4'h0: seg = 7'b000_0001;
                4'h1: seg = 7'b100_1111;
                4'h2: seg = 7'b001_0010;
                4'h3: seg = 7'b000_0110;
                4'h4: seg = 7'b100_1100;
                4'h5: seg = 7'b010_0100;
                4'h6: seg = 7'b010_0000;
                4'h7: seg = 7'b000_1111;
                4'h8: seg = 7'b000_0000;
                4'h9: seg = 7'b000_0100;
            default: 
                seg = 7'b111_1111; // Blank
            endcase
        end
    end
endmodule
