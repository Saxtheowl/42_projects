#!/usr/bin/env python3
"""
Emit a CSV summary of badge guards (gate/ok/no-regression) from badge_history CSV.
Usage: logs_metrics_guard_summary_csv.py --history reports/log_metrics_badge_history.csv --output reports/log_metrics_guard_summary.csv [--last 0] [--delta-last 0]
"""
import argparse
import csv
from pathlib import Path
from collections import Counter


def main():
    parser = argparse.ArgumentParser(description="Render badge guard summary as CSV.")
    parser.add_argument("--history", default="reports/log_metrics_badge_history.csv", help="Badge history CSV path")
    parser.add_argument("--output", default="reports/log_metrics_guard_summary.csv", help="Output CSV path")
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

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", newline="") as f:
        fieldnames = [
            "guard",
            "ok",
            "fail",
            "unknown",
            "total",
            "window",
            "ok_pct",
            "fail_pct",
            "unknown_pct",
            "current_result",
            "current_len",
            "longest_ok",
            "longest_fail",
            "longest_unknown",
        ]
        if prev_rows:
            fieldnames += [
                "delta_ok",
                "delta_fail",
                "delta_unknown",
                "delta_ok_pct",
                "delta_fail_pct",
                "delta_unknown_pct",
                "delta_window",
            ]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for name, counter in guard_counts.items():
            total = sum(counter.values())
            ok_pct = (counter.get("ok", 0) / total * 100) if total else 0.0
            fail_pct = (counter.get("fail", 0) / total * 100) if total else 0.0
            unknown_pct = (counter.get("unknown", 0) / total * 100) if total else 0.0
            prev_total = sum(prev_counts[name].values()) or 1
            writer.writerow(
                {
                    "guard": name,
                    "ok": counter.get("ok", 0),
                    "fail": counter.get("fail", 0),
                    "unknown": counter.get("unknown", 0),
                    "total": total,
                    "window": window_len,
                    "ok_pct": f"{ok_pct:.1f}",
                    "fail_pct": f"{fail_pct:.1f}",
                    "unknown_pct": f"{unknown_pct:.1f}",
                    "current_result": (guard_streaks.get(name, {}).get("current", {}) or {}).get("result", "unknown"),
                    "current_len": (guard_streaks.get(name, {}).get("current", {}) or {}).get("length", 0),
                    "longest_ok": (guard_streaks.get(name, {}).get("longest", {}) or {}).get("ok", 0),
                    "longest_fail": (guard_streaks.get(name, {}).get("longest", {}) or {}).get("fail", 0),
                    "longest_unknown": (guard_streaks.get(name, {}).get("longest", {}) or {}).get("unknown", 0),
                    **(
                        {
                            "delta_ok": counter.get("ok", 0) - prev_counts[name].get("ok", 0),
                            "delta_fail": counter.get("fail", 0) - prev_counts[name].get("fail", 0),
                            "delta_unknown": counter.get("unknown", 0) - prev_counts[name].get("unknown", 0),
                            "delta_ok_pct": f"{((counter.get('ok', 0) - prev_counts[name].get('ok', 0)) / prev_total * 100):.1f}",
                            "delta_fail_pct": f"{((counter.get('fail', 0) - prev_counts[name].get('fail', 0)) / prev_total * 100):.1f}",
                            "delta_unknown_pct": f"{((counter.get('unknown', 0) - prev_counts[name].get('unknown', 0)) / prev_total * 100):.1f}",
                            "delta_window": len(prev_rows),
                        }
                        if prev_rows
                        else {}
                    ),
                }
            )
    print(f"Guard summary CSV written to {output}")


if __name__ == "__main__":
    main()
