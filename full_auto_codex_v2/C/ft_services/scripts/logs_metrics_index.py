#!/usr/bin/env python3
"""
Generate an index (Markdown) linking to the latest metrics artifacts (snapshot, summary, trend, stats, anomalies, compare, manifest, portal, bundle).
Usage: logs_metrics_index.py --reports reports --suffix status_top2 [--compare reports/log_metrics_compare.md] [--output reports/index.md]
"""
import argparse
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

    lines = [
        "# Log Metrics Index",
        "",
        f"- Generated: {generated}",
        f"- Suffix: `{args.suffix}`",
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
                import json

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
        if guard_summary_md.exists():
            lines.append(f"- Guard summary (md): [{guard_summary_md.relative_to(reports_dir)}]({guard_summary_md.relative_to(reports_dir)})")
        if guard_summary_html.exists():
            lines.append(f"- Guard summary (html): [{guard_summary_html.relative_to(reports_dir)}]({guard_summary_html.relative_to(reports_dir)})")
        if guard_summary_json.exists():
            lines.append(f"- Guard summary (json): [{guard_summary_json.relative_to(reports_dir)}]({guard_summary_json.relative_to(reports_dir)})")
        if guard_summary_csv.exists():
            lines.append(f"- Guard summary (csv): [{guard_summary_csv.relative_to(reports_dir)}]({guard_summary_csv.relative_to(reports_dir)})")
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
