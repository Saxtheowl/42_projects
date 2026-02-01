#!/usr/bin/env python3
"""
Piscine Python for Data Science
42 School Project - Data Science Track

Comprehensive demonstration of Python data science concepts.
"""

import sys
import math
import random
import statistics
from typing import List, Tuple, Dict, Any, Optional, Callable
from functools import reduce
from collections import Counter
import csv
import json


# =============================================================================
# Module 00: Starting
# =============================================================================

def module_00():
    """Basic Python introduction."""
    print("\n" + "=" * 60)
    print("MODULE 00: Starting")
    print("=" * 60)

    # Ex00: Hello World
    print("\nEx00 - Hello World:")
    print("Hello World!")

    # Ex01: First function
    print("\nEx01 - First function:")
    def first_function():
        return "Hello from function!"
    print(first_function())

    # Ex02: Countdown
    print("\nEx02 - Countdown:")
    def countdown(n: int):
        for i in range(n, 0, -1):
            print(i, end=" ")
        print("Go!")
    countdown(5)

    # Ex03: NULL not found
    print("\nEx03 - NULL checking:")
    def NULL_not_found(obj) -> int:
        types = {
            type(None): "Nothing",
            float: "Cheese" if obj != obj else None,  # NaN check
            int: "Zero" if obj == 0 else None,
            str: "Empty" if obj == "" else None,
            bool: "Fake" if obj is False else None,
        }
        result = types.get(type(obj))
        if result:
            print(f"{result}: {obj} ({type(obj).__name__})")
            return 0
        print("Type not Found")
        return 1

    NULL_not_found(None)
    NULL_not_found(float('nan'))
    NULL_not_found(0)
    NULL_not_found("")
    NULL_not_found(False)


# =============================================================================
# Module 01: Array
# =============================================================================

def module_01():
    """Arrays and basic operations."""
    print("\n" + "=" * 60)
    print("MODULE 01: Array")
    print("=" * 60)

    # Ex00: Give me args
    print("\nEx00 - Arguments:")
    def give_bmi(height: List[float], weight: List[float]) -> List[float]:
        return [w / (h ** 2) for h, w in zip(height, weight)]

    def apply_limit(bmi: List[float], limit: float) -> List[bool]:
        return [b > limit for b in bmi]

    heights = [1.75, 1.80, 1.65]
    weights = [70, 85, 55]
    bmi = give_bmi(heights, weights)
    print(f"Heights: {heights}")
    print(f"Weights: {weights}")
    print(f"BMI: {[f'{b:.2f}' for b in bmi]}")
    print(f"Above 25: {apply_limit(bmi, 25)}")

    # Ex01: 2D Array
    print("\nEx01 - 2D Array operations:")
    def slice_me(family: List[List], start: int, end: int) -> List[List]:
        print(f"My shape is: ({len(family)}, {len(family[0]) if family else 0})")
        result = family[start:end]
        print(f"My new shape is: ({len(result)}, {len(result[0]) if result else 0})")
        return result

    data = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]]
    print(f"Original: {data}")
    sliced = slice_me(data, 1, 3)
    print(f"Sliced [1:3]: {sliced}")

    # Ex02: Load image (simulation)
    print("\nEx02 - Image loading (simulated):")
    def ft_load(path: str) -> List[List[List[int]]]:
        # Simulate loading a 3x3 RGB image
        return [[[255, 0, 0], [0, 255, 0], [0, 0, 255]],
                [[255, 255, 0], [255, 0, 255], [0, 255, 255]],
                [[128, 128, 128], [0, 0, 0], [255, 255, 255]]]

    img = ft_load("test.jpg")
    print(f"Image shape: ({len(img)}, {len(img[0])}, {len(img[0][0])})")


# =============================================================================
# Module 02: DataTable
# =============================================================================

