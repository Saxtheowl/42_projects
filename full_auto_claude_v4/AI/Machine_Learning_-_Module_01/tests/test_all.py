"""
Complete test suite for Machine Learning Module 01
"""
import numpy as np
import sys
import os

# Add parent directories to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'ex00'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'ex01'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'ex02'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'ex03'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'ex04'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'ex05'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'ex06'))


def test_ex00_simple_gradient():
    """Test Exercise 00: Linear Gradient - Iterative Version"""
    print("\n" + "="*60)
    print("Testing Exercise 00: Linear Gradient - Iterative Version")
    print("="*60)

    from gradient import simple_gradient

    x = np.array([12.4956442, 21.5007972, 31.5527382, 48.9145838, 57.5088733]).reshape((-1, 1))
    y = np.array([37.4013816, 36.1473236, 45.7655287, 46.6793434, 59.5585554]).reshape((-1, 1))

    # Example 0
    theta1 = np.array([2, 0.7]).reshape((-1, 1))
    result = simple_gradient(x, y, theta1)
    expected = np.array([[-19.0342574], [-586.66875564]])

    print(f"Test 1 - theta=[2, 0.7]:")
    print(f"  Result: {result.flatten()}")
    print(f"  Expected: {expected.flatten()}")
    assert result is not None, "Result should not be None"
    assert np.allclose(result, expected, rtol=1e-5), f"Test 1 failed"
    print("  PASSED")

    # Example 1
    theta2 = np.array([1, -0.4]).reshape((-1, 1))
    result = simple_gradient(x, y, theta2)
    expected = np.array([[-57.86823748], [-2230.12297889]])

    print(f"Test 2 - theta=[1, -0.4]:")
    print(f"  Result: {result.flatten()}")
    print(f"  Expected: {expected.flatten()}")
    assert np.allclose(result, expected, rtol=1e-5), f"Test 2 failed"
    print("  PASSED")

    # Test with invalid inputs
    print("Test 3 - Invalid inputs:")
    assert simple_gradient(np.array([]), y, theta1) is None, "Empty x should return None"
    assert simple_gradient(x, np.array([]), theta1) is None, "Empty y should return None"
    assert simple_gradient(x, y, np.array([])) is None, "Empty theta should return None"
    print("  PASSED")

    print("\nExercise 00: ALL TESTS PASSED")
    return True


def test_ex01_vec_gradient():
    """Test Exercise 01: Linear Gradient - Vectorized Version"""
    print("\n" + "="*60)
    print("Testing Exercise 01: Linear Gradient - Vectorized Version")
    print("="*60)

    from vec_gradient import simple_gradient

    x = np.array([12.4956442, 21.5007972, 31.5527382, 48.9145838, 57.5088733]).reshape((-1, 1))
    y = np.array([37.4013816, 36.1473236, 45.7655287, 46.6793434, 59.5585554]).reshape((-1, 1))

    # Example 0
    theta1 = np.array([2, 0.7]).reshape((-1, 1))
    result = simple_gradient(x, y, theta1)
    expected = np.array([[-19.0342574], [-586.66875564]])

    print(f"Test 1 - theta=[2, 0.7]:")
    print(f"  Result: {result.flatten()}")
    print(f"  Expected: {expected.flatten()}")
    assert result is not None, "Result should not be None"
    assert np.allclose(result, expected, rtol=1e-4), f"Test 1 failed"
    print("  PASSED")

    # Example 1
    theta2 = np.array([1, -0.4]).reshape((-1, 1))
    result = simple_gradient(x, y, theta2)
    expected = np.array([[-57.86823748], [-2230.12297889]])

    print(f"Test 2 - theta=[1, -0.4]:")
    print(f"  Result: {result.flatten()}")
    print(f"  Expected: {expected.flatten()}")
    assert np.allclose(result, expected, rtol=1e-4), f"Test 2 failed"
    print("  PASSED")

    # Test with invalid inputs
    print("Test 3 - Invalid inputs:")
    assert simple_gradient(np.array([]), y, theta1) is None, "Empty x should return None"
    print("  PASSED")

    print("\nExercise 01: ALL TESTS PASSED")
    return True


