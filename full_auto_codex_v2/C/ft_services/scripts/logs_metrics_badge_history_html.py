#!/usr/bin/env python3
"""
Render an HTML summary from badge history CSV.
Usage: logs_metrics_badge_history_html.py --history reports/log_metrics_badge_history.csv --output reports/log_metrics_badge_history.html [--last 20]
"""
import argparse
import csv
from pathlib import Path
from collections import Counter


def render_table(rows, headers):
    head = "<tr>" + "".join(f"<th>{h}</th>" for h in headers) + "</tr>"
    body = "\n".join(
        "<tr>" + "".join(f"<td>{row.get(h,'')}</td>" for h in headers) + "</tr>"
        for row in rows
    )
    return f"<table>\n{head}\n{body}\n</table>"


def main():
    parser = argparse.ArgumentParser(description="Render badge history as HTML.")
    parser.add_argument("--history", default="reports/log_metrics_badge_history.csv", help="Badge history CSV path")
    parser.add_argument("--output", default="reports/log_metrics_badge_history.html", help="Output HTML path")
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
    state_rows = [{"state": k, "count": v} for k, v in sorted(state_counts.items())]
    headers = list(rows[0].keys())
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
    timeline_items = []
    color_map = {"alert": "#d9534f", "warn": "#f0ad4e", "ok": "#4c1"}
    for r in rows:
        state = str(r.get("badge_state", "n/a")).lower()
        color = color_map.get(state, "#ccc")
        timeline_items.append(f"<span style='display:inline-block;width:12px;height:12px;background:{color};margin-right:2px;border-radius:2px;' title='{state}'></span>")
    # Streaks
    current_state = str(rows[-1].get("badge_state", "n/a")).lower()
    current_streak = 0
    for r in reversed(rows):
        if str(r.get("badge_state", "n/a")).lower() == current_state:
            current_streak += 1
        else:
            break
    longest = Counter()
    run = Counter()
    for r in rows:
        s = str(r.get("badge_state", "n/a")).lower()
        run[s] += 1
        for other in list(run.keys()):
            if other != s:
                run[other] = 0
        longest[s] = max(longest[s], run[s])
    window = len(rows)
    previous_state = rows[-2].get("badge_state", "n/a") if len(rows) >= 2 else None

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Badge History</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 24px; }}
    table {{ border-collapse: collapse; width: 100%; margin-bottom: 16px; }}
    th, td {{ border: 1px solid #ddd; padding: 6px; text-align: left; }}
    th {{ background: #f4f4f4; }}
  </style>
</head>
<body>
  <h1>Badge History</h1>
  <p>Entries: {len(rows)} (window {window}, last {args.last if args.last else 'all'})</p>
  <h2>States</h2>
  {render_table(state_rows, ["state", "count"])}
  <h2>Latest entries</h2>
  {render_table(rows, headers)}
  <h2>Guards summary</h2>
  {render_table([{"guard": name, "ok": counts.get("ok",0), "fail": counts.get("fail",0), "unknown": counts.get("unknown",0)} for name, counts in guard_counts.items()], ["guard","ok","fail","unknown"])}
  <h2>Timeline</h2>
  <div>{''.join(timeline_items)}</div>
  <h2>Streaks</h2>
  <p>Transition: {previous_state or 'n/a'} -> {current_state}</p>
  <p>Current: {current_streak} × {current_state}</p>
  <ul>
    {"".join(f"<li>{state}: {length}</li>" for state, length in sorted(longest.items()))}
  </ul>
</body>
</html>
"""
    Path(args.output).write_text(html)
    print(f"Badge history HTML written to {args.output}")


if __name__ == "__main__":
    main()
