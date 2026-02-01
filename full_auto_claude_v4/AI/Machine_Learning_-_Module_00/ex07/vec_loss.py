"""
Exercise 07 - Vectorized Loss Function
Implement loss function using dot product: J(theta) = (1/2m) * (y_hat - y) . (y_hat - y)
"""

import numpy as np


def loss_(y, y_hat):
    """
    Computes the half mean squared error of two non-empty numpy.array, without any for loop.
    The two arrays must have the same dimensions.

    Args:
        y: has to be an numpy.array, a vector.
        y_hat: has to be an numpy.array, a vector.

    Returns:
        The half mean squared error of the two vectors as a float.
        None if y or y_hat are empty numpy.array.
        None if y and y_hat does not share the same dimensions.

    Raises:
        This function should not raise any Exceptions.
    """
    try:
        # Input validation
        if not isinstance(y, np.ndarray) or not isinstance(y_hat, np.ndarray):
            return None

        if y.size == 0 or y_hat.size == 0:
            return None

        # Reshape to column vectors if needed
        y_vec = y.reshape(-1, 1) if y.ndim == 1 else y
        y_hat_vec = y_hat.reshape(-1, 1) if y_hat.ndim == 1 else y_hat

        if y_vec.shape != y_hat_vec.shape:
            return None

        # Compute difference
        diff = y_hat_vec - y_vec

        # Compute dot product: (y_hat - y) . (y_hat - y)
        m = y_vec.shape[0]
        dot_product = np.dot(diff.T, diff)[0, 0]

        # Return J(theta) = (1/2m) * dot_product
        return float(dot_product / (2 * m))

    except Exception:
        return None
