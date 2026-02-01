#!/usr/bin/env python3
"""
Computor v2 - Advanced Equation Solver
Supports:
- Polynomial equations of any degree
- Matrix operations
- Function definitions
- Complex numbers
- Graphing (ASCII)
"""

import sys
import re
from typing import Dict, List, Optional, Union, Tuple
import math


class Complex:
    """Complex number class."""
    def __init__(self, real: float = 0, imag: float = 0):
        self.real = real
        self.imag = imag
    
    def __str__(self):
        if self.imag == 0:
            return f"{self.real:.6g}"
        if self.real == 0:
            return f"{self.imag:.6g}i"
        sign = '+' if self.imag >= 0 else '-'
        return f"{self.real:.6g} {sign} {abs(self.imag):.6g}i"
    
    def __repr__(self):
        return f"Complex({self.real}, {self.imag})"
    
    def __add__(self, other):
        if isinstance(other, (int, float)):
            return Complex(self.real + other, self.imag)
        return Complex(self.real + other.real, self.imag + other.imag)
    
    def __radd__(self, other):
        return self + other
    
    def __sub__(self, other):
        if isinstance(other, (int, float)):
            return Complex(self.real - other, self.imag)
        return Complex(self.real - other.real, self.imag - other.imag)
    
    def __mul__(self, other):
        if isinstance(other, (int, float)):
            return Complex(self.real * other, self.imag * other)
        return Complex(
            self.real * other.real - self.imag * other.imag,
            self.real * other.imag + self.imag * other.real
        )
    
    def __rmul__(self, other):
        return self * other
    
    def __truediv__(self, other):
        if isinstance(other, (int, float)):
            return Complex(self.real / other, self.imag / other)
        denom = other.real ** 2 + other.imag ** 2
        return Complex(
            (self.real * other.real + self.imag * other.imag) / denom,
            (self.imag * other.real - self.real * other.imag) / denom
        )
    
    def __neg__(self):
        return Complex(-self.real, -self.imag)
    
    def __pow__(self, n):
        if n == 0:
            return Complex(1, 0)
        if n == 1:
            return self
        result = Complex(1, 0)
        for _ in range(int(n)):
            result = result * self
        return result
    
    def modulus(self) -> float:
        return math.sqrt(self.real ** 2 + self.imag ** 2)
    
    def conjugate(self):
        return Complex(self.real, -self.imag)


class Matrix:
    """Matrix class."""
    def __init__(self, data: List[List[float]]):
        self.data = data
        self.rows = len(data)
        self.cols = len(data[0]) if self.rows > 0 else 0
    
    def __str__(self):
        lines = []
        for row in self.data:
            lines.append("[ " + " ".join(f"{x:8.3f}" for x in row) + " ]")
        return "\n".join(lines)
    
    def __add__(self, other):
        if self.rows != other.rows or self.cols != other.cols:
            raise ValueError("Matrix dimensions must match")
        result = [[self.data[i][j] + other.data[i][j] 
                  for j in range(self.cols)] for i in range(self.rows)]
        return Matrix(result)
    
    def __mul__(self, other):
        if isinstance(other, (int, float)):
            result = [[self.data[i][j] * other 
                      for j in range(self.cols)] for i in range(self.rows)]
            return Matrix(result)
        if self.cols != other.rows:
            raise ValueError(f"Cannot multiply {self.rows}x{self.cols} by {other.rows}x{other.cols}")
        result = [[sum(self.data[i][k] * other.data[k][j] for k in range(self.cols))
                  for j in range(other.cols)] for i in range(self.rows)]
        return Matrix(result)
    
    def transpose(self):
        result = [[self.data[j][i] for j in range(self.rows)] for i in range(self.cols)]
        return Matrix(result)
    
    def determinant(self) -> float:
        if self.rows != self.cols:
            raise ValueError("Matrix must be square")
        if self.rows == 1:
            return self.data[0][0]
        if self.rows == 2:
            return self.data[0][0] * self.data[1][1] - self.data[0][1] * self.data[1][0]
        det = 0
        for j in range(self.cols):
            minor = [[self.data[i][k] for k in range(self.cols) if k != j]
                    for i in range(1, self.rows)]
            det += ((-1) ** j) * self.data[0][j] * Matrix(minor).determinant()
        return det


