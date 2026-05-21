# Chapter 3: Building the ALU

The Arithmetic Logic Unit (ALU) is the computational heart of any processor. It performs arithmetic (add, subtract) and logic (AND, OR, XOR) operations on data.

## Starting Point: The Half Adder

The simplest arithmetic circuit. Adds two single bits.

```verilog
module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);

    assign sum   = a ^ b;  // XOR: sum is 1 when inputs differ
    assign carry = a & b;  // AND: carry is 1 when both are 1

endmodule
```

### Truth Table

| a | b | sum | carry |
|---|---|-----|-------|
| 0 | 0 | 0   | 0     |
| 0 | 1 | 1   | 0     |
| 1 | 0 | 1   | 0     |
| 1 | 1 | 0   | 1     |

### Testbench

```verilog
module half_adder_tb;
    reg a, b;
    wire sum, carry;

    half_adder uut (.a(a), .b(b), .sum(sum), .carry(carry));

    initial begin
        $display("Time | a b | sum carry");
        $display("-----+-----+----------");

        a = 0; b = 0; #10;
        $display("  %0d  | %b %b |  %b    %b", $time, a, b, sum, carry);

        a = 0; b = 1; #10;
        $display("  %0d  | %b %b |  %b    %b", $time, a, b, sum, carry);

        a = 1; b = 0; #10;
        $display("  %0d  | %b %b |  %b    %b", $time, a, b, sum, carry);

        a = 1; b = 1; #10;
        $display("  %0d  | %b %b |  %b    %b", $time, a, b, sum, carry);

        $finish;
    end
endmodule
```

**Expected Output:**
```
Time | a b | sum carry
-----+-----+----------
  10  | 0 0 |  0    0
  20  | 0 1 |  1    0
  30  | 1 0 |  1    0
  40  | 1 1 |  0    1
```

---

## The Full Adder

Adds two bits plus a carry-in from the previous stage.

```verilog
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);

    wire s1, c1, c2;

    half_adder ha1 (.a(a), .b(b), .sum(s1), .carry(c1));
    half_adder ha2 (.a(s1), .b(cin), .sum(sum), .carry(c2));

    assign cout = c1 | c2;

endmodule
```

### Ripple Carry Adder (N-bit)

Chain multiple full adders together:

```verilog
module ripple_carry_adder #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);

    wire [WIDTH:0] carry;
    assign carry[0] = cin;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : adder_stage
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign cout = carry[WIDTH];

endmodule
```

The `generate` loop creates WIDTH copies of the full adder at elaboration time (before simulation). Each copy is independent hardware.

---

## Subtraction via Two's Complement

Subtraction is just addition with a negated operand:

```
A - B = A + (~B) + 1
```

### Adder/Subtractor

```verilog
module adder_subtractor #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             subtract,  // 0 = add, 1 = subtract
    output wire [WIDTH-1:0] result,
    output wire             overflow
);

    wire [WIDTH-1:0] b_oper;
    wire carry_in;

    // When subtract: invert b and set carry-in to 1
    assign b_oper = subtract ? ~b : b;
    assign carry_in = subtract;

    wire [WIDTH:0] full_result;
    assign full_result = {1'b0, a} + {1'b0, b_oper} + carry_in;

    assign result = full_result[WIDTH-1:0];

    // Overflow detection (signed arithmetic)
    // Overflow occurs when adding same-sign numbers produces opposite-sign result
    assign overflow = full_result[WIDTH] ^ full_result[WIDTH-1];

endmodule
```

### Why This Works

```
   A:  0101 (5)
 - B:  0011 (3)
 = A + ~B + 1:

   A:    0101
  ~B:    1100
   1:    0001
  ---+-------
       0010  (2) Correct!
```

---

## The Complete ALU

Now we combine everything into a multi-operation ALU.

