# HW7 — verilog0c: Verilog-to-C Translator

A translator that converts a synthesizable Verilog subset into equivalent C programs for simulation.

See the [main README](../README.md#hw7--verilog0c-verilog-to-c-translator) for a detailed explanation of the problem, approach, implementation, and design decisions.

## Files

| File | Purpose |
|------|---------|
| `verilog0c.c` | Entry point |
| `lexer.c` / `lexer.h` | Verilog tokenizer |
| `parser.c` / `parser.h` | Recursive-descent Verilog parser |
| `ast.c` / `ast.h` | AST node types and tree management |
| `codegen.c` / `codegen.h` | C code generator |
| `vrun.sh` | Script: translate `.v` → `.c`, compile, run |
| `test.sh` | Batch test runner |
| `v/` | Test designs: halfadder, fulladder, comparator, mux2to1, mcu0m CPU |
| `_version/` | Archived development versions (v0.1, v0.2) |
| `_doc/` | Verilog subset EBNF grammar |

## Quick Start

```bash
cd verilog0c
gcc ast.c codegen.c lexer.c parser.c verilog0c.c -o verilog0c
./vrun.sh halfadder
```
