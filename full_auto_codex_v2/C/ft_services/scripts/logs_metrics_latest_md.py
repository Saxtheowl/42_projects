#!/usr/bin/env python3
"""
Render a Markdown summary for the latest metrics run (Totals + deltas + anomalies + links).
Usage: logs_metrics_latest_md.py --reports reports --suffix status_top2 --output reports/log_metrics_latest.md
"""
import argparse
import csv
import json
from pathlib import Path
from typing import Dict, Any, List


def load_totals(csv_path: Path) -> Dict[str, Any]:
    with csv_path.open(newline="") as f:
        rows = list(csv.DictReader(f))
    if not rows:
        raise SystemExit(f"{csv_path}: empty CSV")
    totals = rows[-1]
    if totals.get("log_file") != "Totals":
        raise SystemExit(f"{csv_path}: missing Totals row")
    return totals


def load_history(history_path: Path) -> List[Dict[str, Any]]:
    if not history_path.exists():
        return []
    with history_path.open(newline="") as f:
        return list(csv.DictReader(f))


def load_anomalies(anomalies_json: Path) -> List[Dict[str, Any]]:
    if not anomalies_json.exists():
        return []
    try:
        data = json.loads(anomalies_json.read_text())
        return data if isinstance(data, list) else []
    except Exception:
        return []


