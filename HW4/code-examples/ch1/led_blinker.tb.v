// led_blinker.tb.v
// Testbench for led_blinker

`timescale 1ns / 1ns

module led_blinker_tb;
    reg clk, reset;
    wire [3:0] leds;

    led_blinker uut (
        .clk(clk),
        .reset(reset),
        .leds(leds)
    );

    // Clock generation: 10ns period = 100 MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        $display("LED Blinker Testbench");
        $display("=====================");

        // Apply reset
        reset = 1;
        #20;
        reset = 0;

        $display("Time (ns) | LEDs");
        $display("--------+------");

        // Wait and observe LED rotation
        #100;
        $display("  %0d    | %b", $time, leds);

        #100;
        $display("  %0d    | %b", $time, leds);

        #100;
        $display("  %0d    | %b", $time, leds);

        #100;
        $display("  %0d    | %b", $time, leds);

        #100;
        $display("  %0d    | %b", $time, leds);

        #100;
        $display("  %0d    | %b", $time, leds);

        $display("\nTest complete!");
        $finish;
    end

    initial begin
        $dumpfile("led_blinker.vcd");
        $dumpvars(0, led_blinker_tb);
    end
endmodule
