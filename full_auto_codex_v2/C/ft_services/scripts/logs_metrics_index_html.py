#!/usr/bin/env python3
"""
Generate an HTML index linking to metrics artifacts (csv/json/jsonl/md/html/history/trend/index/bundle/compare).
Usage: logs_metrics_index_html.py --reports reports --suffix status_top2
"""
import argparse
import json
from datetime import datetime, timezone
from pathlib import Path


def load_json(path: Path):
    try:
        return json.loads(path.read_text())
    except Exception:
        return {}


def render_status(label: str, value: str):
    value_lower = (value or "").lower()
    cls = "status-badge neutral"
    if value_lower in ("ok", "success"):
        cls = "status-badge ok"
    elif value_lower in ("fail", "error", "missing"):
        cls = "status-badge fail"
    return f"<span class='{cls}'>{label}: {value}</span>"


def main():
    parser = argparse.ArgumentParser(description="Generate HTML index for metrics artifacts.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix (pattern_topN)")
    parser.add_argument("--compare", help="Path to compare report (optional)")
    parser.add_argument("--output", default=None, help="Output HTML path (default: reports/index.html)")
    args = parser.parse_args()

    reports_dir = Path(args.reports)
    if not reports_dir.exists():
        raise SystemExit(f"Reports directory {reports_dir} not found")
    output_path = Path(args.output) if args.output else reports_dir / "index.html"

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
        "Sitemap": reports_dir / "log_metrics_sitemap.md",
        "Sitemap HTML": reports_dir / "log_metrics_sitemap.html",
        "Summary HTML": Path(f"{base}.summary.html"),
        "Checksums": reports_dir / "log_metrics_checksums.txt",
        "Overview": reports_dir / "log_metrics_overview.md",
        "Overview HTML": reports_dir / "log_metrics_overview.html",
        "Latest JSON": reports_dir / "log_metrics_latest.json",
        "Latest MD": reports_dir / "log_metrics_latest.md",
        "Latest HTML": reports_dir / "log_metrics_latest.html",
        "Badge": reports_dir / "log_metrics_badge.svg",
        "Status JSON": reports_dir / "log_metrics_status.json",
        "Status badge": reports_dir / "log_metrics_status_badge.svg",
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

    run_summary = load_json(reports_dir / "log_metrics_run_summary.json")
    latest = load_json(reports_dir / "log_metrics_latest.json")
    status_data = load_json(reports_dir / "log_metrics_status.json")
    manifest_data = status_data.get("manifest") or {}
    optional_ignored = manifest_data.get("optional_skipped") or []
    manifest_summary_html = ""
    manifest_status = manifest_data.get("status", "n/a")
    if manifest_data:
        total = manifest_data.get("total", "n/a")
        present = manifest_data.get("present", "n/a")
        missing = manifest_data.get("missing_count", "n/a")
        size_total = manifest_data.get("size_bytes", "n/a")
        optional_ignored = manifest_data.get("optional_skipped") or []
        optional_total = manifest_data.get("optional_total", 0)
        optional_present = manifest_data.get("optional_present", 0)
        optional_missing = manifest_data.get("optional_missing_count", len(optional_ignored))
        manifest_summary_html = (
            "<div class='meta'>"
            f"Manifest: total={total}, present={present}, missing={missing}, size={size_total} bytes, "
            f"optional={optional_present}/{optional_total} (ignored={optional_missing})"
        )
        if optional_ignored:
            manifest_summary_html += f", optional ignored: {', '.join(optional_ignored)}"
        manifest_summary_html += "</div>"
    else:
        manifest_fallback = load_json(reports_dir / "log_metrics_manifest.json")
        paths = manifest_fallback.get("paths") or {}
        if paths:
            total = len(paths)
            present = sum(1 for info in paths.values() if info.get("exists"))
            size_total = sum(info.get("size") or 0 for info in paths.values() if info.get("exists"))
            missing = total - present
            manifest_status = "ok" if missing == 0 else "missing"
            manifest_summary_html = f"<div class='meta'>Manifest: total={total}, present={present}, missing={missing}, size={size_total} bytes</div>"
    status_bar = []
    status_bar.append(render_status("Badge", latest.get("badge_state", "n/a")))
    status_bar.append(render_status("Guard", run_summary.get("guard_check", "n/a")))
    status_bar.append(render_status("Checksums", run_summary.get("checksums", "n/a")))
    validation_state = run_summary.get("validation", {}) or {}
    validation_text = validation_state.get("status", "n/a")
    if validation_state.get("mode"):
        validation_text = f"{validation_text} ({validation_state.get('mode')})"
    status_bar.append(render_status("Validation", validation_text))
    compare_state = (run_summary.get("compare") or {}).get("status", "n/a")
    status_bar.append(render_status("Compare", compare_state))
    sitemap_state = (run_summary.get("sitemap") or {}).get("status", "skipped")
    status_bar.append(render_status("Sitemap", sitemap_state))
    status_bar.append(render_status("Manifest", manifest_status))
    overall_state = status_data.get("overall_state", "n/a")
    status_bar.append(render_status("Overall", overall_state))
    status_badge_embed = ""
    status_badge_path = reports_dir / "log_metrics_status_badge.svg"
    if status_badge_path.exists():
        status_badge_rel = status_badge_path.relative_to(reports_dir)
        status_badge_embed = f"<div class='meta'><img src='{status_badge_rel}' alt='Status badge' style='max-width:320px;'></div>"
    totals = latest.get("totals") or {}
    quick_stats = []
    if totals:
        quick_stats.append(f"<li><strong>Overloaded ratio:</strong> {totals.get('overloaded_ratio','n/a')}%</li>")
        quick_stats.append(f"<li><strong>Status checks:</strong> {totals.get('status_checks','n/a')}</li>")
        quick_stats.append(f"<li><strong>Connections:</strong> {totals.get('connections','n/a')}</li>")
        quick_stats.append(f"<li><strong>Overloaded:</strong> {totals.get('overloaded','n/a')}</li>")
    if latest.get("anomalies_count") is not None:
        quick_stats.append(f"<li><strong>Anomalies:</strong> {latest.get('anomalies_count')}</li>")
        if latest.get("anomaly_threshold") is not None:
            quick_stats.append(f"<li><strong>Anomaly threshold:</strong> {latest.get('anomaly_threshold')}</li>")
    sitemap_summary = load_json(reports_dir / "log_metrics_sitemap.json").get("summary", {}) if (reports_dir / "log_metrics_sitemap.json").exists() else {}
    sitemap_meta = ""
    if sitemap_summary:
        opt = sitemap_summary.get("optional_artifacts") or []
        sitemap_meta = (
            f"<div class='meta'>Sitemap: required={sitemap_summary.get('artifacts','n/a')}, present={sitemap_summary.get('present','n/a')}, missing={sitemap_summary.get('missing','n/a')}"
        )
        if opt:
            sitemap_meta += f", optional: {', '.join(opt)}"
        sitemap_meta += "</div>"

    status_snapshot = []
    status_snapshot.append(f"<li>Badge: {status_data.get('badge_state','n/a')}</li>")
    status_snapshot.append(f"<li>Guard: {(run_summary.get('guard_check','n/a'))}</li>")
    status_snapshot.append(f"<li>Checksums: {run_summary.get('checksums','n/a')}</li>")
    validation_state = run_summary.get("validation") or {}
    val_text = validation_state.get("status", "n/a")
    if validation_state.get("mode"):
        val_text = f"{val_text} ({validation_state.get('mode')})"
    status_snapshot.append(f"<li>Validation: {val_text}</li>")
    status_snapshot.append(f"<li>Compare: {(run_summary.get('compare') or {}).get('status','n/a')}</li>")
    status_snapshot.append(f"<li>Sitemap: {sitemap_state}</li>")
    manifest_detail = f"{manifest_status} (missing={manifest_data.get('missing_count','n/a')})"
    if optional_ignored:
        manifest_detail += f", optional_ignored={len(optional_ignored)}"
    status_snapshot.append(f"<li>Manifest: {manifest_detail}</li>")
    status_snapshot.append(f"<li>Overall: {overall_state}</li>")

    rows = []
    badge_state = None
    badge_warn = None
    badge_danger = None
    badge_label = None
    badge_history = reports_dir / "log_metrics_badge_history.csv"
    badge_history_md = reports_dir / "log_metrics_badge_history.md"
    badge_history_html = reports_dir / "log_metrics_badge_history.html"
    overall_history = reports_dir / "log_metrics_overall_history.csv"
    latest_path = reports_dir / "log_metrics_latest.json"
    guard_summary = {}
    guard_overall = {}
    guard_delta = {}
    guard_delta_overall = {}
    guard_streaks = {}
    guard_overall_streak = {}
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
            guard_overall_streak = data.get("badge_guard_overall_streak") or {}
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
    overall_history_rows = []
    if overall_history.exists():
        try:
            import csv
            with overall_history.open(newline="") as f:
                overall_history_rows = list(csv.DictReader(f))[-10:]
        except Exception:
            overall_history_rows = []
    guard_summary_md = reports_dir / "log_metrics_guard_summary.md"
    guard_summary_html = reports_dir / "log_metrics_guard_summary.html"
    guard_summary_json = reports_dir / "log_metrics_guard_summary.json"
    guard_summary_csv = reports_dir / "log_metrics_guard_summary.csv"
    guard_summary_json_data = {}
    guard_overall_json = {}
    guard_overall_streak_json = {}
    sitemap_json = reports_dir / "log_metrics_sitemap.json"
    sitemap_summary_html = ""
    if sitemap_json.exists():
        try:
            sitemap_data = json.loads(sitemap_json.read_text())
            summary = sitemap_data.get("summary") or {}
            sitemap_summary_html = (
                "<h2>Sitemap summary</h2>"
                f"<ul><li>Artifacts: {summary.get('artifacts','n/a')}</li>"
                f"<li>Present: {summary.get('present','n/a')}</li>"
                f"<li>Missing: {summary.get('missing','n/a')}</li>"
                f"<li>Total size (bytes): {summary.get('total_size_bytes','n/a')}</li>"
                f"{''.join(f'<li>Optional (ignored): {opt}</li>' for opt in summary.get('optional_artifacts') or [])}"
                f"{''.join(f'<li>Missing path: {mp}</li>' for mp in summary.get('missing_paths') or [])}"
                "</ul>"
            )
        except Exception:
            sitemap_summary_html = "<p>Sitemap summary unavailable (invalid JSON).</p>"
    if guard_summary_json.exists():
        try:
            guard_summary_json_data = json.loads(guard_summary_json.read_text())
            guard_overall_json = guard_summary_json_data.get("overall") or {}
            guard_overall_streak_json = guard_summary_json_data.get("overall_streak") or {}
        except Exception:
            guard_summary_json_data = {}
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
    .status-bar {{ display: flex; flex-wrap: wrap; gap: 8px; margin: 10px 0 16px; }}
    .status-badge {{ border-radius: 12px; padding: 6px 10px; font-size: 0.9em; border: 1px solid #ccc; background: #f6f6f6; }}
    .status-badge.ok {{ border-color: #8cc152; background: #e5f5d9; color: #3a7b1c; }}
    .status-badge.fail {{ border-color: #da4453; background: #fbe3e6; color: #a51629; }}
    ul {{ line-height: 1.6; }}
  </style>
</head>
<body>
  <h1>Log Metrics Index</h1>
  <div class="meta">Suffix: {args.suffix} | Generated: {generated}</div>
  {manifest_summary_html}
  <div class="status-bar">
    {"".join(status_bar)}
  </div>
  {status_badge_embed}
  <h2>Status snapshot</h2>
  <ul>
    {"".join(status_snapshot)}
  </ul>
  {"<div class='meta'>Manifest optional ignored: " + ", ".join(optional_ignored) + "</div>" if optional_ignored else ""}
  {"<h2>Quick stats</h2><ul>" + "".join(quick_stats) + "</ul>" if quick_stats else ""}
  {sitemap_meta}
  {"<div class='meta'>Manifest optional ignored: " + ", ".join(optional_ignored) + "</div>" if optional_ignored else ""}
  <h2>Key links</h2>
  <ul>
    {"<li><a href='log_metrics_run_summary.json'>Run summary (json)</a></li>" if (reports_dir / "log_metrics_run_summary.json").exists() else ""}
    {"<li><a href='log_metrics_run_summary.md'>Run summary (md)</a></li>" if (reports_dir / "log_metrics_run_summary.md").exists() else ""}
    {"<li><a href='log_metrics_run_summary.html'>Run summary (html)</a></li>" if (reports_dir / "log_metrics_run_summary.html").exists() else ""}
    {"<li><a href='log_metrics_status.json'>Status (json)</a></li>" if (reports_dir / "log_metrics_status.json").exists() else ""}
    {"<li><a href='log_metrics_overall_history.csv'>Overall history (csv)</a></li>" if overall_history.exists() else ""}
    {"<li><a href='portal.html'>Portal</a></li>" if (reports_dir / "portal.html").exists() else ""}
    {"<li><a href='log_metrics_bundle.tar.gz'>Bundle</a></li>" if (reports_dir / "log_metrics_bundle.tar.gz").exists() else ""}
    {"<li><a href='log_metrics_manifest.json'>Manifest</a></li>" if (reports_dir / "log_metrics_manifest.json").exists() else ""}
  </ul>
  <ul>
    {"".join(rows)}
  </ul>
  {sitemap_summary_html}
  {("<h2>Overall history (last 10)</h2><table><tr><th>run_timestamp</th><th>overall</th><th>badge</th><th>anomalies</th><th>overloaded_ratio</th><th>sitemap</th><th>manifest</th></tr>" + "".join(f"<tr><td>{r.get('run_timestamp')}</td><td>{r.get('overall_state')}</td><td>{r.get('badge_state')}</td><td>{r.get('anomalies_count')}</td><td>{r.get('overloaded_ratio')}</td><td>{r.get('sitemap_status')}</td><td>{r.get('manifest_status')}</td></tr>" for r in overall_history_rows) + "</table>") if overall_history_rows else ""}
  {"<p><strong>Badge:</strong> state=" + str(badge_state) + " (label=" + str(badge_label) + ", warn ≥ " + str(badge_warn) + ", alert ≥ " + str(badge_danger) + ")</p>" if badge_state is not None else ""}
  {"<h2>Badge guards</h2><table><tr><th>guard</th><th>ok</th><th>fail</th><th>unknown</th><th>total</th><th>window</th><th>ok%</th><th>fail%</th><th>unknown%</th></tr>" + "".join(f"<tr><td>{g}</td><td>{v.get('ok',0)}</td><td>{v.get('fail',0)}</td><td>{v.get('unknown',0)}</td><td>{v.get('total',0)}</td><td>{v.get('window','?')}</td><td>{v.get('ok_pct','0')}%</td><td>{v.get('fail_pct','0')}%</td><td>{v.get('unknown_pct','0')}%</td></tr>" for g, v in guard_summary.items()) + "</table>" if guard_summary else ""} 
  {("<h3>Badge guards (overall)</h3><table><tr><th>window</th><th>ok</th><th>ok%</th><th>fail</th><th>fail%</th><th>unknown</th><th>unknown%</th><th>total</th></tr>" + f"<tr><td>{guard_overall.get('window','?')}</td><td>{guard_overall.get('ok','?')}</td><td>{guard_overall.get('ok_pct','0')}%</td><td>{guard_overall.get('fail','?')}</td><td>{guard_overall.get('fail_pct','0')}%</td><td>{guard_overall.get('unknown','?')}</td><td>{guard_overall.get('unknown_pct','0')}%</td><td>{guard_overall.get('total','?')}</td></tr></table>") if guard_overall else ""} 
  {("<h3>Badge guards (streak globale)</h3><table><tr><th>current_result</th><th>current_len</th><th>longest_ok</th><th>longest_fail</th><th>longest_unknown</th><th>window</th></tr>" + f"<tr><td>{(guard_overall_streak.get('current',{}) or {}).get('result','?')}</td><td>{(guard_overall_streak.get('current',{}) or {}).get('length','?')}</td><td>{(guard_overall_streak.get('longest',{}) or {}).get('ok',0)}</td><td>{(guard_overall_streak.get('longest',{}) or {}).get('fail',0)}</td><td>{(guard_overall_streak.get('longest',{}) or {}).get('unknown',0)}</td><td>{guard_overall_streak.get('window','?')}</td></tr></table>") if guard_overall_streak else ""} 
  {("<h3>Guard summary (overall, guard_summary.json)</h3><table><tr><th>ok</th><th>fail</th><th>unknown</th><th>total</th><th>window</th><th>ok%</th><th>fail%</th><th>unknown%</th><th>Δok</th><th>Δok%</th><th>Δfail</th><th>Δfail%</th><th>Δunknown</th><th>Δunknown%</th><th>Δwindow</th></tr>" + f"<tr><td>{guard_overall_json.get('ok','?')}</td><td>{guard_overall_json.get('fail','?')}</td><td>{guard_overall_json.get('unknown','?')}</td><td>{guard_overall_json.get('total','?')}</td><td>{guard_overall_json.get('window','?')}</td><td>{guard_overall_json.get('ok_pct','0')}%</td><td>{guard_overall_json.get('fail_pct','0')}%</td><td>{guard_overall_json.get('unknown_pct','0')}%</td><td>{(guard_overall_json.get('delta') or {}).get('ok','?')}</td><td>{(guard_overall_json.get('delta') or {}).get('ok_pct','0')}%</td><td>{(guard_overall_json.get('delta') or {}).get('fail','?')}</td><td>{(guard_overall_json.get('delta') or {}).get('fail_pct','0')}%</td><td>{(guard_overall_json.get('delta') or {}).get('unknown','?')}</td><td>{(guard_overall_json.get('delta') or {}).get('unknown_pct','0')}%</td><td>{(guard_overall_json.get('delta') or {}).get('delta_window','?')}</td></tr></table>") if guard_overall_json else ""} 
  {("<h3>Guard summary (overall streak, guard_summary.json)</h3><table><tr><th>current_result</th><th>current_len</th><th>longest_ok</th><th>longest_fail</th><th>longest_unknown</th><th>window</th></tr>" + f"<tr><td>{(guard_overall_streak_json.get('current',{}) or {}).get('result','?')}</td><td>{(guard_overall_streak_json.get('current',{}) or {}).get('length','?')}</td><td>{(guard_overall_streak_json.get('longest',{}) or {}).get('ok',0)}</td><td>{(guard_overall_streak_json.get('longest',{}) or {}).get('fail',0)}</td><td>{(guard_overall_streak_json.get('longest',{}) or {}).get('unknown',0)}</td><td>{guard_overall_streak_json.get('window','?')}</td></tr></table>") if guard_overall_streak_json else ""} 
  {("<h3>Badge guards streaks</h3><table><tr><th>guard</th><th>current_result</th><th>current_len</th><th>longest_ok</th><th>longest_fail</th><th>longest_unknown</th><th>window</th></tr>" + "".join(f"<tr><td>{g}</td><td>{(v.get('current',{}) or {}).get('result','?')}</td><td>{(v.get('current',{}) or {}).get('length','?')}</td><td>{(v.get('longest',{}) or {}).get('ok',0)}</td><td>{(v.get('longest',{}) or {}).get('fail',0)}</td><td>{(v.get('longest',{}) or {}).get('unknown',0)}</td><td>{v.get('window','?')}</td></tr>" for g, v in guard_streaks.items()) + "</table>") if guard_streaks else ""} 
  {("<h3>Badge guards delta (vs fenêtre précédente)</h3><table><tr><th>guard</th><th>Δok</th><th>Δok%</th><th>Δfail</th><th>Δfail%</th><th>Δunknown</th><th>Δunknown%</th><th>window</th><th>delta_window</th></tr>" + "".join(f"<tr><td>{g}</td><td>{v.get('ok',0):+d}</td><td>{v.get('ok_pct','0')}%</td><td>{v.get('fail',0):+d}</td><td>{v.get('fail_pct','0')}%</td><td>{v.get('unknown',0):+d}</td><td>{v.get('unknown_pct','0')}%</td><td>{v.get('window','?')}</td><td>{v.get('delta_window','?')}</td></tr>" for g, v in guard_delta.items()) + "</table>") if guard_delta else ""} 
  {("<h3>Badge guards delta (overall)</h3><table><tr><th>window</th><th>delta_window</th><th>Δok</th><th>Δok%</th><th>Δfail</th><th>Δfail%</th><th>Δunknown</th><th>Δunknown%</th><th>Δtotal</th></tr>" + f"<tr><td>{guard_delta_overall.get('window','?')}</td><td>{guard_delta_overall.get('delta_window','?')}</td><td>{guard_delta_overall.get('ok','?')}</td><td>{guard_delta_overall.get('ok_pct','0')}%</td><td>{guard_delta_overall.get('fail','?')}</td><td>{guard_delta_overall.get('fail_pct','0')}%</td><td>{guard_delta_overall.get('unknown','?')}</td><td>{guard_delta_overall.get('unknown_pct','0')}%</td><td>{guard_delta_overall.get('total','?')}</td></tr></table>") if guard_delta_overall else ""} 
</body>
</html>
"""
    output_path.write_text(html)
    print(f"HTML index written to {output_path}")


if __name__ == "__main__":
    main()