def main():
    parser = argparse.ArgumentParser(description="Render latest metrics summary as Markdown.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix")
    parser.add_argument("--output", default=None, help="Output MD path (default reports/log_metrics_latest.md)")
    parser.add_argument("--badge-warn", type=float, default=50.0, help="Warn threshold for overloaded_ratio")
    parser.add_argument("--badge-danger", type=float, default=80.0, help="Danger threshold for overloaded_ratio")
    parser.add_argument("--badge-label", default="metrics", help="Badge label to display")
    args = parser.parse_args()

    reports = Path(args.reports)
    base = reports / f"log_metrics_snapshot.{args.suffix}"
    csv_path = Path(f"{base}.csv")
    history_path = reports / "log_metrics_history.csv"
    anomalies_json = reports / "log_metrics_anomalies.json"
    latest_json_path = reports / "log_metrics_latest.json"
    output = Path(args.output) if args.output else reports / "log_metrics_latest.md"

    totals = load_totals(csv_path)
    history = load_history(history_path)
    anomalies = load_anomalies(anomalies_json)

    deltas = {}
    if len(history) >= 2:
        prev, curr = history[-2], history[-1]
        for key in ["status_checks", "connections", "overloaded", "overloaded_ratio"]:
            try:
                deltas[key] = float(curr.get(key, 0) or 0) - float(prev.get(key, 0) or 0)
            except Exception:
                deltas[key] = 0.0

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

    lines = ["# Latest Metrics Summary", "", f"- Suffix: `{args.suffix}`", ""]
    lines.append("## Totals")
    lines.append("")
    lines.append("| metric | value |")
    lines.append("| --- | ---: |")
    for key in ["status_checks", "connections", "overloaded", "overloaded_ratio"]:
        lines.append(f"| {key} | {totals.get(key, '')} |")

    lines.append("")
    lines.append("## Deltas vs précédent")
    lines.append("")
    if deltas:
        lines.append("| metric | delta |")
        lines.append("| --- | ---: |")
        for key, val in deltas.items():
            lines.append(f"| {key} | {val:+.2f} |")
    else:
        lines.append("Pas de deltas (historique insuffisant).")

    lines.append("")
    lines.append("## Anomalies")
    lines.append("")
    if anomalies:
        lines.append("| metric | status | prev | curr | delta_pct |")
        lines.append("| --- | --- | ---: | ---: | ---: |")
        for a in anomalies:
            lines.append(
                f"| {a.get('metric','')} | {a.get('status','')} | {a.get('prev_value','')} | {a.get('curr_value','')} | {a.get('delta_pct','')} |"
            )
    else:
        lines.append("Aucune anomalie détectée.")

    lines.append("")
    lines.append("## Badge")
    lines.append(f"- Label : **{args.badge_label}**")
    lines.append(f"- État : **{badge_state}** (warn ≥ {args.badge_warn}, alert ≥ {args.badge_danger}, précédent: {badge_prev_state or 'n/a'})")
    if badge_history:
        lines.append(
            f"- Fenêtre historique: {badge_window or 'n/a'} (delta {badge_history.get('delta_window', 0)}) — Comptage: {badge_counts or {}} — Streak actuelle: {badge_current_streak.get('length','?')} × {badge_current_streak.get('state','?')}"
        )
    if badge_ok_streak_required:
        lines.append(f"- Garde-fou streak: nécessite ok >= {badge_ok_streak_required}")
    if badge_gate:
        lines.append(f"- Gate: {badge_gate}")
    if badge_no_regression:
        lines.append(f"- Garde no-regression: activé")
    if badge_guard_status:
        lines.append("- Statut des gardes:")
        for name, status in badge_guard_status.items():
            lines.append(f"  - {name}: {status.get('result','n/a')} ({status.get('reason','')})")
    if badge_guard_summary:
        lines.append("- Synthèse gardes (ok/fail/unknown/total/window/%) :")
        for name, summary in badge_guard_summary.items():
            lines.append(
                f"  - {name}: ok={summary.get('ok',0)} ({summary.get('ok_pct','0')}%), fail={summary.get('fail',0)} ({summary.get('fail_pct','0')}%), unknown={summary.get('unknown',0)} ({summary.get('unknown_pct','0')}%), total={summary.get('total',0)}, window={summary.get('window','?')}"
            )
        lines.append("")
        lines.append("| guard | ok | fail | unknown | total | window | ok% | fail% | unknown% |")
        lines.append("| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
        for name, summary in badge_guard_summary.items():
            lines.append(
                f"| {name} | {summary.get('ok',0)} | {summary.get('fail',0)} | {summary.get('unknown',0)} | {summary.get('total',0)} | {summary.get('window','?')} | {summary.get('ok_pct','0')}% | {summary.get('fail_pct','0')}% | {summary.get('unknown_pct','0')}% |"
            )
    guard_streaks = latest_data.get("badge_guard_streaks") or {}
    if guard_streaks:
        lines.append("")
        lines.append("### Streaks des gardes")
        lines.append("| guard | current_result | current_len | longest_ok | longest_fail | longest_unknown | window |")
        lines.append("| --- | --- | ---: | ---: | ---: | ---: | ---: |")
        for name, streak in guard_streaks.items():
            longest = streak.get("longest", {})
            current = streak.get("current", {})
            lines.append(
                f"| {name} | {current.get('result','?')} | {current.get('length','?')} | {longest.get('ok',0)} | {longest.get('fail',0)} | {longest.get('unknown',0)} | {streak.get('window','?')} |"
            )
    guard_overall = latest_data.get("badge_guard_overall") or {}
    guard_overall_streak = latest_data.get("badge_guard_overall_streak") or {}
    if guard_overall:
        lines.append("")
        lines.append("### Synthèse globale des gardes")
        lines.append(
            f"- Total fenêtre {guard_overall.get('window','?')} : ok={guard_overall.get('ok',0)} ({guard_overall.get('ok_pct','0')}%), fail={guard_overall.get('fail',0)} ({guard_overall.get('fail_pct','0')}%), unknown={guard_overall.get('unknown',0)} ({guard_overall.get('unknown_pct','0')}%), total={guard_overall.get('total',0)}"
        )
    guard_delta = latest_data.get("badge_guard_delta") or {}
    guard_delta_overall = latest_data.get("badge_guard_delta_overall") or {}
    if guard_overall_streak:
        lines.append("")
        lines.append("### Streak globale des gardes")
        lines.append(
            f"- Courante: {guard_overall_streak.get('current',{}).get('result','?')} x {guard_overall_streak.get('current',{}).get('length','?')} (fenêtre {guard_overall_streak.get('window','?')}) — Longest ok={guard_overall_streak.get('longest',{}).get('ok',0)}, fail={guard_overall_streak.get('longest',{}).get('fail',0)}, unknown={guard_overall_streak.get('longest',{}).get('unknown',0)}"
        )
    if guard_delta:
        lines.append("")
        lines.append("### Évolution vs fenêtre précédente")
        lines.append("| guard | Δok | Δok% | Δfail | Δfail% | Δunknown | Δunknown% | window | delta_window |")
        lines.append("| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
        for name, delta in guard_delta.items():
            lines.append(
                f"| {name} | {delta.get('ok',0):+d} | {delta.get('ok_pct','0')}% | {delta.get('fail',0):+d} | {delta.get('fail_pct','0')}% | {delta.get('unknown',0):+d} | {delta.get('unknown_pct','0')}% | {delta.get('window','?')} | {delta.get('delta_window','?')} |"
            )
    if guard_delta_overall:
        lines.append("")
        lines.append("### Synthèse globale des deltas")
        lines.append(
            f"- Fenêtre {guard_delta_overall.get('window','?')} vs {guard_delta_overall.get('delta_window','?')} précédents: ok={guard_delta_overall.get('ok','n/a')} ({guard_delta_overall.get('ok_pct','0')}%), fail={guard_delta_overall.get('fail','n/a')} ({guard_delta_overall.get('fail_pct','0')}%), unknown={guard_delta_overall.get('unknown','n/a')} ({guard_delta_overall.get('unknown_pct','0')}%), total={guard_delta_overall.get('total','n/a')}"
        )

    lines.append("")
    lines.append("## Artefacts")
    lines.append("")
    artifacts = [
        ("CSV", Path(f"{base}.csv")),
        ("JSON", Path(f"{base}.json")),
        ("JSONL", Path(f"{base}.jsonl")),
        ("Markdown", Path(f"{base}.md")),
        ("HTML", Path(f"{base}.html")),
        ("Summary (md)", Path(f"{base}.summary.md")),
        ("Summary (html)", Path(f"{base}.summary.html")),
        ("History", history_path),
        ("Trend (md)", reports / "log_metrics_trend.md"),
        ("Trend (html)", reports / "log_metrics_trend.html"),
        ("Stats (md)", reports / "log_metrics_stats.md"),
        ("Stats (html)", reports / "log_metrics_stats.html"),
        ("Anomalies (md)", reports / "log_metrics_anomalies.md"),
        ("Anomalies (html)", reports / "log_metrics_anomalies.html"),
        ("Anomalies (json)", reports / "log_metrics_anomalies.json"),
        ("Overview (md)", reports / "log_metrics_overview.md"),
        ("Overview (html)", reports / "log_metrics_overview.html"),
        ("Latest (html)", reports / "log_metrics_latest.html"),
        ("Manifest", reports / "log_metrics_manifest.json"),
        ("Bundle", reports / "log_metrics_bundle.tar.gz"),
        ("Checksums", reports / "log_metrics_checksums.txt"),
        ("Portal", reports / "portal.html"),
        ("Index (md)", reports / "index.md"),
        ("Index (html)", reports / "index.html"),
        ("Badge (svg)", reports / "log_metrics_badge.svg"),
        ("Guard summary (md)", reports / "log_metrics_guard_summary.md"),
        ("Guard summary (html)", reports / "log_metrics_guard_summary.html"),
        ("Guard summary (json)", reports / "log_metrics_guard_summary.json"),
        ("Guard summary (csv)", reports / "log_metrics_guard_summary.csv"),
    ]
    for label, path in artifacts:
        if path.exists():
            rel = path.relative_to(reports)
            lines.append(f"- {label}: [{rel}]({rel})")

    output.write_text("\n".join(lines))
    print(f"Latest Markdown written to {output}")


if __name__ == "__main__":
    main()
