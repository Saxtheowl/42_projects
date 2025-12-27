#!/usr/bin/env python3
"""
Build a compact JSON summary for the latest metrics run.
Usage: logs_metrics_latest.py --reports reports --suffix status_top2 --output reports/log_metrics_latest.json
"""
import argparse
import csv
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Any
from collections import Counter


def load_totals(csv_path: Path) -> Dict[str, Any]:
    with csv_path.open(newline="") as f:
        rows = list(csv.DictReader(f))
    if not rows:
        raise SystemExit(f"{csv_path}: empty CSV")
    totals = rows[-1]
    if totals.get("log_file") != "Totals":
        raise SystemExit(f"{csv_path}: missing Totals row")
    return {
        "timestamp": totals.get("timestamp"),
        "status_checks": float(totals.get("status_checks", 0) or 0),
        "connections": float(totals.get("connections", 0) or 0),
        "overloaded": float(totals.get("overloaded", 0) or 0),
        "overloaded_ratio": float(totals.get("overloaded_ratio", 0) or 0),
    }


def load_history_count(history_path: Path) -> int:
    if not history_path.exists():
        return 0
    with history_path.open(newline="") as f:
        return sum(1 for _ in csv.DictReader(f))


def load_history_rows(history_path: Path):
    if not history_path.exists():
        return []
    with history_path.open(newline="") as f:
        return list(csv.DictReader(f))


def load_anomalies(anomalies_json: Path):
    if not anomalies_json.exists():
        return []
    try:
        data = json.loads(anomalies_json.read_text())
        return data if isinstance(data, list) else []
    except Exception:
        return []


