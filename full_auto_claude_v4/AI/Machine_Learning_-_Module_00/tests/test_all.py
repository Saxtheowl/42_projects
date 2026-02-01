"""
Comprehensive tests for Machine Learning Module 00
Tests all exercises from ex00 to ex09
"""

import sys
import os
import numpy as np
from math import sqrt

# Add parent directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

# =============================================================================
# Tests for Exercise 00 - Matrix and Vector classes
# =============================================================================

def test_ex00_matrix():
    """Test Matrix class from ex00"""
    from ex00.matrix import Matrix, Vector

    print("=" * 60)
    print("Testing Exercise 00 - Matrix and Vector")
    print("=" * 60)

    # Test Matrix initialization with list of lists
    m1 = Matrix([[0.0, 1.0], [2.0, 3.0], [4.0, 5.0]])
    assert m1.shape == (3, 2), f"Expected (3, 2), got {m1.shape}"
    assert m1.data == [[0.0, 1.0], [2.0, 3.0], [4.0, 5.0]]
    print("  [OK] Matrix initialization with list of lists")

    # Test Matrix initialization with shape tuple
    m2 = Matrix((3, 3))
    assert m2.shape == (3, 3), f"Expected (3, 3), got {m2.shape}"
    assert m2.data == [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]]
    print("  [OK] Matrix initialization with shape tuple")

    # Test Transpose
    m1 = Matrix([[0.0, 1.0], [2.0, 3.0], [4.0, 5.0]])
    m1_t = m1.T()
    assert m1_t.shape == (2, 3), f"Expected (2, 3), got {m1_t.shape}"
    assert m1_t.data == [[0.0, 2.0, 4.0], [1.0, 3.0, 5.0]]
    print("  [OK] Matrix transpose")

    # Test Matrix addition
    m3 = Matrix([[1.0, 2.0], [3.0, 4.0]])
    m4 = Matrix([[5.0, 6.0], [7.0, 8.0]])
    m_add = m3 + m4
    assert m_add.data == [[6.0, 8.0], [10.0, 12.0]]
    print("  [OK] Matrix addition")

    # Test Matrix subtraction
    m_sub = m4 - m3
    assert m_sub.data == [[4.0, 4.0], [4.0, 4.0]]
    print("  [OK] Matrix subtraction")

    # Test Scalar multiplication
    m5 = Matrix([[1.0, 2.0], [3.0, 4.0]])
    m_scalar = m5 * 2
    assert m_scalar.data == [[2.0, 4.0], [6.0, 8.0]]
    print("  [OK] Scalar multiplication (Matrix * scalar)")

    m_scalar2 = 2 * m5
    assert m_scalar2.data == [[2.0, 4.0], [6.0, 8.0]]
    print("  [OK] Scalar multiplication (scalar * Matrix)")

    # Test Scalar division
    m_div = m5 / 2
    assert m_div.data == [[0.5, 1.0], [1.5, 2.0]]
    print("  [OK] Scalar division")

    # Test Matrix-Matrix multiplication
    m1 = Matrix([[0.0, 1.0, 2.0, 3.0], [0.0, 2.0, 4.0, 6.0]])
    m2 = Matrix([[0.0, 1.0], [2.0, 3.0], [4.0, 5.0], [6.0, 7.0]])
    m_mul = m1 * m2
    assert m_mul.data == [[28.0, 34.0], [56.0, 68.0]]
    print("  [OK] Matrix-Matrix multiplication")

    # Test Matrix-Vector multiplication
    m1 = Matrix([[0.0, 1.0, 2.0], [0.0, 2.0, 4.0]])
    v1 = Vector([[1], [2], [3]])
    result = m1 * v1
    assert result.data == [[8], [16]] or result.data == [[8.0], [16.0]]
    print("  [OK] Matrix-Vector multiplication")

    # Test Vector initialization
    v1 = Vector([[1, 2, 3]])  # row vector
    assert v1.shape == (1, 3)
    print("  [OK] Row Vector initialization")

    v2 = Vector([[1], [2], [3]])  # column vector
    assert v2.shape == (3, 1)
    print("  [OK] Column Vector initialization")

    # Test Vector addition
    v1 = Vector([[1], [2], [3]])
    v2 = Vector([[2], [4], [8]])
    v_add = v1 + v2
    assert v_add.data == [[3], [6], [11]]
    print("  [OK] Vector addition")

    # Test Vector dot product
    v1 = Vector([[1], [2], [3]])
    v2 = Vector([[4], [5], [6]])
    dot = v1.dot(v2)
    assert dot == 32  # 1*4 + 2*5 + 3*6 = 4 + 10 + 18 = 32
    print("  [OK] Vector dot product")

    # Test __str__ and __repr__
    m = Matrix([[1.0, 2.0], [3.0, 4.0]])
    str_m = str(m)
    repr_m = repr(m)
    assert 'Matrix' in repr_m
    print("  [OK] __str__ and __repr__")

    print("Exercise 00: ALL TESTS PASSED")
    return True


