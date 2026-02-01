#!/usr/bin/env python3
"""
Expert System - Propositional Logic Inference Engine
Uses backward chaining to evaluate queries based on rules and facts
"""

import sys
import re
from typing import Dict, Set, List, Optional, Tuple
from enum import Enum


class TokenType(Enum):
    FACT = 1
    NOT = 2
    AND = 3
    OR = 4
    XOR = 5
    IMPLIES = 6
    IFF = 7
    LPAREN = 8
    RPAREN = 9


class Token:
    def __init__(self, type: TokenType, value: str = ""):
        self.type = type
        self.value = value


class ASTNode:
    pass


class FactNode(ASTNode):
    def __init__(self, name: str):
        self.name = name


class NotNode(ASTNode):
    def __init__(self, operand: ASTNode):
        self.operand = operand


class BinaryNode(ASTNode):
    def __init__(self, left: ASTNode, operator: TokenType, right: ASTNode):
        self.left = left
        self.operator = operator
        self.right = right


class Rule:
    def __init__(self, condition: ASTNode, conclusion: ASTNode, is_iff: bool = False):
        self.condition = condition
        self.conclusion = conclusion
        self.is_iff = is_iff


class ExpertSystem:
    def __init__(self):
        self.rules: List[Rule] = []
        self.facts: Set[str] = set()
        self.queries: List[str] = []
        self.memo: Dict[str, Optional[bool]] = {}
        self.evaluating: Set[str] = set()

    def tokenize(self, text: str) -> List[Token]:
        """Tokenize expression"""
        tokens = []
        i = 0
        while i < len(text):
            if text[i].isspace():
                i += 1
            elif text[i].isupper():
                tokens.append(Token(TokenType.FACT, text[i]))
                i += 1
            elif text[i] == '!':
                tokens.append(Token(TokenType.NOT))
                i += 1
            elif text[i] == '+':
                tokens.append(Token(TokenType.AND))
                i += 1
            elif text[i] == '|':
                tokens.append(Token(TokenType.OR))
                i += 1
            elif text[i] == '^':
                tokens.append(Token(TokenType.XOR))
                i += 1
            elif text[i:i+3] == '<=>':
                tokens.append(Token(TokenType.IFF))
                i += 3
            elif text[i:i+2] == '=>':
                tokens.append(Token(TokenType.IMPLIES))
                i += 2
            elif text[i] == '(':
                tokens.append(Token(TokenType.LPAREN))
                i += 1
            elif text[i] == ')':
                tokens.append(Token(TokenType.RPAREN))
                i += 1
            else:
                raise ValueError(f"Unknown character: {text[i]}")
        return tokens

    def parse_expression(self, tokens: List[Token], pos: int = 0) -> Tuple[ASTNode, int]:
        """Parse expression into AST using recursive descent"""
        return self.parse_or(tokens, pos)

    def parse_or(self, tokens: List[Token], pos: int) -> Tuple[ASTNode, int]:
        left, pos = self.parse_xor(tokens, pos)
        while pos < len(tokens) and tokens[pos].type == TokenType.OR:
            pos += 1
            right, pos = self.parse_xor(tokens, pos)
            left = BinaryNode(left, TokenType.OR, right)
        return left, pos

    def parse_xor(self, tokens: List[Token], pos: int) -> Tuple[ASTNode, int]:
        left, pos = self.parse_and(tokens, pos)
        while pos < len(tokens) and tokens[pos].type == TokenType.XOR:
            pos += 1
            right, pos = self.parse_and(tokens, pos)
            left = BinaryNode(left, TokenType.XOR, right)
        return left, pos

    def parse_and(self, tokens: List[Token], pos: int) -> Tuple[ASTNode, int]:
        left, pos = self.parse_unary(tokens, pos)
        while pos < len(tokens) and tokens[pos].type == TokenType.AND:
            pos += 1
            right, pos = self.parse_unary(tokens, pos)
            left = BinaryNode(left, TokenType.AND, right)
        return left, pos

    def parse_unary(self, tokens: List[Token], pos: int) -> Tuple[ASTNode, int]:
        if pos < len(tokens) and tokens[pos].type == TokenType.NOT:
            pos += 1
            operand, pos = self.parse_unary(tokens, pos)
            return NotNode(operand), pos
        return self.parse_primary(tokens, pos)

    def parse_primary(self, tokens: List[Token], pos: int) -> Tuple[ASTNode, int]:
        if pos >= len(tokens):
            raise ValueError("Unexpected end of expression")

        if tokens[pos].type == TokenType.LPAREN:
            pos += 1
            node, pos = self.parse_or(tokens, pos)
            if pos >= len(tokens) or tokens[pos].type != TokenType.RPAREN:
                raise ValueError("Missing closing parenthesis")
            return node, pos + 1

        if tokens[pos].type == TokenType.FACT:
            return FactNode(tokens[pos].value), pos + 1

        raise ValueError(f"Unexpected token: {tokens[pos].type}")

    def parse_rule(self, line: str):
        """Parse a rule line"""
        if '<=>' in line:
            parts = line.split('<=>')
            is_iff = True
        elif '=>' in line:
            parts = line.split('=>')
            is_iff = False
        else:
            raise ValueError(f"Invalid rule: {line}")

        condition_tokens = self.tokenize(parts[0].strip())
        conclusion_tokens = self.tokenize(parts[1].strip())

        condition, _ = self.parse_expression(condition_tokens)
        conclusion, _ = self.parse_expression(conclusion_tokens)

        self.rules.append(Rule(condition, conclusion, is_iff))

        # For IFF rules, add reverse implication
        if is_iff:
            self.rules.append(Rule(conclusion, condition, is_iff))

    def parse_file(self, filename: str):
        """Parse input file"""
        with open(filename, 'r') as f:
            for line in f:
                line = line.split('#')[0].strip()
                if not line:
                    continue

                if line.startswith('='):
                    # Initial facts
                    for char in line[1:]:
                        if char.isupper():
                            self.facts.add(char)
                elif line.startswith('?'):
                    # Queries
                    for char in line[1:]:
                        if char.isupper():
                            self.queries.append(char)
                elif '=>' in line or '<=>' in line:
                    self.parse_rule(line)

    def evaluate_node(self, node: ASTNode) -> bool:
        """Evaluate an AST node"""
        if isinstance(node, FactNode):
            return self.evaluate_fact(node.name)
        elif isinstance(node, NotNode):
            return not self.evaluate_node(node.operand)
        elif isinstance(node, BinaryNode):
            left = self.evaluate_node(node.left)
            right = self.evaluate_node(node.right)
            if node.operator == TokenType.AND:
                return left and right
            elif node.operator == TokenType.OR:
                return left or right
            elif node.operator == TokenType.XOR:
                return left != right
        return False

    def get_facts_in_conclusion(self, node: ASTNode) -> Set[str]:
        """Get all fact names from a conclusion node"""
        if isinstance(node, FactNode):
            return {node.name}
        elif isinstance(node, NotNode):
            return self.get_facts_in_conclusion(node.operand)
        elif isinstance(node, BinaryNode):
            return self.get_facts_in_conclusion(node.left) | self.get_facts_in_conclusion(node.right)
        return set()

    def check_conclusion(self, node: ASTNode, fact: str) -> Optional[bool]:
        """Check if fact can be derived from conclusion node"""
        if isinstance(node, FactNode):
            if node.name == fact:
                return True
            return None
        elif isinstance(node, NotNode):
            if isinstance(node.operand, FactNode) and node.operand.name == fact:
                return False
            return None
        elif isinstance(node, BinaryNode):
            left = self.check_conclusion(node.left, fact)
            right = self.check_conclusion(node.right, fact)
            if node.operator == TokenType.AND:
                if left is not None:
                    return left
                return right
            elif node.operator == TokenType.OR:
                if left is True or right is True:
                    return True
                return None
        return None

    def evaluate_fact(self, fact: str) -> bool:
        """Evaluate if a fact is true using backward chaining"""
        # Check memo
        if fact in self.memo:
            return self.memo[fact]

        # Check if it's an initial fact
        if fact in self.facts:
            self.memo[fact] = True
            return True

        # Detect circular dependencies
        if fact in self.evaluating:
            return False
        self.evaluating.add(fact)

        # Search for rules that can prove this fact
        for rule in self.rules:
            facts_in_conclusion = self.get_facts_in_conclusion(rule.conclusion)
            if fact not in facts_in_conclusion:
                continue

            # Check if condition is true
            if self.evaluate_node(rule.condition):
                # Check what value the fact gets
                result = self.check_conclusion(rule.conclusion, fact)
                if result is not None:
                    self.evaluating.discard(fact)
                    self.memo[fact] = result
                    return result

        self.evaluating.discard(fact)
        self.memo[fact] = False
        return False

    def solve(self):
        """Solve all queries"""
        results = {}
        for query in self.queries:
            self.memo.clear()
            self.evaluating.clear()
            result = self.evaluate_fact(query)
            results[query] = result
        return results


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <input_file>")
        sys.exit(1)

    try:
        expert = ExpertSystem()
        expert.parse_file(sys.argv[1])

        print(f"Initial facts: {' '.join(sorted(expert.facts)) if expert.facts else '(none)'}")
        print(f"Queries: {' '.join(expert.queries)}")
        print(f"Rules: {len(expert.rules)}")
        print()

        results = expert.solve()

        print("Results:")
        for query, result in results.items():
            print(f"  {query} = {'true' if result else 'false'}")

    except FileNotFoundError:
        print(f"Error: File '{sys.argv[1]}' not found")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
