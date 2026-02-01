# Machine Learning - Module 01: Univariate Linear Regression

This module implements gradient descent for linear regression, along with normalization techniques.

## Structure

```
Machine_Learning_-_Module_01/
├── ex00/               # Linear Gradient - Iterative Version
│   └── gradient.py
├── ex01/               # Linear Gradient - Vectorized Version
│   └── vec_gradient.py
├── ex02/               # Gradient Descent (fit function)
│   └── fit.py
├── ex03/               # MyLinearRegression Class
│   └── my_linear_regression.py
├── ex04/               # Practicing Linear Regression
│   ├── linear_model.py
│   └── are_blue_pills_magics.csv
├── ex05/               # Z-score Standardization
│   └── z_score.py
├── ex06/               # Min-max Standardization
│   └── minmax.py
├── tests/              # Test suite
│   └── test_all.py
└── README.md
```

## Requirements

- Python 3.7+
- NumPy
- Pandas (for ex04)
- Matplotlib (for ex04)

## Installation

```bash
pip install numpy pandas matplotlib
```

## Exercises

### Exercise 00: Linear Gradient - Iterative Version

Implements the gradient calculation using a for-loop:

```python
from ex00.gradient import simple_gradient

gradient = simple_gradient(x, y, theta)
```

**Formulas:**
- ∇(J)₀ = (1/m) × Σ(h_θ(x⁽ⁱ⁾) - y⁽ⁱ⁾)
- ∇(J)₁ = (1/m) × Σ(h_θ(x⁽ⁱ⁾) - y⁽ⁱ⁾) × x⁽ⁱ⁾

### Exercise 01: Linear Gradient - Vectorized Version

Implements the gradient calculation using matrix operations (no loops):

```python
from ex01.vec_gradient import simple_gradient

gradient = simple_gradient(x, y, theta)
```

**Formula:**
- ∇(J) = (1/m) × X'ᵀ × (X'θ - y)

### Exercise 02: Gradient Descent

Implements the fit function to train a linear regression model:

```python
from ex02.fit import fit_, predict_

new_theta = fit_(x, y, theta, alpha=5e-8, max_iter=1500000)
y_hat = predict_(x, new_theta)
```

**Algorithm:**
```
repeat max_iter times:
    gradient = compute_gradient(x, y, theta)
    theta = theta - alpha * gradient
```

### Exercise 03: MyLinearRegression Class

A complete linear regression class with all necessary methods:

```python
from ex03.my_linear_regression import MyLinearRegression as MyLR

# Create and train model
lr = MyLR(np.array([[1], [1]]), alpha=5e-8, max_iter=1500000)
lr.fit_(x, y)

# Make predictions
y_hat = lr.predict_(x)

# Calculate loss
loss_elements = lr.loss_elem_(y, y_hat)  # Squared errors
loss = lr.loss_(y, y_hat)                 # Mean squared error / 2
mse = MyLR.mse_(y, y_hat)                 # Mean squared error
```

### Exercise 04: Practicing Linear Regression

A complete program that:
1. Loads the `are_blue_pills_magics.csv` dataset
2. Performs linear regression
3. Creates visualization plots
4. Calculates MSE

```bash
cd ex04
python linear_model.py
```

Outputs:
- `plot_predictions.png`: Scatter plot of predictions vs actual data
- `plot_loss_function.png`: Loss function visualization

### Exercise 05: Z-score Standardization

Normalizes data using z-score (standardization):

```python
from ex05.z_score import zscore

x_normalized = zscore(x)
```

**Formula:**
- x'⁽ⁱ⁾ = (x⁽ⁱ⁾ - μ) / σ

Where μ is the mean and σ is the standard deviation.

### Exercise 06: Min-max Standardization

Normalizes data to the range [0, 1]:

```python
from ex06.minmax import minmax

x_normalized = minmax(x)
```

**Formula:**
- x'⁽ⁱ⁾ = (x⁽ⁱ⁾ - min(x)) / (max(x) - min(x))

## Running Tests

```bash
cd Machine_Learning_-_Module_01
python tests/test_all.py
```

## Key Concepts

### Gradient Descent

Gradient descent is an optimization algorithm that iteratively adjusts parameters to minimize a cost function. For linear regression:

1. **Compute predictions**: ŷ = θ₀ + θ₁x
2. **Calculate error**: error = ŷ - y
3. **Compute gradient**: partial derivatives of cost function J
4. **Update parameters**: θ = θ - α × ∇J

### Learning Rate (α)

- Too large: May overshoot the minimum, causing divergence
- Too small: Slow convergence, requires many iterations
- Optimal: Converges smoothly to minimum

### Normalization

Normalization helps gradient descent converge faster by:
- Scaling features to similar ranges
- Preventing numerical instability
- Improving optimization landscape

## Usage Example

```python
import numpy as np
from ex03.my_linear_regression import MyLinearRegression as MyLR

# Sample data
x = np.array([[1], [2], [3], [4], [5]])
y = np.array([[2], [4], [5], [4], [5]])

# Create and train model
model = MyLR(np.array([[0], [0]]), alpha=0.01, max_iter=1000)
model.fit_(x, y)

# Predictions
predictions = model.predict_(x)
print(f"Theta: {model.thetas.flatten()}")
print(f"MSE: {MyLR.mse_(y, predictions)}")
```

## Author

42 AI - Machine Learning Bootcamp