class Polynomial:
    """Polynomial class."""
    def __init__(self, coeffs: Dict[int, float] = None):
        self.coeffs = coeffs or {}
        self._normalize()
    
    def _normalize(self):
        self.coeffs = {k: v for k, v in self.coeffs.items() if abs(v) > 1e-10}
    
    @property
    def degree(self) -> int:
        if not self.coeffs:
            return 0
        return max(self.coeffs.keys())
    
    def __str__(self):
        if not self.coeffs:
            return "0"
        terms = []
        for power in sorted(self.coeffs.keys(), reverse=True):
            coeff = self.coeffs[power]
            if power == 0:
                terms.append(f"{coeff:+.6g}")
            elif power == 1:
                terms.append(f"{coeff:+.6g} * X")
            else:
                terms.append(f"{coeff:+.6g} * X^{power}")
        result = " ".join(terms).strip()
        if result.startswith("+"):
            result = result[1:].strip()
        return result if result else "0"
    
    def __add__(self, other):
        result = dict(self.coeffs)
        for power, coeff in other.coeffs.items():
            result[power] = result.get(power, 0) + coeff
        return Polynomial(result)
    
    def __sub__(self, other):
        result = dict(self.coeffs)
        for power, coeff in other.coeffs.items():
            result[power] = result.get(power, 0) - coeff
        return Polynomial(result)
    
    def __mul__(self, other):
        if isinstance(other, (int, float)):
            return Polynomial({k: v * other for k, v in self.coeffs.items()})
        result = {}
        for p1, c1 in self.coeffs.items():
            for p2, c2 in other.coeffs.items():
                p = p1 + p2
                result[p] = result.get(p, 0) + c1 * c2
        return Polynomial(result)
    
    def evaluate(self, x: Union[float, Complex]) -> Union[float, Complex]:
        result = 0
        for power, coeff in self.coeffs.items():
            if isinstance(x, Complex):
                result = result + (x ** power) * coeff
            else:
                result += coeff * (x ** power)
        return result
    
    def derivative(self):
        result = {}
        for power, coeff in self.coeffs.items():
            if power > 0:
                result[power - 1] = coeff * power
        return Polynomial(result)
    
    def solve(self) -> List[Union[float, Complex]]:
        """Solve polynomial equation."""
        if self.degree == 0:
            if not self.coeffs or self.coeffs.get(0, 0) == 0:
                return ["All real numbers"]
            return []
        
        if self.degree == 1:
            a = self.coeffs.get(1, 0)
            b = self.coeffs.get(0, 0)
            return [-b / a]
        
        if self.degree == 2:
            a = self.coeffs.get(2, 0)
            b = self.coeffs.get(1, 0)
            c = self.coeffs.get(0, 0)
            discriminant = b * b - 4 * a * c
            
            if discriminant > 0:
                sqrt_d = math.sqrt(discriminant)
                return [(-b + sqrt_d) / (2 * a), (-b - sqrt_d) / (2 * a)]
            elif discriminant == 0:
                return [-b / (2 * a)]
            else:
                sqrt_d = math.sqrt(-discriminant)
                return [
                    Complex(-b / (2 * a), sqrt_d / (2 * a)),
                    Complex(-b / (2 * a), -sqrt_d / (2 * a))
                ]
        
        # For higher degrees, use Newton's method to find real roots
        roots = []
        # Try to find roots numerically
        for start in range(-10, 11):
            x = float(start)
            for _ in range(100):
                fx = self.evaluate(x)
                dfx = self.derivative().evaluate(x)
                if abs(dfx) < 1e-10:
                    break
                x_new = x - fx / dfx
                if abs(x_new - x) < 1e-10:
                    # Found a root, check if it's actually close to zero
                    if abs(self.evaluate(x_new)) < 1e-6:
                        # Check if not already in roots
                        is_new = True
                        for r in roots:
                            if abs(r - x_new) < 1e-6:
                                is_new = False
                                break
                        if is_new:
                            roots.append(x_new)
                    break
                x = x_new
        
        return sorted(roots) if roots else ["No real roots found (degree > 2)"]


