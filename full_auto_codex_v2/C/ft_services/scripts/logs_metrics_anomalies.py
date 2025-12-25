#!/usr/bin/env python3
"""
Detect anomalies between the last two history entries.
Usage: logs_metrics_anomalies.py --history reports/log_metrics_history.csv --output reports/log_metrics_anomalies.md --json-output reports/log_metrics_anomalies.json --threshold 20 [--strict]
"""
import argparse
import csv
import json
from pathlib import Path
from typing import Dict, List

FIELDS = ["status_checks", "connections", "overloaded", "overloaded_ratio"]


def to_float(val) -> float:
    try:
        return float(val)
    except (TypeError, ValueError):
        return 0.0


def load_history(path: Path) -> List[Dict[str, str]]:
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    return rows


def compute_anomalies(history: List[Dict[str, str]], threshold: float):
    if len(history) < 2:
        return None, None, []
    prev, curr = history[-2], history[-1]
    anomalies = []
    for field in FIELDS:
        prev_val = to_float(prev.get(field))
        curr_val = to_float(curr.get(field))
        delta = curr_val - prev_val
        if prev_val == 0:
            pct = 100.0 if curr_val > 0 else 0.0
        else:
            pct = (delta / prev_val) * 100.0
        is_anomaly = curr_val > prev_val and pct >= threshold
        anomalies.append(
            {
                "metric": field,
                "prev": prev_val,
                "curr": curr_val,
                "delta": delta,
                "pct": pct,
                "status": "ANOMALY" if is_anomaly else "OK",
            }
        )
    return prev, curr, anomalies


def render_markdown(prev, curr, anomalies, threshold: float) -> str:
    lines = ["# Log Metrics Anomalies", ""]
    if prev is None or curr is None:
        lines.append("> Not enough history to compute anomalies (need at least 2 entries).")
        return "\n".join(lines) + "\n"

    lines.append(f"Comparing last run (`{curr.get('run_timestamp','')}`) against previous (`{prev.get('run_timestamp','')}`) with threshold {threshold:.0f}%.\n")
    lines.append("| metric | previous | current | delta | delta% | status |")
    lines.append("| --- | --- | --- | --- | --- | --- |")
    for row in anomalies:
        lines.append(
            f"| {row['metric']} | {row['prev']:.2f} | {row['curr']:.2f} | {row['delta']:.2f} | {row['pct']:.1f}% | {row['status']} |"
        )
    lines.append("")
    flagged = [r for r in anomalies if r["status"] == "ANOMALY"]
    if flagged:
        lines.append(f"{len(flagged)} anomalies detected (>{threshold:.0f}% increase).")
    else:
        lines.append("No anomalies detected.")
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description="Detect anomalies between the last two history entries.")
    parser.add_argument("--history", default="reports/log_metrics_history.csv", help="History CSV path")
    parser.add_argument("--output", default="reports/log_metrics_anomalies.md", help="Output Markdown path")
    parser.add_argument("--json-output", default="reports/log_metrics_anomalies.json", help="Output JSON path")
    parser.add_argument("--threshold", type=float, default=20.0, help="Threshold percent increase to flag anomalies")
    parser.add_argument("--strict", action="store_true", help="Exit non-zero if anomalies are detected")
    args = parser.parse_args()

    history_path = Path(args.history)
    if not history_path.exists():
        raise SystemExit(f"History {history_path} not found")

    history = load_history(history_path)
    prev, curr, anomalies = compute_anomalies(history, args.threshold)
    md = render_markdown(prev, curr, anomalies, args.threshold)
    Path(args.output).write_text(md)
    Path(args.json_output).write_text(json.dumps(anomalies, indent=2))
    print(f"Anomalies report written to {args.output} and {args.json_output}")

    flagged = [r for r in anomalies if r.get("status") == "ANOMALY"]
    if args.strict and flagged:
        raise SystemExit(2)


if __name__ == "__main__":
    main()
