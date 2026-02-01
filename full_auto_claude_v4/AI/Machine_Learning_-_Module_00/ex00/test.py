"""
Test file for Exercise 00 - Matrix and Vector classes
"""

from matrix import Matrix, Vector


def test_matrix_basic():
    """Test basic Matrix operations."""
    print("Testing Matrix basic operations...")

    # Test initialization with list of lists
    m1 = Matrix([[0.0, 1.0], [2.0, 3.0], [4.0, 5.0]])
    print(f"m1 = {m1}")
    print(f"m1.shape = {m1.shape}")
    assert m1.shape == (3, 2)

    # Test initialization with shape
    m2 = Matrix((3, 3))
    print(f"m2 = {m2}")
    print(f"m2.shape = {m2.shape}")
    assert m2.shape == (3, 3)
    assert m2.data == [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]]

    print("Basic operations: OK\n")


def test_matrix_transpose():
    """Test Matrix transpose."""
    print("Testing Matrix transpose...")

    m1 = Matrix([[0.0, 1.0], [2.0, 3.0], [4.0, 5.0]])
    print(f"m1 = {m1}")
    print(f"m1.shape = {m1.shape}")

    m1_t = m1.T()
    print(f"m1.T() = {m1_t}")
    print(f"m1.T().shape = {m1_t.shape}")
    assert m1_t.shape == (2, 3)
    assert m1_t.data == [[0.0, 2.0, 4.0], [1.0, 3.0, 5.0]]

    # Double transpose should return original
    m1_tt = m1_t.T()
    assert m1_tt.data == m1.data

    print("Transpose: OK\n")


def test_matrix_addition():
    """Test Matrix addition."""
    print("Testing Matrix addition...")

    m1 = Matrix([[1.0, 2.0], [3.0, 4.0]])
    m2 = Matrix([[5.0, 6.0], [7.0, 8.0]])

    result = m1 + m2
    print(f"{m1} + {m2} = {result}")
    assert result.data == [[6.0, 8.0], [10.0, 12.0]]

    print("Addition: OK\n")


def test_matrix_subtraction():
    """Test Matrix subtraction."""
    print("Testing Matrix subtraction...")

    m1 = Matrix([[5.0, 6.0], [7.0, 8.0]])
    m2 = Matrix([[1.0, 2.0], [3.0, 4.0]])

    result = m1 - m2
    print(f"{m1} - {m2} = {result}")
    assert result.data == [[4.0, 4.0], [4.0, 4.0]]

    print("Subtraction: OK\n")


def test_matrix_scalar_operations():
    """Test Matrix scalar multiplication and division."""
    print("Testing Matrix scalar operations...")

    m1 = Matrix([[1.0, 2.0], [3.0, 4.0]])

    # Scalar multiplication
    result = m1 * 2
    print(f"{m1} * 2 = {result}")
    assert result.data == [[2.0, 4.0], [6.0, 8.0]]

    result = 2 * m1
    print(f"2 * {m1} = {result}")
    assert result.data == [[2.0, 4.0], [6.0, 8.0]]

    # Scalar division
    result = m1 / 2
    print(f"{m1} / 2 = {result}")
    assert result.data == [[0.5, 1.0], [1.5, 2.0]]

    print("Scalar operations: OK\n")


def test_matrix_multiplication():
    """Test Matrix-Matrix multiplication."""
    print("Testing Matrix-Matrix multiplication...")

    m1 = Matrix([[0.0, 1.0, 2.0, 3.0], [0.0, 2.0, 4.0, 6.0]])
    m2 = Matrix([[0.0, 1.0], [2.0, 3.0], [4.0, 5.0], [6.0, 7.0]])

    result = m1 * m2
    print(f"m1 * m2 = {result}")
    assert result.data == [[28.0, 34.0], [56.0, 68.0]]

    print("Matrix-Matrix multiplication: OK\n")


def test_matrix_vector_multiplication():
    """Test Matrix-Vector multiplication."""
    print("Testing Matrix-Vector multiplication...")

    m1 = Matrix([[0.0, 1.0, 2.0], [0.0, 2.0, 4.0]])
    v1 = Vector([[1], [2], [3]])

    result = m1 * v1
    print(f"{m1} * {v1} = {result}")
    # Result should be [[8], [16]] or Vector
    assert result.data == [[8.0], [16.0]]

    print("Matrix-Vector multiplication: OK\n")