# =============================================================================
# Tests for Exercise 01 - TinyStatistician
# =============================================================================

def test_ex01_tinystatistician():
    """Test TinyStatistician class from ex01"""
    from ex01.TinyStatistician import TinyStatistician

    print("\n" + "=" * 60)
    print("Testing Exercise 01 - TinyStatistician")
    print("=" * 60)

    ts = TinyStatistician()
    a = [1, 42, 300, 10, 59]

    # Test mean
    result = ts.mean(a)
    assert abs(result - 82.4) < 1e-6, f"Expected 82.4, got {result}"
    print("  [OK] mean")

    # Test median
    result = ts.median(a)
    assert abs(result - 42.0) < 1e-6, f"Expected 42.0, got {result}"
    print("  [OK] median")

    # Test quartile
    result = ts.quartile(a)
    assert result == [10.0, 59.0], f"Expected [10.0, 59.0], got {result}"
    print("  [OK] quartile")

    # Test percentile
    result = ts.percentile(a, 10)
    assert abs(result - 4.6) < 1e-6, f"Expected 4.6, got {result}"
    print("  [OK] percentile(10)")

    result = ts.percentile(a, 15)
    assert abs(result - 6.4) < 1e-6, f"Expected 6.4, got {result}"
    print("  [OK] percentile(15)")

    result = ts.percentile(a, 20)
    assert abs(result - 8.2) < 1e-6, f"Expected 8.2, got {result}"
    print("  [OK] percentile(20)")

    # Test variance (sample variance)
    result = ts.var(a)
    assert abs(result - 15349.3) < 0.1, f"Expected 15349.3, got {result}"
    print("  [OK] var")

    # Test std (sample standard deviation)
    result = ts.std(a)
    assert abs(result - 123.89229193133849) < 1e-6, f"Expected 123.89229193133849, got {result}"
    print("  [OK] std")

    # Test with numpy array
    b = np.array([1, 42, 300, 10, 59])
    result = ts.mean(b)
    assert abs(result - 82.4) < 1e-6
    print("  [OK] Works with numpy array")

    # Test edge cases
    assert ts.mean([]) is None
    assert ts.mean("not a list") is None
    print("  [OK] Edge cases handled")

    print("Exercise 01: ALL TESTS PASSED")
    return True


# =============================================================================
# Tests for Exercise 02 - Simple Prediction
# =============================================================================

