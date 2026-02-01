# Infin_calc

Infinite precision integer calculator.

## Description

A calculator that supports arbitrary precision integer arithmetic, allowing calculations with numbers of any size.

## Features

- Arbitrary precision integers (no size limit)
- Basic arithmetic: +, -, *, /, %
- Exponentiation: ^
- Parentheses for grouping
- Interactive mode
- Command-line expression evaluation

## Usage

```bash
# Interactive mode
./infin_calc.py

# Evaluate expression from command line
./infin_calc.py "2 ^ 100"
./infin_calc.py "99999999999999 * 88888888888888"
```

## Operators

| Operator | Description | Precedence |
|----------|-------------|------------|
| `+` | Addition | Low |
| `-` | Subtraction | Low |
| `*` | Multiplication | Medium |
| `/` | Integer division | Medium |
| `%` | Modulo | Medium |
| `^` | Exponentiation | High |
| `()` | Grouping | Highest |

## Examples

```bash
$ ./infin_calc.py "2 ^ 100"
1267650600228229401496703205376

$ ./infin_calc.py "99999999999999999999 * 88888888888888888888"
8888888888888888888711111111111111111112

$ ./infin_calc.py "1000000000000 / 7"
142857142857

$ ./infin_calc.py "(123 + 456) * 789"
456831
```

## Implementation

The BigInt class provides:
- Digit-by-digit storage (least significant first)
- Grade-school algorithms for arithmetic
- Long division for integer division
- Binary exponentiation for powers

## Files

| File | Description |
|------|-------------|
| `infin_calc.py` | Main calculator implementation |
| `README.md` | Documentation |

## Author

Implementation for 42 curriculum.
