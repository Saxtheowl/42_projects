# Computor v1

A polynomial equation solver that handles equations up to degree 2.

## Description

This program parses and solves polynomial equations, displaying:
- The reduced form of the equation
- The polynomial degree
- The solutions (real or complex)

## Features

- Parses polynomial equations in various formats
- Reduces equations to standard form
- Solves degree 0, 1, and 2 polynomials
- Handles complex solutions for negative discriminants
- No external math libraries (square root implemented from scratch)

## Usage

```bash
chmod +x computor.py
./computor.py "5 * X^0 + 4 * X^1 - 9.3 * X^2 = 1 * X^0"

# or
python3 computor.py "equation"
```

## Examples

### Degree 2 with positive discriminant (two real solutions)
```bash
./computor.py "5 * X^0 + 4 * X^1 - 9.3 * X^2 = 1 * X^0"
```
Output:
```
Reduced form: 4 * X^0 + 4 * X + -9.3 * X^2 = 0
Polynomial degree: 2
Discriminant is strictly positive, the two solutions are:
-0.475131
0.905239
```

### Degree 2 with negative discriminant (complex solutions)
```bash
./computor.py "X^2 + 1 = 0"
```
Output:
```
Reduced form: 1 * X^0 + 1 * X^2 = 0
Polynomial degree: 2
Discriminant is strictly negative, the two complex solutions are:
1i
-1i
```

### Degree 1 (linear equation)
```bash
./computor.py "5 * X^0 + 4 * X^1 = 4 * X^0"
```
Output:
```
Reduced form: 1 * X^0 + 4 * X = 0
Polynomial degree: 1
The solution is:
-0.25
```

### Degree 0 (constant equation)
```bash
./computor.py "5 * X^0 = 5 * X^0"
```
Output:
```
Reduced form: 0 = 0
Polynomial degree: 0
All real numbers are solutions.
```

### Higher degree (unsolvable)
```bash
./computor.py "X^3 + X^2 + X + 1 = 0"
```
Output:
```
Reduced form: 1 * X^0 + 1 * X + 1 * X^2 + 1 * X^3 = 0
Polynomial degree: 3
The polynomial degree is strictly greater than 2, I can't solve.
```

## Equation Format

The equation parser accepts various formats:
- Standard: `5 * X^2 + 4 * X^1 + 3 * X^0 = 0`
- Simplified: `5X^2 + 4X + 3 = 0`
- Lowercase: `5 * x^2 + 4 * x + 3 = 0`

## Algorithm

### Quadratic Formula
For ax² + bx + c = 0:
- Discriminant: Δ = b² - 4ac
- If Δ > 0: Two real solutions x = (-b ± √Δ) / 2a
- If Δ = 0: One solution x = -b / 2a
- If Δ < 0: Two complex solutions x = (-b ± i√|Δ|) / 2a

### Square Root (Newton's Method)
The square root is computed using Newton-Raphson iteration:
```
x_{n+1} = (x_n + n/x_n) / 2
```

## Files

| File | Description |
|------|-------------|
| `computor.py` | Main solver program |
| `README.md` | Documentation |

## Author

Implementation for 42 curriculum.
