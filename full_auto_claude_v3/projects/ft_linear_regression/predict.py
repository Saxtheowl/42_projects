#!/usr/bin/env python3
"""
ft_linear_regression - Prediction Program
Predicts the price of a car based on its mileage using trained thetas.
"""

import csv
import sys
import os


def load_thetas(filename='thetas.csv'):
    """Load theta values from file. Returns (0, 0) if file doesn't exist."""
    try:
        with open(filename, 'r') as f:
            reader = csv.DictReader(f)
            row = next(reader)
            theta0 = float(row['theta0'])
            theta1 = float(row['theta1'])
            return theta0, theta1
    except FileNotFoundError:
        print("Note: No trained model found (thetas.csv). Using default values (0, 0).")
        print("Run 'python3 train.py' first to train the model.\n")
        return 0.0, 0.0
    except (KeyError, ValueError, StopIteration) as e:
        print(f"Error reading thetas file: {e}")
        return 0.0, 0.0


def estimate_price(mileage, theta0, theta1):
    """
    Calculate estimated price using linear hypothesis.
    estimatePrice(mileage) = θ0 + (θ1 * mileage)
    """
    return theta0 + (theta1 * mileage)


def main():
    # Load trained thetas
    theta0, theta1 = load_thetas()

    print("=" * 50)
    print("  Car Price Estimator (Linear Regression)")
    print("=" * 50)
    print(f"\nModel: price = {theta0:.2f} + ({theta1:.6f} * mileage)")
    print("\nEnter 'q' to quit.\n")

    while True:
        try:
            user_input = input("Enter mileage (km): ")

            if user_input.lower() == 'q':
                print("Goodbye!")
                break

            mileage = float(user_input)

            if mileage < 0:
                print("Error: Mileage cannot be negative.\n")
                continue

            price = estimate_price(mileage, theta0, theta1)

            # Price shouldn't be negative
            if price < 0:
                print(f"Estimated price for {mileage:.0f} km: ~0 (car has no value)")
            else:
                print(f"Estimated price for {mileage:.0f} km: {price:.2f}\n")

        except ValueError:
            print("Error: Please enter a valid number.\n")
        except KeyboardInterrupt:
            print("\nGoodbye!")
            break


if __name__ == '__main__':
    main()
