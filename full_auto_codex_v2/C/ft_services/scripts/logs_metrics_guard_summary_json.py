#!/usr/bin/env python3
"""
Emit a JSON summary of badge guards (gate/ok/no-regression) from badge_history CSV.
Usage: logs_metrics_guard_summary_json.py --history reports/log_metrics_badge_history.csv --output reports/log_metrics_guard_summary.json [--last 0] [--delta-last 0]
"""
import argparse
import csv
import json
from pathlib import Path
from collections import Counter


def main():
    parser = argparse.ArgumentParser(description="Render badge guard summary as JSON.")
    parser.add_argument("--history", default="reports/log_metrics_badge_history.csv", help="Badge history CSV path")
    parser.add_argument("--output", default="reports/log_metrics_guard_summary.json", help="Output JSON path")
    parser.add_argument("--last", type=int, default=0, help="Number of latest entries to include (0 = all)")
    parser.add_argument(
        "--delta-last",
        type=int,
        default=0,
        help="Number of entries for the previous window used for deltas (0 = match window)",
    )
    args = parser.parse_args()

    history_path = Path(args.history)
    if not history_path.exists():
        raise SystemExit(f"Badge history not found: {history_path}")

    with history_path.open(newline="") as f:
        reader = list(csv.DictReader(f))
    rows = reader[-args.last :] if args.last and args.last > 0 else reader
    window_len = len(rows)
    delta_window_len = args.delta_last if args.delta_last and args.delta_last > 0 else window_len
    prev_rows = []
    if delta_window_len > 0 and window_len > 0:
        if len(reader) >= window_len + delta_window_len:
            prev_rows = reader[-(window_len + delta_window_len) : -window_len]
    if not rows:
        raise SystemExit(f"{history_path}: empty badge history")

    guard_fields = {
        "gate": "guard_gate_result",
        "ok_streak": "guard_ok_result",
        "no_regression": "guard_no_regression_result",
    }
    guard_counts = {k: Counter() for k in guard_fields}
    guard_streaks = {}
    prev_counts = {k: Counter() for k in guard_fields}
    for r in rows:
        for name, field in guard_fields.items():
            val = str(r.get(field, "") or "").lower()
            if val not in ("ok", "fail"):
                val = "unknown"
            guard_counts[name][val] += 1
    for name, field in guard_fields.items():
        current_result = None
        current_len = 0
        for r in reversed(rows):
            val = str(r.get(field, "") or "").lower()
            if val not in ("ok", "fail"):
                val = "unknown"
            if current_result is None:
                current_result = val
                current_len = 1
            elif val == current_result:
                current_len += 1
            else:
                break
        longest = {"ok": 0, "fail": 0, "unknown": 0}
        running = {"ok": 0, "fail": 0, "unknown": 0}
        for r in rows:
            val = str(r.get(field, "") or "").lower()
            if val not in ("ok", "fail"):
                val = "unknown"
            for k in running:
                running[k] = running[k] + 1 if k == val else 0
                longest[k] = max(longest[k], running[k])
        guard_streaks[name] = {
            "current": {"result": current_result or "unknown", "length": current_len},
            "longest": longest,
            "window": len(rows),
        }
    for r in prev_rows:
        for name, field in guard_fields.items():
            val = str(r.get(field, "") or "").lower()
            if val not in ("ok", "fail"):
                val = "unknown"
            prev_counts[name][val] += 1

    summary = {}
    aggregate_states = []
    prev_aggregate_states = []
    for name, counter in guard_counts.items():
        total = sum(counter.values())
        ok_pct = (counter.get("ok", 0) / total * 100) if total else 0.0
        fail_pct = (counter.get("fail", 0) / total * 100) if total else 0.0
        unknown_pct = (counter.get("unknown", 0) / total * 100) if total else 0.0
        summary[name] = {
            "ok": counter.get("ok", 0),
            "fail": counter.get("fail", 0),
            "unknown": counter.get("unknown", 0),
            "total": total,
            "window": window_len,
            "ok_pct": round(ok_pct, 1),
            "fail_pct": round(fail_pct, 1),
            "unknown_pct": round(unknown_pct, 1),
        }
        if prev_rows:
            prev_total = sum(prev_counts[name].values()) or 1
            summary[name]["delta"] = {
                "ok": counter.get("ok", 0) - prev_counts[name].get("ok", 0),
                "fail": counter.get("fail", 0) - prev_counts[name].get("fail", 0),
                "unknown": counter.get("unknown", 0) - prev_counts[name].get("unknown", 0),
                "window": window_len,
                "delta_window": len(prev_rows),
                "ok_pct": round(((counter.get("ok", 0) - prev_counts[name].get("ok", 0)) / prev_total * 100), 1),
                "fail_pct": round(((counter.get("fail", 0) - prev_counts[name].get("fail", 0)) / prev_total * 100), 1),
                "unknown_pct": round(((counter.get("unknown", 0) - prev_counts[name].get("unknown", 0)) / prev_total * 100), 1),
            }
        summary[name]["streak"] = guard_streaks.get(name, {})
        # Build aggregate view row-wise for overall streak
    for r in rows:
        vals_row = []
        for _, field in guard_fields.items():
            val = str(r.get(field, "") or "").lower()
            if val not in ("ok", "fail"):
                val = "unknown"
            vals_row.append(val)
        if any(v == "fail" for v in vals_row):
            aggregate_states.append("fail")
        elif all(v == "ok" for v in vals_row):
            aggregate_states.append("ok")
        else:
            aggregate_states.append("unknown")
    for r in prev_rows:
        vals_row = []
        for _, field in guard_fields.items():
            val = str(r.get(field, "") or "").lower()
            if val not in ("ok", "fail"):
                val = "unknown"
            vals_row.append(val)
        if any(v == "fail" for v in vals_row):
            prev_aggregate_states.append("fail")
        elif all(v == "ok" for v in vals_row):
            prev_aggregate_states.append("ok")
        else:
            prev_aggregate_states.append("unknown")
    current_overall = None
    current_overall_len = 0
    for val in reversed(aggregate_states):
        if current_overall is None:
            current_overall = val
            current_overall_len = 1
        elif val == current_overall:
            current_overall_len += 1
        else:
            break
    running_overall = {"ok": 0, "fail": 0, "unknown": 0}
    longest_overall = {"ok": 0, "fail": 0, "unknown": 0}
    for val in aggregate_states:
        for k in running_overall:
            running_overall[k] = running_overall[k] + 1 if k == val else 0
            longest_overall[k] = max(longest_overall[k], running_overall[k])
    summary["overall_streak"] = {
        "current": {"result": current_overall or "unknown", "length": current_overall_len},
        "longest": longest_overall,
        "window": len(rows),
    }
    aggregate_counts = Counter(aggregate_states)
    overall = {
        "ok": aggregate_counts.get("ok", 0),
        "fail": aggregate_counts.get("fail", 0),
        "unknown": aggregate_counts.get("unknown", 0),
        "total": sum(aggregate_counts.values()),
        "window": len(aggregate_states),
    }
    total = overall["total"] or 1
    overall["ok_pct"] = round(overall["ok"] / total * 100, 1)
    overall["fail_pct"] = round(overall["fail"] / total * 100, 1)
    overall["unknown_pct"] = round(overall["unknown"] / total * 100, 1)
    if prev_aggregate_states:
        prev_counts = Counter(prev_aggregate_states)
        prev_total = sum(prev_counts.values()) or 1
        overall["delta"] = {
            "ok": overall["ok"] - prev_counts.get("ok", 0),
            "fail": overall["fail"] - prev_counts.get("fail", 0),
            "unknown": overall["unknown"] - prev_counts.get("unknown", 0),
            "delta_window": len(prev_aggregate_states),
            "window": len(aggregate_states),
            "ok_pct": round((overall["ok"] - prev_counts.get("ok", 0)) / prev_total * 100, 1),
            "fail_pct": round((overall["fail"] - prev_counts.get("fail", 0)) / prev_total * 100, 1),
            "unknown_pct": round((overall["unknown"] - prev_counts.get("unknown", 0)) / prev_total * 100, 1),
        }
    summary["overall"] = overall

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(summary, indent=2))
    print(f"Guard summary JSON written to {output}")


if __name__ == "__main__":
    main()
