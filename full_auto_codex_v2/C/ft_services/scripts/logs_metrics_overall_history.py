#!/usr/bin/env python3
"""
Append the current overall status snapshot to a CSV history.

Usage:
  python3 scripts/logs_metrics_overall_history.py --status-json reports/log_metrics_status.json --output reports/log_metrics_overall_history.csv --keep-last 200
"""
import argparse
import csv
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Any, List


def load_status(path: Path) -> Dict[str, Any]:
    if not path.exists():
        raise SystemExit(f"status JSON not found: {path}")
    return json.loads(path.read_text())


def read_rows(path: Path) -> List[Dict[str, str]]:
    if not path.exists():
        return []
    with path.open(newline="") as f:
        return list(csv.DictReader(f))


def write_rows(path: Path, rows: List[Dict[str, str]], fieldnames: List[str]):
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main():
    parser = argparse.ArgumentParser(description="Append overall status to history CSV.")
    parser.add_argument("--status-json", default="reports/log_metrics_status.json", help="Path to status JSON")
    parser.add_argument("--output", default="reports/log_metrics_overall_history.csv", help="Output CSV path")
    parser.add_argument("--keep-last", type=int, default=200, help="Max rows to keep (0 = unlimited)")
    args = parser.parse_args()

    status_path = Path(args.status_json)
    output_path = Path(args.output)
    data = load_status(status_path)

    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    row = {
        "run_timestamp": now,
        "overall_state": str(data.get("overall_state", "")),
        "badge_state": str(data.get("badge_state", "")),
        "anomalies_count": str(data.get("anomalies_count", "")),
        "overloaded_ratio": str(data.get("overloaded_ratio", "")),
        "sitemap_status": (data.get("sitemap") or {}).get("status", ""),
        "manifest_status": (data.get("manifest") or {}).get("status", ""),
        "guard_check": data.get("guard_check", ""),
        "checksums": data.get("checksums", ""),
        "validation_status": (data.get("validation") or {}).get("status", ""),
    }

    fieldnames = list(row.keys())
    rows = read_rows(output_path)
    rows.append(row)
    if args.keep_last and len(rows) > args.keep_last:
        rows = rows[-args.keep_last :]
    write_rows(output_path, rows, fieldnames)
    print(f"Overall history appended to {output_path} (total rows: {len(rows)})")


if __name__ == "__main__":
    main()
