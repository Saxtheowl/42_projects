"""
Exercise 06: Normalization II - Min-max Standardization

Implements the min-max standardization formula:
    x'(i) = (x(i) - min(x)) / (max(x) - min(x))

This scales values to the range [0, 1].
"""
import numpy as np


def minmax(x):
    """
    Computes the normalized version of a non-empty numpy.ndarray using the min-max standardization.

    Args:
        x: has to be an numpy.ndarray, a vector.

    Returns:
        x' as a numpy.ndarray.
        None if x is a non-empty numpy.ndarray or not a numpy.ndarray.

    Raises:
        This function shouldn't raise any Exception.
    """
    try:
        # Type checking
        if not isinstance(x, np.ndarray):
            return None

        # Empty array check
        if x.size == 0:
            return None

        # Calculate min and max
        x_min = np.min(x)
        x_max = np.max(x)

        # Avoid division by zero
        if x_max == x_min:
            return np.zeros_like(x, dtype=float)

        # Calculate min-max normalization
        x_prime = (x - x_min) / (x_max - x_min)

        return x_prime

    except Exception:
        return None


if __name__ == "__main__":
    # Example 1:
    X = np.array([0, 15, -9, 7, 12, 3, -21]).reshape((-1, 1))
    print("Example 1:")
    print(minmax(X))
    # Expected: array([0.58333333, 1., 0.33333333, 0.77777778, 0.91666667,
    #                  0.66666667, 0. ])

    # Example 2:
    Y = np.array([2, 14, -13, 5, 12, 4, -19]).reshape((-1, 1))
    print("\nExample 2:")
    print(minmax(Y))
    # Expected: array([0.63636364, 1., 0.18181818, 0.72727273, 0.93939394,
    #                  0.6969697 , 0. ])
