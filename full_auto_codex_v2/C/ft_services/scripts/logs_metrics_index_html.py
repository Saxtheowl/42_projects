#!/usr/bin/env python3
"""
Generate an HTML index linking to metrics artifacts (csv/json/jsonl/md/html/history/trend/index/bundle/compare).
Usage: logs_metrics_index_html.py --reports reports --suffix status_top2
"""
import argparse
from datetime import datetime, timezone
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="Generate HTML index for metrics artifacts.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix (pattern_topN)")
    parser.add_argument("--compare", help="Path to compare report (optional)")
    args = parser.parse_args()

    reports_dir = Path(args.reports)
    if not reports_dir.exists():
        raise SystemExit(f"Reports directory {reports_dir} not found")

    base = reports_dir / f"log_metrics_snapshot.{args.suffix}"
    files = {
        "CSV": Path(f"{base}.csv"),
        "JSON": Path(f"{base}.json"),
        "JSONL": Path(f"{base}.jsonl"),
        "Markdown": Path(f"{base}.md"),
        "HTML Snapshot": Path(f"{base}.html"),
        "Summary": Path(f"{base}.summary.md"),
        "History": reports_dir / "log_metrics_history.csv",
        "Trend": reports_dir / "log_metrics_trend.md",
        "Trend HTML": reports_dir / "log_metrics_trend.html",
        "Index (md)": reports_dir / "index.md",
        "Bundle": reports_dir / "log_metrics_bundle.tar.gz",
        "Portal": reports_dir / "portal.html",
        "Stats HTML": reports_dir / "log_metrics_stats.html",
        "Anomalies": reports_dir / "log_metrics_anomalies.md",
        "Anomalies HTML": reports_dir / "log_metrics_anomalies.html",
        "Anomalies JSON": reports_dir / "log_metrics_anomalies.json",
        "Manifest JSON": reports_dir / "log_metrics_manifest.json",
        "Summary HTML": Path(f"{base}.summary.html"),
        "Checksums": reports_dir / "log_metrics_checksums.txt",
        "Overview": reports_dir / "log_metrics_overview.md",
        "Overview HTML": reports_dir / "log_metrics_overview.html",
        "Latest JSON": reports_dir / "log_metrics_latest.json",
        "Latest MD": reports_dir / "log_metrics_latest.md",
        "Latest HTML": reports_dir / "log_metrics_latest.html",
        "Badge": reports_dir / "log_metrics_badge.svg",
    }
    compare_path = Path(args.compare) if args.compare else reports_dir / "log_metrics_compare.md"
    if compare_path.exists():
        files["Compare"] = compare_path
        compare_html = reports_dir / "log_metrics_compare.html"
        if compare_html.exists():
            files["Compare HTML"] = compare_html

    missing_base = [k for k, v in files.items() if k in {"CSV", "JSON", "Markdown", "HTML Snapshot"} and not v.exists()]
    if missing_base:
        raise SystemExit(f"Missing required artifacts: {', '.join(missing_base)}")

    generated = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    rows = []
    badge_state = None
    badge_warn = None
    badge_danger = None
    badge_label = None
    badge_history = reports_dir / "log_metrics_badge_history.csv"
    badge_history_md = reports_dir / "log_metrics_badge_history.md"
    badge_history_html = reports_dir / "log_metrics_badge_history.html"
    latest_path = reports_dir / "log_metrics_latest.json"
    guard_summary = {}
    guard_overall = {}
    guard_delta = {}
    guard_delta_overall = {}
    guard_streaks = {}
    if latest_path.exists():
        try:
            import json
            data = json.loads(latest_path.read_text())
            badge_state = data.get("badge_state")
            badge_label = data.get("badge_label")
            thresholds = data.get("badge_thresholds", {})
            badge_warn = thresholds.get("warn")
            badge_danger = thresholds.get("danger")
            guard_summary = data.get("badge_guard_summary") or {}
            guard_overall = data.get("badge_guard_overall") or {}
            guard_delta = data.get("badge_guard_delta") or {}
            guard_delta_overall = data.get("badge_guard_delta_overall") or {}
            guard_streaks = data.get("badge_guard_streaks") or {}
        except Exception:
            badge_state = "n/a"

    for label, path in files.items():
        if path.exists():
            rel = path.relative_to(reports_dir)
            rows.append(f'<li><a href="{rel}">{label}</a></li>')
    if badge_history.exists():
        rel = badge_history.relative_to(reports_dir)
        rows.append(f'<li><a href="{rel}">Badge history (csv)</a></li>')
    if badge_history_md.exists():
        rel = badge_history_md.relative_to(reports_dir)
        rows.append(f'<li><a href="{rel}">Badge history (md)</a></li>')
    if badge_history_html.exists():
        rel = badge_history_html.relative_to(reports_dir)
        rows.append(f'<li><a href="{rel}">Badge history (html)</a></li>')
    guard_summary_md = reports_dir / "log_metrics_guard_summary.md"
    guard_summary_html = reports_dir / "log_metrics_guard_summary.html"
    guard_summary_json = reports_dir / "log_metrics_guard_summary.json"
    guard_summary_csv = reports_dir / "log_metrics_guard_summary.csv"
    if guard_summary_md.exists():
        rel = guard_summary_md.relative_to(reports_dir)
        rows.append(f'<li><a href="{rel}">Guard summary (md)</a></li>')
    if guard_summary_html.exists():
        rel = guard_summary_html.relative_to(reports_dir)
        rows.append(f'<li><a href="{rel}">Guard summary (html)</a></li>')
    if guard_summary_json.exists():
        rel = guard_summary_json.relative_to(reports_dir)
        rows.append(f'<li><a href="{rel}">Guard summary (json)</a></li>')
    if guard_summary_csv.exists():
        rel = guard_summary_csv.relative_to(reports_dir)
        rows.append(f'<li><a href="{rel}">Guard summary (csv)</a></li>')

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Log Metrics Index</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 24px; }}
    h1 {{ margin-bottom: 0; }}
    .meta {{ color: #555; margin-bottom: 16px; }}
    ul {{ line-height: 1.6; }}
  </style>
</head>
<body>
  <h1>Log Metrics Index</h1>
  <div class="meta">Suffix: {args.suffix} | Generated: {generated}</div>
  <ul>
    {"".join(rows)}
  </ul>
  {"<p><strong>Badge:</strong> state=" + str(badge_state) + " (label=" + str(badge_label) + ", warn ≥ " + str(badge_warn) + ", alert ≥ " + str(badge_danger) + ")</p>" if badge_state is not None else ""}
  {"<h2>Badge guards</h2><table><tr><th>guard</th><th>ok</th><th>fail</th><th>unknown</th><th>total</th><th>window</th><th>ok%</th><th>fail%</th><th>unknown%</th></tr>" + "".join(f"<tr><td>{g}</td><td>{v.get('ok',0)}</td><td>{v.get('fail',0)}</td><td>{v.get('unknown',0)}</td><td>{v.get('total',0)}</td><td>{v.get('window','?')}</td><td>{v.get('ok_pct','0')}%</td><td>{v.get('fail_pct','0')}%</td><td>{v.get('unknown_pct','0')}%</td></tr>" for g, v in guard_summary.items()) + "</table>" if guard_summary else ""} 
  {("<h3>Badge guards (overall)</h3><table><tr><th>window</th><th>ok</th><th>ok%</th><th>fail</th><th>fail%</th><th>unknown</th><th>unknown%</th><th>total</th></tr>" + f"<tr><td>{guard_overall.get('window','?')}</td><td>{guard_overall.get('ok','?')}</td><td>{guard_overall.get('ok_pct','0')}%</td><td>{guard_overall.get('fail','?')}</td><td>{guard_overall.get('fail_pct','0')}%</td><td>{guard_overall.get('unknown','?')}</td><td>{guard_overall.get('unknown_pct','0')}%</td><td>{guard_overall.get('total','?')}</td></tr></table>") if guard_overall else ""} 
  {("<h3>Badge guards streaks</h3><table><tr><th>guard</th><th>current_result</th><th>current_len</th><th>longest_ok</th><th>longest_fail</th><th>longest_unknown</th><th>window</th></tr>" + "".join(f"<tr><td>{g}</td><td>{(v.get('current',{}) or {}).get('result','?')}</td><td>{(v.get('current',{}) or {}).get('length','?')}</td><td>{(v.get('longest',{}) or {}).get('ok',0)}</td><td>{(v.get('longest',{}) or {}).get('fail',0)}</td><td>{(v.get('longest',{}) or {}).get('unknown',0)}</td><td>{v.get('window','?')}</td></tr>" for g, v in guard_streaks.items()) + "</table>") if guard_streaks else ""} 
  {("<h3>Badge guards delta (vs fenêtre précédente)</h3><table><tr><th>guard</th><th>Δok</th><th>Δok%</th><th>Δfail</th><th>Δfail%</th><th>Δunknown</th><th>Δunknown%</th><th>window</th><th>delta_window</th></tr>" + "".join(f"<tr><td>{g}</td><td>{v.get('ok',0):+d}</td><td>{v.get('ok_pct','0')}%</td><td>{v.get('fail',0):+d}</td><td>{v.get('fail_pct','0')}%</td><td>{v.get('unknown',0):+d}</td><td>{v.get('unknown_pct','0')}%</td><td>{v.get('window','?')}</td><td>{v.get('delta_window','?')}</td></tr>" for g, v in guard_delta.items()) + "</table>") if guard_delta else ""} 
  {("<h3>Badge guards delta (overall)</h3><table><tr><th>window</th><th>delta_window</th><th>Δok</th><th>Δok%</th><th>Δfail</th><th>Δfail%</th><th>Δunknown</th><th>Δunknown%</th><th>Δtotal</th></tr>" + f"<tr><td>{guard_delta_overall.get('window','?')}</td><td>{guard_delta_overall.get('delta_window','?')}</td><td>{guard_delta_overall.get('ok','?')}</td><td>{guard_delta_overall.get('ok_pct','0')}%</td><td>{guard_delta_overall.get('fail','?')}</td><td>{guard_delta_overall.get('fail_pct','0')}%</td><td>{guard_delta_overall.get('unknown','?')}</td><td>{guard_delta_overall.get('unknown_pct','0')}%</td><td>{guard_delta_overall.get('total','?')}</td></tr></table>") if guard_delta_overall else ""} 
</body>
</html>
"""
    out = reports_dir / "index.html"
    out.write_text(html)
    print(f"HTML index written to {out}")


if __name__ == "__main__":
    main()
