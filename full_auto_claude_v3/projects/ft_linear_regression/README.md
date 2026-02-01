# ft_linear_regression

An introduction to machine learning - implementing linear regression with gradient descent.

## Description

This project implements a simple linear regression algorithm to predict car prices based on mileage. The model is trained using gradient descent optimization.

### Linear Hypothesis

```
estimatePrice(mileage) = θ0 + (θ1 * mileage)
```

### Gradient Descent Formulas

```
tmpθ0 = learningRate * (1/m) * Σ(estimatePrice(mileage[i]) - price[i])
tmpθ1 = learningRate * (1/m) * Σ(estimatePrice(mileage[i]) - price[i]) * mileage[i]
```

Where `m` is the number of data points.

## Files

- `train.py` - Training program that performs gradient descent on the dataset
- `predict.py` - Prediction program that estimates car prices
- `visualize.py` - Bonus: Visualization and precision calculation
- `data.csv` - Sample dataset (mileage vs price)
- `thetas.csv` - Saved model parameters (generated after training)

## Usage

### 1. Train the Model

```bash
python3 train.py
```

Optional parameters:
```bash
python3 train.py [data_file] [learning_rate] [iterations]
python3 train.py data.csv 0.5 1000
```

### 2. Predict Prices

```bash
python3 predict.py
```

Enter a mileage when prompted to get the estimated price.

### 3. Visualize Results (Bonus)

```bash
python3 visualize.py
```

Requires matplotlib: `pip install matplotlib`

## Example Output

### Training
```
Loading data from 'data.csv'...
Loaded 24 data points.

Training with learning_rate=0.5, iterations=1000...
------------------------------------------------------------
Iteration 100: theta0 = 0.853523, theta1 = -0.839462, cost = 0.003451
...
Iteration 1000: theta0 = 0.883695, theta1 = -0.862845, cost = 0.002941
------------------------------------------------------------

Final thetas (original scale):
  theta0 = 8499.5996
  theta1 = -0.021448

Linear equation: price = 8499.60 + (-0.021448 * mileage)
Thetas saved to thetas.csv

Example: Estimated price for 100000 km = 6354.80
```

### Prediction
```
==================================================
  Car Price Estimator (Linear Regression)
==================================================

Model: price = 8499.60 + (-0.021448 * mileage)

Enter 'q' to quit.

Enter mileage (km): 100000
Estimated price for 100000 km: 6354.80

Enter mileage (km): 50000
Estimated price for 50000 km: 7427.20
```

### Visualization Output
```
==================================================
  Linear Regression Analysis
==================================================

Model: price = 8499.60 + (-0.021448 * mileage)
Number of data points: 24

--------------------------------------------------
Precision Metrics:
--------------------------------------------------
  R-squared (R²):           0.7330 (73.30%)
  Mean Squared Error (MSE): 3648129.45
  Root MSE (RMSE):          1910.01
  Mean Absolute Error (MAE):1644.81

--------------------------------------------------
Interpretation:
--------------------------------------------------
  Good fit. The model captures the trend well.
```

## Key Concepts

1. **Feature Normalization**: Data is normalized to [0,1] range for stable gradient descent
2. **Gradient Descent**: Iterative optimization to minimize cost function
3. **Simultaneous Update**: θ0 and θ1 are updated at the same time
4. **Denormalization**: Final thetas are converted back to original scale

## Algorithm Steps

1. Load and parse CSV data
2. Normalize mileage and price values
3. Initialize θ0 = 0 and θ1 = 0
4. For each iteration:
   - Calculate prediction errors
   - Compute gradients for θ0 and θ1
   - Update both thetas simultaneously
5. Denormalize thetas for original scale
6. Save trained parameters

## Requirements

- Python 3.x
- matplotlib (optional, for visualization)

## Author

Implementation for 42 curriculum.
