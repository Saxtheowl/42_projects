#!/usr/bin/env python3
"""
Append the current badge state to a history CSV.
Usage: logs_metrics_badge_history.py --latest reports/log_metrics_latest.json --output reports/log_metrics_badge_history.csv
"""
import argparse
import csv
import json
from pathlib import Path
from datetime import datetime, timezone


def main():
    parser = argparse.ArgumentParser(description="Append badge state to badge history CSV.")
    parser.add_argument("--latest", default="reports/log_metrics_latest.json", help="Path to latest JSON summary")
    parser.add_argument("--output", default="reports/log_metrics_badge_history.csv", help="Badge history CSV output path")
    args = parser.parse_args()

    latest_path = Path(args.latest)
    if not latest_path.exists():
        raise SystemExit(f"Latest JSON not found: {latest_path}")

    latest = json.loads(latest_path.read_text())
    generated_at = latest.get("generated_at") or datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    badge_state = latest.get("badge_state", "n/a")
    badge_label = latest.get("badge_label", "metrics")
    badge_thresholds = latest.get("badge_thresholds", {})
    warn = badge_thresholds.get("warn", "")
    danger = badge_thresholds.get("danger", "")
    suffix = latest.get("suffix", "")
    totals = latest.get("totals", {})
    overloaded_ratio = totals.get("overloaded_ratio", "")
    anomalies_count = latest.get("anomalies_count", "")

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    existing_rows = []
    existing_header = []
    if output.exists():
        with output.open(newline="") as f:
            reader = csv.reader(f)
            rows = list(reader)
            if rows:
                existing_header = rows[0]
                for r in rows[1:]:
                    existing_rows.append(r)

    guard = latest.get("badge_guards") or {}
    guard_status = latest.get("badge_guard_status") or {}
    gate_required = guard.get("gate")
    ok_required = guard.get("ok_streak")
    no_reg_enabled = guard.get("no_regression")
    gate_result = (guard_status.get("gate") or {}).get("result")
    ok_result = (guard_status.get("ok_streak") or {}).get("result")
    no_reg_result = (guard_status.get("no_regression") or {}).get("result")

    row = [
        generated_at,
        suffix,
        badge_label,
        badge_state,
        warn,
        danger,
        overloaded_ratio,
        anomalies_count,
        gate_required,
        ok_required,
        no_reg_enabled,
        gate_result,
        ok_result,
        no_reg_result,
    ]

    header = [
        "generated_at",
        "suffix",
        "badge_label",
        "badge_state",
        "badge_warn",
        "badge_danger",
        "overloaded_ratio",
        "anomalies_count",
        "guard_gate",
        "guard_ok_streak",
        "guard_no_regression",
        "guard_gate_result",
        "guard_ok_result",
        "guard_no_regression_result",
    ]

    if existing_header and existing_header != header:
        upgraded_rows = []
        for r in existing_rows:
            row_fixed = (r + [""] * len(header))[: len(header)]
            upgraded_rows.append(row_fixed)
        existing_rows = upgraded_rows
        existing_header = header
    else:
        existing_header = header

    # Normalize existing rows length
    existing_rows = [(r + [""] * len(existing_header))[: len(existing_header)] for r in existing_rows]
    row = (row + [""] * len(existing_header))[: len(existing_header)]

    with output.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(existing_header)
        if existing_rows:
            writer.writerows(existing_rows)
        writer.writerow(row)
    print(f"Badge history updated at {output}")


if __name__ == "__main__":
    main()