def test_ex02_fit():
    """Test Exercise 02: Gradient Descent (fit function)"""
    print("\n" + "="*60)
    print("Testing Exercise 02: Gradient Descent")
    print("="*60)

    from fit import fit_, predict_

    x = np.array([[12.4956442], [21.5007972], [31.5527382], [48.9145838], [57.5088733]])
    y = np.array([[37.4013816], [36.1473236], [45.7655287], [46.6793434], [59.5585554]])
    theta = np.array([1, 1]).reshape((-1, 1))

    # Example 0
    theta1 = fit_(x, y, theta, alpha=5e-8, max_iter=1500000)
    expected_theta = np.array([[1.40709365], [1.1150909]])

    print(f"Test 1 - Fit with alpha=5e-8, max_iter=1500000:")
    print(f"  Result theta: {theta1.flatten()}")
    print(f"  Expected theta: {expected_theta.flatten()}")
    assert theta1 is not None, "Result should not be None"
    assert np.allclose(theta1, expected_theta, rtol=1e-3), f"Test 1 failed"
    print("  PASSED")

    # Example 1 - Predictions
    y_hat = predict_(x, theta1)
    expected_pred = np.array([[15.3408728], [25.38243697], [36.59126492], [55.95130097], [65.53471499]])

    print(f"Test 2 - Predictions:")
    print(f"  Result: {y_hat.flatten()}")
    print(f"  Expected: {expected_pred.flatten()}")
    assert np.allclose(y_hat, expected_pred, rtol=1e-3), f"Test 2 failed"
    print("  PASSED")

    # Test with invalid inputs
    print("Test 3 - Invalid inputs:")
    assert fit_(np.array([]), y, theta, 0.01, 100) is None, "Empty x should return None"
    print("  PASSED")

    print("\nExercise 02: ALL TESTS PASSED")
    return True


def test_ex03_my_linear_regression():
    """Test Exercise 03: MyLinearRegression class"""
    print("\n" + "="*60)
    print("Testing Exercise 03: MyLinearRegression Class")
    print("="*60)

    from my_linear_regression import MyLinearRegression as MyLR

    x = np.array([[12.4956442], [21.5007972], [31.5527382], [48.9145838], [57.5088733]])
    y = np.array([[37.4013816], [36.1473236], [45.7655287], [46.6793434], [59.5585554]])

    # Example 0.0 - Predictions
    lr1 = MyLR(np.array([[2], [0.7]]))
    y_hat = lr1.predict_(x)
    expected_pred = np.array([[10.74695094], [17.05055804], [24.08691674], [36.24020866], [42.25621131]])

    print(f"Test 1 - Predict with theta=[2, 0.7]:")
    print(f"  Result: {y_hat.flatten()}")
    print(f"  Expected: {expected_pred.flatten()}")
    assert y_hat is not None, "Result should not be None"
    assert np.allclose(y_hat, expected_pred, rtol=1e-5), f"Test 1 failed"
    print("  PASSED")

    # Example 0.1 - Loss elements
    loss_elem = lr1.loss_elem_(y, y_hat)
    expected_loss_elem = np.array([[710.45867381], [364.68645485], [469.96221651], [108.97553412], [299.37111101]])

    print(f"Test 2 - Loss elements:")
    print(f"  Result: {loss_elem.flatten()}")
    print(f"  Expected: {expected_loss_elem.flatten()}")
    assert np.allclose(loss_elem, expected_loss_elem, rtol=1e-5), f"Test 2 failed"
    print("  PASSED")

    # Example 0.2 - Loss
    loss = lr1.loss_(y, y_hat)
    expected_loss = 195.34539903032385

    print(f"Test 3 - Loss:")
    print(f"  Result: {loss}")
    print(f"  Expected: {expected_loss}")
    assert np.isclose(loss, expected_loss, rtol=1e-5), f"Test 3 failed"
    print("  PASSED")

    # Example 1.0 - Fit
    lr2 = MyLR(np.array([[1], [1]]), 5e-8, 1500000)
    lr2.fit_(x, y)
    expected_theta = np.array([[1.40709365], [1.1150909]])

    print(f"Test 4 - Fit:")
    print(f"  Result theta: {lr2.thetas.flatten()}")
    print(f"  Expected theta: {expected_theta.flatten()}")
    assert np.allclose(lr2.thetas, expected_theta, rtol=1e-3), f"Test 4 failed"
    print("  PASSED")

    # Example 1.1 - Predictions after fit
    y_hat = lr2.predict_(x)
    expected_pred = np.array([[15.3408728], [25.38243697], [36.59126492], [55.95130097], [65.53471499]])

    print(f"Test 5 - Predictions after fit:")
    print(f"  Result: {y_hat.flatten()}")
    print(f"  Expected: {expected_pred.flatten()}")
    assert np.allclose(y_hat, expected_pred, rtol=1e-3), f"Test 5 failed"
    print("  PASSED")

    # Example 1.2 - Loss elements after fit
    loss_elem = lr2.loss_elem_(y, y_hat)
    expected_loss_elem = np.array([[486.66604863], [115.88278416], [84.16711596], [85.96919719], [35.71448348]])

    print(f"Test 6 - Loss elements after fit:")
    print(f"  Result: {loss_elem.flatten()}")
    print(f"  Expected: {expected_loss_elem.flatten()}")
    assert np.allclose(loss_elem, expected_loss_elem, rtol=1e-2), f"Test 6 failed"
    print("  PASSED")

    # Example 1.3 - Loss after fit
    loss = lr2.loss_(y, y_hat)
    expected_loss = 80.83996294128525

    print(f"Test 7 - Loss after fit:")
    print(f"  Result: {loss}")
    print(f"  Expected: {expected_loss}")
    assert np.isclose(loss, expected_loss, rtol=1e-2), f"Test 7 failed"
    print("  PASSED")

    print("\nExercise 03: ALL TESTS PASSED")
    return True


