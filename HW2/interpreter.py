from parser import Number, Variable, BinOp, Assign, Print, If, While, Block

class Interpreter:
    def __init__(self):
        self.variables = {}

    def visit(self, node):
        if isinstance(node, Number):
            return node.value
        elif isinstance(node, Variable):
            if node.name in self.variables:
                return self.variables[node.name]
            else:
                raise NameError(f"Undefined variable: {node.name}")
        elif isinstance(node, BinOp):
            left = self.visit(node.left)
            right = self.visit(node.right)
            if node.op == 'PLUS': return left + right
            if node.op == 'MINUS': return left - right
            if node.op == 'MUL': return left * right
            if node.op == 'DIV': return left // right
            if node.op == 'GT': return 1 if left > right else 0
            if node.op == 'LT': return 1 if left < right else 0
            if node.op == 'EQ': return 1 if left == right else 0
        elif isinstance(node, Assign):
            value = self.visit(node.right)
            self.variables[node.left.name] = value
            return value
        elif isinstance(node, Print):
            value = self.visit(node.expr)
            print(value)
            return value
        elif isinstance(node, If):
            if self.visit(node.condition):
                return self.visit(node.true_block)
            elif node.false_block:
                return self.visit(node.false_block)
            return None
        elif isinstance(node, While):
            result = None
            while self.visit(node.condition):
                result = self.visit(node.block)
            return result
        elif isinstance(node, Block):
            result = None
            for stmt in node.statements:
                result = self.visit(stmt)
            return result
        elif isinstance(node, list):
            result = None
            for stmt in node:
                result = self.visit(stmt)
            return result
        raise Exception(f"Unknown node type: {type(node)}")

def interpret(statements):
    interpreter = Interpreter()
    interpreter.visit(statements)
