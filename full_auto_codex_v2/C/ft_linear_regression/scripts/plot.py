#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = PROJECT_ROOT / "src"
sys.path.append(str(SRC_DIR))

from utils import ModelParams, load_dataset, load_model  # type: ignore
from train import estimate_price  # type: ignore


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Plot dataset and learned regression line")
    parser.add_argument(
        "--dataset",
        type=Path,
        default=PROJECT_ROOT / "data" / "data.csv",
        help="CSV file containing mileage,price (default: data/data.csv)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Optional path to save the plot instead of opening a window",
    )
    return parser.parse_args()


def predict_price(theta0: float, theta1: float, mean: float, scale: float, mileage: float) -> float:
    feature = (mileage - mean) / scale if scale != 0 else 0.0
    return estimate_price(theta0, theta1, feature)


def build_regression_line(mileages: list[float], params: ModelParams) -> tuple[list[float], list[float]]:
    if not mileages:
        return [], []

    min_m = min(mileages)
    max_m = max(mileages)
    xs = [min_m, max_m] if min_m != max_m else [min_m - 1, max_m + 1]
    ys = [predict_price(params.theta0, params.theta1, params.mean, params.scale, x) for x in xs]
    return xs, ys


def main() -> int:
    args = parse_args()

    try:
        import matplotlib

        if args.output:
            matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib is required. Install dependencies with `pip install -r requirements.txt`.", file=sys.stderr)
        return 1

    dataset = load_dataset(args.dataset)
    params = load_model()

    xs_line, ys_line = build_regression_line(dataset.mileage, params)

    plt.figure()
    plt.scatter(dataset.mileage, dataset.price, label="Dataset", color="#1f77b4")
    if xs_line:
        plt.plot(xs_line, ys_line, label="Regression", color="#d62728")
    plt.xlabel("Mileage (km)")
    plt.ylabel("Price (€)")
    plt.title("Linear regression fit")
    plt.legend()
    plt.grid(True, linewidth=0.5, alpha=0.4)

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        plt.savefig(args.output, bbox_inches="tight")
        print(f"Plot saved to {args.output}")
    else:
        plt.show()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
