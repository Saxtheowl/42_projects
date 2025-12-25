#!/usr/bin/env python3
"""
Render a Markdown summary of badge guards (gate/ok/no-regression) from badge_history CSV.
Usage: logs_metrics_guard_summary.py --history reports/log_metrics_badge_history.csv --output reports/log_metrics_guard_summary.md [--last 0] [--delta-last 0]
"""
import argparse
import csv
from pathlib import Path
from collections import Counter


def main():
    parser = argparse.ArgumentParser(description="Render badge guard summary as Markdown.")
    parser.add_argument("--history", default="reports/log_metrics_badge_history.csv", help="Badge history CSV path")
    parser.add_argument("--output", default="reports/log_metrics_guard_summary.md", help="Output Markdown path")
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

    has_delta = len(prev_rows) > 0
    delta_window_display = len(prev_rows) if prev_rows else 0
    lines = [
        "# Badge Guard Summary",
        "",
        f"- Entries: {len(rows)} (window {window_len}, delta window {delta_window_display})",
        "",
    ]
    header = ["guard", "window", "ok", "fail", "unknown", "total", "ok%", "fail%", "unknown%"]
    if has_delta:
        header += ["Δok", "Δfail", "Δunknown", "Δok%", "Δfail%", "Δunknown%", "Δwindow"]
    lines.append("| " + " | ".join(header) + " |")
    lines.append("| " + " | ".join("---:" if i else "---" for i in range(len(header))) + " |")
    for name, counts in guard_counts.items():
        total = sum(counts.values())
        ok_pct = (counts.get("ok", 0) / total * 100) if total else 0.0
        fail_pct = (counts.get("fail", 0) / total * 100) if total else 0.0
        unknown_pct = (counts.get("unknown", 0) / total * 100) if total else 0.0
        row = [
            name,
            window_len,
            counts.get("ok", 0),
            counts.get("fail", 0),
            counts.get("unknown", 0),
            total,
            f"{ok_pct:.1f}%",
            f"{fail_pct:.1f}%",
            f"{unknown_pct:.1f}%",
        ]
        if has_delta:
            delta_ok = counts.get("ok", 0) - prev_counts[name].get("ok", 0)
            delta_fail = counts.get("fail", 0) - prev_counts[name].get("fail", 0)
            delta_unknown = counts.get("unknown", 0) - prev_counts[name].get("unknown", 0)
            prev_total = sum(prev_counts[name].values()) or 1
            row += [
                delta_ok,
                delta_fail,
                delta_unknown,
                f"{(delta_ok / prev_total * 100):.1f}%",
                f"{(delta_fail / prev_total * 100):.1f}%",
                f"{(delta_unknown / prev_total * 100):.1f}%",
                len(prev_rows),
            ]
        lines.append("| " + " | ".join(str(v) for v in row) + " |")

    lines.append("")
    lines.append("## Guard streaks (courantes + longest par état)")
    lines.append("| guard | current_result | current_len | longest_ok | longest_fail | longest_unknown | window |")
    lines.append("| --- | --- | ---: | ---: | ---: | ---: | ---: |")
    for name, streak in guard_streaks.items():
        longest = streak.get("longest", {})
        current = streak.get("current", {})
        lines.append(
            "| {guard} | {cur_res} | {cur_len} | {long_ok} | {long_fail} | {long_unknown} | {window} |".format(
                guard=name,
                cur_res=current.get("result", "unknown"),
                cur_len=current.get("length", 0),
                long_ok=longest.get("ok", 0),
                long_fail=longest.get("fail", 0),
                long_unknown=longest.get("unknown", 0),
                window=streak.get("window", 0),
            )
        )

    Path(args.output).write_text("\n".join(lines) + "\n")
    print(f"Guard summary written to {args.output}")


if __name__ == "__main__":
    main()
