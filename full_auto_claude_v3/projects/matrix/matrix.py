#!/usr/bin/env python3
"""
matrix - Enter the Matrix
Complete matrix operations library implementation
"""

import sys
from typing import List, Union, Tuple
from dataclasses import dataclass
import math


@dataclass
class Matrix:
    """Matrix class with comprehensive operations."""
    data: List[List[float]]

    def __post_init__(self):
        if not self.data:
            self.data = [[]]
        self.rows = len(self.data)
        self.cols = len(self.data[0]) if self.data else 0

    @staticmethod
    def zeros(rows: int, cols: int) -> 'Matrix':
        """Create a zero matrix."""
        return Matrix([[0.0] * cols for _ in range(rows)])

    @staticmethod
    def ones(rows: int, cols: int) -> 'Matrix':
        """Create a matrix of ones."""
        return Matrix([[1.0] * cols for _ in range(rows)])

    @staticmethod
    def identity(n: int) -> 'Matrix':
        """Create an identity matrix."""
        data = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
        return Matrix(data)

    @staticmethod
    def from_vector(vec: List[float], column: bool = True) -> 'Matrix':
        """Create a matrix from a vector."""
        if column:
            return Matrix([[x] for x in vec])
        return Matrix([vec])

    def __str__(self) -> str:
        """String representation."""
        if not self.data or not self.data[0]:
            return "[]"

        # Find max width for alignment
        max_width = max(len(f"{x:.4f}") for row in self.data for x in row)

        lines = []
        for row in self.data:
            line = " ".join(f"{x:>{max_width}.4f}" for x in row)
            lines.append(f"[ {line} ]")

        return "\n".join(lines)

    def __repr__(self) -> str:
        return f"Matrix({self.data})"

    def __eq__(self, other: 'Matrix') -> bool:
        if self.rows != other.rows or self.cols != other.cols:
            return False
        for i in range(self.rows):
            for j in range(self.cols):
                if abs(self.data[i][j] - other.data[i][j]) > 1e-10:
                    return False
        return True

    def __add__(self, other: 'Matrix') -> 'Matrix':
        """Matrix addition."""
        if self.rows != other.rows or self.cols != other.cols:
            raise ValueError("Matrix dimensions must match for addition")

        result = Matrix.zeros(self.rows, self.cols)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[i][j] = self.data[i][j] + other.data[i][j]
        return result

    def __sub__(self, other: 'Matrix') -> 'Matrix':
        """Matrix subtraction."""
        if self.rows != other.rows or self.cols != other.cols:
            raise ValueError("Matrix dimensions must match for subtraction")

        result = Matrix.zeros(self.rows, self.cols)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[i][j] = self.data[i][j] - other.data[i][j]
        return result

    def __mul__(self, other: Union['Matrix', float, int]) -> 'Matrix':
        """Matrix multiplication or scalar multiplication."""
        if isinstance(other, (int, float)):
            result = Matrix.zeros(self.rows, self.cols)
            for i in range(self.rows):
                for j in range(self.cols):
                    result.data[i][j] = self.data[i][j] * other
            return result

        if self.cols != other.rows:
            raise ValueError(f"Cannot multiply {self.rows}x{self.cols} by {other.rows}x{other.cols}")

        result = Matrix.zeros(self.rows, other.cols)
        for i in range(self.rows):
            for j in range(other.cols):
                for k in range(self.cols):
                    result.data[i][j] += self.data[i][k] * other.data[k][j]
        return result

    def __rmul__(self, other: Union[float, int]) -> 'Matrix':
        """Right scalar multiplication."""
        return self * other

    def __neg__(self) -> 'Matrix':
        """Negate matrix."""
        return self * -1

    def transpose(self) -> 'Matrix':
        """Return transpose of matrix."""
        result = Matrix.zeros(self.cols, self.rows)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[j][i] = self.data[i][j]
        return result

    @property
    def T(self) -> 'Matrix':
        """Transpose property."""
        return self.transpose()

    def trace(self) -> float:
        """Calculate trace (sum of diagonal)."""
        if self.rows != self.cols:
            raise ValueError("Trace only defined for square matrices")
        return sum(self.data[i][i] for i in range(self.rows))

    def determinant(self) -> float:
        """Calculate determinant using LU decomposition."""
        if self.rows != self.cols:
            raise ValueError("Determinant only defined for square matrices")

        n = self.rows
        if n == 1:
            return self.data[0][0]
        if n == 2:
            return self.data[0][0] * self.data[1][1] - self.data[0][1] * self.data[1][0]

        # LU decomposition with partial pivoting
        matrix = [[self.data[i][j] for j in range(n)] for i in range(n)]
        det = 1.0

        for i in range(n):
            # Find pivot
            max_row = i
            for k in range(i + 1, n):
                if abs(matrix[k][i]) > abs(matrix[max_row][i]):
                    max_row = k

            if max_row != i:
                matrix[i], matrix[max_row] = matrix[max_row], matrix[i]
                det *= -1

            if abs(matrix[i][i]) < 1e-10:
                return 0.0

            det *= matrix[i][i]

            for k in range(i + 1, n):
                factor = matrix[k][i] / matrix[i][i]
                for j in range(i + 1, n):
                    matrix[k][j] -= factor * matrix[i][j]

        return det

    def det(self) -> float:
        """Alias for determinant."""
        return self.determinant()

    def inverse(self) -> 'Matrix':
        """Calculate inverse using Gauss-Jordan elimination."""
        if self.rows != self.cols:
            raise ValueError("Inverse only defined for square matrices")

        n = self.rows

        # Augmented matrix [A | I]
        aug = [[self.data[i][j] for j in range(n)] +
               [1.0 if i == k else 0.0 for k in range(n)]
               for i in range(n)]

        # Forward elimination with partial pivoting
        for i in range(n):
            # Find pivot
            max_row = i
            for k in range(i + 1, n):
                if abs(aug[k][i]) > abs(aug[max_row][i]):
                    max_row = k
            aug[i], aug[max_row] = aug[max_row], aug[i]

            if abs(aug[i][i]) < 1e-10:
                raise ValueError("Matrix is singular")

            # Scale pivot row
            scale = aug[i][i]
            for j in range(2 * n):
                aug[i][j] /= scale

            # Eliminate column
            for k in range(n):
                if k != i:
                    factor = aug[k][i]
                    for j in range(2 * n):
                        aug[k][j] -= factor * aug[i][j]

        # Extract inverse
        return Matrix([[aug[i][j + n] for j in range(n)] for i in range(n)])

    def inv(self) -> 'Matrix':
        """Alias for inverse."""
        return self.inverse()

    def rank(self) -> int:
        """Calculate matrix rank using row echelon form."""
        matrix = [[self.data[i][j] for j in range(self.cols)] for i in range(self.rows)]

        rank = 0
        for col in range(self.cols):
            # Find pivot
            pivot_row = None
            for row in range(rank, self.rows):
                if abs(matrix[row][col]) > 1e-10:
                    pivot_row = row
                    break

            if pivot_row is None:
                continue

            # Swap rows
            matrix[rank], matrix[pivot_row] = matrix[pivot_row], matrix[rank]

            # Eliminate below
            for row in range(rank + 1, self.rows):
                if abs(matrix[row][col]) > 1e-10:
                    factor = matrix[row][col] / matrix[rank][col]
                    for j in range(col, self.cols):
                        matrix[row][j] -= factor * matrix[rank][j]

            rank += 1

        return rank

    def frobenius_norm(self) -> float:
        """Calculate Frobenius norm."""
        return math.sqrt(sum(x * x for row in self.data for x in row))

    def norm(self, p: int = 2) -> float:
        """Calculate matrix norm."""
        if p == 1:
            # Max column sum
            return max(sum(abs(self.data[i][j]) for i in range(self.rows))
                      for j in range(self.cols))
        elif p == 2:
            return self.frobenius_norm()
        elif p == float('inf'):
            # Max row sum
            return max(sum(abs(x) for x in row) for row in self.data)
        else:
            raise ValueError("Unsupported norm")

    def dot(self, other: 'Matrix') -> float:
        """Dot product for vectors."""
        if self.cols != 1 or other.cols != 1:
            raise ValueError("Dot product only for column vectors")
        if self.rows != other.rows:
            raise ValueError("Vectors must have same length")

        return sum(self.data[i][0] * other.data[i][0] for i in range(self.rows))

    def cross(self, other: 'Matrix') -> 'Matrix':
        """Cross product for 3D vectors."""
        if self.rows != 3 or other.rows != 3:
            raise ValueError("Cross product only for 3D vectors")
        if self.cols != 1 or other.cols != 1:
            raise ValueError("Cross product only for column vectors")

        a = [self.data[i][0] for i in range(3)]
        b = [other.data[i][0] for i in range(3)]

        return Matrix([
            [a[1] * b[2] - a[2] * b[1]],
            [a[2] * b[0] - a[0] * b[2]],
            [a[0] * b[1] - a[1] * b[0]]
        ])

    def solve(self, b: 'Matrix') -> 'Matrix':
        """Solve Ax = b using LU decomposition."""
        return self.inverse() * b

    def eigenvalues(self, max_iter: int = 100) -> List[float]:
        """Estimate eigenvalues using QR iteration (simplified)."""
        if self.rows != self.cols:
            raise ValueError("Eigenvalues only for square matrices")

        # Simple power iteration for dominant eigenvalue
        n = self.rows
        v = Matrix.from_vector([1.0] * n)

        for _ in range(max_iter):
            w = self * v
            norm = w.frobenius_norm()
            if norm < 1e-10:
                break
            v = w * (1.0 / norm)

        # Rayleigh quotient
        Av = self * v
        eigenvalue = v.T.dot(Av) / v.T.dot(v) if v.T.dot(v) != 0 else 0

        return [eigenvalue]

    def lu_decomposition(self) -> Tuple['Matrix', 'Matrix']:
        """LU decomposition."""
        if self.rows != self.cols:
            raise ValueError("LU decomposition only for square matrices")

        n = self.rows
        L = Matrix.identity(n)
        U = Matrix([[self.data[i][j] for j in range(n)] for i in range(n)])

        for i in range(n):
            for k in range(i + 1, n):
                if abs(U.data[i][i]) < 1e-10:
                    continue
                factor = U.data[k][i] / U.data[i][i]
                L.data[k][i] = factor
                for j in range(i, n):
                    U.data[k][j] -= factor * U.data[i][j]

        return L, U

    def qr_decomposition(self) -> Tuple['Matrix', 'Matrix']:
        """QR decomposition using Gram-Schmidt."""
        m, n = self.rows, self.cols
        Q = Matrix.zeros(m, n)
        R = Matrix.zeros(n, n)

        for j in range(n):
            # Get column j
            v = [self.data[i][j] for i in range(m)]

            # Orthogonalize against previous columns
            for i in range(j):
                q_i = [Q.data[k][i] for k in range(m)]
                R.data[i][j] = sum(q_i[k] * v[k] for k in range(m))
                for k in range(m):
                    v[k] -= R.data[i][j] * q_i[k]

            # Normalize
            R.data[j][j] = math.sqrt(sum(x * x for x in v))
            if R.data[j][j] > 1e-10:
                for k in range(m):
                    Q.data[k][j] = v[k] / R.data[j][j]

        return Q, R

    def row(self, i: int) -> List[float]:
        """Get row i."""
        return self.data[i][:]

    def col(self, j: int) -> List[float]:
        """Get column j."""
        return [self.data[i][j] for i in range(self.rows)]

    def submatrix(self, row_start: int, row_end: int,
                  col_start: int, col_end: int) -> 'Matrix':
        """Get a submatrix."""
        data = [[self.data[i][j]
                for j in range(col_start, col_end)]
                for i in range(row_start, row_end)]
        return Matrix(data)

    def augment(self, other: 'Matrix') -> 'Matrix':
        """Augment matrix [self | other]."""
        if self.rows != other.rows:
            raise ValueError("Row count must match")

        data = [self.data[i] + other.data[i] for i in range(self.rows)]
        return Matrix(data)

    def stack(self, other: 'Matrix') -> 'Matrix':
        """Stack matrices vertically."""
        if self.cols != other.cols:
            raise ValueError("Column count must match")

        return Matrix(self.data + other.data)