def test_vector_basic():
    """Test Vector basic operations."""
    print("Testing Vector basic operations...")

    # Row vector
    v1 = Vector([[1, 2, 3]])
    print(f"Row vector: {v1}, shape = {v1.shape}")
    assert v1.shape == (1, 3)

    # Column vector
    v2 = Vector([[1], [2], [3]])
    print(f"Column vector: {v2}, shape = {v2.shape}")
    assert v2.shape == (3, 1)

    # Invalid vector should raise error
    try:
        v3 = Vector([[1, 2], [3, 4]])
        print("ERROR: Should have raised ValueError for non-vector matrix")
        assert False
    except ValueError:
        print("Correctly rejected non-vector matrix")

    print("Vector basic operations: OK\n")


def test_vector_addition():
    """Test Vector addition."""
    print("Testing Vector addition...")

    v1 = Vector([[1], [2], [3]])
    v2 = Vector([[2], [4], [8]])

    result = v1 + v2
    print(f"{v1} + {v2} = {result}")
    assert result.data == [[3], [6], [11]]

    print("Vector addition: OK\n")


def test_vector_dot_product():
    """Test Vector dot product."""
    print("Testing Vector dot product...")

    v1 = Vector([[1], [2], [3]])
    v2 = Vector([[4], [5], [6]])

    result = v1.dot(v2)
    print(f"{v1}.dot({v2}) = {result}")
    # 1*4 + 2*5 + 3*6 = 4 + 10 + 18 = 32
    assert result == 32

    print("Dot product: OK\n")


def test_examples_from_subject():
    """Test examples from the subject PDF."""
    print("Testing examples from subject PDF...")

    # Example 1
    m1 = Matrix([[0.0, 1.0], [2.0, 3.0], [4.0, 5.0]])
    print(f"m1.shape = {m1.shape}")
    assert m1.shape == (3, 2)

    print(f"m1.T() = {m1.T()}")
    assert m1.T().data == [[0.0, 2.0, 4.0], [1.0, 3.0, 5.0]]

    print(f"m1.T().shape = {m1.T().shape}")
    assert m1.T().shape == (2, 3)

    # Example 2
    m1 = Matrix([[0., 2., 4.], [1., 3., 5.]])
    print(f"m1.shape = {m1.shape}")
    assert m1.shape == (2, 3)

    print(f"m1.T() = {m1.T()}")
    print(f"m1.T().shape = {m1.T().shape}")
    assert m1.T().shape == (3, 2)

    # Example 3 - Matrix multiplication
    m1 = Matrix([[0.0, 1.0, 2.0, 3.0], [0.0, 2.0, 4.0, 6.0]])
    m2 = Matrix([[0.0, 1.0], [2.0, 3.0], [4.0, 5.0], [6.0, 7.0]])
    print(f"m1 * m2 = {m1 * m2}")
    assert (m1 * m2).data == [[28., 34.], [56., 68.]]

    # Example 4 - Matrix-Vector multiplication
    m1 = Matrix([[0.0, 1.0, 2.0], [0.0, 2.0, 4.0]])
    v1 = Vector([[1], [2], [3]])
    print(f"m1 * v1 = {m1 * v1}")

    # Example 5 - Vector addition
    v1 = Vector([[1], [2], [3]])
    v2 = Vector([[2], [4], [8]])
    print(f"v1 + v2 = {v1 + v2}")
    assert (v1 + v2).data == [[3], [6], [11]]

    print("Subject examples: OK\n")


def run_all_tests():
    """Run all tests."""
    print("=" * 60)
    print("EXERCISE 00 - MATRIX AND VECTOR TESTS")
    print("=" * 60 + "\n")

    test_matrix_basic()
    test_matrix_transpose()
    test_matrix_addition()
    test_matrix_subtraction()
    test_matrix_scalar_operations()
    test_matrix_multiplication()
    test_matrix_vector_multiplication()
    test_vector_basic()
    test_vector_addition()
    test_vector_dot_product()
    test_examples_from_subject()

    print("=" * 60)
    print("ALL TESTS PASSED!")
    print("=" * 60)


if __name__ == "__main__":
    run_all_tests()
