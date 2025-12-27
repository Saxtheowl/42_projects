#!/usr/bin/env python3
"""
Quick consistency check between guard_summary CSV and JSON.
Ensures the special rows/blocks __overall + __overall_streak are aligned.

Usage:
    python3 scripts/logs_metrics_guard_summary_check.py \
        --csv reports/log_metrics_guard_summary.csv \
        --json reports/log_metrics_guard_summary.json
"""
import argparse
import csv
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="Check guard summary CSV/JSON overall blocks consistency.")
    parser.add_argument("--csv", default="reports/log_metrics_guard_summary.csv", help="Guard summary CSV path")
    parser.add_argument("--json", default="reports/log_metrics_guard_summary.json", help="Guard summary JSON path")
    args = parser.parse_args()

    csv_path = Path(args.csv)
    json_path = Path(args.json)
    if not csv_path.exists():
        raise SystemExit(f"Missing CSV: {csv_path}")
    if not json_path.exists():
        raise SystemExit(f"Missing JSON: {json_path}")

    with csv_path.open(newline="") as f:
        rows = list(csv.DictReader(f))
    row_overall = next((r for r in rows if (r.get("guard") or "") == "__overall"), None)
    row_streak = next((r for r in rows if (r.get("guard") or "") == "__overall_streak"), None)
    if not row_overall:
        raise SystemExit(f"{csv_path}: missing __overall row")
    if not row_streak:
        raise SystemExit(f"{csv_path}: missing __overall_streak row")

    try:
        data = json.loads(json_path.read_text())
    except Exception as exc:  # pragma: no cover
        raise SystemExit(f"{json_path}: unreadable JSON ({exc})")

    overall_json = data.get("overall") or {}
    overall_streak_json = data.get("overall_streak") or {}
    if not overall_json:
        raise SystemExit(f"{json_path}: missing overall block")
    if not overall_streak_json:
        raise SystemExit(f"{json_path}: missing overall_streak block")

    # Compare counts/pct/deltas for __overall
    for key in ("ok", "fail", "unknown", "total", "window"):
        if int(row_overall.get(key, 0) or 0) != int(overall_json.get(key, 0) or 0):
            raise SystemExit(
                f"Mismatch overall {key}: csv={row_overall.get(key)}, json={overall_json.get(key)}"
            )
    for key in ("ok_pct", "fail_pct", "unknown_pct"):
        csv_val = float(row_overall.get(key, 0) or 0)
        json_val = float(overall_json.get(key, 0) or 0)
        if abs(csv_val - json_val) > 0.05:
            raise SystemExit(f"Mismatch overall {key}: csv={csv_val}, json={json_val}")
    delta_json = overall_json.get("delta") or {}
    if delta_json:
        for key in ("ok", "fail", "unknown"):
            if int(row_overall.get(f"delta_{key}", 0) or 0) != int(delta_json.get(key, 0) or 0):
                raise SystemExit(
                    f"Mismatch overall delta {key}: csv={row_overall.get(f'delta_{key}')}, json={delta_json.get(key)}"
                )
        for key in ("ok_pct", "fail_pct", "unknown_pct"):
            csv_val = float(row_overall.get(f"delta_{key}", 0) or 0)
            json_val = float(delta_json.get(key, 0) or 0)
            if abs(csv_val - json_val) > 0.05:
                raise SystemExit(
                    f"Mismatch overall delta {key}: csv={csv_val}, json={json_val}"
                )
        if int(row_overall.get("delta_window", 0) or 0) != int(delta_json.get("delta_window", 0) or 0):
            raise SystemExit(
                f"Mismatch overall delta_window: csv={row_overall.get('delta_window')}, json={delta_json.get('delta_window')}"
            )

    # Compare streak block
    for key, csv_key in (("current", "current_result"),):
        csv_res = (row_streak.get(csv_key) or "unknown").lower()
        json_res = (overall_streak_json.get("current", {}) or {}).get("result", "unknown").lower()
        if csv_res != json_res:
            raise SystemExit(f"Mismatch overall_streak current result: csv={csv_res}, json={json_res}")
    if int(row_streak.get("current_len", 0) or 0) != int((overall_streak_json.get("current", {}) or {}).get("length", 0) or 0):
        raise SystemExit(
            f"Mismatch overall_streak current length: csv={row_streak.get('current_len')}, json={(overall_streak_json.get('current',{}) or {}).get('length')}"
        )
    for key, csv_key in (("ok", "longest_ok"), ("fail", "longest_fail"), ("unknown", "longest_unknown")):
        if int(row_streak.get(csv_key, 0) or 0) != int((overall_streak_json.get("longest", {}) or {}).get(key, 0) or 0):
            raise SystemExit(
                f"Mismatch overall_streak longest {key}: csv={row_streak.get(csv_key)}, json={(overall_streak_json.get('longest',{}) or {}).get(key)}"
            )
    if int(row_streak.get("window", 0) or 0) != int(overall_streak_json.get("window", 0) or 0):
        raise SystemExit(
            f"Mismatch overall_streak window: csv={row_streak.get('window')}, json={overall_streak_json.get('window')}"
        )

    print("Guard summary overall blocks are consistent between CSV and JSON.")


if __name__ == "__main__":
    main()
