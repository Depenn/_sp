# Chapter 2: Combinational vs Sequential Design

Digital circuits fall into two fundamental categories. Understanding the difference is the foundation of every hardware design decision.

## Combinational Logic: "Input Determines Output"

A combinational circuit has **no memory**. The output depends ONLY on the current inputs.

### Characteristics

- No clock signal
- No state
- Output appears after propagation delay (gate delays)
- Examples: adders, multiplexers, decoders, encoders

### The Multiplexer

The quintessential combinational circuit. It selects one of several inputs based on a selector signal.

```verilog
// 2-to-1 Multiplexer
module mux2to1 (
    input  wire       sel,
    input  wire       a,
    input  wire       b,
    output wire       out
);

    assign out = sel ? b : a;

endmodule
```

**Hardware:** This becomes a combination of AND, OR, and NOT gates. No flip-flops.

```verilog
// 4-to-1 Multiplexer using generate
module mux4to1 (
    input  wire       sel,    // 2-bit selector
    input  wire [3:0] inputs, // 4 inputs
    output wire       out
);

    assign out = (sel == 2'b00) ? inputs[0] :
                 (sel == 2'b01) ? inputs[1] :
                 (sel == 2'b10) ? inputs[2] :
                                   inputs[3];

endmodule
```

### The Decoder

Takes a binary input and activates exactly one output line.

```verilog
module decoder_2to4 (
    input  wire [1:0] sel,
    output reg  [3:0] out
);

    always @(*) begin
        out = 4'b0000;  // Default: all off
        case (sel)
            2'b00: out[0] = 1'b1;
            2'b01: out[1] = 1'b1;
            2'b10: out[2] = 1'b1;
            2'b11: out[3] = 1'b1;
        endcase
    end

endmodule
```

### Best Practice: Always Use Default Assignments

In combinational blocks, assign a default value FIRST, then override:

```verilog
always @(*) begin
    out = 4'b0000;  // Default prevents inferred latches
    if (enable)
        out = data;
end
```

---

## Sequential Logic: "Memory and Time"

Sequential circuits have **state**. The output depends on both current inputs AND previous values.

### The D Flip-Flop

The most basic sequential element. It captures the input value on a clock edge.

```verilog
module d_flip_flop (
    input  wire clk,
    input  wire d,
    output reg  q
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule
```

**Hardware:** This becomes a physical D flip-flop in the silicon. The `posedge clk` means it samples `d` only when the clock transitions from 0 to 1.

### Adding Reset

```verilog
module d_flip_flop_reset (
    input  wire clk,
    input  wire reset,
    input  wire d,
    output reg  q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 1'b0;  // Asynchronous reset
        else
            q <= d;
    end

endmodule
```

**Synchronous vs Asynchronous Reset:**
- **Asynchronous:** Reset can happen ANY time, even between clock edges. Hardware is slightly more complex.
- **Synchronous:** Reset only takes effect on the clock edge. Simpler timing, but reset must last at least one clock period.

```verilog
// Synchronous reset
always @(posedge clk) begin
    if (reset)
        q <= 1'b0;
    else
        q <= d;
end
```

### The Register

A "register" is just multiple D flip-flops grouped together.

```verilog
module register_8bit (
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  d,
    output reg  [7:0]  q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 8'b0;
        else
            q <= d;
    end

endmodule
```

---

## The Clock: Why It Exists

Without a clock, sequential circuits have no way to agree on when state changes. The clock provides a global rhythm that keeps everything synchronized.

### The Clock Domain

Everything within the same clock domain sees the same clock edge. Signals crossing between different clock domains require special handling (beyond scope of this chapter).

### Clock Frequency and Timing

```
Period = 1 / Frequency
```

- 100 MHz clock = 10 ns period
- 1 GHz clock = 1 ns period

Your entire circuit must compute its result within ONE clock period. This is called the **timing constraint**.

---

## Blocking vs Non-Blocking Assignments: The Definitive Guide

This is the #1 source of confusion in Verilog. Here's the rule:

> **Use blocking (`=`) for combinational logic. Use non-blocking (`<=`) for sequential logic.**

### Why Non-Blocking for Sequential?

```verilog
// WRONG: blocking in sequential
always @(posedge clk) begin
    a = b;   // a gets b's value NOW
    b = a;   // b gets a's NEW value (which was b's old value)
    // Result: a and b swap only if b != a
end

// CORRECT: non-blocking in sequential
always @(posedge clk) begin
    a <= b;  // Schedule: a will get b's OLD value
    b <= a;  // Schedule: b will get a's OLD value
    // Result: a and b swap correctly
end
```

Non-blocking assignments schedule updates for the END of the time step. All RHS values are evaluated simultaneously (like a parallel update).

