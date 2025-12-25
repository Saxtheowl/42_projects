#!/usr/bin/env python3
"""
Render a trend report from the metrics history file.
Usage: logs_metrics_trend.py --history reports/log_metrics_history.csv --last 5 --output reports/log_metrics_trend.md
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


def load_history(path: Path):
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    if not rows:
        raise SystemExit("History file is empty")
    return rows


def render(rows, output_path):
    lines = []
    lines.append("# Log Metrics Trend")
    lines.append("")
    lines.append("| run_timestamp | pattern | topn | snapshot_timestamp | log_files | status_checks | Δstatus | connections | Δconnections | overloaded | Δoverloaded | ratio | Δratio |")
    lines.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
    prev = None
    for row in rows:
        deltas = {}
        for field in FIELDS:
            current = to_float(row.get(field, 0))
            prev_val = to_float(prev.get(field, 0)) if prev else 0.0
            deltas[field] = current - prev_val
        lines.append(
            "| {run_timestamp} | {pattern} | {topn} | {snapshot_timestamp} | {log_files_count} | {status_checks} | {d_status:.2f} | {connections} | {d_connections:.2f} | {overloaded} | {d_overloaded:.2f} | {overloaded_ratio} | {d_ratio:.2f} |".format(
                run_timestamp=row.get("run_timestamp", ""),
                pattern=row.get("pattern", ""),
                topn=row.get("topn", ""),
                snapshot_timestamp=row.get("snapshot_timestamp", ""),
                log_files_count=row.get("log_files_count", ""),
                status_checks=row.get("status_checks", ""),
                d_status=deltas["status_checks"],
                connections=row.get("connections", ""),
                d_connections=deltas["connections"],
                overloaded=row.get("overloaded", ""),
                d_overloaded=deltas["overloaded"],
                overloaded_ratio=row.get("overloaded_ratio", ""),
                d_ratio=deltas["overloaded_ratio"],
            )
        )
        prev = row
    Path(output_path).write_text("\n".join(lines) + "\n")
    print(f"Trend report written to {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Build a trend report from metrics history.")
    parser.add_argument("--history", default="reports/log_metrics_history.csv", help="History CSV path")
    parser.add_argument("--last", type=int, default=5, help="Number of most recent entries to include")
    parser.add_argument("--output", default="reports/log_metrics_trend.md", help="Output Markdown path")
    args = parser.parse_args()

    history_path = Path(args.history)
    if not history_path.exists():
        raise SystemExit(f"History file {history_path} not found")

    rows = load_history(history_path)
    rows = rows[-args.last :] if args.last > 0 else rows
    render(rows, args.output)


if __name__ == "__main__":
    main()
