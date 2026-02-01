# Computor v2

Advanced polynomial equation solver.

## Description

An enhanced version of Computor that solves polynomial equations of any degree, supports complex numbers, and can display ASCII graphs.

## Features

- Polynomial equations of any degree
- Complex number solutions
- Newton's method for degree > 2
- ASCII graphing
- Matrix operations (library)
- Polynomial arithmetic

## Usage

```bash
./computor_v2.py 'equation'
./computor_v2.py --graph 'polynomial'
```

## Examples

```bash
# Quadratic equation
./computor_v2.py 'X^2 - 4 = 0'
# Output: x1 = 2.0, x2 = -2.0

# Complex solutions
./computor_v2.py 'X^2 + 1 = 0'
# Output: x1 = 1i, x2 = -1i

# Cubic equation
./computor_v2.py 'X^3 - 6*X^2 + 11*X - 6 = 0'
# Output: x1 = 1.0, x2 = 2.0, x3 = 3.0

# With graph
./computor_v2.py --graph 'X^2 - 4'
```

## Equation Format

Standard form with `=`:
```
5 * X^0 + 4 * X^1 - 9.3 * X^2 = 1 * X^0
```

Simplified:
```
X^2 - 4 = 0
X^3 - 6*X^2 + 11*X - 6 = 0
```

## Algorithm

- **Degree 0**: Constant equation
- **Degree 1**: Linear equation (direct solution)
- **Degree 2**: Quadratic formula (including complex roots)
- **Degree 3+**: Newton's method with multiple starting points

## Files

| File | Description |
|------|-------------|
| `computor_v2.py` | Main solver |
| `README.md` | Documentation |

## Author

Implementation for 42 curriculum.
