#!/usr/bin/env python3
"""
YASL - Yet Another Scripting Language
Simple interpreted scripting language implementation
"""

import sys
import re
from typing import Dict, List, Any, Optional, Tuple
from enum import Enum, auto
from dataclasses import dataclass


class TokenType(Enum):
    # Literals
    NUMBER = auto()
    STRING = auto()
    IDENTIFIER = auto()
    TRUE = auto()
    FALSE = auto()
    NIL = auto()

    # Operators
    PLUS = auto()
    MINUS = auto()
    STAR = auto()
    SLASH = auto()
    PERCENT = auto()
    EQUAL = auto()
    EQUAL_EQUAL = auto()
    BANG = auto()
    BANG_EQUAL = auto()
    LESS = auto()
    LESS_EQUAL = auto()
    GREATER = auto()
    GREATER_EQUAL = auto()
    AND = auto()
    OR = auto()

    # Delimiters
    LPAREN = auto()
    RPAREN = auto()
    LBRACE = auto()
    RBRACE = auto()
    LBRACKET = auto()
    RBRACKET = auto()
    COMMA = auto()
    SEMICOLON = auto()
    COLON = auto()

    # Keywords
    LET = auto()
    FN = auto()
    IF = auto()
    ELSE = auto()
    WHILE = auto()
    FOR = auto()
    RETURN = auto()
    PRINT = auto()
    INPUT = auto()

    EOF = auto()


@dataclass
class Token:
    type: TokenType
    value: Any
    line: int


class Lexer:
    """Tokenize source code."""

    KEYWORDS = {
        'let': TokenType.LET,
        'fn': TokenType.FN,
        'if': TokenType.IF,
        'else': TokenType.ELSE,
        'while': TokenType.WHILE,
        'for': TokenType.FOR,
        'return': TokenType.RETURN,
        'print': TokenType.PRINT,
        'input': TokenType.INPUT,
        'true': TokenType.TRUE,
        'false': TokenType.FALSE,
        'nil': TokenType.NIL,
        'and': TokenType.AND,
        'or': TokenType.OR,
    }

    def __init__(self, source: str):
        self.source = source
        self.pos = 0
        self.line = 1
        self.tokens: List[Token] = []

    def tokenize(self) -> List[Token]:
        """Tokenize the source code."""
        while self.pos < len(self.source):
            self._scan_token()
        self.tokens.append(Token(TokenType.EOF, None, self.line))
        return self.tokens

    def _scan_token(self):
        c = self._advance()

        if c in ' \t\r':
            return
        if c == '\n':
            self.line += 1
            return
        if c == '#':
            while self.pos < len(self.source) and self.source[self.pos] != '\n':
                self.pos += 1
            return

        # Single character tokens
        simple = {
            '+': TokenType.PLUS, '-': TokenType.MINUS,
            '*': TokenType.STAR, '/': TokenType.SLASH, '%': TokenType.PERCENT,
            '(': TokenType.LPAREN, ')': TokenType.RPAREN,
            '{': TokenType.LBRACE, '}': TokenType.RBRACE,
            '[': TokenType.LBRACKET, ']': TokenType.RBRACKET,
            ',': TokenType.COMMA, ';': TokenType.SEMICOLON, ':': TokenType.COLON,
        }

        if c in simple:
            self.tokens.append(Token(simple[c], c, self.line))
            return

        # Two character tokens
        if c == '=':
            if self._match('='):
                self.tokens.append(Token(TokenType.EQUAL_EQUAL, '==', self.line))
            else:
                self.tokens.append(Token(TokenType.EQUAL, '=', self.line))
            return

        if c == '!':
            if self._match('='):
                self.tokens.append(Token(TokenType.BANG_EQUAL, '!=', self.line))
            else:
                self.tokens.append(Token(TokenType.BANG, '!', self.line))
            return

        if c == '<':
            if self._match('='):
                self.tokens.append(Token(TokenType.LESS_EQUAL, '<=', self.line))
            else:
                self.tokens.append(Token(TokenType.LESS, '<', self.line))
            return

        if c == '>':
            if self._match('='):
                self.tokens.append(Token(TokenType.GREATER_EQUAL, '>=', self.line))
            else:
                self.tokens.append(Token(TokenType.GREATER, '>', self.line))
            return

        # String
        if c == '"':
            self._string()
            return

        # Number
        if c.isdigit():
            self._number(c)
            return

        # Identifier/Keyword
        if c.isalpha() or c == '_':
            self._identifier(c)
            return

        raise SyntaxError(f"Unexpected character '{c}' at line {self.line}")

    def _advance(self) -> str:
        c = self.source[self.pos]
        self.pos += 1
        return c

    def _match(self, expected: str) -> bool:
        if self.pos >= len(self.source):
            return False
        if self.source[self.pos] != expected:
            return False
        self.pos += 1
        return True

    def _string(self):
        start = self.pos
        while self.pos < len(self.source) and self.source[self.pos] != '"':
            if self.source[self.pos] == '\n':
                self.line += 1
            self.pos += 1
        if self.pos >= len(self.source):
            raise SyntaxError(f"Unterminated string at line {self.line}")
        value = self.source[start:self.pos]
        self.pos += 1  # Closing quote
        self.tokens.append(Token(TokenType.STRING, value, self.line))

    def _number(self, first: str):
        value = first
        while self.pos < len(self.source) and (self.source[self.pos].isdigit() or self.source[self.pos] == '.'):
            value += self.source[self.pos]
            self.pos += 1
        num = float(value) if '.' in value else int(value)
        self.tokens.append(Token(TokenType.NUMBER, num, self.line))

    def _identifier(self, first: str):
        value = first
        while self.pos < len(self.source) and (self.source[self.pos].isalnum() or self.source[self.pos] == '_'):
            value += self.source[self.pos]
            self.pos += 1
        token_type = self.KEYWORDS.get(value, TokenType.IDENTIFIER)
        self.tokens.append(Token(token_type, value, self.line))


