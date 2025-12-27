#!/usr/bin/env python3
"""
Generate a consolidated HTML portal for metrics artifacts.
Usage: logs_metrics_portal.py --reports reports --suffix status_top2
"""
import argparse
import csv
import json
from datetime import datetime, timezone
from pathlib import Path


def load_csv(path: Path):
    with path.open(newline="") as f:
        return list(csv.DictReader(f))


def load_json(path: Path):
    return json.loads(path.read_text())


def render_table(rows, headers):
    head = "<tr>" + "".join(f"<th>{h}</th>" for h in headers) + "</tr>"
    body = "\n".join(
        "<tr>" + "".join(f"<td>{row.get(h,'')}</td>" for h in headers) + "</tr>" for row in rows
    )
    return f"<table>\n{head}\n{body}\n</table>"


def render_status(label: str, value: str):
    value_lower = (value or "").lower()
    cls = "status-badge neutral"
    if value_lower in ("ok", "success"):
        cls = "status-badge ok"
    elif value_lower in ("fail", "error", "missing"):
        cls = "status-badge fail"
    return f"<span class='{cls}'>{label}: {value}</span>"


def main():
    parser = argparse.ArgumentParser(description="Generate a consolidated HTML portal for metrics artifacts.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix")
    args = parser.parse_args()

    reports = Path(args.reports)
    base = reports / f"log_metrics_snapshot.{args.suffix}"
    csv_path = Path(f"{base}.csv")
    json_path = Path(f"{base}.json")
    summary_path = Path(f"{base}.summary.md")
    summary_html_path = Path(f"{base}.summary.html")
    history_path = reports / "log_metrics_history.csv"
    trend_path = reports / "log_metrics_trend.md"
    trend_html_path = reports / "log_metrics_trend.html"
    stats_path = reports / "log_metrics_stats.md"
    stats_html_path = reports / "log_metrics_stats.html"
    anomalies_path = reports / "log_metrics_anomalies.md"
    anomalies_html_path = reports / "log_metrics_anomalies.html"
    anomalies_json_path = reports / "log_metrics_anomalies.json"

    compare_md_path = reports / "log_metrics_compare.md"
    compare_html_path = reports / "log_metrics_compare.html"
    manifest_path = reports / "log_metrics_manifest.json"
    checksums_path = reports / "log_metrics_checksums.txt"
    run_summary_path = reports / "log_metrics_run_summary.json"
    run_summary_md_path = reports / "log_metrics_run_summary.md"
    run_summary_html_path = reports / "log_metrics_run_summary.html"
    sitemap_path = reports / "log_metrics_sitemap.md"
    sitemap_html_path = reports / "log_metrics_sitemap.html"
    sitemap_json_path = reports / "log_metrics_sitemap.json"
    status_badge_path = reports / "log_metrics_status_badge.svg"
    overall_history_path = reports / "log_metrics_overall_history.csv"
    sitemap_summary_html = ""
    sitemap_summary_card = ""
    manifest_summary_card = ""
    manifest_status = "n/a"
    if sitemap_json_path.exists():
        try:
            sitemap_data = load_json(sitemap_json_path)
            summary = sitemap_data.get("summary") or {}
            sitemap_summary_html = (
                "<ul>"
                f"<li>Artifacts: {summary.get('artifacts','n/a')}</li>"
                f"<li>Present: {summary.get('present','n/a')}</li>"
                f"<li>Missing: {summary.get('missing','n/a')}</li>"
                f"<li>Total size (bytes): {summary.get('total_size_bytes','n/a')}</li>"
                f"{''.join(f'<li>Optional (ignored): {opt}</li>' for opt in summary.get('optional_artifacts') or [])}"
                f"{''.join(f'<li>Missing path: {mp}</li>' for mp in summary.get('missing_paths') or [])}"
                "</ul>"
            )
            sitemap_summary_card = "<div class='card'><h3>Sitemap summary</h3>"
            sitemap_summary_card += f"<p><strong>Required:</strong> {summary.get('artifacts','n/a')}</p>"
            sitemap_summary_card += f"<p><strong>Present:</strong> {summary.get('present','n/a')}</p>"
            sitemap_summary_card += f"<p><strong>Missing:</strong> {summary.get('missing','n/a')}</p>"
            if summary.get("optional_artifacts"):
                sitemap_summary_card += f"<p class='meta'>Optional: {', '.join(summary.get('optional_artifacts'))}</p>"
            if summary.get("missing_paths"):
                sitemap_summary_card += "<p class='meta'>Missing paths:<br/>" + "<br/>".join(summary.get("missing_paths")) + "</p>"
            sitemap_summary_card += "</div>"
        except Exception:
            sitemap_summary_html = "<p>Sitemap summary unavailable (invalid JSON).</p>"
            sitemap_summary_card = ""
    run_summary_data = {}
    if run_summary_path.exists():
        try:
            run_summary_data = load_json(run_summary_path)
        except Exception:
            run_summary_data = {}
    manifest_summary = {}
    manifest_paths = {}
    manifest_path_resolved = manifest_path
    status_json_path = reports / "log_metrics_status.json"
    status_data = load_json(status_json_path) if (status_json_path.exists()) else {}
    manifest_from_status = status_data.get("manifest") or {}
    if manifest_from_status:
        try:
            missing_count = manifest_from_status.get("missing_count", 0)
            manifest_status = manifest_from_status.get("status", "n/a")
            manifest_summary = manifest_from_status
            manifest_summary_card = "<div class='card'><h3>Manifest</h3>"
            manifest_summary_card += f"<p><strong>Total:</strong> {manifest_from_status.get('total','n/a')}</p>"
            manifest_summary_card += f"<p><strong>Present:</strong> {manifest_from_status.get('present','n/a')}</p>"
            manifest_summary_card += f"<p><strong>Missing:</strong> {missing_count}</p>"
            manifest_summary_card += f"<p><strong>Total size:</strong> {manifest_from_status.get('size_bytes','n/a')} bytes</p>"
            optional_total = manifest_from_status.get("optional_total", 0)
            optional_present = manifest_from_status.get("optional_present", 0)
            optional_missing = manifest_from_status.get("optional_missing_count", 0)
            manifest_summary_card += f"<p><strong>Optional:</strong> {optional_present}/{optional_total} (ignored: {optional_missing})</p>"
            if manifest_from_status.get("optional_coverage") is not None:
                manifest_summary_card += f"<p class='meta'>Optional coverage: {manifest_from_status.get('optional_coverage')}%</p>"
            missing_list = manifest_from_status.get("missing_paths") or []
            if missing_list:
                manifest_summary_card += "<p class='meta'>Missing:<br/>" + "<br/>".join(missing_list[:5]) + ("<br/>…</p>" if len(missing_list) > 5 else "</p>")
            optional_skipped = manifest_from_status.get("optional_skipped") or []
            if optional_skipped:
                manifest_summary_card += "<p class='meta'>Optional ignored:<br/>" + "<br/>".join(optional_skipped[:5]) + ("<br/>…</p>" if len(optional_skipped) > 5 else "</p>")
            manifest_summary_card += "</div>"
        except Exception:
            manifest_summary = {}
    elif manifest_path.exists():
        try:
            manifest_data = load_json(manifest_path)
            manifest_paths = manifest_data.get("paths") or {}
            total = len(manifest_paths)
            present = 0
            missing_list = []
            size_total = 0
            for name, info in manifest_paths.items():
                if info.get("exists"):
                    present += 1
                    size_total += info.get("size") or 0
                else:
                    missing_list.append(info.get("path") or name)
            manifest_summary = {
                "total": total,
                "present": present,
                "missing": total - present,
                "size_bytes": size_total,
                "missing_paths": missing_list,
            }
            manifest_status = "ok" if (total - present) == 0 else "missing"
            manifest_summary_card = "<div class='card'><h3>Manifest</h3>"
            manifest_summary_card += f"<p><strong>Total:</strong> {total}</p>"
            manifest_summary_card += f"<p><strong>Present:</strong> {present}</p>"
            manifest_summary_card += f"<p><strong>Missing:</strong> {total - present}</p>"
            manifest_summary_card += f"<p><strong>Total size:</strong> {size_total} bytes</p>"
            if missing_list:
                manifest_summary_card += "<p class='meta'>Missing:<br/>" + "<br/>".join(missing_list[:5]) + ("<br/>…</p>" if len(missing_list) > 5 else "</p>")
            manifest_summary_card += "</div>"
        except Exception:
            manifest_summary = {}
    status_cards = []
    overview_path = reports / "log_metrics_overview.md"
    overview_html_path = reports / "log_metrics_overview.html"
    latest_json_path = reports / "log_metrics_latest.json"
    latest_html_path = reports / "log_metrics_latest.html"
    latest_md_path = reports / "log_metrics_latest.md"
    badge_path = reports / "log_metrics_badge.svg"
    latest_data = load_json(latest_json_path)
    downloads = []
    status_json_path = reports / "log_metrics_status.json"
    status_data = load_json(status_json_path)
    if manifest_path.exists():
        downloads.append(f"<li><a href='{manifest_path.name}'>Manifest</a></li>")
    bundle_path = reports / "log_metrics_bundle.tar.gz"
    if bundle_path.exists():
        downloads.append(f"<li><a href='{bundle_path.name}'>Bundle (tar.gz)</a></li>")
    if checksums_path.exists():
        downloads.append(f"<li><a href='{checksums_path.name}'>Checksums (sha256)</a></li>")
    run_summary_path = reports / "log_metrics_run_summary.json"
    if run_summary_path.exists():
        downloads.append(f"<li><a href='{run_summary_path.name}'>Run summary (json)</a></li>")
    run_summary_md_path = reports / "log_metrics_run_summary.md"
    if run_summary_md_path.exists():
        downloads.append(f"<li><a href='{run_summary_md_path.name}'>Run summary (md)</a></li>")
    run_summary_html_path = reports / "log_metrics_run_summary.html"
    if run_summary_html_path.exists():
        downloads.append(f"<li><a href='{run_summary_html_path.name}'>Run summary (html)</a></li>")
    if status_json_path.exists():
        downloads.append(f"<li><a href='{status_json_path.name}'>Status (json)</a></li>")
    if status_badge_path.exists():
        downloads.append(f"<li><a href='{status_badge_path.name}'>Status badge (svg)</a></li>")
    if overall_history_path.exists():
        downloads.append(f"<li><a href='{overall_history_path.name}'>Overall history (csv)</a></li>")
    downloads_card = ""
    if downloads:
        downloads_card = "<div class='card'><h3>Downloads</h3><ul>" + "".join(downloads) + "</ul></div>"
    status_badge_card = ""
    if status_badge_path.exists():
        status_badge_card = f"<div class='card'><h3>Status badge</h3><img src='{status_badge_path.name}' alt='Status badge' style='max-width:320px;'></div>"
    if run_summary_data:
        sitemap_info = (run_summary_data.get("sitemap") or {})
        sitemap_status = sitemap_info.get("status", "skipped")
        sitemap_summary_card = "<div class='card'><h3>Sitemap</h3>"
        sitemap_summary_card += f"<p>Status: <strong>{sitemap_status}</strong></p>"
        if sitemap_info.get("json"):
            sitemap_summary_card += f"<p>JSON: <code>{sitemap_info.get('json')}</code></p>"
        if sitemap_info.get("md"):
            sitemap_summary_card += f"<p>Markdown: <code>{sitemap_info.get('md')}</code></p>"
        if sitemap_info.get("html"):
            sitemap_summary_card += f"<p>HTML: <code>{sitemap_info.get('html')}</code></p>"
        sitemap_summary_card += "</div>"

        def card(title, value, extra=None):
            html_block = f"<div class='card'><h3>{title}</h3><p><strong>{value}</strong></p>"
            if extra:
                html_block += f"<p class='meta'>{extra}</p>"
            html_block += "</div>"
            status_cards.append(html_block)

        validation_info = run_summary_data.get("validation") or {}
        validation_txt = validation_info.get("status", "n/a")
        if validation_info.get("mode"):
            validation_txt = f"{validation_txt} (mode: {validation_info.get('mode')})"
        compare_info = run_summary_data.get("compare") or {}
        card("Badge", latest_data.get("badge_state", "n/a"), f"Label: {latest_data.get('badge_label', 'metrics')}")
        card("Guard check", latest_data.get("guard_check", run_summary_data.get('guard_check', 'n/a')))
        card("Checksums", run_summary_data.get("checksums", "n/a"))
        card("Validation", validation_txt)
        card("Compare", compare_info.get("status", "n/a"))
        latest_totals_card = "<div class='card'><h3>Latest totals</h3>"
        totals = latest_data.get("totals") or {}
        latest_totals_card += f"<p><strong>Overloaded ratio:</strong> {totals.get('overloaded_ratio','n/a')}%</p>"
        latest_totals_card += f"<p><strong>Status checks:</strong> {totals.get('status_checks','n/a')}</p>"
        latest_totals_card += f"<p><strong>Connections:</strong> {totals.get('connections','n/a')}</p>"
        latest_totals_card += f"<p><strong>Overloaded:</strong> {totals.get('overloaded','n/a')}</p>"
        if latest_data.get("anomalies_count") is not None:
            latest_totals_card += f"<p><strong>Anomalies:</strong> {latest_data.get('anomalies_count')}</p>"
            if latest_data.get("anomaly_threshold") is not None:
                latest_totals_card += f"<p class='meta'>Anomaly threshold: {latest_data.get('anomaly_threshold')}</p>"
        status_cards.append(latest_totals_card)
        anomalies_card = "<div class='card'><h3>Anomalies</h3>"
        anomalies_card += f"<p><strong>Count:</strong> {latest_data.get('anomalies_count','n/a')}</p>"
        if latest_data.get("anomaly_threshold") is not None:
            anomalies_card += f"<p><strong>Threshold:</strong> {latest_data.get('anomaly_threshold')}</p>"
        anomalies_card += f"<p><strong>Strict:</strong> {str(latest_data.get('anomalies_strict','n/a'))}</p>"
        if (run_summary_data.get('anomalies') or {}).get('md'):
            anomalies_card += f"<p class='meta'>See: <code>{(run_summary_data.get('anomalies') or {}).get('md')}</code></p>"
        status_cards.append(anomalies_card)
    badge_history_path = reports / "log_metrics_badge_history.csv"
    badge_history_md = reports / "log_metrics_badge_history.md"
    badge_history_html = reports / "log_metrics_badge_history.html"
    guard_summary_md = reports / "log_metrics_guard_summary.md"
    guard_summary_html = reports / "log_metrics_guard_summary.html"
    guard_summary_json = reports / "log_metrics_guard_summary.json"
    guard_summary_csv = reports / "log_metrics_guard_summary.csv"
    guard_summary_csv_rows = []
    if guard_summary_csv.exists():
        with guard_summary_csv.open(newline="") as f:
            guard_summary_csv_rows = list(csv.DictReader(f))
    guard_summary_json_data = {}
    if guard_summary_json.exists():
        try:
            guard_summary_json_data = load_json(guard_summary_json)
        except Exception:
            guard_summary_json_data = {}
    guard_overall_json = guard_summary_json_data.get("overall", {}) if guard_summary_json_data else {}
    guard_overall_streak_json = guard_summary_json_data.get("overall_streak", {}) if guard_summary_json_data else {}
    guard_overall_csv = None
    guard_overall_streak_csv = None
    if guard_summary_csv_rows:
        for row in guard_summary_csv_rows:
            name = row.get("guard")
            if name == "__overall":
                guard_overall_csv = row
            elif name == "__overall_streak":
                guard_overall_streak_csv = row
    guard_summary_md = reports / "log_metrics_guard_summary.md"
    badge_history_rows = load_csv(badge_history_path) if badge_history_path.exists() else []
    badge_history_summary = latest_data.get("badge_history", {})
    badge_prev_state = latest_data.get("badge_previous_state") or badge_history_summary.get("previous_state")
    badge_ok_streak_required = latest_data.get("badge_ok_streak_required")
    badge_window = badge_history_summary.get("window")
    badge_guards = latest_data.get("badge_guards") or {}
    badge_gate = badge_guards.get("gate")
    badge_no_regression = badge_guards.get("no_regression")
    badge_guard_status = latest_data.get("badge_guard_status") or {}
    guard_status_str = ", ".join(f"{k}:{v.get('result','n/a')}" for k, v in badge_guard_status.items()) if badge_guard_status else ""
    guard_fields = {
        "gate": "guard_gate_result",
        "ok_streak": "guard_ok_result",
        "no_regression": "guard_no_regression_result",
    }
    guard_counts = {k: {"ok": 0, "fail": 0, "unknown": 0} for k in guard_fields}
    for row in badge_history_rows:
        for name, field in guard_fields.items():
            val = str(row.get(field, "") or "").lower()
            if val not in ("ok", "fail"):
                val = "unknown"
            guard_counts[name][val] = guard_counts[name].get(val, 0) + 1
    badge_guard_summary = latest_data.get("badge_guard_summary") or {}
    badge_guard_overall = latest_data.get("badge_guard_overall") or {}
    badge_guard_delta = latest_data.get("badge_guard_delta") or {}

    required = [csv_path, json_path, summary_path, summary_html_path, history_path, trend_path, trend_html_path, stats_path, stats_html_path, anomalies_path, anomalies_html_path, anomalies_json_path, checksums_path, manifest_path, overview_path, overview_html_path, latest_json_path, latest_html_path, latest_md_path]
    missing = [p for p in required if not p.exists()]
    if missing:
        raise SystemExit(f"Missing artifacts: {', '.join(str(m) for m in missing)}")

    csv_rows = load_csv(csv_path)
    history_rows = load_csv(history_path)
    json_rows = load_json(json_path)

    generated = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    latest_totals = csv_rows[-1] if csv_rows else {}
    badge_state = latest_data.get("badge_state", "n/a")
    badge_thresholds = latest_data.get("badge_thresholds", {})
    badge_label = latest_data.get("badge_label", "metrics")
    badge_history_rows = []
    if badge_history_path.exists():
        try:
            badge_history_rows = load_csv(badge_history_path)
        except Exception:
            badge_history_rows = []

    status_bar = []
    status_bar.append(render_status("Badge", badge_state))
    status_bar.append(render_status("Guard", latest_data.get("guard_check", run_summary_data.get("guard_check", "n/a"))))
    status_bar.append(render_status("Checksums", latest_data.get("checksums_status", run_summary_data.get("checksums", "n/a"))))
    validation_state = latest_data.get("validation_status", (run_summary_data.get("validation") or {}).get("status", "n/a"))
    validation_mode = latest_data.get("validation_mode", (run_summary_data.get("validation") or {}).get("mode"))
    if validation_mode:
        validation_state = f"{validation_state} ({validation_mode})"
    status_bar.append(render_status("Validation", validation_state))
    compare_state = latest_data.get("compare_status", (run_summary_data.get("compare") or {}).get("status", "n/a"))
    status_bar.append(render_status("Compare", compare_state))
    if run_summary_data:
        status_bar.append(render_status("Sitemap", (run_summary_data.get("sitemap") or {}).get("status", "skipped")))
    else:
        status_bar.append(render_status("Sitemap", "n/a"))
    status_bar.append(render_status("Manifest", manifest_status))
    overall_state = (load_json(reports / "log_metrics_status.json").get("overall_state") if (reports / "log_metrics_status.json").exists() else "n/a")
    status_bar.append(render_status("Overall", overall_state))
    overall_history_rows = []
    if overall_history_path.exists():
        try:
            with overall_history_path.open(newline="") as f:
                overall_history_rows = list(csv.DictReader(f))[-10:]
        except Exception:
            overall_history_rows = []

    html = [
        "<!DOCTYPE html>",
        "<html lang='en'>",
        "<head>",
        "  <meta charset='UTF-8'>",
        "  <title>Log Metrics Portal</title>",
        "  <style>",
        "    body { font-family: Arial, sans-serif; margin: 24px; background: #f7f9fb; color: #1c1f23; }",
        "    h1, h2 { margin-bottom: 8px; }",
        "    table { border-collapse: collapse; width: 100%; margin-bottom: 16px; background: #fff; }",
        "    th, td { border: 1px solid #e6e9ed; padding: 6px; text-align: left; }",
        "    th { background: #eef2f6; }",
        "    .meta { color: #555; margin-bottom: 16px; }",
        "    pre { background: #fff; padding: 8px; border: 1px solid #e6e9ed; }",
        "    iframe { width: 100%; height: 320px; border: 1px solid #e6e9ed; background: #fff; }",
        "    .card { border: 1px solid #e1e6ed; padding: 12px; border-radius: 10px; margin: 12px 0; max-width: 620px; background: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.04); }",
        "    .status-bar { display: flex; flex-wrap: wrap; gap: 10px; margin: 12px 0 18px; }",
        "    .status-badge { border-radius: 14px; padding: 8px 12px; font-size: 0.92em; border: 1px solid #d5dce5; background: #f4f6f9; }",
        "    .status-badge.ok { border-color: #8cc152; background: #e5f5d9; color: #2c6c1a; }",
        "    .status-badge.fail { border-color: #da4453; background: #fbe3e6; color: #a51629; }",
        "    .status-badge.neutral { color: #4a4f55; }",
        "    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 12px; margin: 12px 0; }",
        "    .card h3 { margin-top: 0; }",
        "  </style>",
        "</head>",
        "<body>",
        f"<h1>Log Metrics Portal</h1>",
        f"<div class='meta'>Suffix: {args.suffix} | Generated: {generated}</div>",
        "<div class='status-bar'>",
        *status_bar,
        "</div>",
        "<h2>Latest snapshot (Totals)</h2>",
        render_table([latest_totals], ["timestamp", "status_checks", "connections", "overloaded", "overloaded_ratio"]),
        "<h2>Snapshot entries</h2>",
        render_table(csv_rows, ["timestamp", "log_file", "status_checks", "connections", "overloaded", "overloaded_ratio"]),
        "<h2>History</h2>",
        render_table(history_rows, history_rows[0].keys()),
        "<h2>Run summary</h2>",
        "<div class='grid'>",
        "".join(status_cards) if status_cards else "<p>No run summary available.</p>",
        manifest_summary_card,
        sitemap_summary_card,
        downloads_card,
        status_badge_card,
        ("" if not overall_history_rows else "<div class='card'><h3>Overall history (last 10)</h3>" + render_table(overall_history_rows, ["run_timestamp","overall_state","badge_state","anomalies_count","overloaded_ratio","sitemap_status","manifest_status"]) + "</div>"),
        "</div>",
        "<h2>Trend (HTML)</h2>",
        f"<iframe src='{trend_html_path.name}' title='Trend HTML'></iframe>",
        "<h2>Trend (Markdown)</h2>",
        f"<pre>{trend_path.read_text()}</pre>",
        "<h2>Stats (HTML)</h2>",
        f"<iframe src='{stats_html_path.name}' title='Stats HTML'></iframe>",
        "<h2>Stats (Markdown)</h2>",
        f"<pre>{stats_path.read_text()}</pre>",
        "<h2>Anomalies (HTML)</h2>",
        f"<iframe src='{anomalies_html_path.name}' title='Anomalies HTML'></iframe>",
        "<h2>Anomalies (Markdown)</h2>",
        f"<pre>{anomalies_path.read_text()}</pre>",
        "<h2>Anomalies (JSON)</h2>",
        f"<pre>{anomalies_json_path.read_text()}</pre>",
        "<h2>Summary (HTML)</h2>",
        f"<iframe src='{summary_html_path.name}' title='Summary HTML'></iframe>",
        "<h2>Summary (Markdown)</h2>",
        f"<pre>{summary_path.read_text()}</pre>",
        "<h2>Compare (si présent)</h2>",
        f"<pre>{compare_md_path.read_text() if compare_md_path.exists() else 'Compare non généré'}</pre>",
        "<h2>Compare HTML (si présent)</h2>",
        f"<iframe src='{compare_html_path.name}' title='Compare HTML'></iframe>" if compare_html_path.exists() else "<p>Compare HTML non généré.</p>",
        "<h2>Manifest (JSON)</h2>",
        f"<pre>{manifest_path.read_text() if manifest_path.exists() else 'Manifest non généré'}</pre>",
        "<h2>Run summary</h2>",
        f"<p>Run summary JSON: <a href='{run_summary_path.name}'>{run_summary_path.name}</a></p>" if run_summary_path.exists() else "<p>Run summary JSON non généré.</p>",
        f"<p>Run summary MD: <a href='{run_summary_md_path.name}'>{run_summary_md_path.name}</a></p>" if run_summary_md_path.exists() else "<p>Run summary MD non généré.</p>",
        f"<p>Run summary HTML: <a href='{run_summary_html_path.name}'>{run_summary_html_path.name}</a></p>" if run_summary_html_path.exists() else "<p>Run summary HTML non généré.</p>",
        f"<p>Sitemap: <a href='{sitemap_path.name}'>{sitemap_path.name}</a></p>" if sitemap_path.exists() else "<p>Sitemap non généré.</p>",
        f"<p>Sitemap HTML: <a href='{sitemap_html_path.name}'>{sitemap_html_path.name}</a></p>" if sitemap_html_path.exists() else "<p>Sitemap HTML non généré.</p>",
        f"<p>Sitemap JSON: <a href='{sitemap_json_path.name}'>{sitemap_json_path.name}</a></p>" if sitemap_json_path.exists() else "<p>Sitemap JSON non généré.</p>",
        f"<div><h3>Sitemap summary</h3>{sitemap_summary_html}</div>" if sitemap_summary_html else "",
        "<h2>Checksums (sha256)</h2>",
        f"<pre>{checksums_path.read_text()}</pre>",
        "<h2>Overview (Markdown)</h2>",
        f"<pre>{overview_path.read_text()}</pre>",
        "<h2>Overview (HTML)</h2>",
        f"<iframe src='{overview_html_path.name}' title='Overview HTML'></iframe>",
        "<h2>Badge</h2>",
        f"<p>Label : <strong>{badge_label}</strong> — État : <strong>{badge_history_summary.get('last', {}).get('badge_state', 'n/a') or badge_state}</strong> — Précédent : <strong>{badge_prev_state or 'n/a'}</strong> — Seuils : warn ≥ {badge_thresholds.get('warn','n/a')}, alert ≥ {badge_thresholds.get('danger','n/a')}</p>",
        f"<p>Comptage (fenêtre {badge_window or 'n/a'}, delta {badge_history_summary.get('delta_window', 0)}): {badge_history_summary.get('counts','')}</p>" if badge_history_summary else "",
        f"<p>Current streak: {badge_history_summary.get('current_streak',{}).get('length','?')} × {badge_history_summary.get('current_streak',{}).get('state','?')}</p>" if badge_history_summary else "",
        f"<p>Garde-fou streak: ok ≥ {badge_ok_streak_required}</p>" if badge_ok_streak_required else "",
        f"<p>Gate: {badge_gate}</p>" if badge_gate else "",
        "<p>Garde no-regression: activé</p>" if badge_no_regression else "",
        f"<p>Statuts gardes: {guard_status_str or 'n/a'}</p>",
        "<h4>Guards summary (history window)</h4>",
        render_table(
            [
                {"guard": name, "ok": counts.get("ok", 0), "fail": counts.get("fail", 0), "unknown": counts.get("unknown", 0)}
                for name, counts in guard_counts.items()
            ],
            ["guard", "ok", "fail", "unknown"],
        ) if guard_counts else "<p>Pas de gardes.</p>",
        "<h4>Guards summary (latest JSON)</h4>",
        render_table(
            [
                {"guard": name, "ok": summary.get("ok", 0), "fail": summary.get("fail", 0), "unknown": summary.get("unknown", 0), "total": summary.get("total", 0)}
                for name, summary in badge_guard_summary.items()
            ],
            ["guard", "ok", "fail", "unknown", "total"],
        ) if badge_guard_summary else "<p>Pas de synthèse dans latest.</p>",
        "<h4>Guards streaks (latest)</h4>",
        render_table(
            [
                {
                    "guard": name,
                    "current_result": (streak.get("current", {}) or {}).get("result", "?"),
                    "current_len": (streak.get("current", {}) or {}).get("length", "?"),
                    "longest_ok": (streak.get("longest", {}) or {}).get("ok", 0),
                    "longest_fail": (streak.get("longest", {}) or {}).get("fail", 0),
                    "longest_unknown": (streak.get("longest", {}) or {}).get("unknown", 0),
                    "window": streak.get("window", "?"),
                }
                for name, streak in (latest_data.get("badge_guard_streaks") or {}).items()
            ],
            ["guard", "current_result", "current_len", "longest_ok", "longest_fail", "longest_unknown", "window"],
        )
        if latest_data.get("badge_guard_streaks")
        else "<p>Pas de streaks de gardes.</p>",
        "<h4>Guard streak globale (latest)</h4>",
        render_table(
            [
                {
                    "current_result": (latest_data.get("badge_guard_overall_streak", {}) or {}).get("current", {}).get("result", "?"),
                    "current_len": (latest_data.get("badge_guard_overall_streak", {}) or {}).get("current", {}).get("length", "?"),
                    "longest_ok": (latest_data.get("badge_guard_overall_streak", {}) or {}).get("longest", {}).get("ok", 0),
                    "longest_fail": (latest_data.get("badge_guard_overall_streak", {}) or {}).get("longest", {}).get("fail", 0),
                    "longest_unknown": (latest_data.get("badge_guard_overall_streak", {}) or {}).get("longest", {}).get("unknown", 0),
                    "window": (latest_data.get("badge_guard_overall_streak", {}) or {}).get("window", "?"),
                }
            ],
            ["current_result", "current_len", "longest_ok", "longest_fail", "longest_unknown", "window"],
        )
        if latest_data.get("badge_guard_overall_streak")
        else "<p>Pas de streak globale.</p>",
        f"<img src='{badge_path.name}' alt='Metrics badge' style='max-width:240px;'/>" if badge_path.exists() else "<p>Badge non généré (option --no-badge).</p>",
        "<h3>Badge history</h3>",
        render_table(badge_history_rows, badge_history_rows[0].keys()) if badge_history_rows else "<p>Pas d'historique de badge.</p>",
        f"<pre>{badge_history_md.read_text()}</pre>" if badge_history_md.exists() else "",
        f"<iframe src='{badge_history_html.name}' title='Badge history HTML'></iframe>" if badge_history_html.exists() else "",
        f"<p>Guard summary (md): <a href='{guard_summary_md.name}'>{guard_summary_md.name}</a></p>" if guard_summary_md.exists() else "",
        f"<iframe src='{guard_summary_html.name}' title='Guard summary HTML'></iframe>" if guard_summary_html.exists() else "",
        f"<pre>{guard_summary_json.read_text()}</pre>" if guard_summary_json.exists() else "",
        f"<p>Guard summary (csv): <a href='{guard_summary_csv.name}'>{guard_summary_csv.name}</a></p>" if guard_summary_csv.exists() else "",
        render_table(guard_summary_csv_rows, guard_summary_csv_rows[0].keys()) if guard_summary_csv_rows else "<p>Pas de guard summary CSV.</p>",
        render_table([guard_overall_csv], guard_overall_csv.keys()) if guard_overall_csv else "<p>Pas de bloc overall dans le CSV.</p>",
        render_table([guard_overall_streak_csv], guard_overall_streak_csv.keys()) if guard_overall_streak_csv else "<p>Pas de streak globale dans le CSV.</p>",
        render_table([badge_guard_overall], badge_guard_overall.keys()) if badge_guard_overall else "<p>Pas de synthèse globale des gardes.</p>",
        "<h4>Guard summary (overall JSON)</h4>",
        render_table(
            [
                {
                    "ok": guard_overall_json.get("ok", "n/a"),
                    "fail": guard_overall_json.get("fail", "n/a"),
                    "unknown": guard_overall_json.get("unknown", "n/a"),
                    "total": guard_overall_json.get("total", "n/a"),
                    "window": guard_overall_json.get("window", "n/a"),
                    "ok_pct": guard_overall_json.get("ok_pct", "0"),
                    "fail_pct": guard_overall_json.get("fail_pct", "0"),
                    "unknown_pct": guard_overall_json.get("unknown_pct", "0"),
                    "delta_ok": (guard_overall_json.get("delta") or {}).get("ok", "n/a"),
                    "delta_ok_pct": (guard_overall_json.get("delta") or {}).get("ok_pct", "0"),
                    "delta_fail": (guard_overall_json.get("delta") or {}).get("fail", "n/a"),
                    "delta_fail_pct": (guard_overall_json.get("delta") or {}).get("fail_pct", "0"),
                    "delta_unknown": (guard_overall_json.get("delta") or {}).get("unknown", "n/a"),
                    "delta_unknown_pct": (guard_overall_json.get("delta") or {}).get("unknown_pct", "0"),
                    "delta_window": (guard_overall_json.get("delta") or {}).get("delta_window", "n/a"),
                }
            ],
            ["ok", "fail", "unknown", "total", "window", "ok_pct", "fail_pct", "unknown_pct", "delta_ok", "delta_ok_pct", "delta_fail", "delta_fail_pct", "delta_unknown", "delta_unknown_pct", "delta_window"],
        )
        if guard_overall_json
        else "<p>Pas de bloc overall dans guard_summary.json.</p>",
        "<h4>Guard summary (overall streak JSON)</h4>",
        render_table(
            [
                {
                    "current_result": (guard_overall_streak_json.get("current", {}) or {}).get("result", "?"),
                    "current_len": (guard_overall_streak_json.get("current", {}) or {}).get("length", "?"),
                    "longest_ok": (guard_overall_streak_json.get("longest", {}) or {}).get("ok", 0),
                    "longest_fail": (guard_overall_streak_json.get("longest", {}) or {}).get("fail", 0),
                    "longest_unknown": (guard_overall_streak_json.get("longest", {}) or {}).get("unknown", 0),
                    "window": guard_overall_streak_json.get("window", "?"),
                }
            ],
            ["current_result", "current_len", "longest_ok", "longest_fail", "longest_unknown", "window"],
        )
        if guard_overall_streak_json
        else "<p>Pas de streak globale dans guard_summary.json.</p>",
        render_table(
            [
                {
                    "guard": name,
                    "delta_ok": delta.get("ok", 0),
                    "delta_ok_pct": delta.get("ok_pct", "0"),
                    "delta_fail": delta.get("fail", 0),
                    "delta_fail_pct": delta.get("fail_pct", "0"),
                    "delta_unknown": delta.get("unknown", 0),
                    "delta_unknown_pct": delta.get("unknown_pct", "0"),
                    "window": delta.get("window", "?"),
                    "delta_window": delta.get("delta_window", "?"),
                }
                for name, delta in badge_guard_delta.items()
            ],
            ["guard", "delta_ok", "delta_ok_pct", "delta_fail", "delta_fail_pct", "delta_unknown", "delta_unknown_pct", "window", "delta_window"],
        )
        if badge_guard_delta
        else "<p>Pas de deltas de gardes.</p>",
        render_table(
            [
                {
                    "window": latest_data.get("badge_guard_delta_overall", {}).get("window", "n/a"),
                    "delta_window": latest_data.get("badge_guard_delta_overall", {}).get("delta_window", "n/a"),
                    "delta_ok": latest_data.get("badge_guard_delta_overall", {}).get("ok", "n/a"),
                    "delta_ok_pct": latest_data.get("badge_guard_delta_overall", {}).get("ok_pct", "0"),
                    "delta_fail": latest_data.get("badge_guard_delta_overall", {}).get("fail", "n/a"),
                    "delta_fail_pct": latest_data.get("badge_guard_delta_overall", {}).get("fail_pct", "0"),
                    "delta_unknown": latest_data.get("badge_guard_delta_overall", {}).get("unknown", "n/a"),
                    "delta_unknown_pct": latest_data.get("badge_guard_delta_overall", {}).get("unknown_pct", "0"),
                    "delta_total": latest_data.get("badge_guard_delta_overall", {}).get("total", "n/a"),
                }
            ],
            ["window", "delta_window", "delta_ok", "delta_ok_pct", "delta_fail", "delta_fail_pct", "delta_unknown", "delta_unknown_pct", "delta_total"],
        )
        if latest_data.get("badge_guard_delta_overall")
        else "<p>Pas de synthèse delta globale.</p>",
        "<h2>Latest summary (JSON)</h2>",
        f"<pre>{latest_json_path.read_text()}</pre>",
        "<h2>Latest summary (HTML)</h2>",
        f"<iframe src='{latest_html_path.name}' title='Latest HTML'></iframe>",
        "<h2>Latest summary (Markdown)</h2>",
        f"<pre>{latest_md_path.read_text()}</pre>",
        "</body></html>",
    ]
    out = reports / "portal.html"
    out.write_text("\n".join(html))
    print(f"Portal written to {out}")


if __name__ == "__main__":
    main()