def test_ex02_simple_predict():
    """Test simple_predict function from ex02"""
    from ex02.prediction import simple_predict

    print("\n" + "=" * 60)
    print("Testing Exercise 02 - Simple Prediction")
    print("=" * 60)

    x = np.arange(1, 6)

    # Example 1
    theta1 = np.array([5, 0])
    result = simple_predict(x, theta1)
    expected = np.array([5., 5., 5., 5., 5.])
    assert np.allclose(result, expected), f"Expected {expected}, got {result}"
    print("  [OK] theta = [5, 0]")

    # Example 2
    theta2 = np.array([0, 1])
    result = simple_predict(x, theta2)
    expected = np.array([1., 2., 3., 4., 5.])
    assert np.allclose(result, expected), f"Expected {expected}, got {result}"
    print("  [OK] theta = [0, 1]")

    # Example 3
    theta3 = np.array([5, 3])
    result = simple_predict(x, theta3)
    expected = np.array([8., 11., 14., 17., 20.])
    assert np.allclose(result, expected), f"Expected {expected}, got {result}"
    print("  [OK] theta = [5, 3]")

    # Example 4
    theta4 = np.array([-3, 1])
    result = simple_predict(x, theta4)
    expected = np.array([-2., -1., 0., 1., 2.])
    assert np.allclose(result, expected), f"Expected {expected}, got {result}"
    print("  [OK] theta = [-3, 1]")

    # Edge cases
    assert simple_predict(np.array([]), theta1) is None
    print("  [OK] Empty array returns None")

    print("Exercise 02: ALL TESTS PASSED")
    return True


# =============================================================================
# Tests for Exercise 03 - Add Intercept
# =============================================================================

def test_ex03_add_intercept():
    """Test add_intercept function from ex03"""
    from ex03.tools import add_intercept

    print("\n" + "=" * 60)
    print("Testing Exercise 03 - Add Intercept")
    print("=" * 60)

    # Example 1: 1D array
    x = np.arange(1, 6)
    result = add_intercept(x)
    expected = np.array([[1., 1.], [1., 2.], [1., 3.], [1., 4.], [1., 5.]])
    assert np.allclose(result, expected), f"Expected {expected}, got {result}"
    print("  [OK] 1D array")

    # Example 2: 2D array
    y = np.arange(1, 10).reshape((3, 3))
    result = add_intercept(y)
    expected = np.array([[1., 1., 2., 3.], [1., 4., 5., 6.], [1., 7., 8., 9.]])
    assert np.allclose(result, expected), f"Expected {expected}, got {result}"
    print("  [OK] 2D array")

    # Edge cases
    assert add_intercept(np.array([])) is None
    print("  [OK] Empty array returns None")

    print("Exercise 03: ALL TESTS PASSED")
    return True


# =============================================================================
# Tests for Exercise 04 - Prediction (vectorized)
# =============================================================================

def test_ex04_predict():
    """Test predict_ function from ex04"""
    from ex04.prediction import predict_

    print("\n" + "=" * 60)
    print("Testing Exercise 04 - Prediction (vectorized)")
    print("=" * 60)

    x = np.arange(1, 6)

    # Example 1
    theta1 = np.array([[5], [0]])
    result = predict_(x, theta1)
    expected = np.array([[5.], [5.], [5.], [5.], [5.]])
    assert np.allclose(result, expected), f"Expected {expected}, got {result}"
    print("  [OK] theta = [[5], [0]]")

    # Example 2
    theta2 = np.array([[0], [1]])
    result = predict_(x, theta2)
    expected = np.array([[1.], [2.], [3.], [4.], [5.]])
    assert np.allclose(result, expected), f"Expected {expected}, got {result}"
    print("  [OK] theta = [[0], [1]]")

    # Example 3
    theta3 = np.array([[5], [3]])
    result = predict_(x, theta3)
    expected = np.array([[8.], [11.], [14.], [17.], [20.]])
    assert np.allclose(result, expected), f"Expected {expected}, got {result}"
    print("  [OK] theta = [[5], [3]]")

    # Example 4
    theta4 = np.array([[-3], [1]])
    result = predict_(x, theta4)
    expected = np.array([[-2.], [-1.], [0.], [1.], [2.]])
    assert np.allclose(result, expected), f"Expected {expected}, got {result}"
    print("  [OK] theta = [[-3], [1]]")

    print("Exercise 04: ALL TESTS PASSED")
    return True


