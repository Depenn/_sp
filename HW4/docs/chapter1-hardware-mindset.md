# Chapter 1: The Hardware Mindset

## Why Verilog is NOT C++

The biggest mistake beginners make is treating Verilog like a programming language. **It isn't.** Verilog is a *hardware description language*. The distinction is fundamental, and misunderstanding it is the root cause of most beginner bugs.

### The Key Difference: Parallelism vs. Sequential Execution

In C++, code executes line by line:

```c
int a = 5;
int b = a + 3;
a = 10;
// b is still 8 -- it was computed once, in order
```

In Verilog, **everything happens simultaneously**:

```verilog
wire a, b, c;
assign a = 1;
assign b = a + 3;
assign a = 2;  // ERROR in some contexts, or means a is driven by TWO sources
```

This isn't a "program" that runs top-to-bottom. This is a **circuit diagram written in text**. Every `assign` statement creates a physical wire. Every module creates a physical block of logic.

### The Mental Shift

| Software Thinking (Wrong) | Hardware Thinking (Right) |
|---------------------------|---------------------------|
| "This code will execute" | "This circuit will exist" |
| "Variables hold values" | "Wires carry signals" |
| "Functions compute results" | "Logic gates transform signals" |
| "Loops repeat operations" | "Loops generate replicated hardware" |
| "Time passes when I wait" | "Time is the clock signal" |

---

## How Synthesis Actually Works

Synthesis is the process of turning your Verilog into actual gates and flip-flops on a chip. Understanding this process is critical.

### The Synthesis Flow

```
Verilog Code
    |
    v
[Elaboration]    -- Resolves module hierarchy, evaluates parameters
    |
    v
[Translation]    -- Converts Verilog into an internal netlist representation
    |
    v
[Optimization]   -- Simplifies logic (removes dead code, merges gates)
    |
    v
[Technology Mapping] -- Maps logic to specific gates in the target library
    |
    v
Netlist (gates, flip-flops, connections)
```

### What This Means for You

When you write:

```verilog
wire out = a & b;
```

The synthesizer creates an **AND gate**. When you write:

```verilog
reg [3:0] counter;
always @(posedge clk) begin
    counter <= counter + 1;
end
```

The synthesizer creates **four D flip-flops** plus an **adder** plus a **multiplexer** (for the feedback).

**Rule of thumb:** Before writing any Verilog, sketch the circuit you want on paper. Then write code that describes that circuit.

---

## The First Rule of Hardware Design

> **Every signal must be defined in ALL cases.**

In C++, if you forget an `else` branch, the variable just isn't updated. In Verilog (combinational logic), an incomplete assignment creates a **latch** -- an unintended memory element. Latches are the number one cause of timing bugs in beginner designs.

### Example: The Latch Trap

```verilog
// BAD -- creates an inferred latch!
always @(*) begin
    if (sel)
        out = a;
    // What happens when sel is 0? The synthesizer creates a latch
    // to "remember" the previous value of out.
end
```

```verilog
// GOOD -- all cases covered
always @(*) begin
    if (sel)
        out = a;
    else
        out = b;
end
```

---

## Modules: The Building Blocks

A Verilog module is a physical block of hardware with inputs and outputs.

### Anatomy of a Module

```verilog
module example_module (
    input  wire       clk,        // Clock input
    input  wire       reset,      // Reset signal
    input  wire [7:0] data_in,    // 8-bit data input
    output reg  [7:0] data_out    // 8-bit registered output
);

    // Internal logic goes here

endmodule
```

**Key terms:**
- `input` / `output` -- direction of the port
- `wire` -- a physical wire (combinational)
- `reg` -- a storage element (used in procedural blocks)
- `[7:0]` -- a bus of 8 bits, MSB first (Verilog convention)

### Instantiating Modules

```verilog
module top_level (
    input  wire       clk,
    input  wire       button,
    output wire [3:0] leds
);

    // Instantiate a counter module
    counter uut (
        .clk(clk),
        .reset(button),
        .count(leds)
    );

endmodule
```

The `.clk(clk)` syntax means: connect the module's `clk` port to my local `clk` signal. This is called **named port connection** and is strongly preferred over positional connection.

---

## Data Types: wire vs reg

This is the most confusing topic for beginners. Here's the definitive guide:

### wire

- Represents a **physical wire**
- Cannot store a value
- Driven by `assign` statements or module outputs
- Used for combinational logic

