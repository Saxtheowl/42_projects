#!/usr/bin/env python3
"""
Render an HTML table of stats (min/avg/max/latest) from the metrics history.
Usage: logs_metrics_stats_html.py --history reports/log_metrics_history.csv --output reports/log_metrics_stats.html
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
    if not rows:
        raise SystemExit(f"{path}: empty history")
    return rows


def compute_stats(rows: List[Dict[str, str]]) -> Dict[str, Dict[str, float]]:
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


def render_html(stats: Dict[str, Dict[str, float]]) -> str:
    head = "<tr><th>metric</th><th>min</th><th>avg</th><th>max</th><th>latest</th></tr>"
    body = "\n".join(
        f"<tr><td>{field}</td><td>{vals['min']:.2f}</td><td>{vals['avg']:.2f}</td><td>{vals['max']:.2f}</td><td>{vals['latest']:.2f}</td></tr>"
        for field, vals in stats.items()
    )
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Log Metrics Stats</title>
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
  <h1>Log Metrics Stats</h1>
  <table>
    {head}
    {body}
  </table>
</body>
</html>
"""


def main():
    parser = argparse.ArgumentParser(description="Render HTML stats from metrics history.")
    parser.add_argument("--history", default="reports/log_metrics_history.csv", help="History CSV path")
    parser.add_argument("--output", default="reports/log_metrics_stats.html", help="Output HTML path")
    args = parser.parse_args()

    history_path = Path(args.history)
    if not history_path.exists():
        raise SystemExit(f"History {history_path} not found")

    rows = load_history(history_path)
    stats = compute_stats(rows)
    html = render_html(stats)
    Path(args.output).write_text(html)
    print(f"Stats HTML written to {args.output}")


if __name__ == "__main__":
    main()
