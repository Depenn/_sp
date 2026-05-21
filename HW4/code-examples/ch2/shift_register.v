// shift_register.v
// Chapter 2: Universal Shift Register - parallel load, serial in/out, shift left/right

module shift_register #(
    parameter WIDTH = 8
) (
    input  wire              clk,
    input  wire              reset,
    input  wire [1:0]        mode,       // 00=hold, 01=shift right, 10=shift left, 11=load
    input  wire              shift_in,   // Serial input (used for right shift)
    input  wire [WIDTH-1:0]  parallel_in,
    output wire [WIDTH-1:0]  parallel_out,
    output wire              shift_out   // Serial output
);

    reg [WIDTH-1:0] data;

    always @(posedge clk or posedge reset) begin
        if (reset)
            data <= {WIDTH{1'b0}};
        else begin
            case (mode)
                2'b00: data <= data;                        // Hold
                2'b01: data <= {shift_in, data[WIDTH-1:1]}; // Shift right
                2'b10: data <= {data[WIDTH-2:0], shift_in}; // Shift left
                2'b11: data <= parallel_in;                 // Parallel load
            endcase
        end
    end

    assign parallel_out = data;
    assign shift_out = (mode == 2'b01) ? data[0] :
                       (mode == 2'b10) ? data[WIDTH-1] :
                       1'b0;

endmodule

// Testbench
module shift_register_tb;
    parameter WIDTH = 8;

    reg              clk, reset, shift_in;
    reg  [1:0]       mode;
    reg  [WIDTH-1:0] parallel_in;
    wire [WIDTH-1:0] parallel_out;
    wire             shift_out;

    shift_register #(WIDTH) uut (
        .clk(clk),
        .reset(reset),
        .mode(mode),
        .shift_in(shift_in),
        .parallel_in(parallel_in),
        .parallel_out(parallel_out),
        .shift_out(shift_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Shift Register Testbench (WIDTH=%0d)", WIDTH);
        $display("========================================");
        $display("Time | mode |   data    | out");
        $display("-----+------+-----------+-----");

        // Reset
        reset = 1; mode = 2'b00; shift_in = 0;
        #10;
        reset = 0;
        $display("  %0d  |  %b   | %b | %b   (reset)", $time, mode, parallel_out, shift_out);

        // Parallel load
        mode = 2'b11; parallel_in = 8'b10101010;
        #10;
        mode = 2'b00;
        $display("  %0d  |  %b   | %b | %b   (loaded 10101010)", $time, mode, parallel_out, shift_out);

        // Shift right (with shift_in = 1)
        mode = 2'b01; shift_in = 1'b1;
        repeat (4) begin
            #10;
            $display("  %0d  |  %b   | %b | %b   (shift right)", $time, mode, parallel_out, shift_out);
        end

        // Shift left (with shift_in = 0)
        mode = 2'b10; shift_in = 1'b0;
        repeat (4) begin
            #10;
            $display("  %0d  |  %b   | %b | %b   (shift left)", $time, mode, parallel_out, shift_out);
        end

        // Hold
        mode = 2'b00;
        #10;
        $display("  %0d  |  %b   | %b | %b   (hold)", $time, mode, parallel_out, shift_out);

        $display("\nTest complete!");
        $finish;
    end
endmodule
