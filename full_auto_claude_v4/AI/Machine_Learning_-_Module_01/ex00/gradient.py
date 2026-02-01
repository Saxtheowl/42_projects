"""
Exercise 00: Linear Gradient - Iterative Version

Computes the gradient of the loss function using a for loop.
"""
import numpy as np


def simple_gradient(x, y, theta):
    """
    Computes a gradient vector from three non-empty numpy.array, with a for-loop.
    The three arrays must have compatible shapes.

    Args:
        x: has to be an numpy.array, a vector of shape m * 1.
        y: has to be an numpy.array, a vector of shape m * 1.
        theta: has to be an numpy.array, a 2 * 1 vector.

    Return:
        The gradient as a numpy.array, a vector of shape 2 * 1.
        None if x, y, or theta are empty numpy.array.
        None if x, y and theta do not have compatible shapes.
        None if x, y or theta is not of the expected type.

    Raises:
        This function should not raise any Exception.
    """
    try:
        # Type checking
        if not isinstance(x, np.ndarray) or not isinstance(y, np.ndarray) or not isinstance(theta, np.ndarray):
            return None

        # Empty array check
        if x.size == 0 or y.size == 0 or theta.size == 0:
            return None

        # Reshape if necessary
        x = x.reshape(-1, 1) if x.ndim == 1 else x
        y = y.reshape(-1, 1) if y.ndim == 1 else y
        theta = theta.reshape(-1, 1) if theta.ndim == 1 else theta

        # Shape checking
        m = x.shape[0]
        if y.shape[0] != m or theta.shape != (2, 1):
            return None

        # Initialize gradient
        gradient = np.zeros((2, 1))

        # Compute gradient using for loop
        # h_theta(x) = theta_0 + theta_1 * x
        # nabla(J)_0 = (1/m) * sum(h_theta(x^i) - y^i)
        # nabla(J)_1 = (1/m) * sum((h_theta(x^i) - y^i) * x^i)

        for i in range(m):
            h_theta = theta[0, 0] + theta[1, 0] * x[i, 0]
            error = h_theta - y[i, 0]
            gradient[0, 0] += error
            gradient[1, 0] += error * x[i, 0]

        gradient = gradient / m

        return gradient

    except Exception:
        return None


if __name__ == "__main__":
    x = np.array([12.4956442, 21.5007972, 31.5527382, 48.9145838, 57.5088733]).reshape((-1, 1))
    y = np.array([37.4013816, 36.1473236, 45.7655287, 46.6793434, 59.5585554]).reshape((-1, 1))

    # Example 0:
    theta1 = np.array([2, 0.7]).reshape((-1, 1))
    print("Example 0:")
    print(simple_gradient(x, y, theta1))
    # Expected: array([[-19.0342574], [-586.66875564]])

    # Example 1:
    theta2 = np.array([1, -0.4]).reshape((-1, 1))
    print("\nExample 1:")
    print(simple_gradient(x, y, theta2))
    # Expected: array([[-57.86823748], [-2230.12297889]])
