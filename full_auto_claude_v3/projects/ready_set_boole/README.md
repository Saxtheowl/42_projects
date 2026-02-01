# ready_set_boole - Boolean Algebra and Set Theory

Complete implementation of boolean algebra operations and set theory.

## Exercises

| # | Name | Description |
|---|------|-------------|
| 00 | Adder | Add using only bitwise operations |
| 01 | Multiplier | Multiply using only bitwise operations |
| 02 | Gray Code | Binary to Gray code conversion |
| 03 | Eval Formula | Evaluate RPN boolean formulas |
| 04 | Truth Table | Generate truth tables |
| 05 | NNF | Negation Normal Form |
| 06 | CNF | Conjunctive Normal Form |
| 07 | SAT | Boolean satisfiability |
| 08 | Powerset | Set powerset generation |
| 09 | Set Eval | Evaluate set operations |
| 10 | Curve | Space-filling curve mapping |

## Usage

```bash
python3 ready_set_boole.py      # Run demo
```

## RPN Boolean Syntax

| Symbol | Operation |
|--------|-----------|
| 0, 1 | False, True |
| A-Z | Variables |
| ! | NOT |
| & | AND |
| \| | OR |
| ^ | XOR |
| > | Implies |
| = | Equivalence |

## Examples

```python
from ready_set_boole import *

# Bitwise arithmetic
adder(5, 3)        # 8
multiplier(4, 5)   # 20

# Gray code
gray_code(5)       # 7

# Boolean evaluation
eval_formula("10&")  # False
eval_formula("11|")  # True

# Truth table
print_truth_table("AB&")

# Normal forms
negation_normal_form("AB>")  # A!B|
conjunctive_normal_form("AB&C|")

# SAT solving
sat("AB|")    # True (satisfiable)
sat("AA!&")   # False (contradiction)

# Set operations
powerset({1, 2})  # [set(), {1}, {2}, {1,2}]
eval_set("AB&", [{1,2}, {2,3}])  # {2}
```

## Author

Implementation for 42 curriculum.
