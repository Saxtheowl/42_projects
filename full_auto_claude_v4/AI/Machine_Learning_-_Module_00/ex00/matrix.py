"""
Exercise 00 - The Matrix
Matrix and Vector classes with basic operations
Forbidden: Numpy
"""


class Matrix:
    """
    Matrix class for basic matrix operations.

    Attributes:
        data: list of lists containing the matrix elements
        shape: tuple (rows, columns) representing matrix dimensions
    """

    def __init__(self, data):
        """
        Initialize a Matrix with either:
        - A list of lists: Matrix([[1.0, 2.0], [3.0, 4.0]])
        - A shape tuple: Matrix((3, 3)) -> zero-filled matrix
        """
        if isinstance(data, list):
            # Initialize from list of lists
            if not data or not all(isinstance(row, list) for row in data):
                raise ValueError("Data must be a non-empty list of lists")
            if not all(len(row) == len(data[0]) for row in data):
                raise ValueError("All rows must have the same length")
            self.data = [[float(val) for val in row] for row in data]
            self.shape = (len(self.data), len(self.data[0]))

        elif isinstance(data, tuple):
            # Initialize from shape tuple
            if len(data) != 2 or not all(isinstance(d, int) and d > 0 for d in data):
                raise ValueError("Shape must be a tuple of two positive integers")
            rows, cols = data
            self.data = [[0.0 for _ in range(cols)] for _ in range(rows)]
            self.shape = data

        else:
            raise TypeError("Matrix must be initialized with list of lists or shape tuple")

    def T(self):
        """Return the transpose of the matrix."""
        rows, cols = self.shape
        transposed = [[self.data[j][i] for j in range(rows)] for i in range(cols)]
        return type(self)(transposed)

    def __add__(self, other):
        """Add two matrices of same dimensions."""
        if not isinstance(other, Matrix):
            raise TypeError("Can only add Matrix to Matrix")
        if self.shape != other.shape:
            raise ValueError(f"Cannot add matrices of different shapes: {self.shape} vs {other.shape}")

        result = [[self.data[i][j] + other.data[i][j]
                   for j in range(self.shape[1])]
                  for i in range(self.shape[0])]
        return type(self)(result)

    def __radd__(self, other):
        """Right addition."""
        return self.__add__(other)

    def __sub__(self, other):
        """Subtract two matrices of same dimensions."""
        if not isinstance(other, Matrix):
            raise TypeError("Can only subtract Matrix from Matrix")
        if self.shape != other.shape:
            raise ValueError(f"Cannot subtract matrices of different shapes: {self.shape} vs {other.shape}")

        result = [[self.data[i][j] - other.data[i][j]
                   for j in range(self.shape[1])]
                  for i in range(self.shape[0])]
        return type(self)(result)

    def __rsub__(self, other):
        """Right subtraction."""
        if not isinstance(other, Matrix):
            raise TypeError("Can only subtract Matrix from Matrix")
        return other.__sub__(self)

    def __truediv__(self, scalar):
        """Divide matrix by scalar."""
        if not isinstance(scalar, (int, float)):
            raise TypeError("Can only divide Matrix by scalar")
        if scalar == 0:
            raise ZeroDivisionError("Cannot divide by zero")

        result = [[self.data[i][j] / scalar
                   for j in range(self.shape[1])]
                  for i in range(self.shape[0])]
        return type(self)(result)

    def __rtruediv__(self, scalar):
        """Right division (scalar / Matrix) - not typically meaningful."""
        raise NotImplementedError("Division of scalar by Matrix is not supported")

    def __mul__(self, other):
        """
        Multiply matrix by:
        - scalar: element-wise multiplication
        - Vector: matrix-vector multiplication (returns Vector if other is Vector)
        - Matrix: matrix-matrix multiplication
        """
        # Scalar multiplication
        if isinstance(other, (int, float)):
            result = [[self.data[i][j] * other
                       for j in range(self.shape[1])]
                      for i in range(self.shape[0])]
            return type(self)(result)

        # Vector multiplication
        if isinstance(other, Vector):
            # Check dimensions: self is (m x n), other must be (n x 1)
            if self.shape[1] != other.shape[0]:
                raise ValueError(f"Cannot multiply Matrix {self.shape} with Vector {other.shape}")

            result = []
            for i in range(self.shape[0]):
                val = sum(self.data[i][j] * other.data[j][0] for j in range(self.shape[1]))
                result.append([val])
            return Vector(result)

        # Matrix multiplication
        if isinstance(other, Matrix):
            if self.shape[1] != other.shape[0]:
                raise ValueError(f"Cannot multiply Matrix {self.shape} with Matrix {other.shape}")

            rows_a, cols_a = self.shape
            rows_b, cols_b = other.shape

            result = [[sum(self.data[i][k] * other.data[k][j] for k in range(cols_a))
                       for j in range(cols_b)]
                      for i in range(rows_a)]
            return Matrix(result)

        raise TypeError(f"Cannot multiply Matrix by {type(other)}")

    def __rmul__(self, other):
        """Right multiplication."""
        # Scalar multiplication is commutative
        if isinstance(other, (int, float)):
            return self.__mul__(other)
        raise TypeError(f"Cannot multiply {type(other)} by Matrix")

    def __str__(self):
        """String representation."""
        rows_str = [str(row) for row in self.data]
        return f"Matrix([{', '.join(rows_str)}])"

    def __repr__(self):
        """Repr representation."""
        return self.__str__()

    def __eq__(self, other):
        """Check equality."""
        if not isinstance(other, Matrix):
            return False
        return self.data == other.data and self.shape == other.shape


