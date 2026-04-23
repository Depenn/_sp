import sys
from lexer import lex
from parser import Parser
from interpreter import interpret

def main():
    if len(sys.argv) != 2:
        print("Usage: python main.py <filename.sc>")
        sys.exit(1)

    filename = sys.argv[1]
    try:
        with open(filename, 'r') as f:
            code = f.read()
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        sys.exit(1)

    try:
        tokens = lex(code)
        parser = Parser(tokens)
        statements = parser.parse()
        interpret(statements)
    except Exception as e:
        print(f"Error: {e}")
        # sys.exit(1) # Commented out to see the full trace during debugging if needed

if __name__ == "__main__":
    main()
