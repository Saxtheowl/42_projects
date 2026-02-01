"""
Exercise 08 - Lets Make Nice Plots Again
Plot data, prediction line, and loss with distance lines.
"""

import numpy as np
import matplotlib.pyplot as plt
import sys
import os

# Add parent directory for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from ex04.prediction import predict_
from ex07.vec_loss import loss_


def plot_with_loss(x, y, theta):
    """
    Plot the data and prediction line from three non-empty numpy.ndarray.
    Also displays the loss in the title and draws distance lines.

    Args:
        x: has to be an numpy.ndarray, a vector of dimension m * 1.
        y: has to be an numpy.ndarray, a vector of dimension m * 1.
        theta: has to be an numpy.ndarray, a vector of dimension 2 * 1.

    Returns:
        Nothing.

    Raises:
        This function should not raise any Exception.
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

        # Compute loss
        cost = loss_(y, y_hat)
        if cost is None:
            cost = 0.0

        # Create plot
        plt.figure()

        # Plot data points as blue dots
        plt.scatter(x_flat, y_flat, color='blue', label='Data points')

        # Plot prediction line as orange line
        plt.plot(x_flat, y_hat_flat, color='orange', label='Prediction line')

        # Draw vertical lines showing distance from each point to prediction line
        for i in range(len(x_flat)):
            plt.plot([x_flat[i], x_flat[i]], [y_flat[i], y_hat_flat[i]],
                     'r--', linewidth=1)

        plt.xlabel('x')
        plt.ylabel('y')
        plt.title(f'Cost : {cost:.6f}')
        plt.legend()
        plt.grid(True, alpha=0.3)
        plt.show()

    except Exception:
        pass


if __name__ == "__main__":
    # Test examples from subject
    x = np.arange(1, 6)
    y = np.array([11.52434424, 10.62589482, 13.14755699, 18.60682298, 14.14329568])

    # Example 1
    theta1 = np.array([18, -1])
    plot_with_loss(x, y, theta1)

    # Example 2
    theta2 = np.array([14, 0])
    plot_with_loss(x, y, theta2)

    # Example 3
    theta3 = np.array([12, 0.8])
    plot_with_loss(x, y, theta3)