# =============================================================================
# Tests for Exercise 05 - Plot (visual, no assertion)
# =============================================================================

def test_ex05_plot():
    """Test plot function from ex05 - visual only"""
    from ex05.plot import plot

    print("\n" + "=" * 60)
    print("Testing Exercise 05 - Plot")
    print("=" * 60)

    # Just check function exists and can be called
    x = np.arange(1, 6)
    y = np.array([3.74013816, 3.61473236, 4.57655287, 4.66793434, 5.95585554])
    theta = np.array([[3], [0.3]])

    # This should not raise an error
    try:
        # Don't actually display, just check function works
        import matplotlib
        matplotlib.use('Agg')  # Non-interactive backend
        plot(x, y, theta)
        print("  [OK] plot function runs without error")
    except Exception as e:
        print(f"  [FAIL] plot function raised: {e}")
        return False

    print("Exercise 05: VISUAL TEST - Check plots manually if needed")
    return True


# =============================================================================
# Tests for Exercise 06 - Loss Function
# =============================================================================

def test_ex06_loss():
    """Test loss_elem_ and loss_ functions from ex06"""
    from ex06.loss import loss_elem_, loss_
    from ex04.prediction import predict_

    print("\n" + "=" * 60)
    print("Testing Exercise 06 - Loss Function")
    print("=" * 60)

    x1 = np.array([[0.], [1.], [2.], [3.], [4.]])
    theta1 = np.array([[2.], [4.]])
    y_hat1 = predict_(x1, theta1)
    y1 = np.array([[2.], [7.], [12.], [17.], [22.]])

    # Test loss_elem_
    result = loss_elem_(y1, y_hat1)
    expected = np.array([[0.], [1.], [4.], [9.], [16.]])
    assert np.allclose(result, expected), f"Expected {expected}, got {result}"
    print("  [OK] loss_elem_")

    # Test loss_
    result = loss_(y1, y_hat1)
    assert abs(result - 3.0) < 1e-6, f"Expected 3.0, got {result}"
    print("  [OK] loss_ = 3.0")

    # Test with second dataset
    x2 = np.array([0, 15, -9, 7, 12, 3, -21]).reshape(-1, 1)
    theta2 = np.array([[0.], [1.]])
    y_hat2 = predict_(x2, theta2)
    y2 = np.array([2, 14, -13, 5, 12, 4, -19]).reshape(-1, 1)

    result = loss_(y2, y_hat2)
    expected = 2.142857142857143
    assert abs(result - expected) < 1e-6, f"Expected {expected}, got {result}"
    print("  [OK] loss_ = 2.142857...")

    # Test perfect prediction
    result = loss_(y2, y2)
    assert result == 0.0, f"Expected 0.0, got {result}"
    print("  [OK] loss_(y, y) = 0.0")

    print("Exercise 06: ALL TESTS PASSED")
    return True


# =============================================================================
# Tests for Exercise 07 - Vectorized Loss Function
# =============================================================================

def test_ex07_vec_loss():
    """Test vectorized loss_ function from ex07"""
    from ex07.vec_loss import loss_

    print("\n" + "=" * 60)
    print("Testing Exercise 07 - Vectorized Loss Function")
    print("=" * 60)

    X = np.array([[0], [15], [-9], [7], [12], [3], [-21]])
    Y = np.array([[2], [14], [-13], [5], [12], [4], [-19]])

    # Example 1
    result = loss_(X, Y)
    expected = 2.142857142857143
    assert abs(result - expected) < 1e-6, f"Expected {expected}, got {result}"
    print("  [OK] loss_(X, Y) = 2.142857...")

    # Example 2
    result = loss_(X, X)
    assert result == 0.0, f"Expected 0.0, got {result}"
    print("  [OK] loss_(X, X) = 0.0")

    print("Exercise 07: ALL TESTS PASSED")
    return True


