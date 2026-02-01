# Piscine Python for Data Science

Comprehensive Python course covering data science fundamentals.

## Modules

### Module 00: Starting
- Hello World
- Basic functions
- Type checking
- Control flow

### Module 01: Array
- Lists and operations
- 2D arrays (matrices)
- BMI calculator
- Array slicing

### Module 02: DataTable
- Data loading (CSV simulation)
- Data manipulation
- Statistical description
- Data projection

### Module 03: OOP
- Classes and objects
- Operator overloading
- Inheritance
- Diamond problem (MRO)

### Module 04: DOD
- Statistical functions
- Decorators
- Function call limiting
- Context managers

### Module 05: ML Introduction
- Linear regression
- Cost functions (MSE, MAE)
- Data normalization

### Module 06: Matrix Operations
- Matrix addition
- Matrix multiplication
- Transpose
- Trace

## Usage

```bash
# Run all modules
python3 piscine_python_ds.py

# Run specific module
python3 piscine_python_ds.py 0  # Starting
python3 piscine_python_ds.py 5  # ML
python3 piscine_python_ds.py all
```

## Example Output

```
MODULE 05: ML Introduction
==================================================

Ex00 - Linear Regression:
Weight: 1.9945, Bias: 0.1234
R-squared: 0.9987
Predict(5): 10.10
```

## Key Concepts

### Statistics
- Mean, Median, Mode
- Standard Deviation, Variance
- Quartiles

### Linear Regression
```python
y = wx + b
Loss = (1/n) * sum((y_pred - y_true)^2)
```

### Normalization
- Min-Max: (x - min) / (max - min)
- Z-Score: (x - mean) / std

### Matrix Math
- Addition: A + B (element-wise)
- Multiplication: A * B (dot product)
- Transpose: A^T

## Requirements

- Python 3.6+
- No external dependencies

## Author

Implementation for 42 curriculum (data science piscine).