def module_02():
    """Data manipulation and analysis."""
    print("\n" + "=" * 60)
    print("MODULE 02: DataTable")
    print("=" * 60)

    # Simulate a simple DataFrame
    class DataTable:
        def __init__(self, data: Dict[str, List]):
            self.data = data
            self.columns = list(data.keys())

        def head(self, n: int = 5) -> 'DataTable':
            return DataTable({k: v[:n] for k, v in self.data.items()})

        def describe(self) -> Dict[str, Dict[str, float]]:
            stats = {}
            for col, values in self.data.items():
                if all(isinstance(v, (int, float)) for v in values):
                    stats[col] = {
                        'count': len(values),
                        'mean': statistics.mean(values),
                        'std': statistics.stdev(values) if len(values) > 1 else 0,
                        'min': min(values),
                        '25%': sorted(values)[len(values)//4],
                        '50%': statistics.median(values),
                        '75%': sorted(values)[3*len(values)//4],
                        'max': max(values)
                    }
            return stats

        def __getitem__(self, key):
            if isinstance(key, str):
                return self.data[key]
            return DataTable({k: [v[i] for i in key] for k, v in self.data.items()})

        def __repr__(self):
            rows = ["  ".join(f"{c:>10}" for c in self.columns)]
            n_rows = len(list(self.data.values())[0])
            for i in range(min(5, n_rows)):
                row = [str(self.data[c][i])[:10] for c in self.columns]
                rows.append("  ".join(f"{v:>10}" for v in row))
            if n_rows > 5:
                rows.append("...")
            return "\n".join(rows)

    # Ex00: Load
    print("\nEx00 - Loading data:")
    data = DataTable({
        'name': ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve'],
        'age': [25, 30, 35, 28, 32],
        'score': [85.5, 92.3, 78.9, 95.1, 88.7]
    })
    print(data)

    # Ex01: aff_life (Visualization placeholder)
    print("\nEx01 - Life expectancy analysis:")
    life_data = DataTable({
        'country': ['France', 'Japan', 'USA', 'Brazil', 'India'],
        'life_expectancy': [82.5, 84.2, 78.9, 75.5, 69.7]
    })
    print(life_data)
    print(f"\nMax life expectancy: {max(life_data['life_expectancy'])}")

    # Ex02: aff_pop (Population)
    print("\nEx02 - Population analysis:")
    pop_data = DataTable({
        'year': [2000, 2005, 2010, 2015, 2020],
        'france': [60.9, 63.2, 65.0, 66.5, 67.4],
        'germany': [82.2, 82.5, 81.8, 82.2, 83.2]
    })
    print(pop_data)

    # Ex03: Projection life
    print("\nEx03 - Data projection:")
    stats = data.describe()
    print("\nStatistics for numerical columns:")
    for col, col_stats in stats.items():
        print(f"\n{col}:")
        for stat, value in col_stats.items():
            print(f"  {stat}: {value:.2f}")


# =============================================================================
# Module 03: OOP
# =============================================================================

def module_03():
    """Object-Oriented Programming."""
    print("\n" + "=" * 60)
    print("MODULE 03: OOP")
    print("=" * 60)

    # Ex00: calculator
    print("\nEx00 - Calculator:")
    class Calculator:
        def __init__(self, values: List[float]):
            self.values = values

        def __add__(self, n):
            self.values = [v + n for v in self.values]
            return self

        def __mul__(self, n):
            self.values = [v * n for v in self.values]
            return self

        def __sub__(self, n):
            self.values = [v - n for v in self.values]
            return self

        def __truediv__(self, n):
            if n == 0:
                raise ZeroDivisionError("Cannot divide by zero")
            self.values = [v / n for v in self.values]
            return self

    calc = Calculator([1.0, 2.0, 3.0])
    print(f"Initial: {calc.values}")
    calc + 5
    print(f"After +5: {calc.values}")
    calc * 2
    print(f"After *2: {calc.values}")

    # Ex01: Inheritance
    print("\nEx01 - Inheritance:")
    class Fruit:
        def __init__(self, name: str):
            self.name = name
            self.vitamins = []

    class Apple(Fruit):
        def __init__(self):
            super().__init__("Apple")
            self.vitamins = ['A', 'C']

    class Banana(Fruit):
        def __init__(self):
            super().__init__("Banana")
            self.vitamins = ['B6', 'C']

    apple = Apple()
    banana = Banana()
    print(f"{apple.name}: vitamins {apple.vitamins}")
    print(f"{banana.name}: vitamins {banana.vitamins}")

    # Ex02: DiamondTrap
    print("\nEx02 - Diamond inheritance:")
    class A:
        def method(self):
            return "A"

    class B(A):
        def method(self):
            return "B -> " + super().method()

    class C(A):
        def method(self):
            return "C -> " + super().method()

    class D(B, C):
        def method(self):
            return "D -> " + super().method()

    d = D()
    print(f"Method Resolution Order: {[c.__name__ for c in D.__mro__]}")
    print(f"D.method(): {d.method()}")


# =============================================================================
# Module 04: DOD (Data Oriented Design)
# =============================================================================

def module_04():
    """Data Oriented Design and statistics."""
    print("\n" + "=" * 60)
    print("MODULE 04: DOD")
    print("=" * 60)

    # Ex00: Statistics
    print("\nEx00 - Statistics:")
    def ft_statistics(*args, **kwargs) -> None:
        if not args:
            print("ERROR")
            return
        nums = list(args)
        for stat in kwargs.values():
            if stat == "mean":
                print(f"mean: {sum(nums) / len(nums):.2f}")
            elif stat == "median":
                sorted_nums = sorted(nums)
                mid = len(sorted_nums) // 2
                if len(sorted_nums) % 2:
                    print(f"median: {sorted_nums[mid]:.2f}")
                else:
                    print(f"median: {(sorted_nums[mid-1] + sorted_nums[mid]) / 2:.2f}")
            elif stat == "quartile":
                sorted_nums = sorted(nums)
                q1 = sorted_nums[len(sorted_nums) // 4]
                q3 = sorted_nums[3 * len(sorted_nums) // 4]
                print(f"quartile: [{q1:.2f}, {q3:.2f}]")
            elif stat == "std":
                mean = sum(nums) / len(nums)
                variance = sum((x - mean) ** 2 for x in nums) / len(nums)
                print(f"std: {math.sqrt(variance):.2f}")
            elif stat == "var":
                mean = sum(nums) / len(nums)
                variance = sum((x - mean) ** 2 for x in nums) / len(nums)
                print(f"var: {variance:.2f}")

    ft_statistics(1, 42, 360, 11, 64, toto="mean", tutu="median", tata="quartile")

    # Ex01: callLimit
    print("\nEx01 - Call limiter:")
    def callLimit(limit: int):
        count = [0]
        def decorator(func):
            def wrapper(*args, **kwargs):
                if count[0] < limit:
                    count[0] += 1
                    return func(*args, **kwargs)
                print(f"Error: {func.__name__} call limit reached")
                return None
            return wrapper
        return decorator

    @callLimit(3)
    def limited_func():
        print("Function called!")
        return "OK"

    for i in range(5):
        print(f"Call {i+1}: {limited_func()}")

    # Ex02: callLimit context manager
    print("\nEx02 - Context manager:")
    class MyContextManager:
        def __init__(self, name):
            self.name = name

        def __enter__(self):
            print(f"Entering {self.name}")
            return self

        def __exit__(self, exc_type, exc_val, exc_tb):
            print(f"Exiting {self.name}")
            return False

    with MyContextManager("test") as ctx:
        print(f"Inside context: {ctx.name}")


# =============================================================================
# Module 05: Machine Learning Intro
# =============================================================================

def module_05():
    """Machine Learning fundamentals."""
    print("\n" + "=" * 60)
    print("MODULE 05: ML Introduction")
    print("=" * 60)

    # Ex00: Linear Regression
    print("\nEx00 - Linear Regression:")
    class LinearRegression:
        def __init__(self, learning_rate=0.01, iterations=1000):
            self.lr = learning_rate
            self.iterations = iterations
            self.weights = None
            self.bias = None

        def fit(self, X: List[float], y: List[float]):
            n = len(X)
            self.weights = 0.0
            self.bias = 0.0

            for _ in range(self.iterations):
                y_pred = [self.weights * x + self.bias for x in X]
                dw = (-2/n) * sum((y[i] - y_pred[i]) * X[i] for i in range(n))
                db = (-2/n) * sum(y[i] - y_pred[i] for i in range(n))
                self.weights -= self.lr * dw
                self.bias -= self.lr * db

        def predict(self, X: List[float]) -> List[float]:
            return [self.weights * x + self.bias for x in X]

        def score(self, X: List[float], y: List[float]) -> float:
            y_pred = self.predict(X)
            ss_res = sum((y[i] - y_pred[i])**2 for i in range(len(y)))
            ss_tot = sum((yi - statistics.mean(y))**2 for yi in y)
            return 1 - (ss_res / ss_tot)

    X = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    y = [2.1, 4.2, 5.8, 8.1, 10.3, 12.1, 13.9, 16.2, 18.1, 20.0]

    model = LinearRegression(learning_rate=0.01, iterations=1000)
    model.fit(X, y)
    print(f"Weight: {model.weights:.4f}, Bias: {model.bias:.4f}")
    print(f"R-squared: {model.score(X, y):.4f}")
    print(f"Predict(5): {model.predict([5])[0]:.2f}")

    # Ex01: Cost function
    print("\nEx01 - Cost Function:")
    def mse(y_true: List[float], y_pred: List[float]) -> float:
        return sum((yt - yp)**2 for yt, yp in zip(y_true, y_pred)) / len(y_true)

    def mae(y_true: List[float], y_pred: List[float]) -> float:
        return sum(abs(yt - yp) for yt, yp in zip(y_true, y_pred)) / len(y_true)

    y_true = [3, 5, 2.5, 7]
    y_pred = [2.5, 5, 4, 8]
    print(f"MSE: {mse(y_true, y_pred):.4f}")
    print(f"MAE: {mae(y_true, y_pred):.4f}")

    # Ex02: Normalization
    print("\nEx02 - Normalization:")
    def min_max_scale(data: List[float]) -> List[float]:
        min_val, max_val = min(data), max(data)
        return [(x - min_val) / (max_val - min_val) for x in data]

    def z_score_normalize(data: List[float]) -> List[float]:
        mean = statistics.mean(data)
        std = statistics.stdev(data)
        return [(x - mean) / std for x in data]

    data = [10, 20, 30, 40, 50]
    print(f"Original: {data}")
    print(f"Min-Max: {[f'{x:.2f}' for x in min_max_scale(data)]}")
    print(f"Z-Score: {[f'{x:.2f}' for x in z_score_normalize(data)]}")


# =============================================================================
# Module 06: Matrix Operations
# =============================================================================

def module_06():
    """Matrix operations and linear algebra."""
    print("\n" + "=" * 60)
    print("MODULE 06: Matrix Operations")
    print("=" * 60)

    class Matrix:
        def __init__(self, data: List[List[float]]):
            self.data = data
            self.rows = len(data)
            self.cols = len(data[0]) if data else 0

        def __repr__(self):
            return f"Matrix({self.rows}x{self.cols})"

        def __add__(self, other: 'Matrix') -> 'Matrix':
            if self.rows != other.rows or self.cols != other.cols:
                raise ValueError("Matrix dimensions don't match")
            return Matrix([[self.data[i][j] + other.data[i][j]
                          for j in range(self.cols)]
                          for i in range(self.rows)])

        def __mul__(self, other):
            if isinstance(other, (int, float)):
                return Matrix([[self.data[i][j] * other
                              for j in range(self.cols)]
                              for i in range(self.rows)])
            elif isinstance(other, Matrix):
                if self.cols != other.rows:
                    raise ValueError("Matrix dimensions incompatible for multiplication")
                result = [[sum(self.data[i][k] * other.data[k][j]
                             for k in range(self.cols))
                          for j in range(other.cols)]
                         for i in range(self.rows)]
                return Matrix(result)
            raise TypeError("Unsupported operand type")

        def transpose(self) -> 'Matrix':
            return Matrix([[self.data[j][i] for j in range(self.rows)]
                          for i in range(self.cols)])

        def trace(self) -> float:
            if self.rows != self.cols:
                raise ValueError("Trace only defined for square matrices")
            return sum(self.data[i][i] for i in range(self.rows))

        def print(self):
            for row in self.data:
                print([f"{x:6.2f}" for x in row])

    # Ex00: Matrix addition
    print("\nEx00 - Matrix addition:")
    A = Matrix([[1, 2], [3, 4]])
    B = Matrix([[5, 6], [7, 8]])
    C = A + B
    print("A + B =")
    C.print()

    # Ex01: Matrix multiplication
    print("\nEx01 - Matrix multiplication:")
    D = Matrix([[1, 2, 3], [4, 5, 6]])
    E = Matrix([[7, 8], [9, 10], [11, 12]])
    F = D * E
    print("D * E =")
    F.print()

    # Ex02: Transpose
    print("\nEx02 - Transpose:")
    print("D^T =")
    D.transpose().print()

    # Ex03: Trace
    print("\nEx03 - Trace:")
    G = Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    print(f"Trace(G) = {G.trace()}")


# =============================================================================
# Main
# =============================================================================

def main():
    print("Piscine Python for Data Science")
    print("=" * 60)

    if '--help' in sys.argv:
        print("\nUsage: python piscine_python_ds.py [module]")
        print("\nModules:")
        print("  0 - Starting (basics)")
        print("  1 - Array (lists and 2D)")
        print("  2 - DataTable (data manipulation)")
        print("  3 - OOP (classes)")
        print("  4 - DOD (statistics)")
        print("  5 - ML (machine learning intro)")
        print("  6 - Matrix (linear algebra)")
        print("  all - Run all modules")
        return

    modules = {
        '0': module_00,
        '1': module_01,
        '2': module_02,
        '3': module_03,
        '4': module_04,
        '5': module_05,
        '6': module_06,
    }

    if len(sys.argv) > 1:
        choice = sys.argv[1]
        if choice == 'all':
            for m in modules.values():
                m()
        elif choice in modules:
            modules[choice]()
        else:
            print(f"Unknown module: {choice}")
    else:
        # Run all by default
        for m in modules.values():
            m()


if __name__ == "__main__":
    main()
