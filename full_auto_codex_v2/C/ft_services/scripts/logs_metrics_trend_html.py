#!/usr/bin/env python3
"""
Render an HTML trend table from the metrics history.
Usage: logs_metrics_trend_html.py --history reports/log_metrics_history.csv --output reports/log_metrics_trend.html [--last 10]
"""
import argparse
import csv
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Dict


def load_history(path: Path) -> List[Dict[str, str]]:
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    if not rows:
        raise SystemExit(f"{path}: empty history")
    return rows


def fmt_delta(curr: float, prev: float) -> str:
    delta = curr - prev
    if delta > 0:
        return f"+{delta:.2f}"
    if delta < 0:
        return f"{delta:.2f}"
    return "0"


def build_rows(history: List[Dict[str, str]]):
    rows = []
    for idx, row in enumerate(history):
        prev = history[idx - 1] if idx > 0 else None
        def val(key: str) -> float:
            try:
                return float(row.get(key, 0))
            except ValueError:
                return 0.0

        current = {
            "run_timestamp": row.get("run_timestamp", ""),
            "pattern": row.get("pattern", ""),
            "topn": row.get("topn", ""),
            "snapshot_timestamp": row.get("snapshot_timestamp", row.get("timestamp", "")),
            "status_checks": val("status_checks"),
            "connections": val("connections"),
            "overloaded": val("overloaded"),
            "overloaded_ratio": val("overloaded_ratio"),
        }
        if prev:
            deltas = {
                "d_status": fmt_delta(current["status_checks"], float(prev.get("status_checks", 0) or 0)),
                "d_conn": fmt_delta(current["connections"], float(prev.get("connections", 0) or 0)),
                "d_over": fmt_delta(current["overloaded"], float(prev.get("overloaded", 0) or 0)),
                "d_ratio": fmt_delta(current["overloaded_ratio"], float(prev.get("overloaded_ratio", 0) or 0)),
            }
        else:
            deltas = {"d_status": "—", "d_conn": "—", "d_over": "—", "d_ratio": "—"}

        rows.append({**current, **deltas})
    return rows


def render_table(rows: List[Dict[str, str]]) -> str:
    headers = [
        "run_timestamp",
        "pattern",
        "topn",
        "snapshot_timestamp",
        "status_checks",
        "d_status",
        "connections",
        "d_conn",
        "overloaded",
        "d_over",
        "overloaded_ratio",
        "d_ratio",
    ]
    head = "<tr>" + "".join(f"<th>{h}</th>" for h in headers) + "</tr>"
    body = "\n".join(
        "<tr>"
        + "".join(f"<td>{row.get(h, '')}</td>" for h in headers)
        + "</tr>"
        for row in rows
    )
    return f"<table>\n{head}\n{body}\n</table>"


def main():
    parser = argparse.ArgumentParser(description="Render an HTML trend table from the metrics history.")
    parser.add_argument("--history", default="reports/log_metrics_history.csv", help="History CSV path")
    parser.add_argument("--output", default="reports/log_metrics_trend.html", help="Output HTML path")
    parser.add_argument("--last", type=int, default=10, help="Limit to the latest N rows")
    args = parser.parse_args()

    history_path = Path(args.history)
    if not history_path.exists():
        raise SystemExit(f"History not found: {history_path}")

    history = load_history(history_path)
    if args.last > 0:
        history = history[-args.last :]

    rows = build_rows(history)
    generated = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Log Metrics Trend</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 24px; }}
    h1 {{ margin-bottom: 0; }}
    .meta {{ color: #555; margin-bottom: 16px; }}
    table {{ border-collapse: collapse; width: 100%; }}
    th, td {{ border: 1px solid #ddd; padding: 6px; text-align: left; }}
    th {{ background: #f4f4f4; }}
  </style>
</head>
<body>
  <h1>Log Metrics Trend</h1>
  <div class="meta">Source: {history_path} | Generated: {generated}</div>
  {render_table(rows)}
</body>
</html>
"""
    Path(args.output).write_text(html)
    print(f"Trend HTML written to {args.output}")


if __name__ == "__main__":
    main()
