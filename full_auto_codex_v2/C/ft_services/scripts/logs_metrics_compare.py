#!/usr/bin/env python3
"""
Compare two metrics CSV snapshots and produce a Markdown diff report.
Usage: logs_metrics_compare.py --base reports/log_metrics_snapshot.status_top2.csv --target reports/log_metrics_snapshot.status_top2.csv [--output reports/log_metrics_compare.md]
"""
import argparse
import csv
from pathlib import Path


FIELDS = ["status_checks", "connections", "overloaded", "overloaded_ratio"]


def load_csv(path: Path):
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = {row["log_file"]: row for row in reader}
    if "Totals" not in rows:
        raise SystemExit(f"Missing Totals in {path}")
    return rows


def diff(base_rows, target_rows):
    all_keys = set(base_rows.keys()) | set(target_rows.keys())
    entries = []
    for key in sorted(all_keys):
        base = base_rows.get(key)
        target = target_rows.get(key)
        entry = {"log_file": key}
        for field in FIELDS:
            b_val = float(base.get(field, 0)) if base else 0.0
            t_val = float(target.get(field, 0)) if target else 0.0
            entry[f"{field}_base"] = b_val
            entry[f"{field}_target"] = t_val
            entry[f"{field}_delta"] = t_val - b_val
        entries.append(entry)
    return entries


def write_markdown(entries, base_path, target_path, output_path):
    header = (
        "| log_file | status_base | status_target | Δstatus | connections_base | connections_target | Δconnections | "
        "overloaded_base | overloaded_target | Δoverloaded | ratio_base | ratio_target | Δratio |\n"
        "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |\n"
    )
    lines = [
        f"# Log Metrics Diff\n\n- Base: `{base_path}`\n- Target: `{target_path}`\n",
        header,
    ]
    for e in entries:
        lines.append(
            "| {log_file} | {status_checks_base:.2f} | {status_checks_target:.2f} | {status_checks_delta:.2f} | "
            "{connections_base:.2f} | {connections_target:.2f} | {connections_delta:.2f} | "
            "{overloaded_base:.2f} | {overloaded_target:.2f} | {overloaded_delta:.2f} | "
            "{overloaded_ratio_base:.2f} | {overloaded_ratio_target:.2f} | {overloaded_ratio_delta:.2f} |".format(
                **e
            )
        )
    Path(output_path).write_text("\n".join(lines) + "\n")
    print(f"Diff report written to {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Compare two metrics CSV snapshots and output a Markdown diff.")
    parser.add_argument("--base", required=True, help="Base CSV snapshot")
    parser.add_argument("--target", required=True, help="Target CSV snapshot")
    parser.add_argument("--output", help="Output Markdown file (default: reports/log_metrics_compare.md)")
    args = parser.parse_args()

    base_path = Path(args.base)
    target_path = Path(args.target)
    if not base_path.exists():
        raise SystemExit(f"Base file {base_path} not found")
    if not target_path.exists():
        raise SystemExit(f"Target file {target_path} not found")

    output = Path(args.output) if args.output else Path("reports/log_metrics_compare.md")
    base_rows = load_csv(base_path)
    target_rows = load_csv(target_path)
    entries = diff(base_rows, target_rows)
    write_markdown(entries, base_path, target_path, output)


if __name__ == "__main__":
    main()
