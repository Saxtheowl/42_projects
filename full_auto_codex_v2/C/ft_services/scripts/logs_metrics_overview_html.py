#!/usr/bin/env python3
"""
Render an HTML overview of the latest metrics snapshot (Totals + delta vs previous + links).
Usage: logs_metrics_overview_html.py --reports reports --suffix status_top2 --output reports/log_metrics_overview.html
"""
import argparse
import csv
from pathlib import Path
from typing import Dict, List


def load_totals(csv_path: Path) -> Dict[str, str]:
    with csv_path.open(newline="") as f:
        rows = list(csv.DictReader(f))
    if not rows:
        raise SystemExit(f"{csv_path}: empty CSV")
    totals = rows[-1]
    if totals.get("log_file") != "Totals":
        raise SystemExit(f"{csv_path}: missing Totals row")
    return totals


def load_history(history_path: Path) -> List[Dict[str, str]]:
    if not history_path.exists():
        return []
    with history_path.open(newline="") as f:
        return list(csv.DictReader(f))


def delta_rows(history: List[Dict[str, str]]):
    if len(history) < 2:
        return []
    prev, curr = history[-2], history[-1]
    rows = []
    for key in ["status_checks", "connections", "overloaded", "overloaded_ratio"]:
        p = float(prev.get(key, 0) or 0)
        c = float(curr.get(key, 0) or 0)
        rows.append((key, p, c, c - p))
    return rows


def render_table(rows, headers):
    head = "<tr>" + "".join(f"<th>{h}</th>" for h in headers) + "</tr>"
    body = "\n".join(
        "<tr>" + "".join(f"<td>{val}</td>" for val in row) + "</tr>"
        for row in rows
    )
    return f"<table>\n{head}\n{body}\n</table>"


def main():
    parser = argparse.ArgumentParser(description="Render an HTML overview of metrics artifacts.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix")
    parser.add_argument("--output", default=None, help="Output HTML path (default reports/log_metrics_overview.html)")
    args = parser.parse_args()

    reports = Path(args.reports)
    output = Path(args.output) if args.output else reports / "log_metrics_overview.html"
    base = reports / f"log_metrics_snapshot.{args.suffix}"
    csv_path = Path(f"{base}.csv")
    history_path = reports / "log_metrics_history.csv"

    totals = load_totals(csv_path)
    history = load_history(history_path)
    deltas = delta_rows(history)

    links = []
    def add_link(label, path):
        if path.exists():
            rel = path.relative_to(reports)
            links.append((label, rel))

    add_link("CSV", csv_path)
    add_link("JSON", Path(f"{base}.json"))
    add_link("JSONL", Path(f"{base}.jsonl"))
    add_link("Markdown", Path(f"{base}.md"))
    add_link("HTML", Path(f"{base}.html"))
    add_link("Summary (md)", Path(f"{base}.summary.md"))
    add_link("Summary (html)", Path(f"{base}.summary.html"))
    add_link("History", history_path)
    add_link("Trend (md)", reports / "log_metrics_trend.md")
    add_link("Trend (html)", reports / "log_metrics_trend.html")
    add_link("Stats (md)", reports / "log_metrics_stats.md")
    add_link("Stats (html)", reports / "log_metrics_stats.html")
    add_link("Anomalies (md)", reports / "log_metrics_anomalies.md")
    add_link("Anomalies (html)", reports / "log_metrics_anomalies.html")
    add_link("Anomalies (json)", reports / "log_metrics_anomalies.json")
    add_link("Compare (md)", reports / "log_metrics_compare.md")
    add_link("Compare (html)", reports / "log_metrics_compare.html")
    add_link("Index (md)", reports / "index.md")
    add_link("Index (html)", reports / "index.html")
    add_link("Manifest", reports / "log_metrics_manifest.json")
    add_link("Checksums", reports / "log_metrics_checksums.txt")
    add_link("Bundle", reports / "log_metrics_bundle.tar.gz")
    add_link("Portal", reports / "portal.html")

    totals_rows = [(k, totals.get(k, "")) for k in ["status_checks", "connections", "overloaded", "overloaded_ratio"]]
    delta_section = render_table([(k, f"{p:.2f}", f"{c:.2f}", f"{d:.2f}") for k, p, c, d in deltas], ["metric", "previous", "current", "delta"]) if deltas else "<p>Pas de delta (historique insuffisant).</p>"
    links_section = render_table([(label, f"<a href='{rel}'>{rel}</a>") for label, rel in links], ["label", "path"])

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Log Metrics Overview</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 24px; }}
    h1, h2 {{ margin-bottom: 8px; }}
    table {{ border-collapse: collapse; width: 100%; margin-bottom: 16px; }}
    th, td {{ border: 1px solid #ddd; padding: 6px; text-align: left; }}
    th {{ background: #f4f4f4; }}
  </style>
</head>
<body>
  <h1>Log Metrics Overview</h1>
  <h2>Totals</h2>
  {render_table([(k, v) for k, v in totals_rows], ["metric", "value"])}
  <h2>Delta vs précédent</h2>
  {delta_section}
  <h2>Liens artefacts</h2>
  {links_section}
</body>
</html>
"""
    output.write_text(html)
    print(f"Overview HTML written to {output}")


if __name__ == "__main__":
    main()