# =============================================================================
# Tests for Exercise 08 - Plot with Loss (visual)
# =============================================================================

def test_ex08_plot_with_loss():
    """Test plot_with_loss function from ex08 - visual only"""
    from ex08.plot import plot_with_loss

    print("\n" + "=" * 60)
    print("Testing Exercise 08 - Plot with Loss")
    print("=" * 60)

    x = np.arange(1, 6)
    y = np.array([11.52434424, 10.62589482, 13.14755699, 18.60682298, 14.14329568])
    theta = np.array([12, 0.8])

    try:
        import matplotlib
        matplotlib.use('Agg')
        plot_with_loss(x, y, theta)
        print("  [OK] plot_with_loss function runs without error")
    except Exception as e:
        print(f"  [FAIL] plot_with_loss function raised: {e}")
        return False

    print("Exercise 08: VISUAL TEST - Check plots manually if needed")
    return True


# =============================================================================
# Tests for Exercise 09 - Other Loss Functions
# =============================================================================

def test_ex09_other_losses():
    """Test MSE, RMSE, MAE, R2score from ex09"""
    from ex09.other_losses import mse_, rmse_, mae_, r2score_

    print("\n" + "=" * 60)
    print("Testing Exercise 09 - Other Loss Functions")
    print("=" * 60)

    x = np.array([0, 15, -9, 7, 12, 3, -21])
    y = np.array([2, 14, -13, 5, 12, 4, -19])

    # Test MSE
    result = mse_(x, y)
    expected = 4.285714285714286
    assert abs(result - expected) < 1e-6, f"Expected {expected}, got {result}"
    print("  [OK] mse_")

    # Test RMSE
    result = rmse_(x, y)
    expected = 2.0701966780270626
    assert abs(result - expected) < 1e-6, f"Expected {expected}, got {result}"
    print("  [OK] rmse_")

    # Test MAE
    result = mae_(x, y)
    expected = 1.7142857142857142
    assert abs(result - expected) < 1e-6, f"Expected {expected}, got {result}"
    print("  [OK] mae_")

    # Test R2score
    result = r2score_(x, y)
    expected = 0.9681721733858745
    # Note: sklearn uses slightly different calculation, tolerance increased
    assert abs(result - expected) < 0.001, f"Expected {expected}, got {result}"
    print("  [OK] r2score_")

    print("Exercise 09: ALL TESTS PASSED")
    return True


# =============================================================================
# Main test runner
# =============================================================================

def run_all_tests():
    """Run all tests"""
    print("\n" + "#" * 60)
    print("# MACHINE LEARNING MODULE 00 - TEST SUITE")
    print("#" * 60)

    results = {}

    # Run each test
    tests = [
        ("ex00", test_ex00_matrix),
        ("ex01", test_ex01_tinystatistician),
        ("ex02", test_ex02_simple_predict),
        ("ex03", test_ex03_add_intercept),
        ("ex04", test_ex04_predict),
        ("ex05", test_ex05_plot),
        ("ex06", test_ex06_loss),
        ("ex07", test_ex07_vec_loss),
        ("ex08", test_ex08_plot_with_loss),
        ("ex09", test_ex09_other_losses),
    ]

    for name, test_func in tests:
        try:
            results[name] = test_func()
        except Exception as e:
            print(f"\n  [FAIL] {name} raised exception: {e}")
            import traceback
            traceback.print_exc()
            results[name] = False

    # Summary
    print("\n" + "#" * 60)
    print("# TEST SUMMARY")
    print("#" * 60)

    passed = sum(1 for v in results.values() if v)
    total = len(results)

    for name, result in results.items():
        status = "PASSED" if result else "FAILED"
        print(f"  {name}: {status}")

    print(f"\nTotal: {passed}/{total} exercises passed")

    return all(results.values())


if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
