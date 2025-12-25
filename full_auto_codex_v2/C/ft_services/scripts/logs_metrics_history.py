#!/usr/bin/env python3
"""
Append a summary line to the metrics history file from a CSV snapshot.
Usage: logs_metrics_history.py --input reports/log_metrics_snapshot.status_top2.csv --pattern status --topn 2 --history reports/log_metrics_history.csv
"""
import argparse
import csv
from datetime import datetime, timezone
from pathlib import Path


def parse_snapshot(csv_path: Path):
    with csv_path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    if not rows:
        raise SystemExit("No rows in snapshot")
    if rows[-1].get("log_file") != "Totals":
        raise SystemExit("Missing Totals line in snapshot")
    totals = rows[-1]
    snapshot_ts = totals.get("timestamp", "")
    log_files_count = max(0, len(rows) - 1)
    return {
        "snapshot_timestamp": snapshot_ts,
        "log_files_count": log_files_count,
        "status_checks": totals.get("status_checks", ""),
        "connections": totals.get("connections", ""),
        "overloaded": totals.get("overloaded", ""),
        "overloaded_ratio": totals.get("overloaded_ratio", ""),
    }


def append_history(history_path: Path, entry: dict, pattern: str, topn: int):
    exists = history_path.exists()
    headers = [
        "run_timestamp",
        "pattern",
        "topn",
        "snapshot_timestamp",
        "log_files_count",
        "status_checks",
        "connections",
        "overloaded",
        "overloaded_ratio",
    ]
    run_ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    with history_path.open("a", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        if not exists:
            writer.writeheader()
        writer.writerow(
            {
                "run_timestamp": run_ts,
                "pattern": pattern,
                "topn": topn,
                "snapshot_timestamp": entry["snapshot_timestamp"],
                "log_files_count": entry["log_files_count"],
                "status_checks": entry["status_checks"],
                "connections": entry["connections"],
                "overloaded": entry["overloaded"],
                "overloaded_ratio": entry["overloaded_ratio"],
            }
        )
    print(f"History updated: {history_path}")


def main():
    parser = argparse.ArgumentParser(description="Append metrics snapshot summary to history.")
    parser.add_argument("--input", required=True, help="CSV snapshot path")
    parser.add_argument("--pattern", default="status", help="Pattern label")
    parser.add_argument("--topn", type=int, default=2, help="Top N used for the snapshot")
    parser.add_argument("--history", default="reports/log_metrics_history.csv", help="History file path")
    args = parser.parse_args()

    csv_path = Path(args.input)
    if not csv_path.exists():
        raise SystemExit(f"Snapshot {csv_path} not found")
    history_path = Path(args.history)
    entry = parse_snapshot(csv_path)
    append_history(history_path, entry, args.pattern, args.topn)


if __name__ == "__main__":
    main()
