# Machine Learning - Module 00

## Stepping into Machine Learning

This module covers the fundamentals of Machine Learning, including linear algebra basics, statistics, linear regression hypothesis, prediction, and loss functions.

## Project Structure

```
Machine_Learning_-_Module_00/
├── ex00/                  # Matrix and Vector classes
│   ├── matrix.py
│   └── test.py
├── ex01/                  # TinyStatistician
│   └── TinyStatistician.py
├── ex02/                  # Simple Prediction
│   └── prediction.py
├── ex03/                  # Add Intercept
│   └── tools.py
├── ex04/                  # Vectorized Prediction
│   └── prediction.py
├── ex05/                  # Plot
│   └── plot.py
├── ex06/                  # Loss Function
│   └── loss.py
├── ex07/                  # Vectorized Loss Function
│   └── vec_loss.py
├── ex08/                  # Plot with Loss
│   └── plot.py
├── ex09/                  # Other Loss Functions
│   └── other_losses.py
├── tests/                 # Comprehensive test suite
│   └── test_all.py
├── venv/                  # Python virtual environment
└── README.md
```

## Requirements

- Python 3.7+
- NumPy
- Matplotlib

## Installation

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install numpy matplotlib
```

## Running Tests

```bash
# Activate virtual environment
source venv/bin/activate

# Run all tests
python tests/test_all.py

# Run individual exercise test (ex00)
cd ex00 && python test.py
```

## Exercises Overview

### Exercise 00 - The Matrix
Implementation of `Matrix` and `Vector` classes with:
- Initialization (from data or shape)
- Transpose
- Addition, Subtraction
- Scalar multiplication/division
- Matrix-matrix multiplication
- Matrix-vector multiplication
- Vector dot product

**Note:** NumPy is forbidden for this exercise.

### Exercise 01 - TinyStatistician
Statistical methods implementation:
- `mean()`: arithmetic mean
- `median()`: 50th percentile
- `quartile()`: 25th and 75th percentiles
- `percentile(p)`: p-th percentile with interpolation
- `var()`: sample variance (n-1 denominator)
- `std()`: sample standard deviation

### Exercise 02 - Simple Prediction
Implementation of the prediction formula:
```
ŷ = θ₀ + θ₁x
```

### Exercise 03 - Add Intercept
Function to add a column of 1's to the left of a matrix/vector for the linear algebra trick.

### Exercise 04 - Prediction (Vectorized)
Vectorized prediction using matrix multiplication:
```
ŷ = X' · θ
```
where X' is the feature matrix with an intercept column.

### Exercise 05 - Plot
Visualization of data points and prediction line using Matplotlib.

### Exercise 06 - Loss Function
Implementation of the loss function:
```
J(θ) = (1/2m) Σ(ŷᵢ - yᵢ)²
```
- `loss_elem_()`: squared differences
- `loss_()`: half mean squared error

### Exercise 07 - Vectorized Loss Function
Vectorized loss computation using dot product:
```
J(θ) = (1/2m)(ŷ - y)·(ŷ - y)
```

### Exercise 08 - Plot with Loss
Extended visualization showing:
- Data points
- Prediction line
- Loss value in title
- Distance lines from points to predictions

### Exercise 09 - Other Loss Functions
Implementation of additional metrics:
- `mse_()`: Mean Squared Error
- `rmse_()`: Root Mean Squared Error
- `mae_()`: Mean Absolute Error
- `r2score_()`: R² Score (coefficient of determination)

## Mathematical Formulas

### Prediction
```
ŷ = θ₀ + θ₁x
```

### Loss Function (Half MSE)
```
J(θ) = (1/2m) Σᵢ(ŷᵢ - yᵢ)²
```

### Mean Squared Error
```
MSE = (1/m) Σᵢ(ŷᵢ - yᵢ)²
```

### Root Mean Squared Error
```
RMSE = √MSE
```

### Mean Absolute Error
```
MAE = (1/m) Σᵢ|ŷᵢ - yᵢ|
```

### R² Score
```
R² = 1 - (Σᵢ(ŷᵢ - yᵢ)²) / (Σᵢ(yᵢ - ȳ)²)
```

## Test Results

All 10 exercises pass their respective tests:
- ex00: Matrix and Vector operations
- ex01: TinyStatistician methods
- ex02: Simple prediction
- ex03: Add intercept
- ex04: Vectorized prediction
- ex05: Plot function
- ex06: Loss function
- ex07: Vectorized loss
- ex08: Plot with loss
- ex09: Other loss functions

## Key Concepts Learned

1. **Linear Algebra Trick**: Adding an intercept column allows prediction via matrix multiplication
2. **Loss Function**: Measures model performance (lower is better)
3. **MSE/RMSE/MAE**: Different ways to quantify prediction errors
4. **R² Score**: Measures how well predictions match actual values (1.0 = perfect)

## Author

42AI Bootcamp Module - Machine Learning
