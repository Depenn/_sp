class ASTNode:
    pass

class Number(ASTNode):
    def __init__(self, token):
        self.value = int(token.value)

class Variable(ASTNode):
    def __init__(self, token):
        self.name = token.value

class BinOp(ASTNode):
    def __init__(self, left, op, right):
        self.left = left
        self.op = op
        self.right = right

class Assign(ASTNode):
    def __init__(self, left, right):
        self.left = left
        self.right = right

class Print(ASTNode):
    def __init__(self, expr):
        self.expr = expr

class If(ASTNode):
    def __init__(self, condition, true_block, false_block=None):
        self.condition = condition
        self.true_block = true_block
        self.false_block = false_block

class While(ASTNode):
    def __init__(self, condition, block):
        self.condition = condition
        self.block = block

class Block(ASTNode):
    def __init__(self, statements):
        self.statements = statements

class Parser:
    def __init__(self, tokens):
        self.tokens = tokens
        self.pos = 0

    def current_token(self):
        return self.tokens[self.pos]

    def eat(self, token_type):
        if self.current_token().type == token_type:
            token = self.current_token()
            self.pos += 1
            return token
        else:
            raise SyntaxError(f"Unexpected token: {self.current_token().type}, expected: {token_type}")

    def factor(self):
        token = self.current_token()
        if token.type == 'NUMBER':
            self.eat('NUMBER')
            return Number(token)
        elif token.type == 'ID':
            self.eat('ID')
            return Variable(token)
        elif token.type == 'LPAREN':
            self.eat('LPAREN')
            node = self.expression()
            self.eat('RPAREN')
            return node
        raise SyntaxError(f"Unexpected token in factor: {token.type}")

    def term(self):
        node = self.factor()
        while self.current_token().type in ('MUL', 'DIV'):
            token = self.current_token()
            self.eat(token.type)
            node = BinOp(left=node, op=token.type, right=self.factor())
        return node

    def expression(self):
        node = self.term()
        while self.current_token().type in ('PLUS', 'MINUS', 'GT', 'LT', 'EQ'):
            token = self.current_token()
            self.eat(token.type)
            node = BinOp(left=node, op=token.type, right=self.term())
        return node

    def statement(self):
        token = self.current_token()
        if token.type == 'ID':
            if token.value == 'print':
                self.eat('ID')
                expr = self.expression()
                self.eat('SEMI')
                return Print(expr)
            elif token.value == 'if':
                self.eat('ID')
                self.eat('LPAREN')
                cond = self.expression()
                self.eat('RPAREN')
                true_b = self.block()
                false_b = None
                if self.current_token().type == 'ID' and self.current_token().value == 'else':
                    self.eat('ID')
                    false_b = self.block()
                return If(cond, true_b, false_b)
            elif token.value == 'while':
                self.eat('ID')
                self.eat('LPAREN')
                cond = self.expression()
                self.eat('RPAREN')
                b = self.block()
                return While(cond, b)
            else:
                var = Variable(self.eat('ID'))
                self.eat('ASSIGN')
                expr = self.expression()
                self.eat('SEMI')
                return Assign(left=var, right=expr)
        
        if token.type == 'LBRACE':
            return self.block()
        
        raise SyntaxError(f"Unknown statement starting with {token.value}")

    def block(self):
        self.eat('LBRACE')
        statements = []
        while self.current_token().type != 'RBRACE':
            statements.append(self.statement())
        self.eat('RBRACE')
        return Block(statements)

    def parse(self):
        statements = []
        while self.current_token().type != 'EOF':
            statements.append(self.statement())
        return statements
