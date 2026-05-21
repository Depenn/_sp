# HW2 — SimpleCalc Interpreter

A tree-walk interpreter for the SimpleCalc language, written in Python.

See the [main README](../README.md#hw2--simplecalc-interpreter) for a detailed explanation of the problem, approach, implementation, and design decisions.

## Files

| File | Purpose |
|------|---------|
| `lexer.py` | Tokenizes source code into tokens |
| `parser.py` | Builds an AST via recursive descent |
| `interpreter.py` | Walks the AST and executes statements |
| `main.py` | Entry point |
| `example.sc` | Sample SimpleCalc program |

## Quick Start

```bash
python main.py example.sc
```
