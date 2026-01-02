#!/usr/bin/env python3
"""Export the validation summary JSON to CSV for easy tooling."""

from __future__ import annotations

import csv
import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
JSON_PATH = BASE_DIR / "docs" / "validation_summary.json"
CSV_PATH = BASE_DIR / "docs" / "validation_summary.csv"


def main() -> int:
    if not JSON_PATH.exists():
        raise SystemExit(f"{JSON_PATH} missing (run validation_summary.py first)")
    data = json.loads(JSON_PATH.read_text())
    fieldnames = [
        "timestamp",
        "fold_count",
        "best_rmse",
        "worst_rmse",
        "average_rmse",
        "median_rmse",
        "stddev_rmse",
        "bootstrap_samples",
        "bootstrap_average_rmse",
    ]
    CSV_PATH.write_text("")  # ensure file exists
    with CSV_PATH.open("w", newline="", encoding="utf-8") as csvf:
        writer = csv.DictWriter(csvf, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerow(
            {key: data.get(key) for key in fieldnames}
        )
    print(f"Wrote {CSV_PATH.relative_to(BASE_DIR)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
