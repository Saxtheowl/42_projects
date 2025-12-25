#!/usr/bin/env python3
"""Export the validation history table to CSV for quick analysis."""
from pathlib import Path
import csv
import re

def main() -> None:
    root = Path(__file__).resolve().parent.parent
    history_md = root / "docs" / "validation_history.md"
    csv_path = root / "docs" / "validation_history.csv"
    if not history_md.exists():
        raise SystemExit("validation history not found")

    pattern = re.compile(r"- \[(.*?)\]\(.*?\) \| best=(.*?) \| worst=(.*?) \| avg=(.*?)$")
    rows = []
    for line in history_md.read_text().splitlines():
        match = pattern.match(line.strip())
        if not match:
            continue
        rows.append(match.groups())

    if not rows:
        raise SystemExit("no history entries found")

    with csv_path.open("w", newline="", encoding="utf-8") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["timestamp", "best_rmse", "worst_rmse", "average_rmse"])
        writer.writerows(rows)

    print(f"Wrote {csv_path}")


if __name__ == "__main__":
    main()
