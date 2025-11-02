from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent))

from utils import load_model  # type: ignore


def main() -> None:
    parser = argparse.ArgumentParser(description="Predict car price from mileage")
    parser.add_argument("--mileage", type=float, help="Mileage in km", required=False)
    args = parser.parse_args()

    params = load_model()

    if args.mileage is not None:
        mileage = args.mileage
    else:
        mileage = float(input("Enter mileage: "))

    feature = (mileage - params.mean) / params.scale if params.scale != 0 else 0.0
    price = params.theta0 + params.theta1 * feature
    print(f"Estimated price: {price:.2f}")


if __name__ == "__main__":
    main()