# AST Nodes
@dataclass
class NumberNode:
    value: float

@dataclass
class StringNode:
    value: str

@dataclass
class BoolNode:
    value: bool

@dataclass
class NilNode:
    pass

@dataclass
class IdentifierNode:
    name: str

@dataclass
class BinaryNode:
    left: Any
    op: str
    right: Any

@dataclass
class UnaryNode:
    op: str
    operand: Any

@dataclass
class AssignNode:
    name: str
    value: Any

@dataclass
class LetNode:
    name: str
    value: Any

@dataclass
class PrintNode:
    value: Any

@dataclass
class InputNode:
    prompt: Any

@dataclass
class IfNode:
    condition: Any
    then_branch: Any
    else_branch: Any

@dataclass
class WhileNode:
    condition: Any
    body: Any

@dataclass
class BlockNode:
    statements: List[Any]

@dataclass
class FunctionNode:
    name: str
    params: List[str]
    body: Any

@dataclass
class CallNode:
    callee: Any
    args: List[Any]

@dataclass
class ReturnNode:
    value: Any

@dataclass
class ArrayNode:
    elements: List[Any]

@dataclass
class IndexNode:
    array: Any
    index: Any


class Parser:
    """Parse tokens into AST."""

    def __init__(self, tokens: List[Token]):
        self.tokens = tokens
        self.pos = 0

    def parse(self) -> List[Any]:
        """Parse the token stream."""
        statements = []
        while not self._at_end():
            statements.append(self._statement())
        return statements

    def _statement(self):
        if self._match(TokenType.LET):
            return self._let_statement()
        if self._match(TokenType.FN):
            return self._function()
        if self._match(TokenType.IF):
            return self._if_statement()
        if self._match(TokenType.WHILE):
            return self._while_statement()
        if self._match(TokenType.PRINT):
            return self._print_statement()
        if self._match(TokenType.RETURN):
            return self._return_statement()
        if self._match(TokenType.LBRACE):
            return self._block()
        return self._expression_statement()

    def _let_statement(self):
        name = self._consume(TokenType.IDENTIFIER, "Expected variable name").value
        self._consume(TokenType.EQUAL, "Expected '=' after variable name")
        value = self._expression()
        self._match(TokenType.SEMICOLON)
        return LetNode(name, value)

    def _function(self):
        name = self._consume(TokenType.IDENTIFIER, "Expected function name").value
        self._consume(TokenType.LPAREN, "Expected '(' after function name")
        params = []
        if not self._check(TokenType.RPAREN):
            params.append(self._consume(TokenType.IDENTIFIER, "Expected parameter name").value)
            while self._match(TokenType.COMMA):
                params.append(self._consume(TokenType.IDENTIFIER, "Expected parameter name").value)
        self._consume(TokenType.RPAREN, "Expected ')' after parameters")
        self._consume(TokenType.LBRACE, "Expected '{' before function body")
        body = self._block()
        return FunctionNode(name, params, body)

    def _if_statement(self):
        self._consume(TokenType.LPAREN, "Expected '(' after 'if'")
        condition = self._expression()
        self._consume(TokenType.RPAREN, "Expected ')' after condition")
        then_branch = self._statement()
        else_branch = None
        if self._match(TokenType.ELSE):
            else_branch = self._statement()
        return IfNode(condition, then_branch, else_branch)

    def _while_statement(self):
        self._consume(TokenType.LPAREN, "Expected '(' after 'while'")
        condition = self._expression()
        self._consume(TokenType.RPAREN, "Expected ')' after condition")
        body = self._statement()
        return WhileNode(condition, body)

    def _print_statement(self):
        value = self._expression()
        self._match(TokenType.SEMICOLON)
        return PrintNode(value)

    def _return_statement(self):
        value = None
        if not self._check(TokenType.SEMICOLON) and not self._check(TokenType.RBRACE):
            value = self._expression()
        self._match(TokenType.SEMICOLON)
        return ReturnNode(value)

    def _block(self):
        statements = []
        while not self._check(TokenType.RBRACE) and not self._at_end():
            statements.append(self._statement())
        self._consume(TokenType.RBRACE, "Expected '}' after block")
        return BlockNode(statements)

    def _expression_statement(self):
        expr = self._expression()
        self._match(TokenType.SEMICOLON)
        return expr

    def _expression(self):
        return self._assignment()

    def _assignment(self):
        expr = self._or()
        if self._match(TokenType.EQUAL):
            if isinstance(expr, IdentifierNode):
                value = self._assignment()
                return AssignNode(expr.name, value)
            raise SyntaxError("Invalid assignment target")
        return expr

    def _or(self):
        expr = self._and()
        while self._match(TokenType.OR):
            right = self._and()
            expr = BinaryNode(expr, 'or', right)
        return expr

    def _and(self):
        expr = self._equality()
        while self._match(TokenType.AND):
            right = self._equality()
            expr = BinaryNode(expr, 'and', right)
        return expr

    def _equality(self):
        expr = self._comparison()
        while self._match(TokenType.EQUAL_EQUAL, TokenType.BANG_EQUAL):
            op = self.tokens[self.pos - 1].value
            right = self._comparison()
            expr = BinaryNode(expr, op, right)
        return expr

    def _comparison(self):
        expr = self._term()
        while self._match(TokenType.LESS, TokenType.LESS_EQUAL, TokenType.GREATER, TokenType.GREATER_EQUAL):
            op = self.tokens[self.pos - 1].value
            right = self._term()
            expr = BinaryNode(expr, op, right)
        return expr

    def _term(self):
        expr = self._factor()
        while self._match(TokenType.PLUS, TokenType.MINUS):
            op = self.tokens[self.pos - 1].value
            right = self._factor()
            expr = BinaryNode(expr, op, right)
        return expr

    def _factor(self):
        expr = self._unary()
        while self._match(TokenType.STAR, TokenType.SLASH, TokenType.PERCENT):
            op = self.tokens[self.pos - 1].value
            right = self._unary()
            expr = BinaryNode(expr, op, right)
        return expr

    def _unary(self):
        if self._match(TokenType.BANG, TokenType.MINUS):
            op = self.tokens[self.pos - 1].value
            operand = self._unary()
            return UnaryNode(op, operand)
        return self._call()

    def _call(self):
        expr = self._primary()
        while True:
            if self._match(TokenType.LPAREN):
                args = []
                if not self._check(TokenType.RPAREN):
                    args.append(self._expression())
                    while self._match(TokenType.COMMA):
                        args.append(self._expression())
                self._consume(TokenType.RPAREN, "Expected ')' after arguments")
                expr = CallNode(expr, args)
            elif self._match(TokenType.LBRACKET):
                index = self._expression()
                self._consume(TokenType.RBRACKET, "Expected ']' after index")
                expr = IndexNode(expr, index)
            else:
                break
        return expr

    def _primary(self):
        if self._match(TokenType.NUMBER):
            return NumberNode(self.tokens[self.pos - 1].value)
        if self._match(TokenType.STRING):
            return StringNode(self.tokens[self.pos - 1].value)
        if self._match(TokenType.TRUE):
            return BoolNode(True)
        if self._match(TokenType.FALSE):
            return BoolNode(False)
        if self._match(TokenType.NIL):
            return NilNode()
        if self._match(TokenType.IDENTIFIER):
            return IdentifierNode(self.tokens[self.pos - 1].value)
        if self._match(TokenType.INPUT):
            prompt = None
            if self._match(TokenType.LPAREN):
                if not self._check(TokenType.RPAREN):
                    prompt = self._expression()
                self._consume(TokenType.RPAREN, "Expected ')'")
            return InputNode(prompt)
        if self._match(TokenType.LPAREN):
            expr = self._expression()
            self._consume(TokenType.RPAREN, "Expected ')' after expression")
            return expr
        if self._match(TokenType.LBRACKET):
            elements = []
            if not self._check(TokenType.RBRACKET):
                elements.append(self._expression())
                while self._match(TokenType.COMMA):
                    elements.append(self._expression())
            self._consume(TokenType.RBRACKET, "Expected ']'")
            return ArrayNode(elements)
        raise SyntaxError(f"Unexpected token: {self.tokens[self.pos]}")

    def _match(self, *types) -> bool:
        for t in types:
            if self._check(t):
                self.pos += 1
                return True
        return False

    def _check(self, token_type: TokenType) -> bool:
        if self._at_end():
            return False
        return self.tokens[self.pos].type == token_type

    def _consume(self, token_type: TokenType, message: str) -> Token:
        if self._check(token_type):
            token = self.tokens[self.pos]
            self.pos += 1
            return token
        raise SyntaxError(f"{message} at line {self.tokens[self.pos].line}")

    def _at_end(self) -> bool:
        return self.tokens[self.pos].type == TokenType.EOF