def test_ex05_zscore():
    """Test Exercise 05: Z-score Standardization"""
    print("\n" + "="*60)
    print("Testing Exercise 05: Z-score Standardization")
    print("="*60)

    from z_score import zscore

    # Example 1
    X = np.array([0, 15, -9, 7, 12, 3, -21])
    result = zscore(X)
    expected = np.array([-0.08620324, 1.2068453, -0.86203236, 0.51721942, 0.94823559, 0.17240647, -1.89647119])

    print(f"Test 1 - X = [0, 15, -9, 7, 12, 3, -21]:")
    print(f"  Result: {result.flatten()}")
    print(f"  Expected: {expected}")
    assert result is not None, "Result should not be None"
    assert np.allclose(result.flatten(), expected, rtol=1e-5), f"Test 1 failed"
    print("  PASSED")

    # Example 2
    Y = np.array([2, 14, -13, 5, 12, 4, -19]).reshape((-1, 1))
    result = zscore(Y)
    expected = np.array([0.11267619, 1.16432067, -1.20187941, 0.37558731, 0.98904659, 0.28795027, -1.72770165])

    print(f"Test 2 - Y = [2, 14, -13, 5, 12, 4, -19]:")
    print(f"  Result: {result.flatten()}")
    print(f"  Expected: {expected}")
    assert np.allclose(result.flatten(), expected, rtol=1e-5), f"Test 2 failed"
    print("  PASSED")

    # Test with invalid inputs
    print("Test 3 - Invalid inputs:")
    assert zscore(np.array([])) is None, "Empty array should return None"
    assert zscore("not an array") is None, "Non-array should return None"
    print("  PASSED")

    print("\nExercise 05: ALL TESTS PASSED")
    return True


def test_ex06_minmax():
    """Test Exercise 06: Min-max Standardization"""
    print("\n" + "="*60)
    print("Testing Exercise 06: Min-max Standardization")
    print("="*60)

    from minmax import minmax

    # Example 1
    X = np.array([0, 15, -9, 7, 12, 3, -21]).reshape((-1, 1))
    result = minmax(X)
    expected = np.array([0.58333333, 1., 0.33333333, 0.77777778, 0.91666667, 0.66666667, 0.])

    print(f"Test 1 - X = [0, 15, -9, 7, 12, 3, -21]:")
    print(f"  Result: {result.flatten()}")
    print(f"  Expected: {expected}")
    assert result is not None, "Result should not be None"
    assert np.allclose(result.flatten(), expected, rtol=1e-5), f"Test 1 failed"
    print("  PASSED")

    # Example 2
    Y = np.array([2, 14, -13, 5, 12, 4, -19]).reshape((-1, 1))
    result = minmax(Y)
    expected = np.array([0.63636364, 1., 0.18181818, 0.72727273, 0.93939394, 0.6969697, 0.])

    print(f"Test 2 - Y = [2, 14, -13, 5, 12, 4, -19]:")
    print(f"  Result: {result.flatten()}")
    print(f"  Expected: {expected}")
    assert np.allclose(result.flatten(), expected, rtol=1e-5), f"Test 2 failed"
    print("  PASSED")

    # Test with invalid inputs
    print("Test 3 - Invalid inputs:")
    assert minmax(np.array([])) is None, "Empty array should return None"
    assert minmax("not an array") is None, "Non-array should return None"
    print("  PASSED")

    print("\nExercise 06: ALL TESTS PASSED")
    return True


def run_all_tests():
    """Run all tests"""
    print("\n" + "#"*60)
    print("# MACHINE LEARNING MODULE 01 - COMPLETE TEST SUITE")
    print("#"*60)

    results = {}

    try:
        results['ex00'] = test_ex00_simple_gradient()
    except Exception as e:
        print(f"\nExercise 00 FAILED: {e}")
        results['ex00'] = False

    try:
        results['ex01'] = test_ex01_vec_gradient()
    except Exception as e:
        print(f"\nExercise 01 FAILED: {e}")
        results['ex01'] = False

    try:
        results['ex02'] = test_ex02_fit()
    except Exception as e:
        print(f"\nExercise 02 FAILED: {e}")
        results['ex02'] = False

    try:
        results['ex03'] = test_ex03_my_linear_regression()
    except Exception as e:
        print(f"\nExercise 03 FAILED: {e}")
        results['ex03'] = False

    try:
        results['ex05'] = test_ex05_zscore()
    except Exception as e:
        print(f"\nExercise 05 FAILED: {e}")
        results['ex05'] = False

    try:
        results['ex06'] = test_ex06_minmax()
    except Exception as e:
        print(f"\nExercise 06 FAILED: {e}")
        results['ex06'] = False

    # Summary
    print("\n" + "#"*60)
    print("# TEST SUMMARY")
    print("#"*60)

    for ex, passed in results.items():
        status = "PASSED" if passed else "FAILED"
        print(f"  {ex}: {status}")

    all_passed = all(results.values())
    print("\n" + ("ALL TESTS PASSED!" if all_passed else "SOME TESTS FAILED!"))

    return all_passed


if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