### Simulation Order Independence

```verilog
// With non-blocking, order doesn't matter:
always @(posedge clk) begin
    a <= b;
    b <= a;
end

// Same as:
always @(posedge clk) begin
    b <= a;
    a <= b;
end
```

This matters because synthesis tools may reorder your code.

---

## Building Practical Sequential Circuits

### Counter

```verilog
module up_counter (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    output reg  [7:0]  count
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= 8'b0;
        else if (enable)
            count <= count + 1;
    end

endmodule
```

### Shift Register

```verilog
module shift_register (
    input  wire        clk,
    input  wire        reset,
    input  wire        shift_in,
    input  wire        load,
    input  wire [7:0]  parallel_in,
    output wire [7:0]  parallel_out
);

    reg [7:0] data;

    always @(posedge clk or posedge reset) begin
        if (reset)
            data <= 8'b0;
        else if (load)
            data <= parallel_in;
        else
            data <= {data[6:0], shift_in};  // Shift left
    end

    assign parallel_out = data;

endmodule
```

### Finite State Machine (FSM)

The structured way to design sequential control logic.

```verilog
module traffic_light (
    input  wire       clk,
    input  wire       reset,
    input  wire       sensor,   // Car waiting
    output reg  [1:0] light     // 00=red, 01=yellow, 10=green
);

    // State encoding
    localparam RED    = 2'b00;
    localparam YELLOW = 2'b01;
    localparam GREEN  = 2'b10;

    reg [1:0] state, next_state;

    // Sequential block: state register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= RED;
        else
            state <= next_state;
    end

    // Combinational block: next state logic
    always @(*) begin
        case (state)
            RED:    next_state = GREEN;  // Go to green immediately
            GREEN:  next_state = sensor ? GREEN : YELLOW;
            YELLOW: next_state = RED;
            default: next_state = RED;
        endcase
    end

    // Combinational block: output logic
    always @(*) begin
        light = state;  // Moore machine: output depends only on state
    end

endmodule
```

**Two-Style FSM:**
1. **Moore machine** (above): Outputs depend only on current state
2. **Mealy machine**: Outputs depend on current state AND inputs (faster response, but harder to reason about)

---

## The Golden Template: Always Follow This Structure

For every sequential circuit, use this three-block template:

```verilog
module example_fsm (
    input  wire       clk,
    input  wire       reset,
    input  wire       input_signal,
    output reg        output_signal
);

    reg state_reg;
    wire state_next;

    // Block 1: State register (sequential)
    always @(posedge clk or posedge reset) begin
        if (reset)
            state_reg <= RESET_VALUE;
        else
            state_reg <= state_next;
    end

    // Block 2: Next state logic (combinational)
    always @(*) begin
        // Compute state_next from state_reg and inputs
    end

    // Block 3: Output logic (combinational)
    always @(*) begin
        // Compute output_signal from state_reg (and possibly inputs)
    end

endmodule
```

---

## Where Bugs Hide

### Bug #1: Mixed Blocking and Non-Blocking

```verilog
// WRONG
always @(posedge clk) begin
    a = b;    // Blocking
    c <= a;   // Non-blocking with updated a
end
```

### Bug #2: Reading and Writing Same Register in Combinational Block

```verilog
// WRONG: this creates a latch because `total` depends on its previous value
always @(*) begin
    total = total + 1;  // total appears on both sides without clock
end
```

### Bug #3: Clock Domain Crossing

```verilog
// WRONG: signal crosses between different clock domains without synchronization
always @(posedge clk1) begin
    data_reg <= data;
end

assign data_out = data_reg;  // Read by clk2 domain -- needs synchronizer!
```

### Bug #4: Reset Not Asserted Long Enough

```verilog
// WRONG: if reset is asserted for only one cycle and is synchronous,
// and the system hasn't stabilized, state may be corrupted
always @(posedge clk) begin
    if (reset)
        state <= IDLE;
end
```

### Bug #5: Combinational Feedback Loop

```verilog
// WRONG: creates an infinite loop in simulation, oscillation in hardware
wire a, b;
assign a = ~b;
assign b = ~a;
```

---

## Chapter 2 Summary

- Combinational = no memory, output = function(inputs)
- Sequential = memory, output = function(inputs, previous state)
- Clock provides global synchronization
- Blocking (`=`) for combinational, non-blocking (`<=`) for sequential
- FSMs follow a three-block template: state register + next state logic + output logic
- Incomplete assignments in combinational blocks = inferred latches

### Next Chapter
In [Chapter 3](./chapter3-building-alu.md), we'll apply combinational and sequential design principles to build an Arithmetic Logic Unit from scratch.
