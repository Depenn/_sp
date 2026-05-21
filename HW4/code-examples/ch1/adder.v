// adder.v
// Chapter 1: Demonstrates combinational logic, continuous assignments,
// blocking vs non-blocking concepts, and wire vs reg usage.

module adder #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH:0]   sum,     // WIDTH+1 bits to prevent overflow
    output wire             carry,
    output wire             overflow
);

    // Full addition with carry-out
    assign {carry, sum} = {1'b0, a} + {1'b0, b};

    // Signed overflow detection
    assign overflow = a[WIDTH-1] == b[WIDTH-1] && sum[WIDTH-1] != a[WIDTH-1];

endmodule

// Testbench
module adder_tb;
    parameter WIDTH = 8;

    reg  [WIDTH-1:0] a, b;
    wire [WIDTH:0]   sum;
    wire             carry, overflow;

    adder #(WIDTH) uut (
        .a(a), .b(b),
        .sum(sum),
        .carry(carry),
        .overflow(overflow)
    );

    initial begin
        $display("Adder Testbench (WIDTH=%0d)", WIDTH);
        $display("================================");
        $display("  a     b   |  sum   carry  overflow");
        $display("----------- + --------------------");

        // Test case 1: Simple addition
        a = 8'd50; b = 8'd30;
        #5;
        $display("  %03d + %03d |  %03d   %b      %b", a, b, sum, carry, overflow);

        // Test case 2: Carry out
        a = 8'd200; b = 8'd100;
        #5;
        $display("  %03d + %03d |  %03d   %b      %b", a, b, sum, carry, overflow);

        // Test case 3: Signed overflow (both negative -> positive result)
        a = 8'sd(-100); b = 8'sd(-80);
        #5;
        $display("  %03d + %03d |  %03d   %b      %b", $signed(a), $signed(b), $signed(sum), carry, overflow);

        // Test case 4: Signed overflow (both positive -> negative result)
        a = 8'sd(100); b = 8'sd(80);
        #5;
        $display("  %03d + %03d |  %03d   %b      %b", $signed(a), $signed(b), $signed(sum), carry, overflow);

        // Test case 5: No overflow (different signs)
        a = 8'sd(100); b = 8'sd(-50);
        #5;
        $display("  %03d + %03d |  %03d   %b      %b", $signed(a), $signed(b), $signed(sum), carry, overflow);

        $display("\nAll tests complete!");
        $finish;
    end
endmodule
