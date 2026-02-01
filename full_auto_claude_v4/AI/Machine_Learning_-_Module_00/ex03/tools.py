"""
Exercise 03 - Add Intercept
Add a column of 1's to the left side of a given vector or matrix.
"""

import numpy as np


def add_intercept(x):
    """
    Adds a column of 1's to the non-empty numpy.array x.

    Args:
        x: has to be a numpy.array of dimension m * n.

    Returns:
        X, a numpy.array of dimension m * (n + 1).
        None if x is not a numpy.array.
        None if x is an empty numpy.array.

    Raises:
        This function should not raise any Exception.
    """
    try:
        # Input validation
        if not isinstance(x, np.ndarray):
            return None

        if x.size == 0:
            return None

        # Reshape 1D array to column vector
        if x.ndim == 1:
            x = x.reshape(-1, 1)

        # Get number of rows
        m = x.shape[0]

        # Create column of ones
        ones = np.ones((m, 1))

        # Concatenate ones column to the left of x
        return np.concatenate((ones, x), axis=1)

    except Exception:
        return None
