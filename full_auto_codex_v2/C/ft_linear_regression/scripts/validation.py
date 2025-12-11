#!/usr/bin/env python3
from __future__ import annotations

import argparse
import random
from dataclasses import dataclass
from pathlib import Path
from typing import List

import sys

PROJECT_ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = PROJECT_ROOT / "src"
sys.path.append(str(SRC_DIR))

from utils import load_dataset
from train import (
    adjust_learning_rate,
    calculate_rmse,
    estimate_price,
    normalize_feature,
)


@dataclass
class FoldResult:
    fold: int
    theta0: float
    theta1: float
    rmse: float
    learning_rate: float


def train_on_split(
    train_features: List[float],
    train_prices: List[float],
    learning_rate: float,
    iterations: int,
    scheduler: str,
    decay: float,
    min_lr: float,
) -> tuple[float, float, float, float]:
    norm_features, mean, scale = normalize_feature(train_features)
    theta0 = 0.0
    theta1 = 0.0
    m = float(len(norm_features))
    for iteration in range(iterations):
        sum_error = 0.0
        sum_error_mileage = 0.0
        for feature, price in zip(norm_features, train_prices):
            error = estimate_price(theta0, theta1, feature) - price
            sum_error += error
            sum_error_mileage += error * feature
        current_lr = adjust_learning_rate(
            learning_rate, iteration, scheduler, decay, min_lr, iterations
        )
        theta0 -= (current_lr * (1.0 / m) * sum_error)
        theta1 -= (current_lr * (1.0 / m) * sum_error_mileage)
    return theta0, theta1, mean, scale


def main() -> None:
    parser = argparse.ArgumentParser(description="Run validation folds for ft_linear_regression")
    parser.add_argument("dataset", type=Path, help="CSV dataset path")
    parser.add_argument("--folds", type=int, default=3, help="Number of random splits")
    parser.add_argument("--test-size", type=float, default=0.2, help="Fraction of data held out per split")
    parser.add_argument("--seed", type=int, default=0, help="Random seed for splits")
    parser.add_argument("--learning-rate", type=float, default=1e-7)
    parser.add_argument("--iterations", type=int, default=1000)
    parser.add_argument("--scheduler", choices=["constant", "linear", "exponential"], default="constant")
    parser.add_argument("--decay", type=float, default=0.99)
    parser.add_argument("--min-lr", type=float, default=1e-9)
    args = parser.parse_args()

    dataset = load_dataset(args.dataset)
    data = list(zip(dataset.mileage, dataset.price))
    random.seed(args.seed)
    results: list[FoldResult] = []
    for fold in range(1, args.folds + 1):
        random.shuffle(data)
        split_index = max(1, int(len(data) * (1 - args.test_size)))
        train = data[:split_index]
        test = data[split_index:]
        if not test or not train:
            print(f"fold {fold}: insufficient data after split", file=sys.stderr)
            continue
        train_features, train_prices = zip(*train)
        test_features, test_prices = zip(*test)
        theta0, theta1, mean, scale = train_on_split(
            list(train_features),
            list(train_prices),
            args.learning_rate,
            args.iterations,
            args.scheduler,
            args.decay,
            args.min_lr,
        )
        normalized_test = [(f - mean) / scale for f in test_features]
        rmse = calculate_rmse(normalized_test, list(test_prices), theta0, theta1)
        current_lr = adjust_learning_rate(
            args.learning_rate, args.iterations - 1, args.scheduler, args.decay, args.min_lr, args.iterations
        )
        results.append(FoldResult(fold=fold, theta0=theta0, theta1=theta1, rmse=rmse, learning_rate=current_lr))

    for res in results:
        print(
            f"fold {res.fold}: RMSE={res.rmse:.2f}, theta0={res.theta0:.4f}, theta1={res.theta1:.4f}, last_lr={res.learning_rate:.6f}"
        )
    if results:
        avg_rmse = sum(res.rmse for res in results) / len(results)
        print(f"average RMSE across folds: {avg_rmse:.2f}")


if __name__ == "__main__":
    main()
