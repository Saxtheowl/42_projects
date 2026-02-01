#!/usr/bin/env python3
"""
Infin_calc - Infinite Precision Calculator
Supports arbitrary precision integer arithmetic.
"""

import sys
import re
from typing import Tuple


class BigInt:
    """Arbitrary precision integer class."""
    
    def __init__(self, value="0"):
        if isinstance(value, BigInt):
            self.negative = value.negative
            self.digits = value.digits[:]
        elif isinstance(value, int):
            self.negative = value < 0
            self.digits = list(map(int, str(abs(value))[::-1]))
        else:
            value = str(value).strip()
            self.negative = value.startswith('-')
            if self.negative:
                value = value[1:]
            value = value.lstrip('0') or '0'
            self.digits = list(map(int, value[::-1]))
        
        self._normalize()
    
    def _normalize(self):
        """Remove leading zeros and fix negative zero."""
        while len(self.digits) > 1 and self.digits[-1] == 0:
            self.digits.pop()
        if self.digits == [0]:
            self.negative = False
    
    def __str__(self):
        result = ''.join(map(str, reversed(self.digits)))
        return ('-' if self.negative else '') + result
    
    def __repr__(self):
        return f"BigInt('{self}')"
    
    def __neg__(self):
        result = BigInt(self)
        result.negative = not result.negative
        result._normalize()
        return result
    
    def __abs__(self):
        result = BigInt(self)
        result.negative = False
        return result
    
    def __eq__(self, other):
        other = BigInt(other)
        return self.negative == other.negative and self.digits == other.digits
    
    def __lt__(self, other):
        other = BigInt(other)
        if self.negative != other.negative:
            return self.negative
        
        if len(self.digits) != len(other.digits):
            result = len(self.digits) < len(other.digits)
            return not result if self.negative else result
        
        for i in range(len(self.digits) - 1, -1, -1):
            if self.digits[i] != other.digits[i]:
                result = self.digits[i] < other.digits[i]
                return not result if self.negative else result
        
        return False
    
    def __le__(self, other):
        return self < other or self == other
    
    def __gt__(self, other):
        return not self <= other
    
    def __ge__(self, other):
        return not self < other
    
    def _add_abs(self, other: 'BigInt') -> 'BigInt':
        """Add absolute values."""
        result = BigInt()
        result.digits = []
        
        carry = 0
        max_len = max(len(self.digits), len(other.digits))
        
        for i in range(max_len):
            a = self.digits[i] if i < len(self.digits) else 0
            b = other.digits[i] if i < len(other.digits) else 0
            total = a + b + carry
            result.digits.append(total % 10)
            carry = total // 10
        
        if carry:
            result.digits.append(carry)
        
        return result
    
    def _sub_abs(self, other: 'BigInt') -> 'BigInt':
        """Subtract absolute values (assumes self >= other)."""
        result = BigInt()
        result.digits = []
        
        borrow = 0
        for i in range(len(self.digits)):
            a = self.digits[i]
            b = other.digits[i] if i < len(other.digits) else 0
            diff = a - b - borrow
            
            if diff < 0:
                diff += 10
                borrow = 1
            else:
                borrow = 0
            
            result.digits.append(diff)
        
        result._normalize()
        return result
    
    def __add__(self, other):
        other = BigInt(other)
        
        if self.negative == other.negative:
            result = self._add_abs(other)
            result.negative = self.negative
        else:
            if abs(self) >= abs(other):
                result = abs(self)._sub_abs(abs(other))
                result.negative = self.negative
            else:
                result = abs(other)._sub_abs(abs(self))
                result.negative = other.negative
        
        result._normalize()
        return result
    
    def __radd__(self, other):
        return self + other
    
    def __sub__(self, other):
        return self + (-BigInt(other))
    
    def __rsub__(self, other):
        return BigInt(other) - self
    
    def __mul__(self, other):
        other = BigInt(other)
        result = BigInt()
        result.digits = [0] * (len(self.digits) + len(other.digits))
        
        for i, a in enumerate(self.digits):
            for j, b in enumerate(other.digits):
                result.digits[i + j] += a * b
        
        # Handle carries
        carry = 0
        for i in range(len(result.digits)):
            result.digits[i] += carry
            carry = result.digits[i] // 10
            result.digits[i] %= 10
        
        result.negative = self.negative != other.negative
        result._normalize()
        return result
    
    def __rmul__(self, other):
        return self * other
    
    def __floordiv__(self, other):
        other = BigInt(other)
        if other == BigInt(0):
            raise ZeroDivisionError("Division by zero")
        
        result_negative = self.negative != other.negative
        dividend = abs(self)
        divisor = abs(other)
        
        if dividend < divisor:
            return BigInt(0)
        
        # Long division
        result = BigInt()
        result.digits = []
        current = BigInt(0)
        
        for i in range(len(dividend.digits) - 1, -1, -1):
            current.digits.insert(0, dividend.digits[i])
            current._normalize()
            
            quotient_digit = 0
            while current >= divisor:
                current = current - divisor
                quotient_digit += 1
            
            result.digits.insert(0, quotient_digit)
        
        result.negative = result_negative
        result._normalize()
        return result
    
    def __mod__(self, other):
        other = BigInt(other)
        return self - (self // other) * other
    
    def __pow__(self, other):
        other = BigInt(other)
        if other < BigInt(0):
            raise ValueError("Negative exponent not supported")
        
        result = BigInt(1)
        base = BigInt(self)
        exp = BigInt(other)
        
        while exp > BigInt(0):
            if exp.digits[0] % 2 == 1:
                result = result * base
            base = base * base
            exp = exp // BigInt(2)
        
        return result


def tokenize(expr: str):
    """Tokenize an expression."""
    tokens = []
    i = 0
    while i < len(expr):
        if expr[i].isspace():
            i += 1
        elif expr[i].isdigit():
            j = i
            while j < len(expr) and expr[j].isdigit():
                j += 1
            tokens.append(('NUM', expr[i:j]))
            i = j
        elif expr[i] in '+-*/%^()':
            tokens.append((expr[i], expr[i]))
            i += 1
        else:
            raise ValueError(f"Invalid character: {expr[i]}")
    return tokens


class Parser:
    """Recursive descent parser for arithmetic expressions."""
    
    def __init__(self, tokens):
        self.tokens = tokens
        self.pos = 0
    
    def peek(self):
        if self.pos < len(self.tokens):
            return self.tokens[self.pos]
        return None
    
    def consume(self):
        token = self.peek()
        self.pos += 1
        return token
    
    def parse(self) -> BigInt:
        result = self.parse_expr()
        if self.pos < len(self.tokens):
            raise ValueError("Unexpected token")
        return result
    
    def parse_expr(self) -> BigInt:
        """Parse addition/subtraction."""
        left = self.parse_term()
        
        while self.peek() and self.peek()[0] in '+-':
            op = self.consume()[0]
            right = self.parse_term()
            if op == '+':
                left = left + right
            else:
                left = left - right
        
        return left
    
    def parse_term(self) -> BigInt:
        """Parse multiplication/division/modulo."""
        left = self.parse_power()
        
        while self.peek() and self.peek()[0] in '*/%':
            op = self.consume()[0]
            right = self.parse_power()
            if op == '*':
                left = left * right
            elif op == '/':
                left = left // right
            else:
                left = left % right
        
        return left
    
    def parse_power(self) -> BigInt:
        """Parse exponentiation (right-associative)."""
        left = self.parse_unary()
        
        if self.peek() and self.peek()[0] == '^':
            self.consume()
            right = self.parse_power()
            left = left ** right
        
        return left
    
    def parse_unary(self) -> BigInt:
        """Parse unary operators."""
        if self.peek() and self.peek()[0] == '-':
            self.consume()
            return -self.parse_unary()
        if self.peek() and self.peek()[0] == '+':
            self.consume()
            return self.parse_unary()
        return self.parse_primary()
    
    def parse_primary(self) -> BigInt:
        """Parse numbers and parentheses."""
        token = self.peek()
        
        if token is None:
            raise ValueError("Unexpected end of expression")
        
        if token[0] == 'NUM':
            self.consume()
            return BigInt(token[1])
        
        if token[0] == '(':
            self.consume()
            result = self.parse_expr()
            if not self.peek() or self.peek()[0] != ')':
                raise ValueError("Missing closing parenthesis")
            self.consume()
            return result
        
        raise ValueError(f"Unexpected token: {token}")


def evaluate(expr: str) -> BigInt:
    """Evaluate an expression and return the result."""
    tokens = tokenize(expr)
    parser = Parser(tokens)
    return parser.parse()


def main():
    if len(sys.argv) > 1:
        expr = ' '.join(sys.argv[1:])
        print(evaluate(expr))
    else:
        print("Infinite Precision Calculator")
        print("Operators: + - * / % ^ ()")
        print("Enter 'q' to quit")
        print()
        
        while True:
            try:
                expr = input("> ").strip()
                if not expr:
                    continue
                if expr.lower() == 'q':
                    break
                result = evaluate(expr)
                print(result)
            except EOFError:
                break
            except Exception as e:
                print(f"Error: {e}")


if __name__ == "__main__":
    main()
