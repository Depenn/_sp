# SimpleCalc Language (HW2)

SimpleCalc is a minimalist interpreted language implemented in Python.

## Features
- Integer arithmetic: `+`, `-`, `*`, `/`
- Variables and assignment: `x = 5;`
- Output: `print <expr>;`
- Control Flow: `if-else`, `while`
- Comparisons: `>`, `<`, `==`

## Language Specification (EBNF)
```ebnf
program    = { statement } ;
statement  = assignment | print_stmt | if_stmt | while_stmt | block ;
block      = "{" { statement } "}" ;
assignment = identifier "=" expression ";" ;
print_stmt = "print" expression ";" ;
if_stmt    = "if" "(" expression ")" block [ "else" block ] ;
while_stmt = "while" "(" expression ")" block ;
expression = term { ("+" | "-") term } ;
term       = factor { ("*" | "/") factor } ;
factor     = identifier | number | "(" expression ")" | comparison ;
comparison = expression (">" | "<" | "==") expression ;
```

## How to Run
1. Ensure you have Python 3 installed.
2. Run the interpreter with an example file:
   ```bash
   python main.py example.sc
   ```

## Files
- `lexer.py`: Tokenizes the source code.
- `parser.py`: Builds the Abstract Syntax Tree (AST).
- `interpreter.py`: Executes the AST.
- `main.py`: Entry point for the language.
- `example.sc`: A sample program demonstrating language features.
