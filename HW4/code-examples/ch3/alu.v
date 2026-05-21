// alu.v
// Chapter 3: Full ALU with 8 operations and flags

module alu #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       op,
    output wire [WIDTH-1:0] result,
    output wire             zero,
    output wire             overflow,
    output wire             carry_out
);

    wire [WIDTH:0] full_add;
    wire [WIDTH:0] full_sub;
    wire [WIDTH-1:0] a_and_b, a_or_b, a_xor_b;

    assign a_and_b = a & b;
    assign a_or_b  = a | b;
    assign a_xor_b = a ^ b;

    // Addition with carry
    assign full_add = {1'b0, a} + {1'b0, b};

    // Subtraction via two's complement
    assign full_sub = {1'b0, a} + {1'b0, ~b} + 1'b1;

    // Comparison: signed less than
    wire signed_lt;
    assign signed_lt = ($signed(a) < $signed(b));

    // Shifts
    wire [WIDTH-1:0] a_sll;
    wire [WIDTH-1:0] a_sra;
    assign a_sll = a << 1;
    assign a_sra = $signed(a) >>> 1;

    // Result selection
    assign result = (op == 3'b000) ? a_and_b :
                    (op == 3'b001) ? a_or_b  :
                    (op == 3'b010) ? full_add[WIDTH-1:0] :
                    (op == 3'b011) ? full_sub[WIDTH-1:0] :
                    (op == 3'b100) ? a_xor_b :
                    (op == 3'b101) ? {WIDTH-1{1'b0}, signed_lt} :
                    (op == 3'b110) ? a_sll   :
                    (op == 3'b111) ? a_sra   :
                    {WIDTH{1'b0}};

    // Flags
    assign zero = (result == {WIDTH{1'b0}});

    assign overflow = (op == 3'b010) ? full_add[WIDTH] ^ full_add[WIDTH-1] :
                      (op == 3'b011) ? full_sub[WIDTH] ^ full_sub[WIDTH-1] :
                      1'b0;

    assign carry_out = (op == 3'b010) ? full_add[WIDTH] :
                       (op == 3'b011) ? ~full_sub[WIDTH] :  // borrow = NOT carry
                       1'b0;

endmodule

// Testbench
module alu_tb;
    parameter WIDTH = 8;

    reg  [WIDTH-1:0] a, b;
    reg  [2:0]       op;
    wire [WIDTH-1:0] result;
    wire             zero, overflow, carry_out;

    alu #(WIDTH) uut (
        .a(a), .b(b), .op(op),
        .result(result),
        .zero(zero),
        .overflow(overflow),
        .carry_out(carry_out)
    );

    initial begin
        $display("ALU Testbench");
        $display("================");

        // AND
        $display("\n=== AND (op=000) ===");
        op = 3'b000; a = 8'b10101010; b = 8'b11110000;
        #5; $display("a & b = %b (expected: 10100000)", result);

        // OR
        $display("\n=== OR (op=001) ===");
        op = 3'b001;
        #5; $display("a | b = %b (expected: 11111010)", result);

        // ADD
        $display("\n=== ADD (op=010) ===");
        op = 3'b010; a = 8'd100; b = 8'd55;
        #5; $display("100 + 55 = %d, carry=%b, overflow=%b", result, carry_out, overflow);

        a = 8'd200; b = 8'd100;
        #5; $display("200 + 100 = %d, carry=%b, overflow=%b (overflow expected!)", result, carry_out, overflow);

        // SUB
        $display("\n=== SUB (op=011) ===");
        op = 3'b011; a = 8'd100; b = 8'd42;
        #5; $display("100 - 42 = %d", result);

        a = 8'd10; b = 8'd50;
        #5; $display("10 - 50 = %d (unsigned), carry=%b", result, carry_out);

        // XOR
        $display("\n=== XOR (op=100) ===");
        op = 3'b100; a = 8'hFF; b = 8'h55;
        #5; $display("FF ^ 55 = %h (expected: aa)", result);

        // SLT (signed)
        $display("\n=== SLT (op=101) ===");
        op = 3'b101; a = 8'sd(-5); b = 8'sd(3);
        #5; $display("-5 < 3 = %b (expected: 1)", result[0]);

        a = 8'sd(5); b = 8'sd(-3);
        #5; $display("5 < -3 = %b (expected: 0)", result[0]);

        // SLL
        $display("\n=== SLL (op=110) ===");
        op = 3'b110; a = 8'b00001111;
        #5; $display("%b << 1 = %b", a, result);

        // SRA (arithmetic, preserves sign)
        $display("\n=== SRA (op=111) ===");
        op = 3'b111; a = 8'b10000000;
        #5; $display("%b >>> 1 = %b (sign preserved)", a, result);

        // ZERO flag
        $display("\n=== ZERO FLAG ===");
        op = 3'b000; a = 8'b0; b = 8'b0;
        #5; $display("0 & 0 = %d, zero=%b", result, zero);

        $display("\nAll tests complete!");
        $finish;
    end
endmodule
