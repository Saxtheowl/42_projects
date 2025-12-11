from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
from typing import List

import sys

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


def calculate_rmse(features: list[float], target: list[float], theta0: float, theta1: float) -> float:
    m = len(features)
    if m == 0:
        return 0.0
    error_sum = sum(
        (estimate_price(theta0, theta1, f) - t) ** 2 for f, t in zip(features, target)
    )
    return math.sqrt(error_sum / m)


def adjust_learning_rate(base_lr: float, iteration: int, scheduler: str, decay: float, min_lr: float, iterations: int) -> float:
    if scheduler == "constant":
        return base_lr
    if scheduler == "linear":
        fraction = max(0.0, 1.0 - (iteration / max(1, iterations)))
        return max(base_lr * fraction, min_lr)
    if scheduler == "exponential":
        return max(base_lr * (decay ** iteration), min_lr)
    raise ValueError(f"Unknown scheduler: {scheduler}")


def save_history(history: list[dict], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as fh:
        json.dump(history, fh)


def main() -> None:
    parser = argparse.ArgumentParser(description="Train linear regression on mileage dataset")
    parser.add_argument("dataset", type=Path, help="Path to CSV dataset (mileage,price)")
    parser.add_argument("--learning-rate", type=float, default=1e-7)
    parser.add_argument("--iterations", type=int, default=1000)
    parser.add_argument("--scheduler", choices=["constant", "linear", "exponential"], default="constant")
    parser.add_argument("--decay", type=float, default=0.99)
    parser.add_argument("--min-lr", type=float, default=1e-9)
    parser.add_argument("--history", type=Path, default=None,
                        help="Optional JSON file where per-epoch RMSE is recorded")
    args = parser.parse_args()

    dataset = load_dataset(args.dataset)
    features, mean, scale = normalize_feature(dataset.mileage)
    history: list[dict] = []
    theta0 = 0.0
    theta1 = 0.0
    m = float(len(features))
    for iteration in range(args.iterations):
        sum_error = 0.0
        sum_error_mileage = 0.0
        for feature, price in zip(features, dataset.price):
            error = estimate_price(theta0, theta1, feature) - price
            sum_error += error
            sum_error_mileage += error * feature
        current_lr = adjust_learning_rate(args.learning_rate, iteration, args.scheduler, args.decay, args.min_lr, args.iterations)
        theta0 -= (current_lr * (1.0 / m) * sum_error)
        theta1 -= (current_lr * (1.0 / m) * sum_error_mileage)
        history.append({"epoch": iteration + 1, "rmse": calculate_rmse(features, dataset.price, theta0, theta1), "learning_rate": current_lr})
    if args.history:
        save_history(history, args.history)
    save_model(ModelParams(theta0=theta0, theta1=theta1, mean=mean, scale=scale))
    print(f"Training finished: theta0={theta0:.6f}, theta1={theta1:.6f}, mean={mean:.2f}, scale={scale:.2f}")


if __name__ == "__main__":
    main()


if __name__ == "__main__":
    main()