class ReturnException(Exception):
    def __init__(self, value):
        self.value = value


class Environment:
    """Variable environment with scoping."""

    def __init__(self, parent=None):
        self.vars: Dict[str, Any] = {}
        self.parent = parent

    def define(self, name: str, value: Any):
        self.vars[name] = value

    def get(self, name: str) -> Any:
        if name in self.vars:
            return self.vars[name]
        if self.parent:
            return self.parent.get(name)
        raise NameError(f"Undefined variable: {name}")

    def set(self, name: str, value: Any):
        if name in self.vars:
            self.vars[name] = value
            return
        if self.parent:
            self.parent.set(name, value)
            return
        raise NameError(f"Undefined variable: {name}")


class Function:
    """User-defined function."""

    def __init__(self, node: FunctionNode, closure: Environment):
        self.node = node
        self.closure = closure


class Interpreter:
    """Execute AST."""

    def __init__(self):
        self.global_env = Environment()
        self._setup_builtins()

    def _setup_builtins(self):
        self.global_env.define('len', lambda x: len(x))
        self.global_env.define('str', lambda x: str(x))
        self.global_env.define('int', lambda x: int(x))
        self.global_env.define('float', lambda x: float(x))
        self.global_env.define('abs', lambda x: abs(x))
        self.global_env.define('min', lambda *args: min(args))
        self.global_env.define('max', lambda *args: max(args))

    def interpret(self, statements: List[Any]):
        """Interpret statements."""
        for stmt in statements:
            self._execute(stmt, self.global_env)

    def _execute(self, node, env: Environment) -> Any:
        if isinstance(node, NumberNode):
            return node.value
        if isinstance(node, StringNode):
            return node.value
        if isinstance(node, BoolNode):
            return node.value
        if isinstance(node, NilNode):
            return None
        if isinstance(node, IdentifierNode):
            return env.get(node.name)
        if isinstance(node, ArrayNode):
            return [self._execute(e, env) for e in node.elements]
        if isinstance(node, IndexNode):
            arr = self._execute(node.array, env)
            idx = self._execute(node.index, env)
            return arr[int(idx)]
        if isinstance(node, BinaryNode):
            return self._binary(node, env)
        if isinstance(node, UnaryNode):
            return self._unary(node, env)
        if isinstance(node, LetNode):
            value = self._execute(node.value, env)
            env.define(node.name, value)
            return value
        if isinstance(node, AssignNode):
            value = self._execute(node.value, env)
            env.set(node.name, value)
            return value
        if isinstance(node, PrintNode):
            value = self._execute(node.value, env)
            print(value)
            return None
        if isinstance(node, InputNode):
            prompt = ""
            if node.prompt:
                prompt = str(self._execute(node.prompt, env))
            return input(prompt)
        if isinstance(node, IfNode):
            cond = self._execute(node.condition, env)
            if cond:
                return self._execute(node.then_branch, env)
            elif node.else_branch:
                return self._execute(node.else_branch, env)
            return None
        if isinstance(node, WhileNode):
            while self._execute(node.condition, env):
                self._execute(node.body, env)
            return None
        if isinstance(node, BlockNode):
            block_env = Environment(env)
            for stmt in node.statements:
                self._execute(stmt, block_env)
            return None
        if isinstance(node, FunctionNode):
            func = Function(node, env)
            env.define(node.name, func)
            return func
        if isinstance(node, CallNode):
            return self._call(node, env)
        if isinstance(node, ReturnNode):
            value = None
            if node.value:
                value = self._execute(node.value, env)
            raise ReturnException(value)

        raise RuntimeError(f"Unknown node type: {type(node)}")

    def _binary(self, node: BinaryNode, env: Environment) -> Any:
        left = self._execute(node.left, env)

        # Short-circuit evaluation
        if node.op == 'and':
            return left and self._execute(node.right, env)
        if node.op == 'or':
            return left or self._execute(node.right, env)

        right = self._execute(node.right, env)

        ops = {
            '+': lambda a, b: a + b,
            '-': lambda a, b: a - b,
            '*': lambda a, b: a * b,
            '/': lambda a, b: a / b,
            '%': lambda a, b: a % b,
            '==': lambda a, b: a == b,
            '!=': lambda a, b: a != b,
            '<': lambda a, b: a < b,
            '<=': lambda a, b: a <= b,
            '>': lambda a, b: a > b,
            '>=': lambda a, b: a >= b,
        }
        return ops[node.op](left, right)

    def _unary(self, node: UnaryNode, env: Environment) -> Any:
        operand = self._execute(node.operand, env)
        if node.op == '-':
            return -operand
        if node.op == '!':
            return not operand
        raise RuntimeError(f"Unknown unary operator: {node.op}")

    def _call(self, node: CallNode, env: Environment) -> Any:
        callee = self._execute(node.callee, env)
        args = [self._execute(arg, env) for arg in node.args]

        if callable(callee) and not isinstance(callee, Function):
            return callee(*args)

        if isinstance(callee, Function):
            if len(args) != len(callee.node.params):
                raise RuntimeError(f"Expected {len(callee.node.params)} arguments, got {len(args)}")
            func_env = Environment(callee.closure)
            for name, value in zip(callee.node.params, args):
                func_env.define(name, value)
            try:
                self._execute(callee.node.body, func_env)
            except ReturnException as ret:
                return ret.value
            return None

        raise RuntimeError(f"Cannot call {callee}")


