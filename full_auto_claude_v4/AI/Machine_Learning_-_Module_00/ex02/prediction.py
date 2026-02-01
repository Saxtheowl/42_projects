"""
Exercise 02 - Simple Prediction
Implement the prediction formula: y_hat = theta0 + theta1 * x
Forbidden: any functions which performs prediction
"""

import numpy as np


def simple_predict(x, theta):
    """
    Computes the vector of prediction y_hat from two non-empty numpy.ndarray.

    Args:
        x: has to be an numpy.ndarray, a vector of dimension m * 1.
        theta: has to be an numpy.ndarray, a vector of dimension 2 * 1.

    Returns:
        y_hat as a numpy.ndarray, a vector of dimension m * 1.
        None if x or theta are empty numpy.ndarray.
        None if x or theta dimensions are not appropriate.

    Raises:
        This function should not raise any Exception.
    """
    try:
        # Input validation
        if not isinstance(x, np.ndarray) or not isinstance(theta, np.ndarray):
            return None

        if x.size == 0 or theta.size == 0:
            return None

        # Flatten x if needed
        x_flat = x.flatten()

        # Get theta values
        theta_flat = theta.flatten()
        if len(theta_flat) != 2:
            return None

        theta0 = theta_flat[0]
        theta1 = theta_flat[1]

        # Compute predictions: y_hat[i] = theta0 + theta1 * x[i]
        m = len(x_flat)
        y_hat = np.zeros(m)

        for i in range(m):
            y_hat[i] = theta0 + theta1 * x_flat[i]

        return y_hat

    except Exception:
        return None
