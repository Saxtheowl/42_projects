#!/usr/bin/env python3
"""
Generate a concise Markdown overview of the latest metrics snapshot.
Includes Totals, optional delta vs previous history entry, and links to artifacts.
Usage: logs_metrics_overview.py --reports reports --suffix status_top2 --output reports/log_metrics_overview.md
"""
import argparse
import csv
from pathlib import Path
from typing import Dict, List, Optional


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


def delta_section(history: List[Dict[str, str]]) -> Optional[str]:
    if len(history) < 2:
        return None
    prev, curr = history[-2], history[-1]
    lines = [
        "## Delta vs précédent",
        "",
        "| metric | previous | current | delta |",
        "| --- | --- | --- | --- |",
    ]
    for key in ["status_checks", "connections", "overloaded", "overloaded_ratio"]:
        p = float(prev.get(key, 0) or 0)
        c = float(curr.get(key, 0) or 0)
        lines.append(f"| {key} | {p:.2f} | {c:.2f} | {c - p:.2f} |")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Generate a Markdown overview for metrics artifacts.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix (pattern_topN)")
    parser.add_argument("--output", default=None, help="Output file (default reports/log_metrics_overview.md)")
    args = parser.parse_args()

    reports = Path(args.reports)
    base = reports / f"log_metrics_snapshot.{args.suffix}"
    csv_path = Path(f"{base}.csv")
    history_path = reports / "log_metrics_history.csv"

    if not csv_path.exists():
        raise SystemExit(f"Snapshot CSV not found: {csv_path}")

    totals = load_totals(csv_path)
    history = load_history(history_path)
    delta = delta_section(history)

    links = {
        "CSV": csv_path,
        "JSON": Path(f"{base}.json"),
        "JSONL": Path(f"{base}.jsonl"),
        "Markdown": Path(f"{base}.md"),
        "HTML": Path(f"{base}.html"),
        "Summary (md)": Path(f"{base}.summary.md"),
        "Summary (html)": Path(f"{base}.summary.html"),
        "History": history_path,
        "Trend (md)": reports / "log_metrics_trend.md",
        "Trend (html)": reports / "log_metrics_trend.html",
        "Stats (md)": reports / "log_metrics_stats.md",
        "Stats (html)": reports / "log_metrics_stats.html",
        "Anomalies (md)": reports / "log_metrics_anomalies.md",
        "Anomalies (html)": reports / "log_metrics_anomalies.html",
        "Anomalies (json)": reports / "log_metrics_anomalies.json",
        "Index (md)": reports / "index.md",
        "Index (html)": reports / "index.html",
        "Portal": reports / "portal.html",
        "Manifest": reports / "log_metrics_manifest.json",
        "Checksums": reports / "log_metrics_checksums.txt",
        "Bundle": reports / "log_metrics_bundle.tar.gz",
        "Compare (md)": reports / "log_metrics_compare.md",
        "Compare (html)": reports / "log_metrics_compare.html",
    }

    output_path = Path(args.output) if args.output else reports / "log_metrics_overview.md"
    lines = [
        "# Log Metrics Overview",
        "",
        "## Totals",
        "",
        "| metric | value |",
        "| --- | --- |",
    ]
    for key in ["status_checks", "connections", "overloaded", "overloaded_ratio"]:
        lines.append(f"| {key} | {totals.get(key, '')} |")

    if delta:
        lines.append("")
        lines.append(delta)

    lines.append("")
    lines.append("## Liens utiles")
    for label, path in links.items():
        if path.exists():
            rel = path.relative_to(reports)
            lines.append(f"- {label}: {rel}")

    output_path.write_text("\n".join(lines) + "\n")
    print(f"Overview written to {output_path}")


if __name__ == "__main__":
    main()
