"""
Exercise 05: Normalization I - Z-score Standardization

Implements the z-score standardization formula:
    x'(i) = (x(i) - mu) / sigma

Where:
    mu = mean of x
    sigma = standard deviation of x
"""
import numpy as np


def zscore(x):
    """
    Computes the normalized version of a non-empty numpy.ndarray using the z-score standardization.

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

        # Flatten if needed for calculation, but preserve shape
        x_flat = x.flatten()

        # Calculate mean (mu)
        mu = np.mean(x_flat)

        # Calculate standard deviation (sigma)
        # Note: Using ddof=0 to match expected output from PDF examples
        sigma = np.std(x_flat, ddof=0)

        # Avoid division by zero
        if sigma == 0:
            return np.zeros_like(x, dtype=float)

        # Calculate z-score
        x_prime = (x - mu) / sigma

        return x_prime

    except Exception:
        return None


if __name__ == "__main__":
    # Example 1:
    X = np.array([0, 15, -9, 7, 12, 3, -21])
    print("Example 1:")
    print(zscore(X))
    # Expected: array([-0.08620324, 1.2068453, -0.86203236, 0.51721942, 0.94823559,
    #                  0.17240647, -1.89647119])

    # Example 2:
    Y = np.array([2, 14, -13, 5, 12, 4, -19]).reshape((-1, 1))
    print("\nExample 2:")
    print(zscore(Y))
    # Expected: array([ 0.11267619, 1.16432067, -1.20187941, 0.37558731, 0.98904659,
    #                   0.28795027, -1.72770165])
