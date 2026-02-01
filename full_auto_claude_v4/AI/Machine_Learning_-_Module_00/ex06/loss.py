"""
Exercise 06 - Loss Function
Implement loss function: J(theta) = (1/2m) * sum((y_hat - y)^2)
"""

import numpy as np


def loss_elem_(y, y_hat):
    """
    Description:
        Calculates all the elements (y_pred - y)^2 of the loss function.

    Args:
        y: has to be an numpy.array, a vector.
        y_hat: has to be an numpy.array, a vector.

    Returns:
        J_elem: numpy.array, a vector of dimension (number of the training examples, 1).
        None if there is a dimension matching problem between X, Y or theta.
        None if any argument is not of the expected type.

    Raises:
        This function should not raise any Exception.
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

        # Compute (y_hat - y)^2 for each element
        diff = y_hat_vec - y_vec
        return diff ** 2

    except Exception:
        return None


def loss_(y, y_hat):
    """
    Description:
        Calculates the value of loss function.

    Args:
        y: has to be an numpy.array, a vector.
        y_hat: has to be an numpy.array, a vector.

    Returns:
        J_value: has to be a float.
        None if there is a dimension matching problem between X, Y or theta.
        None if any argument is not of the expected type.

    Raises:
        This function should not raise any Exception.
    """
    try:
        # Get element-wise squared errors
        j_elem = loss_elem_(y, y_hat)
        if j_elem is None:
            return None

        # Compute mean and divide by 2
        m = j_elem.shape[0]
        return float(np.sum(j_elem) / (2 * m))

    except Exception:
        return None