```verilog
wire out;
assign out = a & b;  // out reflects the AND of a and b
```

### reg

- Represents a **storage element** (but not always!)
- Assigned inside `always` or `initial` blocks
- Does NOT automatically mean "flip-flop" -- the synthesizer decides based on context

```verilog
reg out;
always @(*) out = a & b;    // Still combinational! reg is just the syntax requirement
always @(posedge clk) out <= a & b;  // Sequential -- this becomes a flip-flop
```

### The Modern Approach (SystemVerilog / Verilog-2005+)

```verilog
logic out;  // Replaces both wire and reg
```

For this book, we'll use the classic `wire`/`reg` distinction since it makes the hardware intent clearer for learning.

---

## Numbers and Operators

### Number Literals

```verilog
8'b1010_1010    // 8-bit binary (underscores improve readability)
4'hA            // 4-bit hexadecimal
16'd255         // 16-bit decimal
32'hDEADBEEF    // 32-bit hexadecimal
-8'sd42         // 8-bit signed decimal (-42)
```

Format: `[width]'[base][value]`

Bases: `b` (binary), `h` (hex), `d` (decimal), `o` (octal)

### Operators

| Category | Operators | Notes |
|----------|-----------|-------|
| Arithmetic | `+`, `-`, `*`, `/`, `%` | Division/modulus are expensive in hardware |
| Bitwise | `&`, `|`, `^`, `~` | Operate on each bit pair |
| Logical | `&&`, `||`, `!` | Return single bit (true/false) |
| Reduction | `&a`, `|a`, `^a` | Collapse a bus to 1 bit |
| Shift | `<<`, `>>`, `<<<`, `>>>` | `<<<` and `>>>` are arithmetic (sign-preserving) |
| Concatenation | `{a, b}` | Join signals into wider bus |
| Replication | `{4{a}}` | Repeat `a` four times |

### Important: Bit-Width Matters

```verilog
wire [7:0] a, b;
wire [8:0] sum;

assign sum = a + b;  // WRONG -- a + b produces 8 bits, result may overflow
assign sum = a + b + 1'b0;  // Still 8-bit addition, then extended
assign sum = {1'b0, a} + {1'b0, b};  // CORRECT -- extend first, then add
```

---

## Continuous Assignments

`assign` statements create **combinational logic** that is always active:

```verilog
wire a, b, c, out;

assign out = (a & b) | c;  // This circuit ALWAYS evaluates this expression
```

Think of `assign` as soldering a gate between wires. The gate is always "on" -- there's no concept of "executing" the assignment.

### Tristate Buffers

```verilog
wire bus;
assign bus = enable ? data : 1'bz;  // 'z' = high impedance
```

The `z` value represents a disconnected wire. Multiple drivers can share a bus if only one drives at a time (others are `z`).

---

## Where Bugs Hide

### Bug #1: Inferred Latches
Covered above. Missing `else` or incomplete case statements in combinational blocks.

### Bug #2: Multiple Drivers
Driving the same `wire` from two places creates a short circuit.

```verilog
wire out;
assign out = a;
assign out = b;  // ERROR: out has two drivers
```

### Bug #3: Width Mismatch
```verilog
wire [3:0] small;
wire [7:0] big;
assign small = big;  // Silently truncates upper 4 bits
assign big = small;  // Pads upper 4 bits with zeros
```

### Bug #4: Blocking vs Non-Blocking Confusion
```verilog
// Sequential logic with blocking = ordering bug
always @(posedge clk) begin
    a = b;     // Blocking: happens immediately
    c = a;     // Gets NEW value of a, not old value
end

// Always use non-blocking (<=) for sequential logic
always @(posedge clk) begin
    a <= b;    // Non-blocking: scheduled for end of block
    c <= a;    // Gets OLD value of a
end
```

---

## Chapter 1 Summary

- Verilog describes **hardware**, not a sequence of instructions
- Every line of code maps to physical gates, wires, or storage elements
- Synthesis transforms your code into a netlist of components
- Complete assignments in all cases -- no latches allowed
- `wire` = physical wire, `reg` = procedural assignment target
- Bit widths matter -- extend before operating

### Next Chapter
In [Chapter 2](./chapter2-combinational-vs-sequential.md), we'll dive into the two fundamental categories of digital circuits and understand why clocks exist.
