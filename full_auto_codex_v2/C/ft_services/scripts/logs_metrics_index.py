#!/usr/bin/env python3
"""
Generate an index (Markdown) linking to the latest metrics artifacts (snapshot, summary, trend, stats, anomalies, compare, manifest, portal, bundle).
Usage: logs_metrics_index.py --reports reports --suffix status_top2 [--compare reports/log_metrics_compare.md] [--output reports/index.md]
"""
import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="Generate a metrics reports index.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix (pattern_topN)")
    parser.add_argument("--compare", help="Path to an optional compare report (Markdown)")
    parser.add_argument("--output", help="Output index file (default: <reports>/index.md)")
    args = parser.parse_args()

    reports_dir = Path(args.reports)
    if not reports_dir.exists():
        raise SystemExit(f"Reports directory {reports_dir} not found")

    base = reports_dir / f"log_metrics_snapshot.{args.suffix}"
    snapshot_files = {
        "CSV": Path(f"{base}.csv"),
        "JSON": Path(f"{base}.json"),
        "JSONL": Path(f"{base}.jsonl"),
        "Markdown": Path(f"{base}.md"),
        "HTML": Path(f"{base}.html"),
        "Summary (md)": Path(f"{base}.summary.md"),
        "Summary (html)": Path(f"{base}.summary.html"),
    }
    missing = [name for name, path in snapshot_files.items() if not path.exists()]
    if missing:
        raise SystemExit(f"Missing artifacts for suffix {args.suffix}: {', '.join(missing)}")

    compare_path = Path(args.compare) if args.compare else None
    if compare_path and not compare_path.exists():
        raise SystemExit(f"Compare report {compare_path} not found")
    compare_html = reports_dir / "log_metrics_compare.html"

    output = Path(args.output) if args.output else reports_dir / "index.md"
    generated = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    def load_json(path: Path, label: str) -> dict:
        if not path.exists():
            return {}
        try:
            return json.loads(path.read_text())
        except Exception as exc:  # pragma: no cover - defensive guardrail
            print(f"[index] warning: failed to read {label} at {path}: {exc}", file=sys.stderr)
            return {}

    run_summary_path = reports_dir / "log_metrics_run_summary.json"
    latest_path = reports_dir / "log_metrics_latest.json"
    status_json_path = reports_dir / "log_metrics_status.json"

    run_summary = load_json(run_summary_path, "run_summary")
    latest = load_json(latest_path, "latest")
    status_data = load_json(status_json_path, "status")
    overall_history_path = reports_dir / "log_metrics_overall_history.csv"
    overall_history_rows = []
    if overall_history_path.exists():
        try:
            import csv
            with overall_history_path.open(newline="") as f:
                overall_history_rows = list(csv.DictReader(f))[-10:]
        except Exception:
            overall_history_rows = []
    manifest_path = reports_dir / "log_metrics_manifest.json"
    manifest_data = {}
    manifest_summary = None
    optional_manifest = {"compare_html", "compare_md", "checksums_guard"}
    sitemap_summary = None
    sitemap_path = reports_dir / "log_metrics_sitemap.json"
    if manifest_path.exists():
        try:
            manifest_data = json.loads(manifest_path.read_text())
            paths = manifest_data.get("paths") or {}
            total = len(paths)
            present = sum(1 for name, info in paths.items() if info.get("exists") and name not in optional_manifest)
            missing = sum(1 for name, info in paths.items() if not info.get("exists") and name not in optional_manifest)
            size_total = sum(info.get("size") or 0 for name, info in paths.items() if info.get("exists") and name not in optional_manifest)
            manifest_summary = (total, present, missing, size_total)
        except Exception:
            manifest_data = {}
    if sitemap_path.exists():
        try:
            sitemap_data = json.loads(sitemap_path.read_text())
            summary = sitemap_data.get("summary") or {}
            sitemap_summary = summary
        except Exception:
            sitemap_summary = None

    lines = [
        "# Log Metrics Index",
        "",
        f"- Generated: {generated}",
        f"- Suffix: `{args.suffix}`",
        "",
        "## Status",
    ]
    def status_line(label, value):
        lines.append(f"- {label}: **{value}**")

    badge_state = run_summary.get("badge_state") or status_data.get("badge_state") or latest.get("badge_state") or "n/a"
    guard_state = run_summary.get("guard_check") or status_data.get("guard_check") or "n/a"
    checksums_state = run_summary.get("checksums") or status_data.get("checksums") or "n/a"
    status_line("Badge", badge_state)
    status_line("Guard check", guard_state)
    status_line("Checksums", checksums_state)
    validation = run_summary.get("validation") or status_data.get("validation") or {}
    validation_text = validation.get("status", "n/a")
    if validation.get("mode"):
        validation_text = f"{validation_text} (mode: {validation.get('mode')})"
    status_line("Validation", validation_text)
    status_line("Compare", (status_data.get("compare") or run_summary.get("compare") or {}).get("status", "n/a"))
    status_line("Sitemap", (status_data.get("sitemap") or run_summary.get("sitemap") or {}).get("status", "skipped"))
    manifest_info = status_data.get("manifest") or {}
    manifest_optional = manifest_info.get("optional_skipped") or []
    manifest_optional_total = manifest_info.get("optional_total")
    manifest_optional_present = manifest_info.get("optional_present")
    manifest_optional_missing = manifest_info.get("optional_missing_count")
    manifest_optional_coverage = manifest_info.get("optional_coverage")
    if manifest_summary:
        status_line("Manifest", "ok" if manifest_summary[2] == 0 else "missing")
    if manifest_summary:
        total, present, missing, size_total = manifest_summary
        lines.append("")
        lines.append("## Manifest")
        lines.append(f"- Total: **{total}**, Present: **{present}**, Missing: **{missing}**, Size: **{size_total} bytes**")
        if manifest_optional_total is not None:
            opt_present = manifest_optional_present if manifest_optional_present is not None else "n/a"
            opt_total = manifest_optional_total if manifest_optional_total is not None else "n/a"
            opt_missing = manifest_optional_missing if manifest_optional_missing is not None else "n/a"
            lines.append(f"- Optional: **{opt_present}/{opt_total}** (ignored: {opt_missing})")
            if manifest_optional_coverage is not None:
                lines.append(f"- Optional coverage: **{manifest_optional_coverage}%**")
        if manifest_optional:
            lines.append(f"- Optional ignored: {', '.join(manifest_optional)}")
    status_json = reports_dir / "log_metrics_status.json"
    lines.append("")
    lines.append("## Key links")
    if (reports_dir / "log_metrics_run_summary.json").exists():
        lines.append(f"- Run summary (json): [{(reports_dir / 'log_metrics_run_summary.json').name}]({(reports_dir / 'log_metrics_run_summary.json').name})")
    if (reports_dir / "log_metrics_run_summary.md").exists():
        lines.append(f"- Run summary (md): [{(reports_dir / 'log_metrics_run_summary.md').name}]({(reports_dir / 'log_metrics_run_summary.md').name})")
    if (reports_dir / "log_metrics_run_summary.html").exists():
        lines.append(f"- Run summary (html): [{(reports_dir / 'log_metrics_run_summary.html').name}]({(reports_dir / 'log_metrics_run_summary.html').name})")
    if status_json.exists():
        lines.append(f"- Status (json): [{status_json.name}]({status_json.name})")
    if overall_history_path.exists():
        rel = overall_history_path.relative_to(reports_dir)
        lines.append(f"- Overall history (csv): [{rel}]({rel})")
    if (reports_dir / "portal.html").exists():
        lines.append(f"- Portal: [portal.html](portal.html)")
    if (reports_dir / "log_metrics_bundle.tar.gz").exists():
        lines.append(f"- Bundle: [log_metrics_bundle.tar.gz](log_metrics_bundle.tar.gz)")
    if (reports_dir / "log_metrics_manifest.json").exists():
        lines.append(f"- Manifest: [log_metrics_manifest.json](log_metrics_manifest.json)")
    if sitemap_summary:
        lines.append("")
        lines.append("## Sitemap")
        lines.append(f"- Required: **{sitemap_summary.get('artifacts','n/a')}**, Present: **{sitemap_summary.get('present','n/a')}**, Missing: **{sitemap_summary.get('missing','n/a')}**")
        if sitemap_summary.get("optional_artifacts"):
            lines.append(f"- Optional: {', '.join(sitemap_summary.get('optional_artifacts'))}")
    totals = latest.get("totals") or {}
    if totals or latest.get("anomalies_count") is not None:
        lines.append("")
        lines.append("## Quick stats")
        if totals:
            lines.append(f"- Overloaded ratio: **{totals.get('overloaded_ratio','n/a')}%**")
            lines.append(f"- Status checks: **{totals.get('status_checks','n/a')}**")
            lines.append(f"- Connections: **{totals.get('connections','n/a')}**")
            lines.append(f"- Overloaded: **{totals.get('overloaded','n/a')}**")
        if latest.get("anomalies_count") is not None:
            lines.append(f"- Anomalies: **{latest.get('anomalies_count')}**")
    lines += [
        "",
        "## Snapshots",
    ]
    for name, path in snapshot_files.items():
        rel = path.relative_to(reports_dir)
        lines.append(f"- {name}: [{rel}]({rel})")

    history = reports_dir / "log_metrics_history.csv"
    if history.exists():
        lines.append("")
        lines.append("## History")
        rel = history.relative_to(reports_dir)
        lines.append(f"- History CSV: [{rel}]({rel})")
    trend_md = reports_dir / "log_metrics_trend.md"
    trend_html = reports_dir / "log_metrics_trend.html"
    if trend_md.exists() or trend_html.exists():
        lines.append("")
        lines.append("## Trend")
        if trend_md.exists():
            lines.append(f"- Trend (md): [{trend_md.relative_to(reports_dir)}]({trend_md.relative_to(reports_dir)})")
        if trend_html.exists():
            lines.append(f"- Trend (html): [{trend_html.relative_to(reports_dir)}]({trend_html.relative_to(reports_dir)})")

    stats_md = reports_dir / "log_metrics_stats.md"
    stats_html = reports_dir / "log_metrics_stats.html"
    if stats_md.exists() or stats_html.exists():
        lines.append("")
        lines.append("## Stats")
        if stats_md.exists():
            lines.append(f"- Stats (md): [{stats_md.relative_to(reports_dir)}]({stats_md.relative_to(reports_dir)})")
        if stats_html.exists():
            lines.append(f"- Stats (html): [{stats_html.relative_to(reports_dir)}]({stats_html.relative_to(reports_dir)})")

    anomalies_md = reports_dir / "log_metrics_anomalies.md"
    anomalies_html = reports_dir / "log_metrics_anomalies.html"
    anomalies_json = reports_dir / "log_metrics_anomalies.json"
    if anomalies_md.exists() or anomalies_html.exists() or anomalies_json.exists():
        lines.append("")
        lines.append("## Anomalies")
        if anomalies_md.exists():
            lines.append(f"- Anomalies (md): [{anomalies_md.relative_to(reports_dir)}]({anomalies_md.relative_to(reports_dir)})")
        if anomalies_html.exists():
            lines.append(f"- Anomalies (html): [{anomalies_html.relative_to(reports_dir)}]({anomalies_html.relative_to(reports_dir)})")
        if anomalies_json.exists():
            lines.append(f"- Anomalies (json): [{anomalies_json.relative_to(reports_dir)}]({anomalies_json.relative_to(reports_dir)})")

    if compare_path:
        rel = compare_path.relative_to(reports_dir)
        lines.append("")
        lines.append("## Compare")
        lines.append(f"- Diff report: [{rel}]({rel})")
        if compare_html.exists():
            lines.append(f"- Diff report (html): [{compare_html.relative_to(reports_dir)}]({compare_html.relative_to(reports_dir)})")

    manifest = reports_dir / "log_metrics_manifest.json"
    if manifest.exists():
        lines.append("")
        lines.append("## Manifest")
        lines.append(f"- Manifest (json): [{manifest.relative_to(reports_dir)}]({manifest.relative_to(reports_dir)})")
        sitemap_md = reports_dir / "log_metrics_sitemap.md"
        sitemap_html = reports_dir / "log_metrics_sitemap.html"
        sitemap_json = reports_dir / "log_metrics_sitemap.json"
        if sitemap_md.exists():
            lines.append(f"- Sitemap: [{sitemap_md.relative_to(reports_dir)}]({sitemap_md.relative_to(reports_dir)})")
        if sitemap_html.exists():
            lines.append(f"- Sitemap (html): [{sitemap_html.relative_to(reports_dir)}]({sitemap_html.relative_to(reports_dir)})")
        if sitemap_json.exists():
            lines.append(f"- Sitemap (json): [{sitemap_json.relative_to(reports_dir)}]({sitemap_json.relative_to(reports_dir)})")
            try:
                data = json.loads(sitemap_json.read_text())
                summary = data.get("summary") or {}
                lines.append("  - Sitemap summary:")
                lines.append(f"    - Artifacts: {summary.get('artifacts', 'n/a')}")
                lines.append(f"    - Present: {summary.get('present', 'n/a')}")
                lines.append(f"    - Missing: {summary.get('missing', 'n/a')}")
                lines.append(f"    - Total size (bytes): {summary.get('total_size_bytes', 'n/a')}")
                optional_artifacts = summary.get("optional_artifacts") or []
                if optional_artifacts:
                    lines.append("    - Optional (ignored):")
                    for opt in optional_artifacts:
                        lines.append(f"      - {opt}")
                missing_paths = summary.get("missing_paths") or []
                if missing_paths:
                    lines.append("    - Missing paths:")
                    for mp in missing_paths:
                        lines.append(f"      - {mp}")
            except Exception:
                lines.append("  - Sitemap summary: unreadable JSON")

    run_summary = reports_dir / "log_metrics_run_summary.json"
    run_summary_md = reports_dir / "log_metrics_run_summary.md"
    run_summary_html = reports_dir / "log_metrics_run_summary.html"
    if run_summary.exists() or run_summary_md.exists() or run_summary_html.exists():
        lines.append("")
        lines.append("## Run summary")
        if run_summary.exists():
            try:
                summary = json.loads(run_summary.read_text())
                guard_check = summary.get("guard_check")
                checksums = summary.get("checksums")
                validation = (summary.get("validation") or {}).get("status")
                compare_status = (summary.get("compare") or {}).get("status")
                badge_state = summary.get("badge_state")
                anomalies_count = summary.get("anomalies_count")
                overloaded_ratio = summary.get("overloaded_ratio")
                lines.append(f"- Run summary (json): [{run_summary.relative_to(reports_dir)}]({run_summary.relative_to(reports_dir)})")
                lines.append(
                    f"- Badge={badge_state}, anomalies={anomalies_count}, overloaded_ratio={overloaded_ratio}, guard_check={guard_check}, checksums={checksums}, validation={validation}, compare={compare_status}"
                )
            except Exception:
                lines.append(f"- Run summary (json): [{run_summary.relative_to(reports_dir)}]({run_summary.relative_to(reports_dir)}) (unreadable)")
        if run_summary_md.exists():
            lines.append(f"- Run summary (md): [{run_summary_md.relative_to(reports_dir)}]({run_summary_md.relative_to(reports_dir)})")
        if run_summary_html.exists():
            lines.append(f"- Run summary (html): [{run_summary_html.relative_to(reports_dir)}]({run_summary_html.relative_to(reports_dir)})")

    if overall_history_path.exists():
        lines.append("")
        lines.append("## Overall history")
        lines.append(f"- Overall history (csv): [{overall_history_path.relative_to(reports_dir)}]({overall_history_path.relative_to(reports_dir)})")
        if overall_history_rows:
            headers = ["run_timestamp","overall_state","badge_state","anomalies_count","overloaded_ratio","sitemap_status","manifest_status","guard_check","checksums","validation_status"]
            lines.append("")
            # markdown table
            lines.append("| " + " | ".join(headers) + " |")
            lines.append("| " + " | ".join("---" for _ in headers) + " |")
            for row in overall_history_rows:
                lines.append("| " + " | ".join(str(row.get(h, "")) for h in headers) + " |")

    overview = reports_dir / "log_metrics_overview.md"
    if overview.exists():
        lines.append("")
        lines.append("## Overview")
        lines.append(f"- Overview: [{overview.relative_to(reports_dir)}]({overview.relative_to(reports_dir)})")
        overview_html = reports_dir / "log_metrics_overview.html"
        if overview_html.exists():
            lines.append(f"- Overview (html): [{overview_html.relative_to(reports_dir)}]({overview_html.relative_to(reports_dir)})")

    checksums = reports_dir / "log_metrics_checksums.txt"
    if checksums.exists():
        lines.append("")
        lines.append("## Checksums")
        lines.append(f"- Checksums (sha256): [{checksums.relative_to(reports_dir)}]({checksums.relative_to(reports_dir)})")

    badge = reports_dir / "log_metrics_badge.svg"
    latest_json = reports_dir / "log_metrics_latest.json"
    badge_history = reports_dir / "log_metrics_badge_history.csv"
    badge_history_md = reports_dir / "log_metrics_badge_history.md"
    badge_history_html = reports_dir / "log_metrics_badge_history.html"
    if badge.exists() or latest_json.exists():
        lines.append("")
        lines.append("## Badge")
        if latest_json.exists():
            try:
                data = json.loads(latest_json.read_text())
                state = data.get("badge_state", "n/a")
                thresholds = data.get("badge_thresholds", {})
                label = data.get("badge_label", "metrics")
                warn = thresholds.get("warn", "n/a")
                danger = thresholds.get("danger", "n/a")
                history = data.get("badge_history", {}) or {}
                counts = history.get("counts", {})
                current_streak = history.get("current_streak", {})
                window = history.get("window")
                previous_state = data.get("badge_previous_state") or history.get("previous_state")
                ok_streak_required = data.get("badge_ok_streak_required")
                lines.append(f"- State: `{state}` (label `{label}`, warn ≥ {warn}, alert ≥ {danger})")
                if counts:
                    delta_window = badge_history.get("delta_window", 0)
                    lines.append(f"- Badge counts (last {window or 'all'} | delta window {delta_window}): {counts}")
                if current_streak:
                    lines.append(f"- Current streak: {current_streak.get('length','?')} × {current_streak.get('state','?')}")
                if previous_state:
                    lines.append(f"- Previous badge state: {previous_state}")
                guards = data.get("badge_guards") or {}
                guard_status = data.get("badge_guard_status") or {}
                gate = guards.get("gate")
                no_reg = guards.get("no_regression")
                ok_guard = ok_streak_required or guards.get("ok_streak")
                guard_summary = data.get("badge_guard_summary") or {}
                guard_streaks = data.get("badge_guard_streaks") or {}
                if ok_guard:
                    lines.append(f"- OK streak guard: ok >= {ok_guard} ({guard_status.get('ok_streak',{}).get('result','n/a')})")
                if gate:
                    lines.append(f"- Gate guard: {gate} ({guard_status.get('gate',{}).get('result','n/a')})")
                if no_reg:
                    lines.append(f"- No-regression guard: enabled ({guard_status.get('no_regression',{}).get('result','n/a')})")
                if guard_summary:
                    lines.append("- Guard summary (ok/fail/unknown/total/window/%):")
                    for name, summary in guard_summary.items():
                        lines.append(
                            f"  - {name}: ok={summary.get('ok',0)}, fail={summary.get('fail',0)}, unknown={summary.get('unknown',0)} (total={summary.get('total',0)}, window={summary.get('window','?')}, ok={summary.get('ok_pct','0')}%, fail={summary.get('fail_pct','0')}%, unknown={summary.get('unknown_pct','0')}%)"
                        )
                    lines.append("")
                    lines.append("| guard | ok | fail | unknown | total | window | ok% | fail% | unknown% |")
                    lines.append("| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
                    for name, summary in guard_summary.items():
                        lines.append(
                            f"| {name} | {summary.get('ok',0)} | {summary.get('fail',0)} | {summary.get('unknown',0)} | {summary.get('total',0)} | {summary.get('window','?')} | {summary.get('ok_pct','0')}% | {summary.get('fail_pct','0')}% | {summary.get('unknown_pct','0')}% |"
                        )
                    overall = data.get("badge_guard_overall") or {}
                    if overall:
                        lines.append("")
                        lines.append("| window | ok | ok% | fail | fail% | unknown | unknown% | total |")
                        lines.append("| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
                        lines.append(
                            f"| {overall.get('window','?')} | {overall.get('ok',0)} | {overall.get('ok_pct','0')}% | {overall.get('fail',0)} | {overall.get('fail_pct','0')}% | {overall.get('unknown',0)} | {overall.get('unknown_pct','0')}% | {overall.get('total',0)} |"
                        )
                overall_streak = data.get("badge_guard_overall_streak") or {}
                if overall_streak:
                    lines.append("")
                    lines.append("Streak globale (tous gardes combinés) :")
                    lines.append(
                        f"- Courante: {overall_streak.get('current',{}).get('result','?')} x {overall_streak.get('current',{}).get('length','?')} (fenêtre {overall_streak.get('window','?')}); longest ok={overall_streak.get('longest',{}).get('ok',0)}, fail={overall_streak.get('longest',{}).get('fail',0)}, unknown={overall_streak.get('longest',{}).get('unknown',0)}"
                    )
                if guard_streaks:
                    lines.append("")
                    lines.append("| guard | current_result | current_len | longest_ok | longest_fail | longest_unknown | window |")
                    lines.append("| --- | --- | ---: | ---: | ---: | ---: | ---: |")
                    for name, streak in guard_streaks.items():
                        longest = streak.get("longest", {})
                        current = streak.get("current", {})
                        lines.append(
                            f"| {name} | {current.get('result','?')} | {current.get('length','?')} | {longest.get('ok',0)} | {longest.get('fail',0)} | {longest.get('unknown',0)} | {streak.get('window','?')} |"
                        )
            except Exception:
                lines.append("- State: non disponible (latest JSON illisible)")
        if badge.exists():
            lines.append(f"- Badge (svg): [{badge.relative_to(reports_dir)}]({badge.relative_to(reports_dir)})")
        if badge_history.exists():
            lines.append(f"- Badge history (csv): [{badge_history.relative_to(reports_dir)}]({badge_history.relative_to(reports_dir)})")
        if badge_history_md.exists():
            lines.append(f"- Badge history (md): [{badge_history_md.relative_to(reports_dir)}]({badge_history_md.relative_to(reports_dir)})")
        if badge_history_html.exists():
            lines.append(f"- Badge history (html): [{badge_history_html.relative_to(reports_dir)}]({badge_history_html.relative_to(reports_dir)})")
    guard_summary_md = reports_dir / "log_metrics_guard_summary.md"
    guard_summary_html = reports_dir / "log_metrics_guard_summary.html"
    guard_summary_json = reports_dir / "log_metrics_guard_summary.json"
    guard_summary_csv = reports_dir / "log_metrics_guard_summary.csv"
    guard_summary_json_data = {}
    if guard_summary_json.exists():
        try:
            guard_summary_json_data = json.loads(guard_summary_json.read_text())
        except Exception:
            guard_summary_json_data = {}
    if guard_summary_md.exists():
        lines.append(f"- Guard summary (md): [{guard_summary_md.relative_to(reports_dir)}]({guard_summary_md.relative_to(reports_dir)})")
    if guard_summary_html.exists():
        lines.append(f"- Guard summary (html): [{guard_summary_html.relative_to(reports_dir)}]({guard_summary_html.relative_to(reports_dir)})")
    if guard_summary_json.exists():
        lines.append(f"- Guard summary (json): [{guard_summary_json.relative_to(reports_dir)}]({guard_summary_json.relative_to(reports_dir)})")
    if guard_summary_csv.exists():
        lines.append(f"- Guard summary (csv): [{guard_summary_csv.relative_to(reports_dir)}]({guard_summary_csv.relative_to(reports_dir)})")
    if guard_summary_json_data:
        overall_json = guard_summary_json_data.get("overall") or {}
        overall_streak_json = guard_summary_json_data.get("overall_streak") or {}
        if overall_json:
            lines.append("")
            lines.append("Guard summary (overall, guard_summary.json) :")
            lines.append("| ok | fail | unknown | total | window | ok% | fail% | unknown% | Δok | Δok% | Δfail | Δfail% | Δunknown | Δunknown% | Δwindow |")
            lines.append("| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
            delta = overall_json.get("delta") or {}
            lines.append(
                "| {ok} | {fail} | {unknown} | {total} | {window} | {ok_pct}% | {fail_pct}% | {unknown_pct}% | {dok} | {dokpct}% | {dfail} | {dfailpct}% | {dunk} | {dunkpct}% | {dwin} |".format(
                    ok=overall_json.get("ok", 0),
                    fail=overall_json.get("fail", 0),
                    unknown=overall_json.get("unknown", 0),
                    total=overall_json.get("total", 0),
                    window=overall_json.get("window", "?"),
                    ok_pct=overall_json.get("ok_pct", "0"),
                    fail_pct=overall_json.get("fail_pct", "0"),
                    unknown_pct=overall_json.get("unknown_pct", "0"),
                    dok=delta.get("ok", 0),
                    dokpct=delta.get("ok_pct", "0"),
                    dfail=delta.get("fail", 0),
                    dfailpct=delta.get("fail_pct", "0"),
                    dunk=delta.get("unknown", 0),
                    dunkpct=delta.get("unknown_pct", "0"),
                    dwin=delta.get("delta_window", "?"),
                )
            )
        if overall_streak_json:
            lines.append("")
            lines.append("Streak globale (guard_summary.json) :")
            lines.append(
                f"- Courante: {overall_streak_json.get('current',{}).get('result','?')} x {overall_streak_json.get('current',{}).get('length','?')} (fenêtre {overall_streak_json.get('window','?')}); longest ok={overall_streak_json.get('longest',{}).get('ok',0)}, fail={overall_streak_json.get('longest',{}).get('fail',0)}, unknown={overall_streak_json.get('longest',{}).get('unknown',0)}"
            )
        guard_delta = data.get("badge_guard_delta") or {}
        if guard_delta:
            lines.append("")
            lines.append("| guard | Δok | Δok% | Δfail | Δfail% | Δunknown | Δunknown% | window | delta_window |")
            lines.append("| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
            for name, delta in guard_delta.items():
                lines.append(
                    f"| {name} | {delta.get('ok',0):+d} | {delta.get('ok_pct','0')}% | {delta.get('fail',0):+d} | {delta.get('fail_pct','0')}% | {delta.get('unknown',0):+d} | {delta.get('unknown_pct','0')}% | {delta.get('window','?')} | {delta.get('delta_window','?')} |"
                )
            delta_overall = data.get("badge_guard_delta_overall") or {}
            if delta_overall:
                lines.append("")
                lines.append("| window | delta_window | Δok | Δok% | Δfail | Δfail% | Δunknown | Δunknown% | Δtotal |")
                lines.append("| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
                lines.append(
                    f"| {delta_overall.get('window','?')} | {delta_overall.get('delta_window','?')} | {delta_overall.get('ok','n/a')} | {delta_overall.get('ok_pct','0')}% | {delta_overall.get('fail','n/a')} | {delta_overall.get('fail_pct','0')}% | {delta_overall.get('unknown','n/a')} | {delta_overall.get('unknown_pct','0')}% | {delta_overall.get('total','n/a')} |"
                )

    latest = reports_dir / "log_metrics_latest.json"
    if latest.exists():
        lines.append("")
        lines.append("## Latest summary")
        lines.append(f"- Latest (json): [{latest.relative_to(reports_dir)}]({latest.relative_to(reports_dir)})")
        latest_html = reports_dir / "log_metrics_latest.html"
        if latest_html.exists():
            lines.append(f"- Latest (html): [{latest_html.relative_to(reports_dir)}]({latest_html.relative_to(reports_dir)})")
        latest_md = reports_dir / "log_metrics_latest.md"
        if latest_md.exists():
            lines.append(f"- Latest (md): [{latest_md.relative_to(reports_dir)}]({latest_md.relative_to(reports_dir)})")

    portal = reports_dir / "portal.html"
    if portal.exists():
        lines.append("")
        lines.append("## Portal")
        lines.append(f"- Portal: [{portal.relative_to(reports_dir)}]({portal.relative_to(reports_dir)})")

    bundle = reports_dir / "log_metrics_bundle.tar.gz"
    if bundle.exists():
        lines.append("")
        lines.append("## Bundle")
        lines.append(f"- Bundle: [{bundle.relative_to(reports_dir)}]({bundle.relative_to(reports_dir)})")

    output.write_text("\n".join(lines) + "\n")
    print(f"Index written to {output}")


if __name__ == "__main__":
    main()