def parse_polynomial(expr: str) -> Polynomial:
    """Parse a polynomial expression."""
    coeffs = {}
    
    # Remove spaces and standardize
    expr = expr.replace(" ", "").replace("-", "+-")
    
    # Split into terms
    terms = [t for t in expr.split("+") if t]
    
    for term in terms:
        if "X" not in term.upper():
            # Constant term
            try:
                coeffs[0] = coeffs.get(0, 0) + float(term)
            except ValueError:
                pass
        else:
            # Parse coefficient and power
            term = term.replace("x", "X")
            if "^" in term:
                match = re.match(r"([+-]?\d*\.?\d*)\*?X\^(\d+)", term)
                if match:
                    coeff_str, power_str = match.groups()
                    coeff = float(coeff_str) if coeff_str and coeff_str != '+' else 1.0
                    if coeff_str == '-':
                        coeff = -1.0
                    power = int(power_str)
                    coeffs[power] = coeffs.get(power, 0) + coeff
            else:
                match = re.match(r"([+-]?\d*\.?\d*)\*?X", term)
                if match:
                    coeff_str = match.group(1)
                    coeff = float(coeff_str) if coeff_str and coeff_str not in ['+', '-'] else 1.0
                    if coeff_str == '-':
                        coeff = -1.0
                    coeffs[1] = coeffs.get(1, 0) + coeff
    
    return Polynomial(coeffs)


def parse_equation(equation: str) -> Polynomial:
    """Parse an equation and convert to standard form (= 0)."""
    if "=" not in equation:
        return parse_polynomial(equation)
    
    left, right = equation.split("=")
    left_poly = parse_polynomial(left)
    right_poly = parse_polynomial(right)
    
    return left_poly - right_poly


def ascii_graph(poly: Polynomial, x_min: float = -10, x_max: float = 10,
                y_min: float = -10, y_max: float = 10,
                width: int = 60, height: int = 20):
    """Generate ASCII graph of polynomial."""
    canvas = [[' ' for _ in range(width)] for _ in range(height)]
    
    # Draw axes
    x_zero = int((0 - x_min) / (x_max - x_min) * (width - 1))
    y_zero = int((y_max - 0) / (y_max - y_min) * (height - 1))
    
    if 0 <= x_zero < width:
        for y in range(height):
            canvas[y][x_zero] = '|'
    if 0 <= y_zero < height:
        for x in range(width):
            canvas[y_zero][x] = '-'
    if 0 <= x_zero < width and 0 <= y_zero < height:
        canvas[y_zero][x_zero] = '+'
    
    # Plot function
    for x_pixel in range(width):
        x = x_min + (x_pixel / (width - 1)) * (x_max - x_min)
        y = poly.evaluate(x)
        y_pixel = int((y_max - y) / (y_max - y_min) * (height - 1))
        if 0 <= y_pixel < height:
            canvas[y_pixel][x_pixel] = '*'
    
    # Print canvas
    print(f"  y: [{y_min}, {y_max}]")
    for row in canvas:
        print(''.join(row))
    print(f"  x: [{x_min}, {x_max}]")


def main():
    if len(sys.argv) < 2:
        print("Computor v2 - Advanced Equation Solver")
        print()
        print("Usage:")
        print("  ./computor_v2.py 'equation'")
        print()
        print("Examples:")
        print("  ./computor_v2.py '5 * X^0 + 4 * X^1 - 9.3 * X^2 = 1 * X^0'")
        print("  ./computor_v2.py 'X^3 - 6*X^2 + 11*X - 6 = 0'")
        print("  ./computor_v2.py --graph 'X^2 - 4'")
        return
    
    show_graph = "--graph" in sys.argv
    equation = " ".join([a for a in sys.argv[1:] if a != "--graph"])
    
    try:
        poly = parse_equation(equation)
        
        print(f"Input: {equation}")
        print(f"Reduced form: {poly} = 0")
        print(f"Polynomial degree: {poly.degree}")
        print()
        
        solutions = poly.solve()
        
        if not solutions:
            print("No solution.")
        elif solutions == ["All real numbers"]:
            print("Solution: All real numbers are solutions.")
        elif solutions == ["No real roots found (degree > 2)"]:
            print("No real roots found (numerical methods for degree > 2)")
        else:
            print("Solutions:")
            for i, sol in enumerate(solutions, 1):
                print(f"  x{i} = {sol}")
        
        if show_graph:
            print()
            print("Graph:")
            ascii_graph(poly)
        
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
