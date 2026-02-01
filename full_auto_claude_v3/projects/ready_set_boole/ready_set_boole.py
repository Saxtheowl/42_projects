#!/usr/bin/env python3
"""
ready_set_boole - Boolean Algebra and Set Theory
Complete implementation of boolean operations and set theory
"""

import sys
from typing import List, Set, Tuple, Dict, Optional, Any
from dataclasses import dataclass
from enum import Enum


# ============================================================
# Exercise 00: Adder
# ============================================================

def adder(a: int, b: int) -> int:
    """Add two numbers using only bitwise operations."""
    while b != 0:
        carry = a & b
        a = a ^ b
        b = carry << 1
    return a


# ============================================================
# Exercise 01: Multiplier
# ============================================================

def multiplier(a: int, b: int) -> int:
    """Multiply two numbers using only bitwise operations."""
    result = 0
    negative = (a < 0) ^ (b < 0)
    a, b = abs(a), abs(b)

    while b > 0:
        if b & 1:
            result = adder(result, a)
        a <<= 1
        b >>= 1

    return -result if negative else result


# ============================================================
# Exercise 02: Gray Code
# ============================================================

def gray_code(n: int) -> int:
    """Convert number to Gray code."""
    return n ^ (n >> 1)


# ============================================================
# Exercise 03: Boolean Evaluation
# ============================================================

def eval_formula(formula: str) -> bool:
    """
    Evaluate a boolean formula in Reverse Polish Notation.

    Symbols:
    - 0, 1: False, True
    - !: NOT
    - &: AND
    - |: OR
    - ^: XOR
    - >: Material condition (implies)
    - =: Equivalence (iff)
    """
    stack = []

    for char in formula:
        if char == '0':
            stack.append(False)
        elif char == '1':
            stack.append(True)
        elif char == '!':
            a = stack.pop()
            stack.append(not a)
        elif char == '&':
            b, a = stack.pop(), stack.pop()
            stack.append(a and b)
        elif char == '|':
            b, a = stack.pop(), stack.pop()
            stack.append(a or b)
        elif char == '^':
            b, a = stack.pop(), stack.pop()
            stack.append(a != b)
        elif char == '>':
            b, a = stack.pop(), stack.pop()
            stack.append((not a) or b)
        elif char == '=':
            b, a = stack.pop(), stack.pop()
            stack.append(a == b)

    return stack[0] if stack else False


# ============================================================
# Exercise 04: Truth Table
# ============================================================

def print_truth_table(formula: str):
    """Print truth table for a formula with variables A-Z."""
    # Find variables
    variables = sorted(set(c for c in formula if c.isupper()))
    n = len(variables)

    if n == 0:
        print("No variables found")
        return

    # Print header
    print("| " + " | ".join(variables) + " | = |")
    print("|" + "---|" * (n + 1))

    # Generate all combinations
    for i in range(2 ** n):
        values = {}
        row = []
        for j, var in enumerate(variables):
            val = (i >> (n - 1 - j)) & 1
            values[var] = val
            row.append(str(val))

        # Evaluate formula
        eval_formula_str = formula
        for var, val in values.items():
            eval_formula_str = eval_formula_str.replace(var, str(val))

        result = 1 if eval_formula(eval_formula_str) else 0
        row.append(str(result))

        print("| " + " | ".join(row) + " |")


# ============================================================
# Exercise 05: Negation Normal Form
# ============================================================

class Node:
    """AST node for boolean expressions."""
    pass


@dataclass
class Var(Node):
    name: str

    def __str__(self):
        return self.name


@dataclass
class Not(Node):
    child: Node

    def __str__(self):
        return f"!{self.child}"


@dataclass
class BinOp(Node):
    left: Node
    right: Node
    op: str

    def __str__(self):
        return f"({self.left}{self.op}{self.right})"


def parse_rpn(formula: str) -> Node:
    """Parse RPN formula to AST."""
    stack = []

    for char in formula:
        if char.isupper():
            stack.append(Var(char))
        elif char == '!':
            stack.append(Not(stack.pop()))
        elif char in '&|^>=':
            right, left = stack.pop(), stack.pop()
            stack.append(BinOp(left, right, char))

    return stack[0] if stack else Var('?')


