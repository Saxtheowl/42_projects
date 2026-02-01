"""
Exercise 09 - Other Loss Functions
Implement MSE, RMSE, MAE, R2score
"""

import numpy as np


def mse_(y, y_hat):
    """
    Description:
        Calculate the MSE between the predicted output and the real output.

    Args:
        y: has to be a numpy.array, a vector of dimension m * 1.
        y_hat: has to be a numpy.array, a vector of dimension m * 1.

    Returns:
        mse: has to be a float.
        None if there is a matching dimension problem.

    Raises:
        This function should not raise any Exceptions.
    """
    try:
        # Input validation
        if not isinstance(y, np.ndarray) or not isinstance(y_hat, np.ndarray):
            return None

        if y.size == 0 or y_hat.size == 0:
            return None

        # Flatten arrays
        y_flat = y.flatten()
        y_hat_flat = y_hat.flatten()

        if y_flat.shape != y_hat_flat.shape:
            return None

        m = len(y_flat)

        # MSE = (1/m) * sum((y_hat - y)^2)
        diff = y_hat_flat - y_flat
        return float(np.sum(diff ** 2) / m)

    except Exception:
        return None


def rmse_(y, y_hat):
    """
    Description:
        Calculate the RMSE between the predicted output and the real output.

    Args:
        y: has to be a numpy.array, a vector of dimension m * 1.
        y_hat: has to be a numpy.array, a vector of dimension m * 1.

    Returns:
        rmse: has to be a float.
        None if there is a matching dimension problem.

    Raises:
        This function should not raise any Exceptions.
    """
    try:
        mse = mse_(y, y_hat)
        if mse is None:
            return None

        # RMSE = sqrt(MSE)
        return float(np.sqrt(mse))

    except Exception:
        return None


def mae_(y, y_hat):
    """
    Description:
        Calculate the MAE between the predicted output and the real output.

    Args:
        y: has to be a numpy.array, a vector of dimension m * 1.
        y_hat: has to be a numpy.array, a vector of dimension m * 1.

    Returns:
        mae: has to be a float.
        None if there is a matching dimension problem.

    Raises:
        This function should not raise any Exceptions.
    """
    try:
        # Input validation
        if not isinstance(y, np.ndarray) or not isinstance(y_hat, np.ndarray):
            return None

        if y.size == 0 or y_hat.size == 0:
            return None

        # Flatten arrays
        y_flat = y.flatten()
        y_hat_flat = y_hat.flatten()

        if y_flat.shape != y_hat_flat.shape:
            return None

        m = len(y_flat)

        # MAE = (1/m) * sum(|y_hat - y|)
        diff = y_hat_flat - y_flat
        return float(np.sum(np.abs(diff)) / m)

    except Exception:
        return None


def r2score_(y, y_hat):
    """
    Description:
        Calculate the R2score between the predicted output and the output.

    Args:
        y: has to be a numpy.array, a vector of dimension m * 1.
        y_hat: has to be a numpy.array, a vector of dimension m * 1.

    Returns:
        r2score: has to be a float.
        None if there is a matching dimension problem.

    Raises:
        This function should not raise any Exceptions.
    """
    try:
        # Input validation
        if not isinstance(y, np.ndarray) or not isinstance(y_hat, np.ndarray):
            return None

        if y.size == 0 or y_hat.size == 0:
            return None

        # Flatten arrays
        y_flat = y.flatten()
        y_hat_flat = y_hat.flatten()

        if y_flat.shape != y_hat_flat.shape:
            return None

        # R2 = 1 - (sum((y_hat - y)^2) / sum((y - y_mean)^2))
        y_mean = np.mean(y_flat)

        ss_res = np.sum((y_hat_flat - y_flat) ** 2)  # Residual sum of squares
        ss_tot = np.sum((y_flat - y_mean) ** 2)      # Total sum of squares

        if ss_tot == 0:
            return None

        return float(1 - (ss_res / ss_tot))

    except Exception:
        return None
