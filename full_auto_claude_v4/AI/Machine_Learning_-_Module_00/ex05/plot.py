"""
Exercise 05 - Let's Make Nice Plots
Plot data points and prediction line.
"""

import numpy as np
import matplotlib.pyplot as plt
import sys
import os

# Add parent directory for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from ex04.prediction import predict_


def plot(x, y, theta):
    """
    Plot the data and prediction line from three non-empty numpy.array.

    Args:
        x: has to be an numpy.array, a vector of dimension m * 1.
        y: has to be an numpy.array, a vector of dimension m * 1.
        theta: has to be an numpy.array, a vector of dimension 2 * 1.

    Returns:
        Nothing.

    Raises:
        This function should not raise any Exceptions.
    """
    try:
        # Input validation
        if not isinstance(x, np.ndarray) or not isinstance(y, np.ndarray):
            return
        if not isinstance(theta, np.ndarray):
            return
        if x.size == 0 or y.size == 0 or theta.size == 0:
            return

        # Flatten arrays
        x_flat = x.flatten()
        y_flat = y.flatten()

        # Compute predictions
        y_hat = predict_(x, theta)
        if y_hat is None:
            return
        y_hat_flat = y_hat.flatten()

        # Create plot
        plt.figure()

        # Plot data points as blue dots
        plt.scatter(x_flat, y_flat, color='blue', label='Data points')

        # Plot prediction line as orange line
        plt.plot(x_flat, y_hat_flat, color='orange', label='Prediction line')

        plt.xlabel('x')
        plt.ylabel('y')
        plt.legend()
        plt.grid(True, alpha=0.3)
        plt.show()

    except Exception:
        pass


if __name__ == "__main__":
    # Test examples from subject
    x = np.arange(1, 6)
    y = np.array([3.74013816, 3.61473236, 4.57655287, 4.66793434, 5.95585554])

    # Example 1
    theta1 = np.array([[4.5], [-0.2]])
    plot(x, y, theta1)

    # Example 2
    theta2 = np.array([[-1.5], [2]])
    plot(x, y, theta2)

    # Example 3
    theta3 = np.array([[3], [0.3]])
    plot(x, y, theta3)
