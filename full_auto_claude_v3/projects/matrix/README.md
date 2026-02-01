# matrix - Enter the Matrix

Comprehensive matrix operations library for linear algebra.

## Features

- Matrix creation (zeros, ones, identity)
- Basic operations (add, subtract, multiply, scalar multiply)
- Transpose
- Determinant calculation
- Matrix inverse (Gauss-Jordan elimination)
- Matrix rank
- LU decomposition
- QR decomposition (Gram-Schmidt)
- Eigenvalue estimation
- Solve linear systems Ax = b
- Vector operations (dot product, cross product, magnitude, normalize)

## Usage

```bash
python3 matrix.py    # Run demos
```

## As a Library

```python
from matrix import Matrix, Vector

# Create matrices
A = Matrix([[1, 2], [3, 4]])
B = Matrix.identity(2)

# Operations
C = A + B           # Addition
D = A * B           # Multiplication
E = A.T             # Transpose
det = A.det()       # Determinant
inv = A.inv()       # Inverse

# Decomposition
L, U = A.lu_decomposition()
Q, R = A.qr_decomposition()

# Solve Ax = b
x = A.solve(b)

# Vectors
v1 = Vector([1, 2, 3])
v2 = Vector([4, 5, 6])
dot = v1.dot(v2)
cross = v1.cross(v2)
```

## Matrix Methods

| Method | Description |
|--------|-------------|
| `zeros(r, c)` | Create zero matrix |
| `ones(r, c)` | Create matrix of ones |
| `identity(n)` | Create identity matrix |
| `transpose()` / `.T` | Matrix transpose |
| `det()` | Determinant |
| `inv()` | Inverse |
| `rank()` | Matrix rank |
| `trace()` | Sum of diagonal |
| `norm(p)` | Matrix norm |
| `lu_decomposition()` | LU factorization |
| `qr_decomposition()` | QR factorization |
| `solve(b)` | Solve Ax = b |

## Author

Implementation for 42 curriculum.
