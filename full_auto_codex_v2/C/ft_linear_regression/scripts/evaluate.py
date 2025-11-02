#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path
from math import sqrt

PROJECT_ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = PROJECT_ROOT / "src"
sys.path.append(str(SRC_DIR))

from utils import load_dataset, load_model  # type: ignore
from train import normalize_feature, estimate_price  # type: ignore


def rmse(values, predictions):
    diff_sq = [(v - p) ** 2 for v, p in zip(values, predictions)]
    return sqrt(sum(diff_sq) / len(diff_sq)) if diff_sq else 0.0


def main():
    parser = argparse.ArgumentParser(description="Evaluate model on a dataset")
    parser.add_argument("dataset", type=Path, help="CSV file with mileage,price")
    args = parser.parse_args()

    dataset = load_dataset(args.dataset)
    params = load_model()
    features, _, _ = normalize_feature(dataset.mileage)
    predictions = [estimate_price(params.theta0, params.theta1, f) for f in features]
    error = rmse(dataset.price, predictions)
    print(f"RMSE: {error:.2f}")


if __name__ == "__main__":
    main()
