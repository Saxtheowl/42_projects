#!/usr/bin/env python3
"""
Generate a simple HTML report from a metrics CSV snapshot (expects a Totals line).
Usage: logs_metrics_report_html.py --input reports/log_metrics_snapshot.status_top2.csv [--output reports/log_metrics_snapshot.status_top2.html]
"""
import argparse
import csv
from datetime import datetime, timezone
from pathlib import Path


def load_rows(csv_path: Path):
    with csv_path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    if not rows:
        raise SystemExit("No rows found in CSV")
    if rows[-1].get("log_file") != "Totals":
        raise SystemExit("Missing Totals line in CSV (last row must have log_file=Totals)")
    return rows


def render_html(rows, source):
    generated = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    head = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Log Metrics Report</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 24px; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background: #f4f4f4; }
    tr:nth-child(even) { background: #fafafa; }
    .totals { font-weight: bold; }
  </style>
</head>
<body>
"""
    meta = f"<h1>Log Metrics Report</h1>\n<p>Source: <code>{source}</code><br>Generated: {generated}</p>\n"
    header = "<table>\n<tr><th>log_file</th><th>status_checks</th><th>connections</th><th>overloaded</th><th>overloaded_ratio</th><th>timestamp</th></tr>\n"
    body_rows = []
    for row in rows:
        cls = " class=\"totals\"" if row.get("log_file") == "Totals" else ""
        body_rows.append(
            f"<tr{cls}><td>{row.get('log_file','')}</td>"
            f"<td>{row.get('status_checks','')}</td>"
            f"<td>{row.get('connections','')}</td>"
            f"<td>{row.get('overloaded','')}</td>"
            f"<td>{row.get('overloaded_ratio','')}</td>"
            f"<td>{row.get('timestamp','')}</td></tr>"
        )
    footer = "</table>\n</body>\n</html>\n"
    return head + meta + header + "\n".join(body_rows) + "\n" + footer


def main():
    parser = argparse.ArgumentParser(description="Generate an HTML report from a metrics CSV snapshot.")
    parser.add_argument("--input", default="reports/log_metrics_snapshot.status_top2.csv", help="Path to CSV snapshot")
    parser.add_argument("--output", help="Output HTML file (defaults to <input>.html)")
    args = parser.parse_args()

    csv_path = Path(args.input)
    if not csv_path.exists():
        raise SystemExit(f"Input CSV {csv_path} not found")
    output = Path(args.output) if args.output else csv_path.with_suffix(".html")

    rows = load_rows(csv_path)
    html = render_html(rows, source=str(csv_path))
    output.write_text(html)
    print(f"HTML report written to {output}")


if __name__ == "__main__":
    main()