class Vector(Matrix):
    """Vector class (column matrix)."""

    def __init__(self, data: List[float]):
        super().__init__([[x] for x in data])

    @staticmethod
    def from_matrix(m: Matrix) -> 'Vector':
        if m.cols != 1:
            raise ValueError("Matrix must be a column vector")
        return Vector([m.data[i][0] for i in range(m.rows)])

    def __len__(self) -> int:
        return self.rows

    def __getitem__(self, i: int) -> float:
        return self.data[i][0]

    def magnitude(self) -> float:
        """Vector magnitude."""
        return math.sqrt(sum(x[0] ** 2 for x in self.data))

    def normalize(self) -> 'Vector':
        """Return normalized vector."""
        mag = self.magnitude()
        if mag < 1e-10:
            return Vector([0.0] * self.rows)
        return Vector([self.data[i][0] / mag for i in range(self.rows)])


def run_demos():
    """Run demonstration of matrix operations."""
    print("=" * 60)
    print("Matrix Operations Demo")
    print("=" * 60)

    # Basic operations
    print("\n1. Matrix Creation")
    print("-" * 40)

    A = Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    print("A =")
    print(A)

    I = Matrix.identity(3)
    print("\nIdentity(3) =")
    print(I)

    # Arithmetic
    print("\n2. Arithmetic Operations")
    print("-" * 40)

    B = Matrix([[9, 8, 7], [6, 5, 4], [3, 2, 1]])
    print("B =")
    print(B)

    print("\nA + B =")
    print(A + B)

    print("\nA - B =")
    print(A - B)

    print("\n2 * A =")
    print(2 * A)

    # Matrix multiplication
    print("\n3. Matrix Multiplication")
    print("-" * 40)

    C = Matrix([[1, 2], [3, 4], [5, 6]])
    D = Matrix([[7, 8, 9], [10, 11, 12]])

    print("C (3x2) =")
    print(C)
    print("\nD (2x3) =")
    print(D)
    print("\nC * D =")
    print(C * D)

    # Transpose
    print("\n4. Transpose")
    print("-" * 40)
    print("C^T =")
    print(C.T)

    # Determinant
    print("\n5. Determinant")
    print("-" * 40)

    E = Matrix([[1, 2, 3], [0, 1, 4], [5, 6, 0]])
    print("E =")
    print(E)
    print(f"\ndet(E) = {E.det():.4f}")

    # Inverse
    print("\n6. Inverse")
    print("-" * 40)

    F = Matrix([[4, 7], [2, 6]])
    print("F =")
    print(F)
    print("\nF^-1 =")
    print(F.inv())
    print("\nF * F^-1 =")
    print(F * F.inv())

    # LU Decomposition
    print("\n7. LU Decomposition")
    print("-" * 40)

    G = Matrix([[2, 1, 1], [4, 3, 3], [8, 7, 9]])
    print("G =")
    print(G)

    L, U = G.lu_decomposition()
    print("\nL =")
    print(L)
    print("\nU =")
    print(U)
    print("\nL * U =")
    print(L * U)

    # QR Decomposition
    print("\n8. QR Decomposition")
    print("-" * 40)

    H = Matrix([[12, -51, 4], [6, 167, -68], [-4, 24, -41]])
    print("H =")
    print(H)

    Q, R = H.qr_decomposition()
    print("\nQ =")
    print(Q)
    print("\nR =")
    print(R)

    # Rank
    print("\n9. Matrix Rank")
    print("-" * 40)

    J = Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    print("J =")
    print(J)
    print(f"rank(J) = {J.rank()}")

    K = Matrix([[1, 0, 0], [0, 1, 0], [0, 0, 1]])
    print("\nK = Identity(3)")
    print(f"rank(K) = {K.rank()}")

    # Vector operations
    print("\n10. Vector Operations")
    print("-" * 40)

    v1 = Vector([1, 2, 3])
    v2 = Vector([4, 5, 6])

    print(f"v1 = {[v1[i] for i in range(len(v1))]}")
    print(f"v2 = {[v2[i] for i in range(len(v2))]}")
    print(f"|v1| = {v1.magnitude():.4f}")
    print(f"v1 . v2 = {v1.dot(v2):.4f}")

    v3 = v1.cross(v2)
    print(f"v1 x v2 = {[v3[i] for i in range(len(v3))]}")

    # Solve linear system
    print("\n11. Solving Linear Systems")
    print("-" * 40)

    # Ax = b
    A_sys = Matrix([[3, 1], [1, 2]])
    b = Matrix([[9], [8]])

    print("System: Ax = b")
    print("A =")
    print(A_sys)
    print("\nb =")
    print(b)

    x = A_sys.solve(b)
    print("\nx = A^-1 * b =")
    print(x)

    print("\nVerification: A * x =")
    print(A_sys * x)

    print("\n" + "=" * 60)
    print("Matrix operations complete!")
    print("=" * 60)


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--help':
            print("matrix - Matrix Operations Library")
            print("\nUsage:")
            print("  python matrix.py       - Run demos")
            print("  python matrix.py --help - Show this help")
            return

    run_demos()


if __name__ == "__main__":
    main()
