#!/usr/bin/env python3
"""
Render a simple HTML summary from a snapshot CSV (Totals row).
Usage: logs_metrics_summary_html.py --input reports/log_metrics_snapshot.status_top2.csv --output reports/log_metrics_snapshot.status_top2.summary.html
"""
import argparse
import csv
from pathlib import Path


def load_totals(path: Path):
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    if not rows:
        raise SystemExit(f"{path}: empty CSV")
    totals = rows[-1]
    if totals.get("log_file") != "Totals":
        raise SystemExit(f"{path}: missing Totals row")
    return totals


def render_html(totals: dict) -> str:
    rows = [
        ("status_checks", totals.get("status_checks", "")),
        ("connections", totals.get("connections", "")),
        ("overloaded", totals.get("overloaded", "")),
        ("overloaded_ratio", totals.get("overloaded_ratio", "")),
    ]
    head = "<tr><th>metric</th><th>value</th></tr>"
    body = "\n".join(f"<tr><td>{k}</td><td>{v}</td></tr>" for k, v in rows)
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Log Metrics Summary</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 24px; }}
    h1 {{ margin-bottom: 0; }}
    table {{ border-collapse: collapse; width: 100%; }}
    th, td {{ border: 1px solid #ddd; padding: 6px; text-align: left; }}
    th {{ background: #f4f4f4; }}
  </style>
</head>
<body>
  <h1>Log Metrics Summary</h1>
  <table>
    {head}
    {body}
  </table>
</body>
</html>
"""


def main():
    parser = argparse.ArgumentParser(description="Render an HTML summary from a snapshot CSV.")
    parser.add_argument("--input", required=True, help="Snapshot CSV path")
    parser.add_argument("--output", required=True, help="Output HTML path")
    args = parser.parse_args()

    csv_path = Path(args.input)
    if not csv_path.exists():
        raise SystemExit(f"Input CSV not found: {csv_path}")
    totals = load_totals(csv_path)
    html = render_html(totals)
    Path(args.output).write_text(html)
    print(f"Summary HTML written to {args.output}")


if __name__ == "__main__":
    main()
