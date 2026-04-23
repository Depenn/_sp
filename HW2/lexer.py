import re

TOKEN_TYPES = [
    ('NUMBER', r'\d+'),
    ('ID', r'[a-zA-Z_]\w*'),
    ('ASSIGN', r'='),
    ('PLUS', r'\+'),
    ('MINUS', r'-'),
    ('MUL', r'\*'),
    ('DIV', r'/'),
    ('LPAREN', r'\('),
    ('RPAREN', r'\)'),
    ('LBRACE', r'\{'),
    ('RBRACE', r'\}'),
    ('GT', r'>'),
    ('LT', r'<'),
    ('EQ', r'=='),
    ('SEMI', r';'),
    ('WHITESPACE', r'\s+'),
]

class Token:
    def __init__(self, type, value):
        self.type = type
        self.value = value
    def __repr__(self):
        return f'Token({self.type}, {self.value})'

def lex(code):
    tokens = []
    pos = 0
    while pos < len(code):
        match = None
        for token_type, pattern in TOKEN_TYPES:
            regex = re.compile(pattern)
            match = regex.match(code, pos)
            if match:
                value = match.group(0)
                if token_type != 'WHITESPACE':
                    tokens.append(Token(token_type, value))
                pos = match.end(0)
                break
        if not match:
            raise SyntaxError(f'Illegal character at position {pos}: {code[pos]}')
    tokens.append(Token('EOF', None))
    return tokens