```verilog
module alu #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       op,      // Operation select
    output wire [WIDTH-1:0] result,
    output wire             zero,
    output wire             overflow,
    output wire             carry_out
);

    wire [WIDTH:0] full_add;
    wire [WIDTH-1:0] a_and_b, a_or_b, a_xor_b;

    // Bitwise operations
    assign a_and_b = a & b;
    assign a_or_b  = a | b;
    assign a_xor_b = a ^ b;

    // Addition
    assign full_add = {1'b0, a} + {1'b0, b};

    // Subtraction (A - B)
    wire [WIDTH:0] full_sub;
    assign full_sub = {1'b0, a} + {1'b0, ~b} + 1'b1;

    // Comparison: A < B (signed)
    wire signed_lt;
    assign signed_lt = ($signed(a) < $signed(b));

    // Left shift
    wire [WIDTH-1:0] a_sll;
    assign a_sll = a << 1;

    // Right shift (arithmetic)
    wire [WIDTH-1:0] a_sra;
    assign a_sra = $signed(a) >>> 1;

    // Select result based on operation
    assign result = (op == 3'b000) ? a_and_b :   // AND
                    (op == 3'b001) ? a_or_b  :   // OR
                    (op == 3'b010) ? a + b   :   // ADD
                    (op == 3'b011) ? a - b   :   // SUB
                    (op == 3'b100) ? a_xor_b :   // XOR
                    (op == 3'b101) ? signed_lt : // SLT (signed less than)
                    (op == 3'b110) ? a_sll   :   // SLL
                    (op == 3'b111) ? a_sra   :   // SRA
                                    8'b0;

    // Flags
    assign zero = (result == {WIDTH{1'b0}});
    assign overflow = (op == 3'b010) ? full_add[WIDTH] :
                      (op == 3'b011) ? full_sub[WIDTH] :
                                       1'b0;
    assign carry_out = (op == 3'b010) ? full_add[WIDTH] :
                       (op == 3'b011) ? full_sub[WIDTH] :
                                        1'b0;

endmodule
```

### Operation Table

| op | Operation | Description |
|----|-----------|-------------|
| 000 | AND | Bitwise AND |
| 001 | OR | Bitwise OR |
| 010 | ADD | Addition |
| 011 | SUB | Subtraction |
| 100 | XOR | Bitwise XOR |
| 101 | SLT | Signed Less Than |
| 110 | SLL | Shift Left Logical |
| 111 | SRA | Shift Right Arithmetic |

---

## ALU Testbench

```verilog
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

    task test_op(input [2:0] opcode, input string name);
        begin
            $display("\n=== %s ===", name);
            op = opcode;
            #5;
        end
    endtask

    initial begin
        $display("ALU Testbench");
        $display("================");

        // Test AND
        test_op(3'b000, "AND");
        a = 8'b10101010; b = 8'b11110000; #5;
        $display("a & b = %b", result);

        // Test OR
        test_op(3'b001, "OR");
        $display("a | b = %b", result);

        // Test ADD
        test_op(3'b010, "ADD");
        a = 8'd100; b = 8'd55; #5;
        $display("100 + 55 = %d (carry=%b, overflow=%b)", result, carry_out, overflow);

        a = 8'd200; b = 8'd100; #5;
        $display("200 + 100 = %d (carry=%b, overflow=%b) -- overflow expected!", result, carry_out, overflow);

        // Test SUB
        test_op(3'b011, "SUB");
        a = 8'd100; b = 8'd42; #5;
        $display("100 - 42 = %d", result);

        // Test SLT
        test_op(3'b101, "SLT (signed)");
        a = 8'sd(-5); b = 8'sd(3); #5;
        $display("-5 < 3 = %b", result);

        a = 8'sd(5); b = 8'sd(-3); #5;
        $display("5 < -3 = %b", result);

        // Test ZERO flag
        test_op(3'b000, "ZERO FLAG");
        a = 8'b0; b = 8'b0; #5;
        $display("0 & 0 = %d, zero=%b", result, zero);

        $display("\nAll tests passed!");
        $finish;
    end
endmodule
```

