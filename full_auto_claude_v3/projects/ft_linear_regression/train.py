#!/usr/bin/env python3
"""
ft_linear_regression - Training Program
Trains a linear regression model using gradient descent.
"""

import csv
import sys
import os


def load_data(filename):
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
    except (KeyError, ValueError) as e:
        print(f"Error: Invalid data format in CSV. {e}")
        sys.exit(1)
    return mileages, prices


def normalize(data):
    """Normalize data to range [0, 1]."""
    min_val = min(data)
    max_val = max(data)
    if max_val == min_val:
        return [0.0] * len(data), min_val, max_val
    normalized = [(x - min_val) / (max_val - min_val) for x in data]
    return normalized, min_val, max_val


def estimate_price(mileage, theta0, theta1):
    """Calculate estimated price using linear hypothesis."""
    return theta0 + (theta1 * mileage)


def train(mileages, prices, learning_rate=0.1, iterations=1000):
    """
    Train the model using gradient descent.

    Formula:
    tmpθ0 = learningRate * (1/m) * Σ(estimatePrice(mileage[i]) - price[i])
    tmpθ1 = learningRate * (1/m) * Σ(estimatePrice(mileage[i]) - price[i]) * mileage[i]
    """
    theta0 = 0.0
    theta1 = 0.0
    m = len(mileages)

    for i in range(iterations):
        # Calculate gradients
        sum_error = 0.0
        sum_error_mileage = 0.0

        for j in range(m):
            error = estimate_price(mileages[j], theta0, theta1) - prices[j]
            sum_error += error
            sum_error_mileage += error * mileages[j]

        # Simultaneously update theta0 and theta1
        tmp_theta0 = learning_rate * (1 / m) * sum_error
        tmp_theta1 = learning_rate * (1 / m) * sum_error_mileage

        theta0 -= tmp_theta0
        theta1 -= tmp_theta1

        # Print progress every 100 iterations
        if (i + 1) % 100 == 0:
            cost = sum((estimate_price(mileages[k], theta0, theta1) - prices[k])**2
                      for k in range(m)) / (2 * m)
            print(f"Iteration {i + 1}: theta0 = {theta0:.6f}, theta1 = {theta1:.6f}, cost = {cost:.6f}")

    return theta0, theta1


def denormalize_thetas(theta0_norm, theta1_norm, km_min, km_max, price_min, price_max):
    """Convert normalized thetas back to original scale."""
    # price_norm = theta0_norm + theta1_norm * km_norm
    # price_norm = (price - price_min) / (price_max - price_min)
    # km_norm = (km - km_min) / (km_max - km_min)
    #
    # Substituting:
    # (price - price_min) / (price_max - price_min) = theta0_norm + theta1_norm * (km - km_min) / (km_max - km_min)
    # price = price_min + (price_max - price_min) * (theta0_norm + theta1_norm * (km - km_min) / (km_max - km_min))
    # price = price_min + (price_max - price_min) * theta0_norm + (price_max - price_min) * theta1_norm * (km - km_min) / (km_max - km_min)
    # price = price_min + (price_max - price_min) * theta0_norm - (price_max - price_min) * theta1_norm * km_min / (km_max - km_min)
    #         + (price_max - price_min) * theta1_norm / (km_max - km_min) * km
    #
    # theta0 = price_min + (price_max - price_min) * theta0_norm - (price_max - price_min) * theta1_norm * km_min / (km_max - km_min)
    # theta1 = (price_max - price_min) * theta1_norm / (km_max - km_min)

    price_range = price_max - price_min
    km_range = km_max - km_min

    theta1 = (price_range * theta1_norm) / km_range
    theta0 = price_min + price_range * theta0_norm - theta1 * km_min

    return theta0, theta1


def save_thetas(theta0, theta1, filename='thetas.csv'):
    """Save theta values to a file."""
    with open(filename, 'w') as f:
        f.write(f"theta0,theta1\n")
        f.write(f"{theta0},{theta1}\n")
    print(f"Thetas saved to {filename}")


def main():
    # Configuration
    data_file = 'data.csv'
    learning_rate = 0.5
    iterations = 1000

    # Allow command line arguments
    if len(sys.argv) > 1:
        data_file = sys.argv[1]
    if len(sys.argv) > 2:
        learning_rate = float(sys.argv[2])
    if len(sys.argv) > 3:
        iterations = int(sys.argv[3])

    print(f"Loading data from '{data_file}'...")
    mileages, prices = load_data(data_file)
    print(f"Loaded {len(mileages)} data points.")

    # Normalize data for better gradient descent convergence
    mileages_norm, km_min, km_max = normalize(mileages)
    prices_norm, price_min, price_max = normalize(prices)

    print(f"\nTraining with learning_rate={learning_rate}, iterations={iterations}...")
    print("-" * 60)

    # Train on normalized data
    theta0_norm, theta1_norm = train(mileages_norm, prices_norm, learning_rate, iterations)

    # Convert back to original scale
    theta0, theta1 = denormalize_thetas(theta0_norm, theta1_norm, km_min, km_max, price_min, price_max)

    print("-" * 60)
    print(f"\nFinal thetas (original scale):")
    print(f"  theta0 = {theta0:.4f}")
    print(f"  theta1 = {theta1:.6f}")
    print(f"\nLinear equation: price = {theta0:.2f} + ({theta1:.6f} * mileage)")

    # Save thetas
    save_thetas(theta0, theta1)

    # Test prediction
    test_km = 100000
    predicted_price = estimate_price(test_km, theta0, theta1)
    print(f"\nExample: Estimated price for {test_km} km = {predicted_price:.2f}")


if __name__ == '__main__':
    main()