def main():
    parser = argparse.ArgumentParser(description="Generate a JSON summary for the latest metrics snapshot.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix (pattern_topN)")
    parser.add_argument("--output", default=None, help="Output path (default reports/log_metrics_latest.json)")
    parser.add_argument("--badge-history", default=None, help="Badge history CSV path (default reports/log_metrics_badge_history.csv)")
    parser.add_argument("--badge-history-last", type=int, default=0, help="Number of latest badge history entries to expose (0 = all)")
    parser.add_argument(
        "--badge-history-delta-last",
        type=int,
        default=0,
        help="Number of entries used for the previous window when computing deltas (0 = match history window)",
    )
    parser.add_argument("--badge-warn", type=float, default=50.0, help="Warn threshold for overloaded_ratio")
    parser.add_argument("--badge-danger", type=float, default=80.0, help="Danger threshold for overloaded_ratio")
    parser.add_argument("--badge-label", default="metrics", help="Badge label")
    parser.add_argument("--badge-ok-streak", type=int, default=0, help="Required OK streak (for gating)")
    parser.add_argument("--badge-gate", default="", help="Badge gate level (warn|alert) used for gating")
    parser.add_argument("--badge-no-regression", action="store_true", help="Record that no-regression guard is enabled")
    args = parser.parse_args()

    reports = Path(args.reports)
    base = reports / f"log_metrics_snapshot.{args.suffix}"
    csv_path = Path(f"{base}.csv")
    history_path = reports / "log_metrics_history.csv"
    anomalies_json = reports / "log_metrics_anomalies.json"
    output = Path(args.output) if args.output else reports / "log_metrics_latest.json"

    if not csv_path.exists():
        raise SystemExit(f"CSV not found: {csv_path}")

    snapshot_totals = load_totals(csv_path)
    anomalies = load_anomalies(anomalies_json)
    flagged_anomalies = [a for a in anomalies if str(a.get("status")).upper() != "OK"]
    history_count = load_history_count(history_path)
    history_rows = load_history_rows(history_path)
    deltas = {}
    if len(history_rows) >= 2:
        prev, curr = history_rows[-2], history_rows[-1]
        for key in ["status_checks", "connections", "overloaded", "overloaded_ratio"]:
            try:
                deltas[key] = float(curr.get(key, 0) or 0) - float(prev.get(key, 0) or 0)
            except Exception:
                deltas[key] = 0.0

    badge_history_path = Path(args.badge_history) if args.badge_history else reports / "log_metrics_badge_history.csv"
    badge_history_summary = None
    previous_state = None
    guard_summary = None
    guard_overall = None
    guard_overall_streak = None
    guard_delta = None
    guard_delta_overall = None
    guard_streaks = None
    if badge_history_path.exists():
        try:
            with badge_history_path.open(newline="") as f:
                rows = list(csv.DictReader(f))
            subset = rows[-args.badge_history_last :] if args.badge_history_last and args.badge_history_last > 0 else rows
            window_len = len(subset)
            delta_window_len = args.badge_history_delta_last if args.badge_history_delta_last and args.badge_history_delta_last > 0 else window_len
            prev_subset = []
            counts = Counter(r.get("badge_state", "n/a") for r in subset)
            last_entry = subset[-1] if subset else {}
            current_state = str(last_entry.get("badge_state", "n/a")).lower() if subset else "n/a"
            current_streak = 0
            for r in reversed(subset):
                if str(r.get("badge_state", "n/a")).lower() == current_state:
                    current_streak += 1
                else:
                    break
            longest = Counter()
            run = Counter()
            for r in subset:
                s = str(r.get("badge_state", "n/a")).lower()
                run[s] += 1
                for other in list(run.keys()):
                    if other != s:
                        run[other] = 0
                longest[s] = max(longest[s], run[s])
            previous_entry = subset[-2] if len(subset) >= 2 else (rows[-2] if len(rows) >= 2 else None)
            previous_state = str(previous_entry.get("badge_state", "n/a")).lower() if previous_entry else None
            guard_fields = {
                "gate": "guard_gate_result",
                "ok_streak": "guard_ok_result",
                "no_regression": "guard_no_regression_result",
            }
            guard_counts = {k: Counter() for k in guard_fields}
            aggregate_states = []
            for r in subset:
                for name, field in guard_fields.items():
                    val = str(r.get(field, "") or "").lower()
                    if val not in ("ok", "fail"):
                        val = "unknown"
                    guard_counts[name][val] += 1
                vals_row = []
                for _, field in guard_fields.items():
                    val = str(r.get(field, "") or "").lower()
                    if val not in ("ok", "fail"):
                        val = "unknown"
                    vals_row.append(val)
                if any(v == "fail" for v in vals_row):
                    aggregate_states.append("fail")
                elif all(v == "ok" for v in vals_row):
                    aggregate_states.append("ok")
                else:
                    aggregate_states.append("unknown")
            guard_streaks = {}
            for name, field in guard_fields.items():
                current_result = None
                current_len = 0
                for r in reversed(subset):
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
                for r in subset:
                    val = str(r.get(field, "") or "").lower()
                    if val not in ("ok", "fail"):
                        val = "unknown"
                    for k in running:
                        running[k] = running[k] + 1 if k == val else 0
                        longest[k] = max(longest[k], running[k])
                guard_streaks[name] = {
                    "current": {"result": current_result or "unknown", "length": current_len},
                    "longest": longest,
                    "window": window_len,
                }
            guard_summary = {
                name: {
                    "ok": guard_counts[name].get("ok", 0),
                    "fail": guard_counts[name].get("fail", 0),
                    "unknown": guard_counts[name].get("unknown", 0),
                    "total": sum(guard_counts[name].values()),
                    "window": window_len,
                    "ok_pct": round((guard_counts[name].get("ok", 0) / sum(guard_counts[name].values()) * 100) if sum(guard_counts[name].values()) else 0.0, 1),
                    "fail_pct": round((guard_counts[name].get("fail", 0) / sum(guard_counts[name].values()) * 100) if sum(guard_counts[name].values()) else 0.0, 1),
                    "unknown_pct": round((guard_counts[name].get("unknown", 0) / sum(guard_counts[name].values()) * 100) if sum(guard_counts[name].values()) else 0.0, 1),
                }
                for name in guard_counts
            }
            guard_delta = None
            guard_delta_overall = None
            prev_subset = []
            if window_len > 0 and delta_window_len > 0 and len(rows) >= window_len + delta_window_len:
                prev_subset = rows[-(window_len + delta_window_len) : -window_len]
                prev_counts = {k: Counter() for k in guard_fields}
                prev_aggregate_states = []
                for r in prev_subset:
                    for name, field in guard_fields.items():
                        val = str(r.get(field, "") or "").lower()
                        if val not in ("ok", "fail"):
                            val = "unknown"
                        prev_counts[name][val] += 1
                    vals_row = []
                    for _, field in guard_fields.items():
                        val = str(r.get(field, "") or "").lower()
                        if val not in ("ok", "fail"):
                            val = "unknown"
                        vals_row.append(val)
                    if any(v == "fail" for v in vals_row):
                        prev_aggregate_states.append("fail")
                    elif all(v == "ok" for v in vals_row):
                        prev_aggregate_states.append("ok")
                    else:
                        prev_aggregate_states.append("unknown")
                guard_delta = {
                    name: {
                        "ok": guard_counts[name].get("ok", 0) - prev_counts[name].get("ok", 0),
                        "fail": guard_counts[name].get("fail", 0) - prev_counts[name].get("fail", 0),
                        "unknown": guard_counts[name].get("unknown", 0) - prev_counts[name].get("unknown", 0),
                        "window": window_len,
                        "delta_window": len(prev_subset),
                        "ok_pct": round(((guard_counts[name].get("ok", 0) - prev_counts[name].get("ok", 0)) / (sum(prev_counts[name].values()) or 1)) * 100, 1),
                        "fail_pct": round(((guard_counts[name].get("fail", 0) - prev_counts[name].get("fail", 0)) / (sum(prev_counts[name].values()) or 1)) * 100, 1),
                        "unknown_pct": round(((guard_counts[name].get("unknown", 0) - prev_counts[name].get("unknown", 0)) / (sum(prev_counts[name].values()) or 1)) * 100, 1),
                    }
                    for name in guard_counts
                }
                prev_counts_total = Counter(prev_aggregate_states)
                prev_total_all = sum(prev_counts_total.values()) or 1
                guard_delta_overall = {
                    "ok": aggregate_states.count("ok") - prev_counts_total.get("ok", 0),
                    "fail": aggregate_states.count("fail") - prev_counts_total.get("fail", 0),
                    "unknown": aggregate_states.count("unknown") - prev_counts_total.get("unknown", 0),
                    "window": len(aggregate_states),
                    "delta_window": len(prev_aggregate_states),
                }
                guard_delta_overall["total"] = guard_delta_overall["ok"] + guard_delta_overall["fail"] + guard_delta_overall["unknown"]
                guard_delta_overall["ok_pct"] = round((guard_delta_overall["ok"] / prev_total_all) * 100, 1)
                guard_delta_overall["fail_pct"] = round((guard_delta_overall["fail"] / prev_total_all) * 100, 1)
                guard_delta_overall["unknown_pct"] = round((guard_delta_overall["unknown"] / prev_total_all) * 100, 1)
            # Overall percentages across guards (row-level aggregation)
            aggregate_counts = Counter(aggregate_states)
            totals_sum = sum(aggregate_counts.values())
            guard_overall = {
                "ok": aggregate_counts.get("ok", 0),
                "fail": aggregate_counts.get("fail", 0),
                "unknown": aggregate_counts.get("unknown", 0),
                "total": totals_sum,
                "window": len(aggregate_states),
                "ok_pct": round((aggregate_counts.get("ok", 0) / totals_sum * 100) if totals_sum else 0.0, 1),
                "fail_pct": round((aggregate_counts.get("fail", 0) / totals_sum * 100) if totals_sum else 0.0, 1),
                "unknown_pct": round((aggregate_counts.get("unknown", 0) / totals_sum * 100) if totals_sum else 0.0, 1),
            }
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
            guard_overall_streak = {
                "current": {"result": current_overall or "unknown", "length": current_overall_len},
                "longest": longest_overall,
                "window": len(subset),
            }
            badge_history_summary = {
                "entries": len(rows),
                "window": window_len,
                "delta_window": len(prev_subset) if guard_delta else 0,
                "counts": dict(counts),
                "last": last_entry,
                "current_streak": {"state": current_state, "length": current_streak},
                "longest_streaks": dict(longest),
                "previous": previous_entry,
                "previous_state": previous_state,
                "last_transition": {"from": previous_state, "to": current_state} if previous_state else None,
                "path": str(badge_history_path.relative_to(reports)),
            }
        except Exception:
            badge_history_summary = {"error": "unable to read badge history"}

    overloaded_ratio = snapshot_totals.get("overloaded_ratio", 0.0)
    badge_state = "ok"
    if len(flagged_anomalies) > 0 or overloaded_ratio >= args.badge_danger:
        badge_state = "alert"
    elif overloaded_ratio >= args.badge_warn:
        badge_state = "warn"

    order = {"ok": 0, "warn": 1, "alert": 2}
    guard_status = {}
    # Gate guard
    if args.badge_gate:
        gate = str(args.badge_gate).lower()
        state_rank = order.get(badge_state, 0)
        gate_rank = order.get(gate, 1)
        fail = state_rank >= gate_rank
        guard_status["gate"] = {
            "required": gate,
            "state": badge_state,
            "result": "fail" if fail else "ok",
            "reason": f"state {badge_state} {'exceeds' if fail else '<'} gate {gate}",
        }
    # OK streak guard
    if args.badge_ok_streak:
        current = (badge_history_summary or {}).get("current_streak") or {}
        length = int(current.get("length", 0) or 0)
        state = str(current.get("state", "")).lower()
        fail = not (state == "ok" and length >= args.badge_ok_streak)
        guard_status["ok_streak"] = {
            "required": args.badge_ok_streak,
            "state": state,
            "length": length,
            "result": "fail" if fail else "ok",
            "reason": f"state={state}, streak={length}, required ok>={args.badge_ok_streak}",
        }
    # No-regression guard
    if args.badge_no_regression:
        prev_state = previous_state
        if prev_state is None:
            guard_status["no_regression"] = {"result": "unknown", "reason": "no previous state"}
        else:
            fail = order.get(badge_state, 0) > order.get(prev_state, 0)
            guard_status["no_regression"] = {
                "previous": prev_state,
                "current": badge_state,
                "result": "fail" if fail else "ok",
                "reason": f"{prev_state} -> {badge_state}",
            }

    summary = {
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "suffix": args.suffix,
        "reports_dir": str(reports),
        "totals": snapshot_totals,
        "deltas": deltas if deltas else None,
        "history_count": history_count,
        "anomalies_count": len(flagged_anomalies),
        "anomalies_flagged_count": len(flagged_anomalies),
        "anomalies_total": len(anomalies),
        "anomalies": anomalies,
        "badge_state": badge_state,
        "badge_previous_state": previous_state,
        "badge_label": args.badge_label,
        "badge_thresholds": {"warn": args.badge_warn, "danger": args.badge_danger},
        "badge_ok_streak_required": args.badge_ok_streak or None,
        "badge_guards": {
            "gate": args.badge_gate or None,
            "ok_streak": args.badge_ok_streak or None,
            "no_regression": bool(args.badge_no_regression),
        },
        "badge_guard_status": guard_status or None,
        "badge_history": badge_history_summary,
        "badge_guard_summary": guard_summary,
        "badge_guard_overall": guard_overall,
        "badge_guard_delta": guard_delta,
        "badge_guard_delta_overall": guard_delta_overall,
        "badge_guard_streaks": guard_streaks,
        "badge_guard_overall_streak": guard_overall_streak,
        "artifacts": {
            "csv": str(csv_path.relative_to(reports)),
            "json": str(Path(f"{base}.json").relative_to(reports)),
            "jsonl": str(Path(f"{base}.jsonl").relative_to(reports)),
            "markdown": str(Path(f"{base}.md").relative_to(reports)),
            "html": str(Path(f"{base}.html").relative_to(reports)),
            "summary_md": str(Path(f"{base}.summary.md").relative_to(reports)),
            "summary_html": str(Path(f"{base}.summary.html").relative_to(reports)),
            "history": str(history_path.relative_to(reports)) if history_path.exists() else None,
            "trend_md": "log_metrics_trend.md",
            "trend_html": "log_metrics_trend.html",
            "stats_md": "log_metrics_stats.md",
            "stats_html": "log_metrics_stats.html",
            "anomalies_md": "log_metrics_anomalies.md",
            "anomalies_html": "log_metrics_anomalies.html",
            "anomalies_json": "log_metrics_anomalies.json",
            "overview_md": "log_metrics_overview.md",
            "overview_html": "log_metrics_overview.html",
            "manifest": "log_metrics_manifest.json",
            "bundle": "log_metrics_bundle.tar.gz",
            "checksums": "log_metrics_checksums.txt",
            "portal": "portal.html",
            "index_md": "index.md",
            "index_html": "index.html",
            "badge_svg": "log_metrics_badge.svg",
            "guard_summary_md": "log_metrics_guard_summary.md" if (reports / "log_metrics_guard_summary.md").exists() else None,
            "guard_summary_html": "log_metrics_guard_summary.html" if (reports / "log_metrics_guard_summary.html").exists() else None,
            "guard_summary_json": "log_metrics_guard_summary.json" if (reports / "log_metrics_guard_summary.json").exists() else None,
            "guard_summary_csv": "log_metrics_guard_summary.csv" if (reports / "log_metrics_guard_summary.csv").exists() else None,
        },
    }
    output.write_text(json.dumps(summary, indent=2))
    print(f"Latest summary written to {output}")


if __name__ == "__main__":
    main()
