module debouncer(
    input clk,
    input button,
    output reg stable
);
    reg [15:0] counter = 0;
    reg button_state = 0;

    always @(posedge clk) begin
        if (button == button_state) begin
            counter = 0;
        end else begin
            counter = counter + 1;
            if (counter == 65535) begin
                button_state = button;
                stable = button;
            end
        end
    end
endmodule
