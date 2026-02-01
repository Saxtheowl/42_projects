"""
Exercise 04 - Prediction (vectorized)
Implement prediction using the linear algebra trick: y_hat = X' . theta
"""

import numpy as np
import sys
import os

# Add parent directory for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from ex03.tools import add_intercept


def predict_(x, theta):
    """
    Computes the vector of prediction y_hat from two non-empty numpy.array.

    Args:
        x: has to be an numpy.array, a vector of dimension m * 1.
        theta: has to be an numpy.array, a vector of dimension 2 * 1.

    Returns:
        y_hat as a numpy.array, a vector of dimension m * 1.
        None if x and/or theta are not numpy.array.
        None if x or theta are empty numpy.array.
        None if x or theta dimensions are not appropriate.

    Raises:
        This function should not raise any Exceptions.
    """
    try:
        # Input validation
        if not isinstance(x, np.ndarray) or not isinstance(theta, np.ndarray):
            return None

        if x.size == 0 or theta.size == 0:
            return None

        # Reshape x to column vector if 1D
        if x.ndim == 1:
            x = x.reshape(-1, 1)

        # Ensure theta is 2D column vector
        if theta.ndim == 1:
            theta = theta.reshape(-1, 1)

        if theta.shape[0] != 2:
            return None

        # Add intercept column (column of 1's)
        X_prime = add_intercept(x)
        if X_prime is None:
            return None

        # Compute y_hat = X' . theta
        y_hat = np.dot(X_prime, theta)

        return y_hat

    except Exception:
        return None
