#!/usr/bin/env python3
"""
Convert a metrics CSV snapshot to JSONL (one object per line) for ingestion.
Usage: logs_metrics_snapshot_to_jsonl.py --input reports/log_metrics_snapshot.status_top2.csv --output reports/log_metrics_snapshot.status_top2.jsonl
The Totals line is kept as a dedicated record.
"""
import argparse
import csv
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="Convert a metrics CSV snapshot to JSONL.")
    parser.add_argument("--input", required=True, help="CSV snapshot path")
    parser.add_argument("--output", help="Output JSONL path (default: <input>.jsonl)")
    args = parser.parse_args()

    csv_path = Path(args.input)
    if not csv_path.exists():
        raise SystemExit(f"Input CSV {csv_path} not found")
    out_path = Path(args.output) if args.output else csv_path.with_suffix(".jsonl")

    with csv_path.open(newline="") as f_in, out_path.open("w") as f_out:
        reader = csv.DictReader(f_in)
        rows = list(reader)
        if not rows:
            raise SystemExit("No rows found in CSV")
        if rows[-1].get("log_file") != "Totals":
            raise SystemExit("Missing Totals line in CSV (last row must have log_file=Totals)")
        for row in rows:
            f_out.write(json.dumps(row) + "\n")
    print(f"JSONL written to {out_path}")


if __name__ == "__main__":
    main()