class Vector(Matrix):
    """
    Vector class - a Matrix that is either a row vector (1 x n) or column vector (n x 1).

    Inherits from Matrix with additional validation and dot product method.
    """

    def __init__(self, data):
        """
        Initialize a Vector with a list of lists.
        Must be either:
        - Row vector: [[1, 2, 3]]
        - Column vector: [[1], [2], [3]]
        """
        if isinstance(data, tuple):
            # Allow shape initialization for vectors
            if len(data) != 2:
                raise ValueError("Shape must be a tuple of two integers")
            if data[0] != 1 and data[1] != 1:
                raise ValueError("Vector must be either a row (1 x n) or column (n x 1)")
            super().__init__(data)
        elif isinstance(data, list):
            # Validate it's a valid vector
            if not data:
                raise ValueError("Vector cannot be empty")
            if not all(isinstance(row, list) for row in data):
                raise ValueError("Data must be a list of lists")

            # Check if it's a row vector (1 x n) or column vector (n x 1)
            if len(data) == 1:
                # Row vector
                super().__init__(data)
            elif all(len(row) == 1 for row in data):
                # Column vector
                super().__init__(data)
            else:
                raise ValueError("Vector must be either a row (1 x n) or column (n x 1)")
        else:
            raise TypeError("Vector must be initialized with list of lists or shape tuple")

    def dot(self, v):
        """
        Compute the dot product between this vector and v.
        Both vectors must have the same shape.
        """
        if not isinstance(v, Vector):
            raise TypeError("Dot product requires two Vectors")

        # Get the elements as flat lists
        if self.shape[0] == 1:
            # Row vector
            self_flat = self.data[0]
        else:
            # Column vector
            self_flat = [row[0] for row in self.data]

        if v.shape[0] == 1:
            v_flat = v.data[0]
        else:
            v_flat = [row[0] for row in v.data]

        if len(self_flat) != len(v_flat):
            raise ValueError(f"Vectors must have same length for dot product: {len(self_flat)} vs {len(v_flat)}")

        return sum(a * b for a, b in zip(self_flat, v_flat))

    def T(self):
        """Return the transpose of the vector (row <-> column)."""
        result = super().T()
        return Vector(result.data)

    def __add__(self, other):
        """Add two vectors."""
        result = super().__add__(other)
        return Vector(result.data)

    def __sub__(self, other):
        """Subtract two vectors."""
        result = super().__sub__(other)
        return Vector(result.data)

    def __mul__(self, other):
        """Multiply vector by scalar."""
        result = super().__mul__(other)
        if isinstance(result, Matrix) and (result.shape[0] == 1 or result.shape[1] == 1):
            return Vector(result.data)
        return result

    def __rmul__(self, other):
        """Right multiplication."""
        # If other is a Matrix (but not a Vector), let Matrix handle it
        if isinstance(other, Matrix) and not isinstance(other, Vector):
            return other.__mul__(self)
        return self.__mul__(other)

    def __truediv__(self, scalar):
        """Divide vector by scalar."""
        result = super().__truediv__(scalar)
        return Vector(result.data)

    def __str__(self):
        """String representation."""
        rows_str = [str(row) for row in self.data]
        return f"Vector([{', '.join(rows_str)}])"

    def __repr__(self):
        """Repr representation."""
        return self.__str__()
