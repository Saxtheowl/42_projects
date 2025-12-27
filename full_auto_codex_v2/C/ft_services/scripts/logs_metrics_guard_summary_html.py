#!/usr/bin/env python3
"""
Render an HTML summary of badge guards (gate/ok/no-regression) from badge_history CSV.
Usage: logs_metrics_guard_summary_html.py --history reports/log_metrics_badge_history.csv --output reports/log_metrics_guard_summary.html [--last 0] [--delta-last 0]
"""
import argparse
import csv
from pathlib import Path
from collections import Counter


def render_table(rows, headers):
    head = "<tr>" + "".join(f"<th>{h}</th>" for h in headers) + "</tr>"
    body = "\n".join("<tr>" + "".join(f"<td>{row.get(h,'')}</td>" for h in headers) + "</tr>" for row in rows)
    return f"<table>\n{head}\n{body}\n</table>"


def main():
    parser = argparse.ArgumentParser(description="Render badge guard summary as HTML.")
    parser.add_argument("--history", default="reports/log_metrics_badge_history.csv", help="Badge history CSV path")
    parser.add_argument("--output", default="reports/log_metrics_guard_summary.html", help="Output HTML path")
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
    aggregate_states = []
    prev_aggregate_states = []
    prev_counts = {k: Counter() for k in guard_fields}
    for r in rows:
        vals_row = []
        for name, field in guard_fields.items():
            val = str(r.get(field, "") or "").lower()
            if val not in ("ok", "fail"):
                val = "unknown"
            guard_counts[name][val] += 1
            vals_row.append(val)
        if any(v == "fail" for v in vals_row):
            aggregate_states.append("fail")
        elif all(v == "ok" for v in vals_row):
            aggregate_states.append("ok")
        else:
            aggregate_states.append("unknown")
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
    # Overall streak
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
    overall_streak_html = render_table(
        [
            {
                "current_result": current_overall or "unknown",
                "current_len": current_overall_len,
                "longest_ok": longest_overall["ok"],
                "longest_fail": longest_overall["fail"],
                "longest_unknown": longest_overall["unknown"],
                "window": len(rows),
            }
        ],
        ["current_result", "current_len", "longest_ok", "longest_fail", "longest_unknown", "window"],
    )
    for r in prev_rows:
        vals_row = []
        for name, field in guard_fields.items():
            val = str(r.get(field, "") or "").lower()
            if val not in ("ok", "fail"):
                val = "unknown"
            prev_counts[name][val] += 1
            vals_row.append(val)
        if vals_row:
            if any(v == "fail" for v in vals_row):
                prev_aggregate_states.append("fail")
            elif all(v == "ok" for v in vals_row):
                prev_aggregate_states.append("ok")
            else:
                prev_aggregate_states.append("unknown")

    guard_rows = []
    has_delta = len(prev_rows) > 0
    for name, counts in guard_counts.items():
        total = sum(counts.values())
        ok_pct = (counts.get("ok", 0) / total * 100) if total else 0.0
        fail_pct = (counts.get("fail", 0) / total * 100) if total else 0.0
        unknown_pct = (counts.get("unknown", 0) / total * 100) if total else 0.0
        guard_rows.append(
            {
                "guard": name,
                "window": window_len,
                "ok": counts.get("ok", 0),
                "fail": counts.get("fail", 0),
                "unknown": counts.get("unknown", 0),
                "total": total,
                "ok_pct": f"{ok_pct:.1f}%",
                "fail_pct": f"{fail_pct:.1f}%",
                "unknown_pct": f"{unknown_pct:.1f}%",
            }
        )
        if has_delta:
            prev_total = sum(prev_counts[name].values()) or 1
            guard_rows[-1].update(
                {
                    "delta_ok": counts.get("ok", 0) - prev_counts[name].get("ok", 0),
                    "delta_fail": counts.get("fail", 0) - prev_counts[name].get("fail", 0),
                    "delta_unknown": counts.get("unknown", 0) - prev_counts[name].get("unknown", 0),
                    "delta_ok_pct": f"{(counts.get('ok',0) - prev_counts[name].get('ok',0))/prev_total*100:.1f}%",
                    "delta_fail_pct": f"{(counts.get('fail',0) - prev_counts[name].get('fail',0))/prev_total*100:.1f}%",
                    "delta_unknown_pct": f"{(counts.get('unknown',0) - prev_counts[name].get('unknown',0))/prev_total*100:.1f}%",
                    "delta_window": len(prev_rows),
                }
            )

    aggregate_counts = Counter(aggregate_states)
    prev_aggregate_counts = Counter(prev_aggregate_states)
    agg_rows = [
        {
            "ok": aggregate_counts.get("ok", 0),
            "fail": aggregate_counts.get("fail", 0),
            "unknown": aggregate_counts.get("unknown", 0),
            "total": sum(aggregate_counts.values()),
            "window": len(aggregate_states),
            "ok_pct": f"{(aggregate_counts.get('ok',0)/(sum(aggregate_counts.values()) or 1)*100):.1f}%",
            "fail_pct": f"{(aggregate_counts.get('fail',0)/(sum(aggregate_counts.values()) or 1)*100):.1f}%",
            "unknown_pct": f"{(aggregate_counts.get('unknown',0)/(sum(aggregate_counts.values()) or 1)*100):.1f}%",
        }
    ]
    if prev_aggregate_states:
        prev_total = sum(prev_aggregate_counts.values()) or 1
        agg_rows[-1].update(
            {
                "delta_ok": aggregate_counts.get("ok", 0) - prev_aggregate_counts.get("ok", 0),
                "delta_fail": aggregate_counts.get("fail", 0) - prev_aggregate_counts.get("fail", 0),
                "delta_unknown": aggregate_counts.get("unknown", 0) - prev_aggregate_counts.get("unknown", 0),
                "delta_ok_pct": f"{(aggregate_counts.get('ok',0) - prev_aggregate_counts.get('ok',0))/prev_total*100:.1f}%",
                "delta_fail_pct": f"{(aggregate_counts.get('fail',0) - prev_aggregate_counts.get('fail',0))/prev_total*100:.1f}%",
                "delta_unknown_pct": f"{(aggregate_counts.get('unknown',0) - prev_aggregate_counts.get('unknown',0))/prev_total*100:.1f}%",
                "delta_window": len(prev_aggregate_states),
            }
        )

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Badge Guard Summary</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 24px; }}
    table {{ border-collapse: collapse; width: 100%; }}
    th, td {{ border: 1px solid #ddd; padding: 6px; text-align: left; }}
    th {{ background: #f4f4f4; }}
  </style>
</head>
<body>
  <h1>Badge Guard Summary</h1>
  <p>Entries: {len(rows)} (window {window_len}, delta window {len(prev_rows) if has_delta else 0})</p>
  {render_table(guard_rows, ["guard","window","ok","fail","unknown","total","ok_pct","fail_pct","unknown_pct"] + (["delta_ok","delta_fail","delta_unknown","delta_ok_pct","delta_fail_pct","delta_unknown_pct","delta_window"] if {has_delta} else []))}
  <h2>Streak globale</h2>
  {overall_streak_html}
  <h2>Guard streaks</h2>
  {render_table([{"guard": name, "current_result": (streak.get("current",{}) or {}).get("result","unknown"), "current_len": (streak.get("current",{}) or {}).get("length",0), "longest_ok": (streak.get("longest",{}) or {}).get("ok",0), "longest_fail": (streak.get("longest",{}) or {}).get("fail",0), "longest_unknown": (streak.get("longest",{}) or {}).get("unknown",0), "window": streak.get("window",0)} for name, streak in guard_streaks.items()], ["guard","current_result","current_len","longest_ok","longest_fail","longest_unknown","window"]) if guard_streaks else "<p>No streaks.</p>"}
  <h2>Streak globale (counts + pct)</h2>
  {render_table(agg_rows, ["ok","fail","unknown","total","window","ok_pct","fail_pct","unknown_pct"] + (["delta_ok","delta_fail","delta_unknown","delta_ok_pct","delta_fail_pct","delta_unknown_pct","delta_window"] if prev_aggregate_states else []))}
</body>
</html>
"""
    Path(args.output).write_text(html)
    print(f"Guard summary HTML written to {args.output}")


if __name__ == "__main__":
    main()