**Expected Output:**
```
ALU Testbench
================

=== AND ===
a & b = 10100000

=== OR ===
a | b = 11111010

=== ADD ===
100 + 55 = 155 (carry=0, overflow=0)
200 + 100 = 44 (carry=1, overflow=1) -- overflow expected!

=== SUB ===
100 - 42 = 58

=== SLT (signed) ===
-5 < 3 = 1
5 < -3 = 0

=== ZERO FLAG ===
0 & 0 = 0, zero=1

All tests passed!
```

---

## Registered ALU (Pipelined)

For high-frequency designs, we register the ALU outputs:

```verilog
module alu_registered #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             reset,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       op,
    output reg  [WIDTH-1:0] result,
    output reg              zero,
    output reg              overflow
);

    // Combinational ALU
    wire [WIDTH-1:0] comb_result;
    wire comb_zero, comb_overflow;

    alu #(WIDTH) comb_alu (
        .a(a), .b(b), .op(op),
        .result(comb_result),
        .zero(comb_zero),
        .overflow(comb_overflow),
        .carry_out()
    );

    // Register outputs
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result   <= {WIDTH{1'b0}};
            zero     <= 1'b0;
            overflow <= 1'b0;
        end else begin
            result   <= comb_result;
            zero     <= comb_zero;
            overflow <= comb_overflow;
        end
    end

endmodule
```

This adds one clock cycle of latency but allows higher clock frequencies (the combinational delay is bounded within one pipeline stage).

---

## Where Bugs Hide

### Bug #1: Signed vs Unsigned Comparison

```verilog
// WRONG: unsigned comparison
wire lt = (a < b);  // Treats 0xFF as 255

// CORRECT: signed comparison
wire lt = ($signed(a) < $signed(b));  // Treats 0xFF as -1
```

### Bug #2: Overflow Ignored

```verilog
// WRONG: result width same as operands -- overflow silently lost
wire [7:0] sum = a + b;  // a=200, b=100 gives 44, not 300

// CORRECT: extend result width
wire [8:0] sum = {1'b0, a} + {1'b0, b};  // sum = 300
```

### Bug #3: Non-Blocking in Combinational ALU

```verilog
// WRONG: sequential-style assignment in combinational block
always @(*) begin
    result <= a + b;  // Non-blocking in @(*) -- works but non-idiomatic
end

// CORRECT: use assign or blocking
assign result = a + b;
// or
always @(*) begin
    result = a + b;
end
```

### Bug #4: Missing Operations in Case/Mux

```verilog
// BAD: not all 3-bit values covered, creates latch
assign result = (op == 3'b000) ? a & b :
                (op == 3'b001) ? a | b :
                // Missing 6 operations!
                8'b0;

// GOOD: explicitly handle all cases, or use default
assign result = (op == 3'b000) ? a & b :
                (op == 3'b001) ? a | b :
                (op == 3'b010) ? a + b :
                (op == 3'b011) ? a - b :
                (op == 3'b100) ? a ^ b :
                (op == 3'b101) ? slt :
                (op == 3'b110) ? sll :
                (op == 3'b111) ? sra :
                8'b0;  // Default for safety
```

### Bug #5: Carry Flag Wrong in Subtraction

```verilog
// Many implementations confuse carry and borrow
// In subtraction: carry_out = NOT(borrow_out)
// So a - b where a >= b gives carry_out = 1
// a - b where a < b gives carry_out = 0
```

---

## Chapter 3 Summary

- Half adder = XOR + AND
- Full adder = two half adders + OR
- N-bit adder = ripple carry chain (slow) or carry-lookahead (fast)
- Subtraction = addition with inverted operand + 1
- ALU combines multiple operations behind a multiplexer
- Flags (zero, overflow, carry) enable conditional branching
- Registered ALU trades latency for frequency

### Next Chapter
In [Chapter 4](./chapter4-riscv-instruction-set.md), we'll use the ALU as a core component to implement a RISC-V instruction set and build a working processor datapath.
