#!/usr/bin/env python3
"""
Check a metrics CSV snapshot for overload ratios above a threshold.
Usage: logs_metrics_alerts.py --input reports/log_metrics_snapshot.status_top2.csv --threshold 50
Returns exit code 0 if all ratios are <= threshold, 1 otherwise (and prints offending rows).
"""
import argparse
import csv
import sys
from pathlib import Path


def load_rows(path: Path):
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    if not rows:
        raise SystemExit("No rows found in CSV")
    if rows[-1].get("log_file") != "Totals":
        raise SystemExit("Missing Totals line in CSV (last row must have log_file=Totals)")
    return rows


def check(rows, threshold):
    offenders = []
    for row in rows:
        try:
            ratio = float(row.get("overloaded_ratio", 0))
        except ValueError:
            ratio = 0
        if ratio > threshold:
            offenders.append((row.get("log_file", ""), ratio))
    return offenders


def main():
    parser = argparse.ArgumentParser(description="Check overload ratios in a metrics CSV snapshot.")
    parser.add_argument("--input", default="reports/log_metrics_snapshot.status_top2.csv", help="Path to CSV snapshot")
    parser.add_argument("--threshold", type=float, default=50.0, help="Maximum allowed overloaded_ratio")
    args = parser.parse_args()

    csv_path = Path(args.input)
    if not csv_path.exists():
        raise SystemExit(f"Input CSV {csv_path} not found")

    rows = load_rows(csv_path)
    offenders = check(rows, args.threshold)
    if offenders:
        print(f"[ALERT] Overloaded ratio above {args.threshold}% for:")
        for name, ratio in offenders:
            print(f" - {name}: {ratio:.2f}%")
        sys.exit(1)
    print(f"[OK] All overloaded ratios <= {args.threshold}%")


if __name__ == "__main__":
    main()
