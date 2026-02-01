#!/usr/bin/env python3
"""
ft_linear_regression - Visualization Program (Bonus)
Plots the data and regression line, calculates precision (R-squared).
"""

import csv
import sys

try:
    import matplotlib.pyplot as plt
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("Warning: matplotlib not installed. Install with 'pip install matplotlib'")
    print("Visualization will be skipped, but precision will still be calculated.\n")


def load_data(filename='data.csv'):
    """Load mileage and price data from CSV file."""
    mileages = []
    prices = []
    try:
        with open(filename, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                mileages.append(float(row['km']))
                prices.append(float(row['price']))
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        sys.exit(1)
    return mileages, prices


def load_thetas(filename='thetas.csv'):
    """Load theta values from file."""
    try:
        with open(filename, 'r') as f:
            reader = csv.DictReader(f)
            row = next(reader)
            theta0 = float(row['theta0'])
            theta1 = float(row['theta1'])
            return theta0, theta1
    except FileNotFoundError:
        print("Error: No trained model found (thetas.csv).")
        print("Run 'python3 train.py' first to train the model.")
        sys.exit(1)
    except (KeyError, ValueError, StopIteration) as e:
        print(f"Error reading thetas file: {e}")
        sys.exit(1)


def estimate_price(mileage, theta0, theta1):
    """Calculate estimated price."""
    return theta0 + (theta1 * mileage)


def calculate_precision(mileages, prices, theta0, theta1):
    """
    Calculate R-squared (coefficient of determination).
    R² = 1 - (SS_res / SS_tot)
    where:
      SS_res = Σ(y_i - ŷ_i)²  (sum of squared residuals)
      SS_tot = Σ(y_i - ȳ)²    (total sum of squares)
    """
    n = len(prices)
    mean_price = sum(prices) / n

    ss_tot = sum((p - mean_price) ** 2 for p in prices)
    ss_res = sum((prices[i] - estimate_price(mileages[i], theta0, theta1)) ** 2
                 for i in range(n))

    if ss_tot == 0:
        return 0.0

    r_squared = 1 - (ss_res / ss_tot)
    return r_squared


def calculate_mse(mileages, prices, theta0, theta1):
    """Calculate Mean Squared Error."""
    n = len(prices)
    mse = sum((prices[i] - estimate_price(mileages[i], theta0, theta1)) ** 2
              for i in range(n)) / n
    return mse


def calculate_mae(mileages, prices, theta0, theta1):
    """Calculate Mean Absolute Error."""
    n = len(prices)
    mae = sum(abs(prices[i] - estimate_price(mileages[i], theta0, theta1))
              for i in range(n)) / n
    return mae


def plot_data(mileages, prices, theta0, theta1):
    """Plot the data points and regression line."""
    if not HAS_MATPLOTLIB:
        return

    plt.figure(figsize=(10, 6))

    # Plot data points
    plt.scatter(mileages, prices, color='blue', label='Actual data', alpha=0.7)

    # Plot regression line
    min_km = min(mileages)
    max_km = max(mileages)
    x_line = [min_km, max_km]
    y_line = [estimate_price(x, theta0, theta1) for x in x_line]
    plt.plot(x_line, y_line, color='red', linewidth=2, label='Regression line')

    plt.xlabel('Mileage (km)')
    plt.ylabel('Price')
    plt.title('Car Price vs Mileage - Linear Regression')
    plt.legend()
    plt.grid(True, alpha=0.3)

    # Save to file
    plt.savefig('regression_plot.png', dpi=150, bbox_inches='tight')
    print("Plot saved to 'regression_plot.png'")

    # Show plot
    plt.show()


def main():
    # Load data and thetas
    mileages, prices = load_data()
    theta0, theta1 = load_thetas()

    print("=" * 50)
    print("  Linear Regression Analysis")
    print("=" * 50)
    print(f"\nModel: price = {theta0:.2f} + ({theta1:.6f} * mileage)")
    print(f"Number of data points: {len(mileages)}")

    # Calculate precision metrics
    r_squared = calculate_precision(mileages, prices, theta0, theta1)
    mse = calculate_mse(mileages, prices, theta0, theta1)
    mae = calculate_mae(mileages, prices, theta0, theta1)
    rmse = mse ** 0.5

    print("\n" + "-" * 50)
    print("Precision Metrics:")
    print("-" * 50)
    print(f"  R-squared (R²):           {r_squared:.4f} ({r_squared * 100:.2f}%)")
    print(f"  Mean Squared Error (MSE): {mse:.2f}")
    print(f"  Root MSE (RMSE):          {rmse:.2f}")
    print(f"  Mean Absolute Error (MAE):{mae:.2f}")

    # Interpretation
    print("\n" + "-" * 50)
    print("Interpretation:")
    print("-" * 50)
    if r_squared >= 0.9:
        print("  Excellent fit! The model explains most of the variance.")
    elif r_squared >= 0.7:
        print("  Good fit. The model captures the trend well.")
    elif r_squared >= 0.5:
        print("  Moderate fit. The model captures some of the pattern.")
    else:
        print("  Poor fit. The linear model may not be appropriate.")

    # Plot
    if HAS_MATPLOTLIB:
        print("\n" + "-" * 50)
        print("Generating plot...")
        plot_data(mileages, prices, theta0, theta1)
    else:
        print("\nInstall matplotlib to see the visualization:")
        print("  pip install matplotlib")


if __name__ == '__main__':
    main()