def to_nnf(node: Node) -> Node:
    """Convert to Negation Normal Form."""
    if isinstance(node, Var):
        return node

    if isinstance(node, Not):
        child = node.child

        if isinstance(child, Var):
            return node

        if isinstance(child, Not):
            return to_nnf(child.child)

        if isinstance(child, BinOp):
            if child.op == '&':
                # !(A & B) = !A | !B
                return to_nnf(BinOp(Not(child.left), Not(child.right), '|'))
            elif child.op == '|':
                # !(A | B) = !A & !B
                return to_nnf(BinOp(Not(child.left), Not(child.right), '&'))
            elif child.op == '>':
                # !(A > B) = A & !B
                return to_nnf(BinOp(child.left, Not(child.right), '&'))
            elif child.op == '=':
                # !(A = B) = (A & !B) | (!A & B)
                return to_nnf(BinOp(
                    BinOp(child.left, Not(child.right), '&'),
                    BinOp(Not(child.left), child.right, '&'),
                    '|'
                ))
            elif child.op == '^':
                # !(A ^ B) = A = B
                return to_nnf(BinOp(child.left, child.right, '='))

    if isinstance(node, BinOp):
        # Eliminate material condition
        if node.op == '>':
            # A > B = !A | B
            return to_nnf(BinOp(Not(node.left), node.right, '|'))

        # Eliminate equivalence
        if node.op == '=':
            # A = B = (A & B) | (!A & !B)
            return to_nnf(BinOp(
                BinOp(node.left, node.right, '&'),
                BinOp(Not(node.left), Not(node.right), '&'),
                '|'
            ))

        # Eliminate XOR
        if node.op == '^':
            # A ^ B = (A | B) & (!A | !B)
            return to_nnf(BinOp(
                BinOp(node.left, node.right, '|'),
                BinOp(Not(node.left), Not(node.right), '|'),
                '&'
            ))

        return BinOp(to_nnf(node.left), to_nnf(node.right), node.op)

    return node


def ast_to_rpn(node: Node) -> str:
    """Convert AST back to RPN."""
    if isinstance(node, Var):
        return node.name
    if isinstance(node, Not):
        return ast_to_rpn(node.child) + "!"
    if isinstance(node, BinOp):
        return ast_to_rpn(node.left) + ast_to_rpn(node.right) + node.op
    return ""


def negation_normal_form(formula: str) -> str:
    """Convert formula to NNF."""
    ast = parse_rpn(formula)
    nnf = to_nnf(ast)
    return ast_to_rpn(nnf)


# ============================================================
# Exercise 06: Conjunctive Normal Form
# ============================================================

def to_cnf(node: Node) -> Node:
    """Convert to Conjunctive Normal Form."""
    node = to_nnf(node)
    return distribute_or(node)


def distribute_or(node: Node) -> Node:
    """Distribute OR over AND."""
    if isinstance(node, (Var, Not)):
        return node

    if isinstance(node, BinOp):
        left = distribute_or(node.left)
        right = distribute_or(node.right)

        if node.op == '&':
            return BinOp(left, right, '&')

        if node.op == '|':
            # Distribute: (A & B) | C = (A | C) & (B | C)
            if isinstance(left, BinOp) and left.op == '&':
                return distribute_or(BinOp(
                    BinOp(left.left, right, '|'),
                    BinOp(left.right, right, '|'),
                    '&'
                ))
            if isinstance(right, BinOp) and right.op == '&':
                return distribute_or(BinOp(
                    BinOp(left, right.left, '|'),
                    BinOp(left, right.right, '|'),
                    '&'
                ))
            return BinOp(left, right, '|')

    return node


def conjunctive_normal_form(formula: str) -> str:
    """Convert formula to CNF."""
    ast = parse_rpn(formula)
    cnf = to_cnf(ast)
    return ast_to_rpn(cnf)


# ============================================================
# Exercise 07: SAT Solver
# ============================================================

def sat(formula: str) -> bool:
    """Check if formula is satisfiable."""
    variables = sorted(set(c for c in formula if c.isupper()))
    n = len(variables)

    if n == 0:
        return eval_formula(formula)

    # Try all combinations
    for i in range(2 ** n):
        eval_str = formula
        for j, var in enumerate(variables):
            val = (i >> (n - 1 - j)) & 1
            eval_str = eval_str.replace(var, str(val))

        if eval_formula(eval_str):
            return True

    return False


# ============================================================
# Exercise 08: Powerset
# ============================================================

def powerset(s: Set[int]) -> List[Set[int]]:
    """Return powerset of a set."""
    result = [set()]

    for elem in s:
        new_subsets = []
        for subset in result:
            new_subsets.append(subset | {elem})
        result.extend(new_subsets)

    return result


# ============================================================
# Exercise 09: Set Evaluation
# ============================================================

def eval_set(formula: str, sets: List[Set[int]]) -> Set[int]:
    """
    Evaluate set formula in RPN.
    Variables A, B, C... correspond to sets[0], sets[1], sets[2]...

    Operations:
    - !: Complement (requires universe)
    - &: Intersection
    - |: Union
    - ^: Symmetric difference
    """
    stack = []

    # Build universe
    universe = set()
    for s in sets:
        universe |= s

    var_map = {chr(ord('A') + i): s for i, s in enumerate(sets)}

    for char in formula:
        if char.isupper() and char in var_map:
            stack.append(var_map[char])
        elif char == '!':
            a = stack.pop()
            stack.append(universe - a)
        elif char == '&':
            b, a = stack.pop(), stack.pop()
            stack.append(a & b)
        elif char == '|':
            b, a = stack.pop(), stack.pop()
            stack.append(a | b)
        elif char == '^':
            b, a = stack.pop(), stack.pop()
            stack.append(a ^ b)

    return stack[0] if stack else set()


