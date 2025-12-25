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
    overview_path = reports / "log_metrics_overview.md"
    overview_html_path = reports / "log_metrics_overview.html"
    latest_json_path = reports / "log_metrics_latest.json"
    latest_html_path = reports / "log_metrics_latest.html"
    latest_md_path = reports / "log_metrics_latest.md"
    badge_path = reports / "log_metrics_badge.svg"
    latest_data = load_json(latest_json_path)
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

    html = [
        "<!DOCTYPE html>",
        "<html lang='en'>",
        "<head>",
        "  <meta charset='UTF-8'>",
        "  <title>Log Metrics Portal</title>",
        "  <style>",
        "    body { font-family: Arial, sans-serif; margin: 24px; }",
        "    h1, h2 { margin-bottom: 8px; }",
        "    table { border-collapse: collapse; width: 100%; margin-bottom: 16px; }",
        "    th, td { border: 1px solid #ddd; padding: 6px; text-align: left; }",
        "    th { background: #f4f4f4; }",
        "    .meta { color: #555; margin-bottom: 16px; }",
        "    pre { background: #f9f9f9; padding: 8px; border: 1px solid #eee; }",
        "    iframe { width: 100%; height: 320px; border: 1px solid #eee; }",
        "  </style>",
        "</head>",
        "<body>",
        f"<h1>Log Metrics Portal</h1>",
        f"<div class='meta'>Suffix: {args.suffix} | Generated: {generated}</div>",
        "<h2>Latest snapshot (Totals)</h2>",
        render_table([latest_totals], ["timestamp", "status_checks", "connections", "overloaded", "overloaded_ratio"]),
        "<h2>Snapshot entries</h2>",
        render_table(csv_rows, ["timestamp", "log_file", "status_checks", "connections", "overloaded", "overloaded_ratio"]),
        "<h2>History</h2>",
        render_table(history_rows, history_rows[0].keys()),
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
        render_table([badge_guard_overall], badge_guard_overall.keys()) if badge_guard_overall else "<p>Pas de synthèse globale des gardes.</p>",
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
