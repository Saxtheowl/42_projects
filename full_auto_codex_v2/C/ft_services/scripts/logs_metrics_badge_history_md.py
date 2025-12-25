#!/usr/bin/env python3
"""
Render a Markdown summary from badge history CSV.
Usage: logs_metrics_badge_history_md.py --history reports/log_metrics_badge_history.csv --output reports/log_metrics_badge_history.md [--last 20]
"""
import argparse
import csv
from pathlib import Path
from collections import Counter


def main():
    parser = argparse.ArgumentParser(description="Render badge history as Markdown.")
    parser.add_argument("--history", default="reports/log_metrics_badge_history.csv", help="Badge history CSV path")
    parser.add_argument("--output", default="reports/log_metrics_badge_history.md", help="Output Markdown path")
    parser.add_argument("--last", type=int, default=20, help="Number of latest entries to display (0 = all)")
    args = parser.parse_args()

    history_path = Path(args.history)
    if not history_path.exists():
        raise SystemExit(f"Badge history not found: {history_path}")

    with history_path.open(newline="") as f:
        reader = list(csv.DictReader(f))
    rows = reader[-args.last :] if args.last and args.last > 0 else reader
    if not rows:
        raise SystemExit(f"{history_path}: empty badge history")

    state_counts = Counter(r.get("badge_state", "n/a") for r in rows)
    window = len(rows)
    previous_state = rows[-2].get("badge_state", "n/a") if len(rows) >= 2 else None
    # Compute streaks on the window
    current_state = rows[-1].get("badge_state", "n/a").lower()
    current_streak = 0
    longest = Counter()
    for r in reversed(rows):
        s = str(r.get("badge_state", "n/a")).lower()
        if s == current_state:
            current_streak += 1
        else:
            break
    # Longest streak per state
    for r in rows:
        s = str(r.get("badge_state", "n/a")).lower()
        longest[s] = max(longest[s], longest.get(f"_run_{s}", 0) + 1)
        longest[f"_run_{s}"] = longest.get(f"_run_{s}", 0) + 1
        # reset other runs
        for k in list(longest.keys()):
            if k.startswith("_run_") and k != f"_run_{s}":
                longest[k] = 0
    longest_streaks = {k.replace("_run_", ""): v for k, v in longest.items() if k.startswith("_run_") is False}

    lines = ["# Badge History", "", f"- Entries: {len(rows)} (last {args.last if args.last else 'all'})", ""]
    lines.append("## States")
    lines.append("")
    lines.append("| state | count |")
    lines.append("| --- | ---: |")
    for state, count in sorted(state_counts.items()):
        lines.append(f"| {state} | {count} |")

    lines.append("")
    lines.append("## Latest entries")
    lines.append("")
    headers = rows[0].keys()
    lines.append("| " + " | ".join(headers) + " |")
    lines.append("| " + " | ".join(["---"] * len(headers)) + " |")
    for r in rows:
        lines.append("| " + " | ".join(str(r.get(h, "")) for h in headers) + " |")

    lines.append("")
    lines.append("## Timeline (last entries)")
    lines.append("")
    state_map = {"alert": "🟥", "warn": "🟧", "ok": "🟩"}
    timeline = "".join(state_map.get(r.get("badge_state", "").lower(), "⬜") for r in rows)
    lines.append(timeline if timeline else "Aucune donnée.")
    lines.append("")
    lines.append("## Streaks")
    lines.append("")
    lines.append(f"- Window: {window} entrées (last {args.last if args.last else 'all'})")
    if previous_state:
        lines.append(f"- Transition: {previous_state} -> {current_state}")
    lines.append(f"- Current streak: {current_streak} × `{current_state}`")
    if longest_streaks:
        lines.append("- Longest streaks:")
        for state, length in sorted(longest_streaks.items()):
            lines.append(f"  - {state}: {length}")

    # Guard status summary (ok/fail/unknown per guard)
    guard_fields = {
        "gate": "guard_gate_result",
        "ok_streak": "guard_ok_result",
        "no_regression": "guard_no_regression_result",
    }
    guard_counts = {k: Counter() for k in guard_fields}
    for r in rows:
        for name, field in guard_fields.items():
            val = str(r.get(field, "") or "").lower()
            if val not in ("ok", "fail"):
                val = "unknown"
            guard_counts[name][val] += 1

    lines.append("")
    lines.append("## Guards summary")
    lines.append("")
    lines.append("| guard | ok | fail | unknown |")
    lines.append("| --- | ---: | ---: | ---: |")
    for name, counts in guard_counts.items():
        lines.append(f"| {name} | {counts.get('ok',0)} | {counts.get('fail',0)} | {counts.get('unknown',0)} |")

    Path(args.output).write_text("\n".join(lines) + "\n")
    print(f"Badge history Markdown written to {args.output}")


if __name__ == "__main__":
    main()