# ============================================================
# Exercise 10: Curve (Map)
# ============================================================

def map_value(x: int, y: int) -> float:
    """Map 2D coordinates to [0,1] using reverse bits."""
    # Interleave bits (Morton code / Z-order curve)
    def interleave(x: int, y: int) -> int:
        result = 0
        for i in range(16):
            result |= ((x >> i) & 1) << (2 * i)
            result |= ((y >> i) & 1) << (2 * i + 1)
        return result

    z = interleave(x, y)
    return z / (2 ** 32 - 1)


def reverse_map(n: float) -> Tuple[int, int]:
    """Reverse map from [0,1] to 2D coordinates."""
    z = int(n * (2 ** 32 - 1))

    x = y = 0
    for i in range(16):
        x |= ((z >> (2 * i)) & 1) << i
        y |= ((z >> (2 * i + 1)) & 1) << i

    return x, y


# ============================================================
# Demo
# ============================================================

def run_demo():
    """Run demonstrations."""
    print("Ready, Set, Boole! - Boolean Algebra Demo")
    print("=" * 60)

    # Exercise 00: Adder
    print("\n[Exercise 00] Adder")
    print(f"  adder(5, 3) = {adder(5, 3)}")
    print(f"  adder(42, 17) = {adder(42, 17)}")

    # Exercise 01: Multiplier
    print("\n[Exercise 01] Multiplier")
    print(f"  multiplier(5, 3) = {multiplier(5, 3)}")
    print(f"  multiplier(7, 8) = {multiplier(7, 8)}")

    # Exercise 02: Gray Code
    print("\n[Exercise 02] Gray Code")
    for i in range(8):
        print(f"  {i} -> {gray_code(i)} ({bin(gray_code(i))})")

    # Exercise 03: Boolean Evaluation
    print("\n[Exercise 03] Boolean Evaluation (RPN)")
    formulas = ["10&", "10|", "11>", "10=", "1011||="]
    for f in formulas:
        print(f"  eval_formula('{f}') = {eval_formula(f)}")

    # Exercise 04: Truth Table
    print("\n[Exercise 04] Truth Table for 'AB&C|'")
    print_truth_table("AB&C|")

    # Exercise 05: NNF
    print("\n[Exercise 05] Negation Normal Form")
    print(f"  NNF('AB&!') = {negation_normal_form('AB&!')}")
    print(f"  NNF('AB|!') = {negation_normal_form('AB|!')}")
    print(f"  NNF('AB>') = {negation_normal_form('AB>')}")

    # Exercise 06: CNF
    print("\n[Exercise 06] Conjunctive Normal Form")
    print(f"  CNF('AB&C|') = {conjunctive_normal_form('AB&C|')}")

    # Exercise 07: SAT
    print("\n[Exercise 07] SAT Solver")
    print(f"  sat('AB|') = {sat('AB|')}")
    print(f"  sat('AA!&') = {sat('AA!&')}")

    # Exercise 08: Powerset
    print("\n[Exercise 08] Powerset")
    s = {1, 2, 3}
    print(f"  powerset({s}) = {powerset(s)}")

    # Exercise 09: Set Evaluation
    print("\n[Exercise 09] Set Evaluation")
    sets = [{1, 2}, {2, 3}, {3, 4}]
    print(f"  Sets: A={sets[0]}, B={sets[1]}, C={sets[2]}")
    print(f"  eval_set('AB&', sets) = {eval_set('AB&', sets)}")
    print(f"  eval_set('AB|', sets) = {eval_set('AB|', sets)}")
    print(f"  eval_set('AB^', sets) = {eval_set('AB^', sets)}")

    # Exercise 10: Curve
    print("\n[Exercise 10] Map (Z-order curve)")
    print(f"  map_value(0, 0) = {map_value(0, 0)}")
    print(f"  map_value(100, 100) = {map_value(100, 100)}")
    print(f"  reverse_map(0.5) = {reverse_map(0.5)}")


def main():
    """Main entry point."""
    if len(sys.argv) > 1 and sys.argv[1] == '--help':
        print("ready_set_boole - Boolean Algebra and Set Theory")
        print()
        print("Usage:")
        print("  python ready_set_boole.py         - Run demo")
        print("  python ready_set_boole.py --help  - Show help")
        print()
        print("Functions available:")
        print("  adder(a, b)        - Add using bitwise ops")
        print("  multiplier(a, b)   - Multiply using bitwise ops")
        print("  gray_code(n)       - Convert to Gray code")
        print("  eval_formula(f)    - Evaluate RPN formula")
        print("  print_truth_table(f) - Print truth table")
        print("  negation_normal_form(f) - Convert to NNF")
        print("  conjunctive_normal_form(f) - Convert to CNF")
        print("  sat(f)             - Check satisfiability")
        print("  powerset(s)        - Get powerset")
        print("  eval_set(f, sets)  - Evaluate set formula")
        return

    run_demo()


if __name__ == "__main__":
    main()
