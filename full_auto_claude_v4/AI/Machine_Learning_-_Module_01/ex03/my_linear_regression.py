"""
Exercise 03: Linear Regression with Class

A class containing all methods necessary to perform linear regression.
"""
import numpy as np


class MyLinearRegression:
    """
    Description:
        My personnal linear regression class to fit like a boss.
    """

    def __init__(self, thetas, alpha=0.001, max_iter=1000):
        """
        Initialize the linear regression model.

        Args:
            thetas: numpy.ndarray, initial theta values (2 * 1 vector)
            alpha: float, learning rate (default 0.001)
            max_iter: int, number of iterations (default 1000)
        """
        if isinstance(thetas, np.ndarray):
            self.thetas = thetas.reshape(-1, 1).astype(float).copy()
        else:
            self.thetas = np.array(thetas).reshape(-1, 1).astype(float)
        self.alpha = alpha
        self.max_iter = max_iter

    def predict_(self, x):
        """
        Computes the prediction vector y_hat from a non-empty numpy.array.

        Args:
            x: has to be an numpy.array, a vector of dimension m * 1.

        Returns:
            y_hat as a numpy.array, a vector of dimension m * 1.
            None if x is an empty numpy.array or not of expected type.

        Raises:
            This function should not raise any Exception.
        """
        try:
            if not isinstance(x, np.ndarray):
                return None

            if x.size == 0:
                return None

            x = x.reshape(-1, 1) if x.ndim == 1 else x

            m = x.shape[0]
            X_prime = np.hstack((np.ones((m, 1)), x))
            y_hat = X_prime @ self.thetas

            return y_hat

        except Exception:
            return None

    def loss_elem_(self, y, y_hat):
        """
        Calculates all the elements (y_pred - y)^2 of the loss function.

        Args:
            y: has to be an numpy.array, a vector of dimension m * 1.
            y_hat: has to be an numpy.array, a vector of dimension m * 1.

        Returns:
            J_elem: numpy.array, a vector of dimension m * 1 containing the squared errors.
            None if there is a dimension matching problem.

        Raises:
            This function should not raise any Exception.
        """
        try:
            if not isinstance(y, np.ndarray) or not isinstance(y_hat, np.ndarray):
                return None

            if y.size == 0 or y_hat.size == 0:
                return None

            y = y.reshape(-1, 1) if y.ndim == 1 else y
            y_hat = y_hat.reshape(-1, 1) if y_hat.ndim == 1 else y_hat

            if y.shape != y_hat.shape:
                return None

            J_elem = (y_hat - y) ** 2

            return J_elem

        except Exception:
            return None

    def loss_(self, y, y_hat):
        """
        Calculates the value of the loss function.

        Args:
            y: has to be an numpy.array, a vector of dimension m * 1.
            y_hat: has to be an numpy.array, a vector of dimension m * 1.

        Returns:
            J_value: float, the value of the loss function.
            None if there is a dimension matching problem.

        Raises:
            This function should not raise any Exception.
        """
        try:
            J_elem = self.loss_elem_(y, y_hat)
            if J_elem is None:
                return None

            m = y.shape[0]
            J_value = float(np.sum(J_elem) / (2 * m))

            return J_value

        except Exception:
            return None

    def _gradient(self, x, y):
        """
        Computes the gradient vector.

        Args:
            x: has to be a numpy.array, a matrix of shape m * 1.
            y: has to be a numpy.array, a vector of shape m * 1.

        Return:
            The gradient as a numpy.ndarray, a vector of dimension 2 * 1.
            None if x or y is an empty numpy.ndarray.

        Raises:
            This function should not raise any Exception.
        """
        try:
            if not isinstance(x, np.ndarray) or not isinstance(y, np.ndarray):
                return None

            if x.size == 0 or y.size == 0:
                return None

            x = x.reshape(-1, 1) if x.ndim == 1 else x
            y = y.reshape(-1, 1) if y.ndim == 1 else y

            m = x.shape[0]
            if y.shape[0] != m:
                return None

            X_prime = np.hstack((np.ones((m, 1)), x))
            y_hat = X_prime @ self.thetas
            gradient = (1 / m) * X_prime.T @ (y_hat - y)

            return gradient

        except Exception:
            return None

    def fit_(self, x, y):
        """
        Description:
            Fits the model to the training dataset contained in x and y.

        Args:
            x: has to be a numpy.ndarray, a vector of dimension m * 1.
            y: has to be a numpy.ndarray, a vector of dimension m * 1.

        Returns:
            self: the fitted model (returns self for method chaining)
            None if there is a matching dimension problem.

        Raises:
            This function should not raise any Exception.
        """
        try:
            if not isinstance(x, np.ndarray) or not isinstance(y, np.ndarray):
                return None

            if x.size == 0 or y.size == 0:
                return None

            x = x.reshape(-1, 1) if x.ndim == 1 else x
            y = y.reshape(-1, 1) if y.ndim == 1 else y

            m = x.shape[0]
            if y.shape[0] != m:
                return None

            # Gradient descent loop
            for _ in range(self.max_iter):
                gradient = self._gradient(x, y)
                if gradient is None:
                    return None
                self.thetas = self.thetas - self.alpha * gradient

            return self

        except Exception:
            return None

    @staticmethod
    def mse_(y, y_hat):
        """
        Calculates the Mean Squared Error between y and y_hat.

        Args:
            y: has to be an numpy.array, a vector of dimension m * 1.
            y_hat: has to be an numpy.array, a vector of dimension m * 1.

        Returns:
            mse: float, the MSE value.
            None if there is a dimension matching problem.

        Raises:
            This function should not raise any Exception.
        """
        try:
            if not isinstance(y, np.ndarray) or not isinstance(y_hat, np.ndarray):
                return None

            if y.size == 0 or y_hat.size == 0:
                return None

            y = y.reshape(-1, 1) if y.ndim == 1 else y
            y_hat = y_hat.reshape(-1, 1) if y_hat.ndim == 1 else y_hat

            if y.shape != y_hat.shape:
                return None

            m = y.shape[0]
            mse = float(np.sum((y_hat - y) ** 2) / m)

            return mse

        except Exception:
            return None


if __name__ == "__main__":
    x = np.array([[12.4956442], [21.5007972], [31.5527382], [48.9145838], [57.5088733]])
    y = np.array([[37.4013816], [36.1473236], [45.7655287], [46.6793434], [59.5585554]])

    lr1 = MyLinearRegression(np.array([[2], [0.7]]))

    # Example 0.0:
    y_hat = lr1.predict_(x)
    print("Example 0.0 - Predictions:")
    print(y_hat)

    # Example 0.1:
    print("\nExample 0.1 - Loss elements:")
    print(lr1.loss_elem_(y, y_hat))

    # Example 0.2:
    print("\nExample 0.2 - Loss:")
    print(lr1.loss_(y, y_hat))

    # Example 1.0:
    lr2 = MyLinearRegression(np.array([[1], [1]]), 5e-8, 1500000)
    lr2.fit_(x, y)
    print("\nExample 1.0 - Fitted thetas:")
    print(lr2.thetas)

    # Example 1.1:
    y_hat = lr2.predict_(x)
    print("\nExample 1.1 - Predictions after fit:")
    print(y_hat)

    # Example 1.2:
    print("\nExample 1.2 - Loss elements after fit:")
    print(lr2.loss_elem_(y, y_hat))

    # Example 1.3:
    print("\nExample 1.3 - Loss after fit:")
    print(lr2.loss_(y, y_hat))
