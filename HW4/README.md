# HW4 — The Verilog Architect

An educational book on digital design: from logic gates to a minimal RISC-V processor, written in Verilog.

See the [main README](../README.md#hw4--the-verilog-architect) for a detailed explanation of the problem, approach, implementation, and design decisions.

## Structure

```
HW4/
├── docs/              # Book chapters (Markdown)
│   ├── chapter1-hardware-mindset.md
│   ├── chapter2-combinational-vs-sequential.md
│   ├── chapter3-building-alu.md
│   └── chapter4-riscv-instruction-set.md
└── code-examples/     # Verilog examples by chapter
    ├── ch1/           # adder, led_blinker
    ├── ch2/           # d_flip_flop, counter, shift_register, fsm_traffic_light
    ├── ch3/           # alu
    └── ch4/           # decoder, regfile, simple_riscv
```

## Quick Start

```bash
cd code-examples
iverilog -o output ch1/adder.v
vvp output
```
