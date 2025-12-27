#!/usr/bin/env python3
"""
Render an HTML summary for the latest metrics run (Totals + anomalies + key links).
Usage: logs_metrics_latest_html.py --reports reports --suffix status_top2 --output reports/log_metrics_latest.html
"""
import argparse
import csv
import json
from pathlib import Path
from typing import Dict, List, Any


def load_totals(csv_path: Path) -> Dict[str, Any]:
    with csv_path.open(newline="") as f:
        rows = list(csv.DictReader(f))
    if not rows:
        raise SystemExit(f"{csv_path}: empty CSV")
    totals = rows[-1]
    if totals.get("log_file") != "Totals":
        raise SystemExit(f"{csv_path}: missing Totals row")
    return totals


def load_anomalies(anomalies_json: Path) -> List[Dict[str, Any]]:
    if not anomalies_json.exists():
        return []
    data = json.loads(anomalies_json.read_text())
    if not isinstance(data, list):
        return []
    return data


def render_table(rows, headers):
    head = "<tr>" + "".join(f"<th>{h}</th>" for h in headers) + "</tr>"
    body = "\n".join("<tr>" + "".join(f"<td>{val}</td>" for val in row) + "</tr>" for row in rows)
    return f"<table>\n{head}\n{body}\n</table>"