def run_demo():
    """Run demo program."""
    print("YASL - Yet Another Scripting Language Demo")
    print("=" * 50)

    demo_code = '''
# Variables
let name = "YASL"
let version = 1.0
print "Welcome to " + name + " version " + str(version)

# Functions
fn factorial(n) {
    if (n <= 1) {
        return 1
    }
    return n * factorial(n - 1)
}

print "Factorial of 5: " + str(factorial(5))

# Loops
let sum = 0
let i = 1
while (i <= 10) {
    sum = sum + i
    i = i + 1
}
print "Sum of 1-10: " + str(sum)

# Arrays
let arr = [1, 2, 3, 4, 5]
print "Array length: " + str(len(arr))
print "First element: " + str(arr[0])

# Conditionals
let x = 42
if (x > 50) {
    print "Large"
} else {
    print "Small or medium"
}

# Fibonacci
fn fib(n) {
    if (n <= 1) {
        return n
    }
    return fib(n - 1) + fib(n - 2)
}
print "Fibonacci(10): " + str(fib(10))

print "Done!"
'''

    print("\nRunning demo code:")
    print("-" * 50)

    try:
        lexer = Lexer(demo_code)
        tokens = lexer.tokenize()

        parser = Parser(tokens)
        ast = parser.parse()

        interpreter = Interpreter()
        interpreter.interpret(ast)

    except (SyntaxError, NameError, RuntimeError) as e:
        print(f"Error: {e}")


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("YASL - Yet Another Scripting Language")
        print("\nUsage:")
        print("  python yasl.py <script.yasl>  - Run script")
        print("  python yasl.py demo           - Run demo")
        print("  python yasl.py repl           - Interactive mode")
        return

    if sys.argv[1] == 'demo':
        run_demo()
        return

    if sys.argv[1] == 'repl':
        print("YASL REPL (type 'exit' to quit)")
        interpreter = Interpreter()
        while True:
            try:
                line = input(">>> ")
                if line.strip() == 'exit':
                    break
                if not line.strip():
                    continue
                lexer = Lexer(line)
                tokens = lexer.tokenize()
                parser = Parser(tokens)
                ast = parser.parse()
                result = None
                for stmt in ast:
                    result = interpreter._execute(stmt, interpreter.global_env)
                if result is not None:
                    print(result)
            except EOFError:
                break
            except Exception as e:
                print(f"Error: {e}")
        return

    # Run script file
    try:
        with open(sys.argv[1], 'r') as f:
            source = f.read()
    except FileNotFoundError:
        print(f"Error: File not found: {sys.argv[1]}")
        return

    try:
        lexer = Lexer(source)
        tokens = lexer.tokenize()
        parser = Parser(tokens)
        ast = parser.parse()
        interpreter = Interpreter()
        interpreter.interpret(ast)
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
