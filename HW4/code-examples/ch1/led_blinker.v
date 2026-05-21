// led_blinker.v
// Chapter 1: Simple LED blinker - demonstrates basic module structure
// This is the "Hello World" of hardware design.

module led_blinker (
    input  wire       clk,
    input  wire       reset,
    output reg  [3:0] leds
);

    reg [27:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 28'b0;
            leds    <= 4'b0001;
        end else begin
            counter <= counter + 1;
            if (counter == 28'hFFFFFFF) begin
                leds <= {leds[2:0], leds[3]};  // Rotate left
            end
        end
    end

endmodule