def main():
    parser = argparse.ArgumentParser(description="Render latest metrics summary as HTML.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix")
    parser.add_argument("--output", default=None, help="Output HTML path (default reports/log_metrics_latest.html)")
    parser.add_argument("--badge-warn", type=float, default=50.0, help="Warn threshold for overloaded_ratio")
    parser.add_argument("--badge-danger", type=float, default=80.0, help="Danger threshold for overloaded_ratio")
    parser.add_argument("--badge-label", default="metrics", help="Badge label to display")
    args = parser.parse_args()

    reports = Path(args.reports)
    base = reports / f"log_metrics_snapshot.{args.suffix}"
    csv_path = Path(f"{base}.csv")
    anomalies_json = reports / "log_metrics_anomalies.json"
    output = Path(args.output) if args.output else reports / "log_metrics_latest.html"
    latest_json_path = reports / "log_metrics_latest.json"

    totals = load_totals(csv_path)
    anomalies = load_anomalies(anomalies_json)
    history_rows = []
    history_path = reports / "log_metrics_history.csv"
    if history_path.exists():
        with history_path.open(newline="") as f:
            history_rows = list(csv.DictReader(f))

    links = []
    def add_link(label, path: Path):
        if path.exists():
            links.append((label, path.relative_to(reports)))

    add_link("CSV", csv_path)
    add_link("JSON", Path(f"{base}.json"))
    add_link("JSONL", Path(f"{base}.jsonl"))
    add_link("Markdown", Path(f"{base}.md"))
    add_link("HTML", Path(f"{base}.html"))
    add_link("Summary (md)", Path(f"{base}.summary.md"))
    add_link("Summary (html)", Path(f"{base}.summary.html"))
    add_link("History", reports / "log_metrics_history.csv")
    add_link("Trend (md)", reports / "log_metrics_trend.md")
    add_link("Trend (html)", reports / "log_metrics_trend.html")
    add_link("Stats (md)", reports / "log_metrics_stats.md")
    add_link("Stats (html)", reports / "log_metrics_stats.html")
    add_link("Anomalies (md)", reports / "log_metrics_anomalies.md")
    add_link("Anomalies (html)", reports / "log_metrics_anomalies.html")
    add_link("Anomalies (json)", reports / "log_metrics_anomalies.json")
    add_link("Overview (md)", reports / "log_metrics_overview.md")
    add_link("Overview (html)", reports / "log_metrics_overview.html")
    add_link("Portal", reports / "portal.html")
    add_link("Manifest", reports / "log_metrics_manifest.json")
    add_link("Bundle", reports / "log_metrics_bundle.tar.gz")
    add_link("Checksums", reports / "log_metrics_checksums.txt")
    add_link("Badge (svg)", reports / "log_metrics_badge.svg")
    add_link("Guard summary (md)", reports / "log_metrics_guard_summary.md")
    add_link("Guard summary (html)", reports / "log_metrics_guard_summary.html")
    add_link("Guard summary (json)", reports / "log_metrics_guard_summary.json")
    add_link("Guard summary (csv)", reports / "log_metrics_guard_summary.csv")

    anomalies_rows = []
    deltas_rows = []
    if len(history_rows) >= 2:
        prev, curr = history_rows[-2], history_rows[-1]
        for key in ["status_checks", "connections", "overloaded", "overloaded_ratio"]:
            try:
                delta = float(curr.get(key, 0) or 0) - float(prev.get(key, 0) or 0)
            except Exception:
                delta = 0.0
            deltas_rows.append((key, f"{delta:+.2f}"))
    for a in anomalies:
        anomalies_rows.append(
            (
                a.get("metric", ""),
                a.get("status", ""),
                a.get("prev_value", ""),
                a.get("curr_value", ""),
                a.get("delta_pct", ""),
            )
        )

    latest_data = {}
    if latest_json_path.exists():
        try:
            latest_data = json.loads(latest_json_path.read_text())
        except Exception:
            latest_data = {}

    overloaded_ratio = float(totals.get("overloaded_ratio", 0) or 0)
    badge_state = str(latest_data.get("badge_state", "") or "").lower()
    if not badge_state:
        badge_state = "ok"
        if len(anomalies) > 0 or overloaded_ratio >= args.badge_danger:
            badge_state = "alert"
        elif overloaded_ratio >= args.badge_warn:
            badge_state = "warn"
    badge_history = latest_data.get("badge_history") or {}
    badge_counts = badge_history.get("counts") or {}
    badge_window = badge_history.get("window")
    badge_current_streak = badge_history.get("current_streak") or {}
    badge_prev_state = latest_data.get("badge_previous_state") or badge_history.get("previous_state")
    badge_ok_streak_required = latest_data.get("badge_ok_streak_required")
    badge_guards = latest_data.get("badge_guards") or {}
    badge_gate = badge_guards.get("gate")
    badge_no_regression = badge_guards.get("no_regression")
    badge_guard_status = latest_data.get("badge_guard_status") or {}
    badge_guard_summary = latest_data.get("badge_guard_summary") or {}
    badge_guard_rows = [
        {
            "guard": k,
            "ok": v.get("ok", 0),
            "fail": v.get("fail", 0),
            "unknown": v.get("unknown", 0),
            "total": v.get("total", 0),
            "window": v.get("window", "n/a"),
            "ok_pct": f"{v.get('ok_pct','0')}%",
            "fail_pct": f"{v.get('fail_pct','0')}%",
            "unknown_pct": f"{v.get('unknown_pct','0')}%",
        }
        for k, v in badge_guard_summary.items()
    ]

    totals_rows = [(k, totals.get(k, "")) for k in ["status_checks", "connections", "overloaded", "overloaded_ratio"]]
    anomalies_section = render_table(anomalies_rows, ["metric", "status", "prev", "curr", "delta_pct"]) if anomalies_rows else "<p>Aucune anomalie détectée.</p>"
    links_section = render_table([(label, f"<a href='{rel}'>{rel}</a>") for label, rel in links], ["label", "path"])

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Latest Metrics Summary</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 24px; }}
    h1, h2 {{ margin-bottom: 8px; }}
    table {{ border-collapse: collapse; width: 100%; margin-bottom: 16px; }}
    th, td {{ border: 1px solid #ddd; padding: 6px; text-align: left; }}
    th {{ background: #f4f4f4; }}
  </style>
</head>
<body>
  <h1>Latest Metrics Summary ({args.suffix})</h1>
  <h2>Totals</h2>
  {render_table(totals_rows, ["metric", "value"])}
  <h2>Deltas vs précédent</h2>
  {render_table(deltas_rows, ["metric", "delta"]) if deltas_rows else "<p>Pas de deltas (historique insuffisant).</p>"}
  <h2>Anomalies</h2>
  {anomalies_section}
  <h2>Badge</h2>
  <p>Label: <strong>{args.badge_label}</strong> — State: <strong>{badge_state}</strong> — Prev: <strong>{badge_prev_state or 'n/a'}</strong> — thresholds: warn ≥ {args.badge_warn}, alert ≥ {args.badge_danger}</p>
  <p>History window: {badge_window or 'n/a'} (delta window {badge_history.get('delta_window', 0)}) | Counts: {badge_counts or {}} | Current streak: {badge_current_streak.get('length','?')} × {badge_current_streak.get('state','?')} {"| OK streak required: " + str(badge_ok_streak_required) if badge_ok_streak_required else ""} {"| Gate: " + str(badge_gate) if badge_gate else ""} {"| No regression guard" if badge_no_regression else ""}</p>
  <ul>
    {''.join(f"<li>{name}: {status.get('result','n/a')} ({status.get('reason','')})</li>" for name, status in badge_guard_status.items()) if badge_guard_status else "<li>No guard status</li>"}
  </ul>
  {render_table(badge_guard_rows, ['guard','ok','fail','unknown','total','window','ok_pct','fail_pct','unknown_pct']) if badge_guard_rows else "<p>No guard summary.</p>"}
  {render_table([{'window': latest_data.get('badge_guard_overall',{}).get('window','n/a'), 'ok': latest_data.get('badge_guard_overall',{}).get('ok','n/a'), 'ok_pct': f"{latest_data.get('badge_guard_overall',{}).get('ok_pct','0')}%", 'fail': latest_data.get('badge_guard_overall',{}).get('fail','n/a'), 'fail_pct': f"{latest_data.get('badge_guard_overall',{}).get('fail_pct','0')}%", 'unknown': latest_data.get('badge_guard_overall',{}).get('unknown','n/a'), 'unknown_pct': f"{latest_data.get('badge_guard_overall',{}).get('unknown_pct','0')}%", 'total': latest_data.get('badge_guard_overall',{}).get('total','n/a')}], ['window','ok','ok_pct','fail','fail_pct','unknown','unknown_pct','total']) if latest_data.get('badge_guard_overall') else ""} 
  {render_table([{'current_result': (latest_data.get('badge_guard_overall_streak',{}) or {}).get('current',{}).get('result','?'), 'current_len': (latest_data.get('badge_guard_overall_streak',{}) or {}).get('current',{}).get('length','?'), 'longest_ok': (latest_data.get('badge_guard_overall_streak',{}) or {}).get('longest',{}).get('ok',0), 'longest_fail': (latest_data.get('badge_guard_overall_streak',{}) or {}).get('longest',{}).get('fail',0), 'longest_unknown': (latest_data.get('badge_guard_overall_streak',{}) or {}).get('longest',{}).get('unknown',0), 'window': (latest_data.get('badge_guard_overall_streak',{}) or {}).get('window','?')}], ['current_result','current_len','longest_ok','longest_fail','longest_unknown','window']) if latest_data.get('badge_guard_overall_streak') else ""} 
  {render_table([{'guard': name, 'current_result': (streak.get('current',{}) or {}).get('result','?'), 'current_len': (streak.get('current',{}) or {}).get('length','?'), 'longest_ok': (streak.get('longest',{}) or {}).get('ok',0), 'longest_fail': (streak.get('longest',{}) or {}).get('fail',0), 'longest_unknown': (streak.get('longest',{}) or {}).get('unknown',0), 'window': streak.get('window','?')} for name, streak in (latest_data.get('badge_guard_streaks') or {}).items()], ['guard','current_result','current_len','longest_ok','longest_fail','longest_unknown','window']) if latest_data.get('badge_guard_streaks') else ""} 
  {render_table([{'guard': name, 'delta_ok': delta.get('ok',0), 'delta_ok_pct': delta.get('ok_pct','0'), 'delta_fail': delta.get('fail',0), 'delta_fail_pct': delta.get('fail_pct','0'), 'delta_unknown': delta.get('unknown',0), 'delta_unknown_pct': delta.get('unknown_pct','0'), 'window': delta.get('window','?'), 'delta_window': delta.get('delta_window','?')} for name, delta in (latest_data.get('badge_guard_delta') or {}).items()], ['guard','delta_ok','delta_ok_pct','delta_fail','delta_fail_pct','delta_unknown','delta_unknown_pct','window','delta_window']) if latest_data.get('badge_guard_delta') else ""} 
  {render_table([{'window': latest_data.get('badge_guard_delta_overall',{}).get('window','n/a'), 'delta_window': latest_data.get('badge_guard_delta_overall',{}).get('delta_window','n/a'), 'ok': latest_data.get('badge_guard_delta_overall',{}).get('ok','n/a'), 'ok_pct': f"{latest_data.get('badge_guard_delta_overall',{}).get('ok_pct','0')}%", 'fail': latest_data.get('badge_guard_delta_overall',{}).get('fail','n/a'), 'fail_pct': f"{latest_data.get('badge_guard_delta_overall',{}).get('fail_pct','0')}%", 'unknown': latest_data.get('badge_guard_delta_overall',{}).get('unknown','n/a'), 'unknown_pct': f"{latest_data.get('badge_guard_delta_overall',{}).get('unknown_pct','0')}%", 'total': latest_data.get('badge_guard_delta_overall',{}).get('total','n/a')}], ['window','delta_window','ok','ok_pct','fail','fail_pct','unknown','unknown_pct','total']) if latest_data.get('badge_guard_delta_overall') else ""} 
  {f"<img src='log_metrics_badge.svg' alt='Metrics badge' style='max-width:240px;'/>" if (reports / 'log_metrics_badge.svg').exists() else "<p>Badge non généré.</p>"}
  <h2>Liens artefacts</h2>
  {links_section}
</body>
</html>
"""
    output.write_text(html)
    print(f"Latest HTML written to {output}")


if __name__ == "__main__":
    main()
