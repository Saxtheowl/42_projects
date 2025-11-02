from __future__ import annotations

import argparse
from pathlib import Path

import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent))

from utils import Dataset, ModelParams, load_dataset, save_model  # type: ignore


def normalize_feature(values: list[float]) -> tuple[list[float], float, float]:
    mean = sum(values) / len(values)
    min_v = min(values)
    max_v = max(values)
    scale = max_v - min_v
    if scale == 0:
        return [0.0 for _ in values], mean, 1.0
    normalized = [(v - mean) / scale for v in values]
    return normalized, mean, scale


def estimate_price(theta0: float, theta1: float, feature: float) -> float:
    return theta0 + theta1 * feature


def gradient_descent(features: list[float], target: list[float], learning_rate: float, iterations: int) -> tuple[float, float]:
    theta0 = 0.0
    theta1 = 0.0
    m = float(len(features))
    if m == 0:
        return theta0, theta1

    for _ in range(iterations):
        sum_error = 0.0
        sum_error_mileage = 0.0
        for feature, price in zip(features, target):
            error = estimate_price(theta0, theta1, feature) - price
            sum_error += error
            sum_error_mileage += error * feature
        theta0 -= (learning_rate * (1.0 / m) * sum_error)
        theta1 -= (learning_rate * (1.0 / m) * sum_error_mileage)
    return theta0, theta1


def main() -> None:
    parser = argparse.ArgumentParser(description="Train linear regression on mileage dataset")
    parser.add_argument("dataset", type=Path, help="Path to CSV dataset (mileage,price)")
    parser.add_argument("--learning-rate", type=float, default=1e-7)
    parser.add_argument("--iterations", type=int, default=1000)
    args = parser.parse_args()

    dataset = load_dataset(args.dataset)
    features, mean, scale = normalize_feature(dataset.mileage)
    theta0, theta1 = gradient_descent(features, dataset.price, args.learning_rate, args.iterations)
    save_model(ModelParams(theta0=theta0, theta1=theta1, mean=mean, scale=scale))
    print(f"Training finished: theta0={theta0:.6f}, theta1={theta1:.6f}, mean={mean:.2f}, scale={scale:.2f}")


if __name__ == "__main__":
    main()
