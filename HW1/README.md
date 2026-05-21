# HW1 — p0 Compiler & Virtual Machine

A compiler and virtual machine for the p0 language, written in C.

See the [main README](../README.md#hw1--p0-compiler--virtual-machine) for a detailed explanation of the problem, approach, implementation, and design decisions.

## Files

| File | Purpose |
|------|---------|
| `compiler.c` | Single-file compiler + VM implementation |
| `design.md` | While-statement design principles and backpatching |
| `function_call.md` | Function call mechanism and stack frame isolation |
| `p0/` | Example p0 programs (`while.p0`, `recursive.p0`) |
| `reference/` | Reference implementations (Rust version, alternative C, BNF grammar) |

## Quick Start

```bash
gcc -o compiler compiler.c
./compiler p0/while.p0
```
