import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "src"
sys.path.append(str(ROOT))

from train import gradient_descent, estimate_price  # type: ignore


def test_gradient_descent_converges():
    features = [0, 0.5, 1.0]
    theta0, theta1 = gradient_descent(features, [1, 3, 5], learning_rate=0.1, iterations=500)
    assert math.isclose(estimate_price(theta0, theta1, 0), 1, rel_tol=5e-2)
    assert math.isclose(estimate_price(theta0, theta1, 1.0), 5, rel_tol=5e-2)
