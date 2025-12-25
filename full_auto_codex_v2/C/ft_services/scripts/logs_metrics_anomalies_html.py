#!/usr/bin/env python3
"""
Render an HTML anomalies table comparing the last two history entries.
Usage: logs_metrics_anomalies_html.py --history reports/log_metrics_history.csv --output reports/log_metrics_anomalies.html --threshold 20
"""
import argparse
import csv
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


def compute(history: List[Dict[str, str]], threshold: float):
    if len(history) < 2:
        return None, None, []
    prev, curr = history[-2], history[-1]
    rows = []
    for field in FIELDS:
        prev_val = to_float(prev.get(field))
        curr_val = to_float(curr.get(field))
        delta = curr_val - prev_val
        pct = 100.0 if prev_val == 0 and curr_val > 0 else (delta / prev_val * 100.0 if prev_val else 0.0)
        is_anomaly = curr_val > prev_val and pct >= threshold
        rows.append(
            {
                "metric": field,
                "previous": prev_val,
                "current": curr_val,
                "delta": delta,
                "pct": pct,
                "status": "ANOMALY" if is_anomaly else "OK",
            }
        )
    return prev, curr, rows


def render_html(prev, curr, rows, threshold: float) -> str:
    if prev is None or curr is None:
        body = "<p>Not enough history to compute anomalies (need at least 2 entries).</p>"
        meta = ""
    else:
        meta = f"<div class='meta'>Comparing {curr.get('run_timestamp','')} vs {prev.get('run_timestamp','')} (threshold {threshold:.0f}% increase)</div>"
        head = (
            "<tr><th>metric</th><th>previous</th><th>current</th><th>delta</th>"
            "<th>delta%</th><th>status</th></tr>"
        )
        body_rows = "\n".join(
            f"<tr><td>{r['metric']}</td><td>{r['previous']:.2f}</td><td>{r['current']:.2f}</td>"
            f"<td>{r['delta']:.2f}</td><td>{r['pct']:.1f}%</td><td>{r['status']}</td></tr>"
            for r in rows
        )
        body = f"<table>{head}{body_rows}</table>"

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Log Metrics Anomalies</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 24px; }}
    h1 {{ margin-bottom: 0; }}
    .meta {{ color: #555; margin-bottom: 12px; }}
    table {{ border-collapse: collapse; width: 100%; }}
    th, td {{ border: 1px solid #ddd; padding: 6px; text-align: left; }}
    th {{ background: #f4f4f4; }}
  </style>
</head>
<body>
  <h1>Log Metrics Anomalies</h1>
  {meta}
  {body}
</body>
</html>
"""


def main():
    parser = argparse.ArgumentParser(description="Render HTML anomalies from the metrics history.")
    parser.add_argument("--history", default="reports/log_metrics_history.csv", help="History CSV path")
    parser.add_argument("--output", default="reports/log_metrics_anomalies.html", help="Output HTML path")
    parser.add_argument("--threshold", type=float, default=20.0, help="Threshold percent increase to flag anomalies")
    args = parser.parse_args()

    history_path = Path(args.history)
    if not history_path.exists():
        raise SystemExit(f"History {history_path} not found")

    history = load_history(history_path)
    prev, curr, rows = compute(history, args.threshold)
    html = render_html(prev, curr, rows, args.threshold)
    Path(args.output).write_text(html)
    print(f"Anomalies HTML written to {args.output}")


if __name__ == "__main__":
    main()
