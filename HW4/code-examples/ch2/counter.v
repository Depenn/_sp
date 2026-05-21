// counter.v
// Chapter 2: Up/Down Counter with enable and load

module counter #(
    parameter WIDTH = 8
) (
    input  wire              clk,
    input  wire              reset,
    input  wire              enable,
    input  wire              up_down,    // 1 = up, 0 = down
    input  wire              load,
    input  wire [WIDTH-1:0]  load_value,
    output wire [WIDTH-1:0]  count,
    output wire              zero,
    output wire              overflow
);

    reg [WIDTH-1:0] count_reg;

    always @(posedge clk or posedge reset) begin
        if (reset)
            count_reg <= {WIDTH{1'b0}};
        else if (load)
            count_reg <= load_value;
        else if (enable) begin
            if (up_down)
                count_reg <= count_reg + 1;
            else
                count_reg <= count_reg - 1;
        end
    end

    assign count = count_reg;
    assign zero = (count_reg == {WIDTH{1'b0}});
    assign overflow = (up_down && count_reg == {WIDTH{1'b1}}) ||
                      (!up_down && count_reg == {WIDTH{1'b0}});

endmodule

// Testbench
module counter_tb;
    parameter WIDTH = 4;

    reg             clk, reset, enable, up_down, load;
    reg  [WIDTH-1:0] load_value;
    wire [WIDTH-1:0] count;
    wire             zero, overflow;

    counter #(WIDTH) uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .up_down(up_down),
        .load(load),
        .load_value(load_value),
        .count(count),
        .zero(zero),
        .overflow(overflow)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Counter Testbench (WIDTH=%0d)", WIDTH);
        $display("=================================");
        $display("Time | count | zero | overflow");
        $display("-----+-------+------+----------");

        // Reset
        reset = 1; enable = 0; load = 0; up_down = 1;
        #10;
        reset = 0; enable = 1;
        $display("  %0d  |  %02d   |  %b   |   %b      (reset, start counting up)", $time, count, zero, overflow);

        // Count up
        repeat (5) begin
            #10;
            $display("  %0d  |  %02d   |  %b   |   %b", $time, count, zero, overflow);
        end

        // Count down
        up_down = 0;
        $display("  %0d  |  %02d   |  %b   |   %b      (switch to counting down)", $time, count, zero, overflow);

        repeat (5) begin
            #10;
            $display("  %0d  |  %02d   |  %b   |   %b", $time, count, zero, overflow);
        end

        // Load value
        load = 1; load_value = 4'd12; up_down = 1;
        #10;
        load = 0;
        $display("  %0d  |  %02d   |  %b   |   %b      (loaded 12)", $time, count, zero, overflow);

        repeat (4) begin
            #10;
            $display("  %0d  |  %02d   |  %b   |   %b", $time, count, zero, overflow);
        end

        $display("\nTest complete!");
        $finish;
    end
endmodule
