// module mouse_controller(
//     input clock_100Mhz, // 100 MHz clock
//     input reset,        // Reset signal
//     input Mouse_Data,   // Mouse PS2 Data (noisy)
//     input Mouse_Clk,    // Mouse PS2 Clock
//     output reg [15:0] displayed_number // Output number to be displayed
//     );

//     reg [5:0] Mouse_bits;
//     wire debounced_mouse_data; // Debounced mouse data signal

//     // Instantiate debounce module
//     debounce debounce_mouse (
//         .clk(clock_100Mhz),
//         .reset(reset),
//         .noisy_signal(Mouse_Data),
//         .debounced_signal(debounced_mouse_data)
//     );

//     always @(posedge Mouse_Clk or posedge reset)
//     begin
//         if (reset)
//             Mouse_bits <= 0;
//         else if (Mouse_bits <= 31) 
//             Mouse_bits <= Mouse_bits + 1;
//         else 
//             Mouse_bits <= 0;
//     end

//     always @(negedge Mouse_Clk or posedge reset)
//     begin
//         if (reset)
//             displayed_number <= 0;
//         else begin
//             if (Mouse_bits == 1) begin
//                 if (debounced_mouse_data == 1)
//                     displayed_number <= displayed_number + 1;
//             end
//             else if (Mouse_bits == 2) begin
//                 if (debounced_mouse_data == 1 && displayed_number > 0)
//                     displayed_number <= displayed_number - 1;
//             end
//         end 
//     end    

// endmodule

module mouse_controller(
    input clock_100Mhz,
    input reset,
    input Mouse_Data,
    input Mouse_Clk,
    output reg [15:0] displayed_number
    );

    reg [5:0] Mouse_bits;
    wire debounced_mouse_data;

    debounce debounce_mouse (
        .clk(clock_100Mhz),
        .reset(reset),
        .noisy_signal(Mouse_Data),
        .debounced_signal(debounced_mouse_data)
    );

    always @(posedge Mouse_Clk or posedge reset)
    begin
        if (reset)
            Mouse_bits <= 0;
        else if (Mouse_bits <= 31) 
            Mouse_bits <= Mouse_bits + 1;
        else 
            Mouse_bits <= 0;
    end

    always @(negedge Mouse_Clk or posedge reset)
    begin
        if (reset)
            displayed_number <= 0;
        else begin
            if (Mouse_bits == 1) begin
                if (debounced_mouse_data == 1)
                    displayed_number <= displayed_number + 1;
            end
            else if (Mouse_bits == 2) begin
                if (debounced_mouse_data == 1 && displayed_number > 0)
                    displayed_number <= displayed_number - 1;
            end
        end 
    end    

endmodule
