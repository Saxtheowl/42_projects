"""
Exercise 02: Gradient Descent

Implements linear gradient descent to fit a model to a dataset.
"""
import numpy as np


def predict_(x, theta):
    """
    Computes the prediction vector y_hat from two non-empty numpy.array.

    Args:
        x: has to be an numpy.array, a vector of dimension m * 1.
        theta: has to be an numpy.array, a vector of dimension 2 * 1.

    Returns:
        y_hat as a numpy.array, a vector of dimension m * 1.
        None if x or theta are empty numpy.array.
        None if x or theta dimensions are not appropriate.

    Raises:
        This function should not raise any Exception.
    """
    try:
        if not isinstance(x, np.ndarray) or not isinstance(theta, np.ndarray):
            return None

        if x.size == 0 or theta.size == 0:
            return None

        x = x.reshape(-1, 1) if x.ndim == 1 else x
        theta = theta.reshape(-1, 1) if theta.ndim == 1 else theta

        if theta.shape != (2, 1):
            return None

        m = x.shape[0]
        X_prime = np.hstack((np.ones((m, 1)), x))
        y_hat = X_prime @ theta

        return y_hat

    except Exception:
        return None


def simple_gradient(x, y, theta):
    """
    Computes a gradient vector from three non-empty numpy.array.

    Args:
        x: has to be a numpy.array, a matrix of shape m * 1.
        y: has to be a numpy.array, a vector of shape m * 1.
        theta: has to be a numpy.array, a 2 * 1 vector.

    Return:
        The gradient as a numpy.ndarray, a vector of dimension 2 * 1.
        None if x, y, or theta is an empty numpy.ndarray.

    Raises:
        This function should not raise any Exception.
    """
    try:
        if not isinstance(x, np.ndarray) or not isinstance(y, np.ndarray) or not isinstance(theta, np.ndarray):
            return None

        if x.size == 0 or y.size == 0 or theta.size == 0:
            return None

        x = x.reshape(-1, 1) if x.ndim == 1 else x
        y = y.reshape(-1, 1) if y.ndim == 1 else y
        theta = theta.reshape(-1, 1) if theta.ndim == 1 else theta

        m = x.shape[0]
        if y.shape[0] != m or theta.shape != (2, 1):
            return None

        X_prime = np.hstack((np.ones((m, 1)), x))
        y_hat = X_prime @ theta
        gradient = (1 / m) * X_prime.T @ (y_hat - y)

        return gradient

    except Exception:
        return None


def fit_(x, y, theta, alpha, max_iter):
    """
    Description:
        Fits the model to the training dataset contained in x and y.

    Args:
        x: has to be a numpy.ndarray, a vector of dimension m * 1: (number of training examples, 1).
        y: has to be a numpy.ndarray, a vector of dimension m * 1: (number of training examples, 1).
        theta: has to be a numpy.ndarray, a vector of dimension 2 * 1.
        alpha: has to be a float, the learning rate
        max_iter: has to be an int, the number of iterations done during the gradient descent

    Returns:
        new_theta: numpy.ndarray, a vector of dimension 2 * 1.
        None if there is a matching dimension problem.

    Raises:
        This function should not raise any Exception.
    """
    try:
        # Type checking
        if not isinstance(x, np.ndarray) or not isinstance(y, np.ndarray) or not isinstance(theta, np.ndarray):
            return None
        if not isinstance(alpha, (int, float)) or not isinstance(max_iter, int):
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

        # Make a copy of theta to avoid modifying the original
        new_theta = theta.astype(float).copy()

        # Gradient descent loop
        for _ in range(max_iter):
            gradient = simple_gradient(x, y, new_theta)
            if gradient is None:
                return None
            new_theta = new_theta - alpha * gradient

        return new_theta

    except Exception:
        return None


if __name__ == "__main__":
    x = np.array([[12.4956442], [21.5007972], [31.5527382], [48.9145838], [57.5088733]])
    y = np.array([[37.4013816], [36.1473236], [45.7655287], [46.6793434], [59.5585554]])
    theta = np.array([1, 1]).reshape((-1, 1))

    # Example 0:
    theta1 = fit_(x, y, theta, alpha=5e-8, max_iter=1500000)
    print("Example 0 - Fitted theta:")
    print(theta1)
    # Expected: array([[1.40709365], [1.1150909 ]])

    # Example 1:
    print("\nExample 1 - Predictions:")
    print(predict_(x, theta1))
    # Expected: array([[15.3408728 ], [25.38243697], [36.59126492], [55.95130097], [65.53471499]])
