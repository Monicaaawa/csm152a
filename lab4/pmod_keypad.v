module pmod_keypad(
    input clk,
    input [3:0] keypad_in,
    output reg [3:0] key_out
);

always @(posedge clk) begin
    case (keypad_in)
        4'b0001: key_out = 4'h1;
        4'b0010: key_out = 4'h2;
        4'b0100: key_out = 4'h3;
        4'b1000: key_out = 4'h4;
        default: key_out = 4'h0;
    endcase
end

endmodule
