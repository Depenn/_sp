// d_flip_flop.v
// Chapter 2: D Flip-Flop variants - async reset, sync reset, enable

// Basic D Flip-Flop
module dff (
    input  wire clk,
    input  wire d,
    output reg  q
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule

// D Flip-Flop with Asynchronous Reset
module dff_async_reset (
    input  wire clk,
    input  wire reset,
    input  wire d,
    output reg  q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 1'b0;
        else
            q <= d;
    end

endmodule

// D Flip-Flop with Synchronous Reset
module dff_sync_reset (
    input  wire clk,
    input  wire reset,
    input  wire d,
    output reg  q
);

    always @(posedge clk) begin
        if (reset)
            q <= 1'b0;
        else
            q <= d;
    end

endmodule

// D Flip-Flop with Enable
module dff_enable (
    input  wire clk,
    input  wire reset,
    input  wire enable,
    input  wire d,
    output reg  q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 1'b0;
        else if (enable)
            q <= d;
    end

endmodule

// Testbench
module dff_tb;
    reg clk, reset, d, enable;
    wire q_async, q_sync, q_en;

    dff_async_reset uut_async (.clk(clk), .reset(reset), .d(d), .q(q_async));
    dff_sync_reset  uut_sync  (.clk(clk), .reset(reset), .d(d), .q(q_sync));
    dff_enable      uut_en    (.clk(clk), .reset(reset), .enable(enable), .d(d), .q(q_en));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("D Flip-Flop Testbench");
        $display("=====================");
        $display("Time | d | Q_async | Q_sync | Q_enable");
        $display("-----+---+---------+--------+----------");

        // Initialize
        reset = 1; d = 0; enable = 0;
        #10;
        $display("  %0d  | %b |    %b    |   %b    |    %b     (reset asserted)", $time, d, q_async, q_sync, q_en);

        // Deassert reset
        reset = 0; d = 1; enable = 1;
        #10;
        $display("  %0d  | %b |    %b    |   %b    |    %b     (d=1, enable=1)", $time, d, q_async, q_sync, q_en);

        // Change d
        d = 0;
        #10;
        $display("  %0d  | %b |    %b    |   %b    |    %b     (d=0)", $time, d, q_async, q_sync, q_en);

        // Disable enable, change d
        enable = 0; d = 1;
        #10;
        $display("  %0d  | %b |    %b    |   %b    |    %b     (enable=0, d=1 -- Q_en should not change)", $time, d, q_async, q_sync, q_en);

        // Re-enable, d=1
        enable = 1;
        #10;
        $display("  %0d  | %b |    %b    |   %b    |    %b     (enable=1, d=1)", $time, d, q_async, q_sync, q_en);

        $display("\nTest complete!");
        $finish;
    end
endmodule
