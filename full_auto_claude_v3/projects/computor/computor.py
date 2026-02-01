#!/usr/bin/env python3
"""
Computor v1 - Polynomial Equation Solver
Solves polynomial equations up to degree 2
"""

import sys
import re
from typing import Dict, Tuple, Optional

def parse_term(term: str) -> Tuple[float, int]:
    """Parse a single term like '5*X^2' or '3*X' or '2'"""
    term = term.strip()
    if not term:
        return (0, 0)

    # Handle different formats
    # Format: coefficient * X ^ power
    patterns = [
        r'^([+-]?\d*\.?\d*)\s*\*?\s*[xX]\s*\^\s*(\d+)$',  # 5*X^2, X^2, 5X^2
        r'^([+-]?\d*\.?\d*)\s*\*?\s*[xX]$',                # 5*X, X, 5X
        r'^([+-]?\d+\.?\d*)$',                             # 5, -3.5
    ]

    for i, pattern in enumerate(patterns):
        match = re.match(pattern, term)
        if match:
            if i == 0:  # X^power
                coef = match.group(1)
                if coef in ('', '+'):
                    coef = 1
                elif coef == '-':
                    coef = -1
                else:
                    coef = float(coef)
                power = int(match.group(2))
                return (coef, power)
            elif i == 1:  # X (power = 1)
                coef = match.group(1)
                if coef in ('', '+'):
                    coef = 1
                elif coef == '-':
                    coef = -1
                else:
                    coef = float(coef)
                return (coef, 1)
            else:  # constant
                return (float(match.group(1)), 0)

    raise ValueError(f"Cannot parse term: {term}")


def parse_side(side: str) -> Dict[int, float]:
    """Parse one side of the equation"""
    coefficients = {}

    # Add spaces around + and - for easier splitting
    side = re.sub(r'(?<![\^eE])([+-])', r' \1', side)
    terms = side.split()

    current_term = ""
    for token in terms:
        if token in ('+', '-'):
            if current_term:
                coef, power = parse_term(current_term)
                coefficients[power] = coefficients.get(power, 0) + coef
            current_term = token
        else:
            current_term += token

    if current_term:
        coef, power = parse_term(current_term)
        coefficients[power] = coefficients.get(power, 0) + coef

    return coefficients


def parse_equation(equation: str) -> Dict[int, float]:
    """Parse the full equation and return reduced form coefficients"""
    if '=' not in equation:
        raise ValueError("Equation must contain '='")

    left, right = equation.split('=')

    left_coefs = parse_side(left.strip())
    right_coefs = parse_side(right.strip())

    # Move right side to left (subtract)
    result = dict(left_coefs)
    for power, coef in right_coefs.items():
        result[power] = result.get(power, 0) - coef

    # Remove zero coefficients
    result = {k: v for k, v in result.items() if abs(v) > 1e-10}

    return result


def format_reduced(coefficients: Dict[int, float]) -> str:
    """Format the reduced form of the equation"""
    if not coefficients:
        return "0 = 0"

    terms = []
    for power in sorted(coefficients.keys()):
        coef = coefficients[power]
        if abs(coef) < 1e-10:
            continue

        if coef == int(coef):
            coef_str = str(int(coef))
        else:
            coef_str = f"{coef:.6g}"

        if power == 0:
            term = coef_str
        elif power == 1:
            term = f"{coef_str} * X"
        else:
            term = f"{coef_str} * X^{power}"

        if terms and coef > 0:
            terms.append(f"+ {term}")
        else:
            terms.append(term)

    return " ".join(terms) + " = 0"


def get_degree(coefficients: Dict[int, float]) -> int:
    """Get the polynomial degree"""
    if not coefficients:
        return 0
    return max(coefficients.keys())


def sqrt_manual(n: float) -> float:
    """Calculate square root without using math library"""
    if n < 0:
        raise ValueError("Cannot compute square root of negative number")
    if n == 0:
        return 0

    # Newton's method
    x = n
    for _ in range(100):
        x_new = 0.5 * (x + n / x)
        if abs(x_new - x) < 1e-15:
            break
        x = x_new
    return x


def solve_degree0(coefficients: Dict[int, float]) -> Optional[str]:
    """Solve degree 0 equation (constant = 0)"""
    c = coefficients.get(0, 0)
    if abs(c) < 1e-10:
        return "All real numbers are solutions."
    else:
        return "No solution exists."


def solve_degree1(coefficients: Dict[int, float]) -> str:
    """Solve degree 1 equation (bx + c = 0)"""
    b = coefficients.get(1, 0)
    c = coefficients.get(0, 0)

    if abs(b) < 1e-10:
        return solve_degree0({0: c})

    x = -c / b
    if x == int(x):
        return f"The solution is:\n{int(x)}"
    return f"The solution is:\n{x:.6g}"


def solve_degree2(coefficients: Dict[int, float]) -> str:
    """Solve degree 2 equation (ax² + bx + c = 0)"""
    a = coefficients.get(2, 0)
    b = coefficients.get(1, 0)
    c = coefficients.get(0, 0)

    if abs(a) < 1e-10:
        return solve_degree1({1: b, 0: c})

    discriminant = b * b - 4 * a * c

    if abs(discriminant) < 1e-10:
        # One solution (double root)
        x = -b / (2 * a)
        if x == int(x):
            return f"Discriminant is zero, the solution is:\n{int(x)}"
        return f"Discriminant is zero, the solution is:\n{x:.6g}"
    elif discriminant > 0:
        # Two real solutions
        sqrt_d = sqrt_manual(discriminant)
        x1 = (-b - sqrt_d) / (2 * a)
        x2 = (-b + sqrt_d) / (2 * a)
        return f"Discriminant is strictly positive, the two solutions are:\n{x1:.6g}\n{x2:.6g}"
    else:
        # Complex solutions
        real_part = -b / (2 * a)
        imag_part = sqrt_manual(-discriminant) / (2 * a)

        if abs(real_part) < 1e-10:
            return f"Discriminant is strictly negative, the two complex solutions are:\n{imag_part:.6g}i\n-{imag_part:.6g}i"
        else:
            sign = "+" if imag_part >= 0 else "-"
            return f"Discriminant is strictly negative, the two complex solutions are:\n{real_part:.6g} {sign} {abs(imag_part):.6g}i\n{real_part:.6g} {'-' if sign == '+' else '+'} {abs(imag_part):.6g}i"


def solve(equation: str) -> None:
    """Main solving function"""
    try:
        coefficients = parse_equation(equation)

        print(f"Reduced form: {format_reduced(coefficients)}")

        degree = get_degree(coefficients)
        print(f"Polynomial degree: {degree}")

        if degree > 2:
            print("The polynomial degree is strictly greater than 2, I can't solve.")
            return

        if degree == 0:
            print(solve_degree0(coefficients))
        elif degree == 1:
            print(solve_degree1(coefficients))
        else:
            print(solve_degree2(coefficients))

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} \"equation\"")
        print("Example: python3 computor.py \"5 * X^0 + 4 * X^1 - 9.3 * X^2 = 1 * X^0\"")
        sys.exit(1)

    solve(sys.argv[1])


if __name__ == "__main__":
    main()
