#!/usr/bin/env python3
"""
Compute stats (min/avg/max) from the metrics history.
Usage: logs_metrics_stats.py --history reports/log_metrics_history.csv --output reports/log_metrics_stats.md
"""
import argparse
import csv
from pathlib import Path


FIELDS = ["status_checks", "connections", "overloaded", "overloaded_ratio"]


def to_float(val):
    try:
        return float(val)
    except (TypeError, ValueError):
        return 0.0


def compute_stats(rows):
    stats = {}
    for field in FIELDS:
        values = [to_float(r.get(field)) for r in rows]
        if not values:
            stats[field] = {"min": 0.0, "max": 0.0, "avg": 0.0, "latest": 0.0}
            continue
        stats[field] = {
            "min": min(values),
            "max": max(values),
            "avg": sum(values) / len(values),
            "latest": values[-1],
        }
    return stats


def load_history(path: Path):
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    if not rows:
        raise SystemExit("History file is empty")
    return rows


def render(stats, output_path: Path):
    lines = [
        "# Log Metrics Stats",
        "",
        "| metric | min | avg | max | latest |",
        "| --- | --- | --- | --- | --- |",
    ]
    for field in FIELDS:
        s = stats[field]
        lines.append(
            f"| {field} | {s['min']:.2f} | {s['avg']:.2f} | {s['max']:.2f} | {s['latest']:.2f} |"
        )
    output_path.write_text("\n".join(lines) + "\n")
    print(f"Stats written to {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Compute stats from metrics history.")
    parser.add_argument("--history", default="reports/log_metrics_history.csv", help="History CSV path")
    parser.add_argument("--output", default="reports/log_metrics_stats.md", help="Output Markdown path")
    args = parser.parse_args()

    history_path = Path(args.history)
    if not history_path.exists():
        raise SystemExit(f"History {history_path} not found")
    rows = load_history(history_path)
    stats = compute_stats(rows)
    render(stats, Path(args.output))


if __name__ == "__main__":
    main()
