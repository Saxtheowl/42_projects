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
    best_epoch: int
    best_train_rmse: float


def train_on_split(
    train_features: List[float],
    train_prices: List[float],
    learning_rate: float,
    iterations: int,
    scheduler: str,
    decay: float,
    min_lr: float,
    early_stop: bool,
    patience: int,
    min_delta: float,
) -> tuple[float, float, float, float, float, int, float]:
    norm_features, mean, scale = normalize_feature(train_features)
    theta0 = 0.0
    theta1 = 0.0
    m = float(len(norm_features))
    best_rmse = float("inf")
    best_epoch = -1
    best_theta0 = theta0
    best_theta1 = theta1
    last_lr = learning_rate
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
        last_lr = current_lr
        theta0 -= (current_lr * (1.0 / m) * sum_error)
        theta1 -= (current_lr * (1.0 / m) * sum_error_mileage)
        train_rmse = calculate_rmse(norm_features, train_prices, theta0, theta1)
        if train_rmse + min_delta < best_rmse:
            best_rmse = train_rmse
            best_epoch = iteration
            best_theta0 = theta0
            best_theta1 = theta1
        elif early_stop and best_epoch >= 0 and iteration - best_epoch >= patience:
            break
    if early_stop and best_epoch >= 0:
        theta0, theta1 = best_theta0, best_theta1
    return theta0, theta1, mean, scale, best_rmse, best_epoch, last_lr


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
    parser.add_argument("--early-stop", action="store_true", help="Enable early stopping on training RMSE")
    parser.add_argument("--patience", type=int, default=25, help="Early stopping patience")
    parser.add_argument("--min-delta", type=float, default=1e-4, help="Minimum RMSE improvement to reset patience")
    parser.add_argument("--bootstrap-samples", type=int, default=0, help="Run bootstrap validation with N samples")
    parser.add_argument("--bootstrap-seed", type=int, default=0, help="Random seed for bootstrap sampling")
    parser.add_argument(
        "--output",
        type=Path,
        default=PROJECT_ROOT / "data" / "validation_report.txt",
        help="Write validation summary to this file",
    )
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
        theta0, theta1, mean, scale, best_rmse, best_epoch, last_lr = train_on_split(
            list(train_features),
            list(train_prices),
            args.learning_rate,
            args.iterations,
            args.scheduler,
            args.decay,
            args.min_lr,
            args.early_stop,
            args.patience,
            args.min_delta,
        )
        normalized_test = [(f - mean) / scale for f in test_features]
        rmse = calculate_rmse(normalized_test, list(test_prices), theta0, theta1)
        results.append(
            FoldResult(
                fold=fold,
                theta0=theta0,
                theta1=theta1,
                rmse=rmse,
                learning_rate=last_lr,
                best_epoch=best_epoch,
                best_train_rmse=best_rmse,
            )
        )

    output_lines: list[str] = []
    for res in results:
        best_epoch_label = "n/a" if res.best_epoch < 0 else str(res.best_epoch + 1)
        line = (
            f"fold {res.fold}: RMSE={res.rmse:.2f}, theta0={res.theta0:.4f}, "
            f"theta1={res.theta1:.4f}, last_lr={res.learning_rate:.6f}, "
            f"best_epoch={best_epoch_label}, best_train_rmse={res.best_train_rmse:.4f}"
        )
        output_lines.append(line)
        print(line)
    if results:
        avg_rmse = sum(res.rmse for res in results) / len(results)
        avg_line = f"average RMSE across folds: {avg_rmse:.2f}"
        output_lines.append(avg_line)
        print(avg_line)

    if args.bootstrap_samples > 0:
        bootstrap_rng = random.Random(args.bootstrap_seed)
        bootstrap_rmses: list[float] = []
        total_points = len(data)
        for sample_idx in range(1, args.bootstrap_samples + 1):
            indices = [bootstrap_rng.randrange(total_points) for _ in range(total_points)]
            sampled = [data[i] for i in indices]
            sampled_set = set(indices)
            oob = [data[i] for i in range(total_points) if i not in sampled_set]
            if not oob:
                line = f"bootstrap {sample_idx}: skipped (no out-of-bag data)"
                output_lines.append(line)
                print(line)
                continue
            train_features, train_prices = zip(*sampled)
            test_features, test_prices = zip(*oob)
            theta0, theta1, mean, scale, best_rmse, best_epoch, last_lr = train_on_split(
                list(train_features),
                list(train_prices),
                args.learning_rate,
                args.iterations,
                args.scheduler,
                args.decay,
                args.min_lr,
                args.early_stop,
                args.patience,
                args.min_delta,
            )
            normalized_test = [(f - mean) / scale for f in test_features]
            rmse = calculate_rmse(normalized_test, list(test_prices), theta0, theta1)
            bootstrap_rmses.append(rmse)
            best_epoch_label = "n/a" if best_epoch < 0 else str(best_epoch + 1)
            line = (
                f"bootstrap {sample_idx}: RMSE={rmse:.2f}, oob={len(oob)}, "
                f"last_lr={last_lr:.6f}, best_epoch={best_epoch_label}, best_train_rmse={best_rmse:.4f}"
            )
            output_lines.append(line)
            print(line)
        if bootstrap_rmses:
            avg_bootstrap = sum(bootstrap_rmses) / len(bootstrap_rmses)
            avg_bootstrap_line = f"bootstrap average RMSE: {avg_bootstrap:.2f}"
            output_lines.append(avg_bootstrap_line)
            print(avg_bootstrap_line)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text("\n".join(output_lines))


if __name__ == "__main__":
    main()
