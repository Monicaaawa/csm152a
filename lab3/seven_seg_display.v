module seven_seg_display(
    input clk_fast,
    input [3:0] sec_ones, sec_tens, min_ones, min_tens,
    output reg [3:0] an,
    output reg [6:0] seg
);
    reg [1:0] digit_sel = 0;
    reg [3:0] digit;

    always @(posedge clk_fast) begin
        digit_sel = digit_sel + 1;
    end

    always @(*) begin
        case (digit_sel)
            2'b00: begin an = 4'b1110; digit = sec_ones; end
            2'b01: begin an = 4'b1101; digit = sec_tens; end
            2'b10: begin an = 4'b1011; digit = min_ones; end
            2'b11: begin an = 4'b0111; digit = min_tens; end
        endcase
    end

    always @(*) begin
        case (digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end
endmodule
