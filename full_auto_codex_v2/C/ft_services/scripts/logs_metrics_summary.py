#!/usr/bin/env python3
"""
Build a short Markdown summary from a metrics CSV snapshot (uses Totals).
Usage: logs_metrics_summary.py --input reports/log_metrics_snapshot.status_top2.csv --output reports/log_metrics_summary.md
"""
import argparse
import csv
from pathlib import Path


def load_totals(csv_path: Path):
    with csv_path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    if not rows:
        raise SystemExit("Snapshot is empty")
    if rows[-1].get("log_file") != "Totals":
        raise SystemExit("Snapshot missing Totals")
    totals = rows[-1]
    return totals


def main():
    parser = argparse.ArgumentParser(description="Generate a Markdown summary from metrics snapshot.")
    parser.add_argument("--input", required=True, help="CSV snapshot path")
    parser.add_argument("--output", help="Output Markdown path (default: <input>.summary.md)")
    args = parser.parse_args()

    csv_path = Path(args.input)
    if not csv_path.exists():
        raise SystemExit(f"{csv_path} not found")
    out = Path(args.output) if args.output else csv_path.with_suffix(".summary.md")

    totals = load_totals(csv_path)
    snapshot_ts = totals.get("timestamp", "")
    lines = [
        "# Log Metrics Summary",
        "",
        f"- Snapshot: `{csv_path}`",
        f"- Snapshot timestamp (UTC): {snapshot_ts}",
        "",
        "| metric | value |",
        "| --- | --- |",
        f"| status_checks | {totals.get('status_checks','')} |",
        f"| connections | {totals.get('connections','')} |",
        f"| overloaded | {totals.get('overloaded','')} |",
        f"| overloaded_ratio | {totals.get('overloaded_ratio','')} |",
    ]
    out.write_text("\n".join(lines) + "\n")
    print(f"Summary written to {out}")


if __name__ == "__main__":
    main()
