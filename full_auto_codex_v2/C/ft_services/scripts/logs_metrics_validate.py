#!/usr/bin/env python3
"""
Validate that all expected metrics artifacts exist and contain a Totals entry.
Usage: logs_metrics_validate.py --reports reports --suffix status_top2
Exits 1 on missing artifacts or missing Totals.
"""
import argparse
import csv
import json
from pathlib import Path


def check_csv(path: Path):
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    if not rows:
        raise SystemExit(f"{path}: empty CSV")
    if rows[-1].get("log_file") != "Totals":
        raise SystemExit(f"{path}: missing Totals line")


def check_json(path: Path):
    data = json.loads(path.read_text())
    if not data:
        raise SystemExit(f"{path}: empty JSON")
    if data[-1].get("log_file") != "Totals":
        raise SystemExit(f"{path}: missing Totals entry")


def check_summary(path: Path):
    content = path.read_text()
    if "Log Metrics Summary" not in content:
        raise SystemExit(f"{path}: missing summary header")
    if "| status_checks" not in content or "| connections" not in content:
        raise SystemExit(f"{path}: missing metrics rows")


def check_stats(path: Path):
    content = path.read_text()
    if "Log Metrics Stats" not in content:
        raise SystemExit(f"{path}: missing stats header")
    if "| metric | min | avg | max | latest |" not in content:
        raise SystemExit(f"{path}: missing stats table")


def check_portal(path: Path):
    if "<h1>Log Metrics Portal</h1>" not in path.read_text():
        raise SystemExit(f"{path}: missing portal header")


def check_trend_html(path: Path):
    if "<h1>Log Metrics Trend</h1>" not in path.read_text():
        raise SystemExit(f"{path}: missing trend header")


def check_stats_html(path: Path):
    if "<h1>Log Metrics Stats</h1>" not in path.read_text():
        raise SystemExit(f"{path}: missing stats HTML header")
    if "<table>" not in path.read_text():
        raise SystemExit(f"{path}: missing stats HTML table")

def check_anomalies(path: Path):
    if "Log Metrics Anomalies" not in path.read_text():
        raise SystemExit(f"{path}: missing anomalies header")


def check_anomalies_html(path: Path):
    text = path.read_text()
    if "<h1>Log Metrics Anomalies</h1>" not in text or "<table>" not in text:
        raise SystemExit(f"{path}: missing anomalies HTML content")


def check_anomalies_json(path: Path):
    import json

    data = json.loads(path.read_text())
    if not isinstance(data, list):
        raise SystemExit(f"{path}: anomalies JSON not a list")


def check_manifest(manifest_path: Path, reports_dir: Path):
    import json

    if not manifest_path.exists():
        raise SystemExit(f"{manifest_path}: missing manifest")
    data = json.loads(manifest_path.read_text())
    if "paths" not in data:
        raise SystemExit(f"{manifest_path}: missing paths entry")
    required_keys = [
        "csv",
        "json",
        "jsonl",
        "md",
        "html",
        "summary",
        "history",
        "trend_md",
        "trend_html",
        "stats_md",
        "stats_html",
        "anomalies_md",
        "anomalies_html",
        "anomalies_json",
        "index_md",
        "index_html",
        "portal",
        "bundle",
        "manifest",
        "checksums",
        "overview",
        "overview_md",
        "overview_html",
        "badge_svg",
    ]
    for key in required_keys:
        entry = data["paths"].get(key)
        if not entry:
            raise SystemExit(f"{manifest_path}: missing entry for {key}")
        if key == "checksums":
            continue
        declared_exists = entry.get("exists")
        rel_path = entry.get("path")
        abs_path = reports_dir / rel_path if rel_path else None
        actual_exists = abs_path.exists() if abs_path else False
        if declared_exists != actual_exists:
            raise SystemExit(f"{manifest_path}: mismatch for {key} (manifest exists={declared_exists}, actual={actual_exists})")
        if key == "checksums":
            continue
        if declared_exists and abs_path and "sha256" in entry and entry.get("sha256"):
            import hashlib
            h = hashlib.sha256()
            with abs_path.open("rb") as f:
                for chunk in iter(lambda: f.read(8192), b""):
                    h.update(chunk)
            digest = h.hexdigest()
            if digest != entry["sha256"]:
                raise SystemExit(f"{manifest_path}: sha256 mismatch for {key}")


def check_latest(latest_path: Path, csv_path: Path, reports_dir: Path):
    import json
    import csv

    if not latest_path.exists():
        raise SystemExit(f"{latest_path}: missing latest summary")
    data = json.loads(latest_path.read_text())
    suffix = data.get("suffix")
    if not suffix:
        raise SystemExit(f"{latest_path}: missing suffix")

    with csv_path.open(newline="") as f:
        rows = list(csv.DictReader(f))
    if not rows:
        raise SystemExit(f"{csv_path}: empty CSV")
    totals_row = rows[-1]
    if totals_row.get("log_file") != "Totals":
        raise SystemExit(f"{csv_path}: missing Totals row")

    def to_float(val):
        try:
            return float(val)
        except Exception:
            return 0.0

    totals = data.get("totals") or {}
    for key in ["status_checks", "connections", "overloaded", "overloaded_ratio"]:
        expected = to_float(totals_row.get(key))
        got = to_float(totals.get(key))
        if abs(expected - got) > 1e-6:
            raise SystemExit(f"{latest_path}: totals mismatch for {key} (csv={expected}, latest={got})")

    # Check deltas if provided and history allows
    history_path = reports_dir / "log_metrics_history.csv"
    if history_path.exists():
        with history_path.open(newline="") as f:
            hist_rows = list(csv.DictReader(f))
        if len(hist_rows) >= 2:
            prev, curr = hist_rows[-2], hist_rows[-1]
            deltas = latest_path and json.loads(latest_path.read_text()).get("deltas", {})
            for key in ["status_checks", "connections", "overloaded", "overloaded_ratio"]:
                try:
                    expected_delta = float(curr.get(key, 0) or 0) - float(prev.get(key, 0) or 0)
                    actual_delta = float(deltas.get(key, 0) or 0)
                except Exception:
                    continue
                if abs(expected_delta - actual_delta) > 1e-6:
                    raise SystemExit(f"{latest_path}: delta mismatch for {key} (history={expected_delta}, latest={actual_delta})")

    anomalies = data.get("anomalies", [])
    anomalies_count = data.get("anomalies_count")
    if anomalies_count is not None and anomalies_count != len(anomalies):
        raise SystemExit(f"{latest_path}: anomalies_count mismatch (declared {anomalies_count}, got {len(anomalies)})")

    guards = data.get("badge_guards") or {}
    if guards:
        gate = guards.get("gate")
        if gate and gate not in {"warn", "alert"}:
            raise SystemExit(f"{latest_path}: invalid badge gate '{gate}' (expected warn|alert)")
        ok_guard = guards.get("ok_streak")
        required_ok = data.get("badge_ok_streak_required")
        if ok_guard and required_ok and int(ok_guard) != int(required_ok):
            raise SystemExit(f"{latest_path}: badge ok-streak guard mismatch (guards={ok_guard}, required={required_ok})")
        if "no_regression" in guards and not isinstance(guards.get("no_regression"), bool):
            raise SystemExit(f"{latest_path}: badge no_regression guard must be boolean")

    # Guard summary validation vs badge_history if present
    guard_summary = data.get("badge_guard_summary") or {}
    guard_overall = data.get("badge_guard_overall") or {}
    guard_delta = data.get("badge_guard_delta") or {}
    guard_delta_overall = data.get("badge_guard_delta_overall") or {}
    badge_history_path = reports_dir / "log_metrics_badge_history.csv"
    if guard_summary and badge_history_path.exists():
        with badge_history_path.open(newline="") as f:
            hist_rows = list(csv.DictReader(f))
        guard_fields = {
            "gate": "guard_gate_result",
            "ok_streak": "guard_ok_result",
            "no_regression": "guard_no_regression_result",
        }
        recomputed = {k: {"ok": 0, "fail": 0, "unknown": 0} for k in guard_fields}
        window_len = data.get("badge_history", {}).get("window", len(hist_rows)) or len(hist_rows)
        subset = hist_rows[-window_len:]
        delta_window_len = (
            int((guard_delta_overall or {}).get("delta_window", 0) or 0)
            or int(next(iter((guard_delta or {}).values()), {}).get("delta_window", 0) or 0)
            or int((data.get("badge_history") or {}).get("delta_window", 0) or 0)
        )
        if delta_window_len == 0:
            delta_window_len = window_len
        prev_subset = (
            hist_rows[-(window_len + delta_window_len) : -window_len]
            if window_len > 0 and delta_window_len > 0 and len(hist_rows) >= window_len + delta_window_len
            else []
        )
        prev_counts = {k: {"ok": 0, "fail": 0, "unknown": 0} for k in guard_fields}
        for r in subset:
            for name, field in guard_fields.items():
                val = str(r.get(field, "") or "").lower()
                if val not in ("ok", "fail"):
                    val = "unknown"
                recomputed[name][val] = recomputed[name].get(val, 0) + 1
        for r in prev_subset:
            for name, field in guard_fields.items():
                val = str(r.get(field, "") or "").lower()
                if val not in ("ok", "fail"):
                    val = "unknown"
                prev_counts[name][val] = prev_counts[name].get(val, 0) + 1
        totals_guard = {"ok": 0, "fail": 0, "unknown": 0}
        totals_delta = {"ok": 0, "fail": 0, "unknown": 0}
        # Guard streaks validation
        guard_streaks = data.get("badge_guard_streaks") or {}
        # Recompute streaks from history subset
        recomputed_streaks = {}
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
            recomputed_streaks[name] = {
                "current": {"result": current_result or "unknown", "length": current_len},
                "longest": longest,
                "window": window_len,
            }

        for name, counts in recomputed.items():
            expected = guard_summary.get(name) or {}
            if int(expected.get("window", window_len) or 0) != window_len:
                raise SystemExit(
                    f"{latest_path}: guard summary window mismatch for {name} (latest={expected.get('window')}, expected={window_len})"
                )
            for key in ("ok", "fail", "unknown"):
                if int(expected.get(key, 0) or 0) != counts.get(key, 0):
                    raise SystemExit(f"{latest_path}: guard summary mismatch for {name}/{key} (latest={expected.get(key)}, hist={counts.get(key)})")
            total = sum(counts.values())
            totals_guard["ok"] += counts.get("ok", 0)
            totals_guard["fail"] += counts.get("fail", 0)
            totals_guard["unknown"] += counts.get("unknown", 0)
            pct_sum = 0.0
            for pct_key, num_key in (("ok_pct", "ok"), ("fail_pct", "fail"), ("unknown_pct", "unknown")):
                latest_pct = float(expected.get(pct_key, 0) or 0)
                recomputed_pct = round((counts.get(num_key, 0) / total * 100) if total else 0.0, 1)
                pct_sum += latest_pct
                if abs(latest_pct - recomputed_pct) > 0.05:
                    raise SystemExit(
                        f"{latest_path}: guard summary percent mismatch for {name}/{pct_key} (latest={latest_pct}, hist={recomputed_pct})"
                    )
            if pct_sum > 100.2 or pct_sum < 99.8:
                raise SystemExit(f"{latest_path}: guard summary percentages for {name} do not sum to 100 (got {pct_sum})")
            if guard_streaks:
                streak = guard_streaks.get(name) or {}
                # Current streak
                current_result = None
                current_len = 0
                for r in reversed(subset):
                    val = str(r.get(guard_fields[name], "") or "").lower()
                    if val not in ("ok", "fail"):
                        val = "unknown"
                    if current_result is None:
                        current_result = val
                        current_len = 1
                    elif val == current_result:
                        current_len += 1
                    else:
                        break
                if int(streak.get("window", window_len) or 0) != window_len:
                    raise SystemExit(
                        f"{latest_path}: guard streak window mismatch for {name} (latest={streak.get('window')}, expected={window_len})"
                    )
                current_expected = streak.get("current") or {}
                if (current_expected.get("result") or "unknown").lower() != (current_result or "unknown"):
                    raise SystemExit(
                        f"{latest_path}: guard streak current result mismatch for {name} (latest={current_expected.get('result')}, expected={current_result})"
                    )
                if int(current_expected.get("length", 0) or 0) != current_len:
                    raise SystemExit(
                        f"{latest_path}: guard streak current length mismatch for {name} (latest={current_expected.get('length')}, expected={current_len})"
                    )
                longest_expected = streak.get("longest") or {}
                running = {"ok": 0, "fail": 0, "unknown": 0}
                longest_calc = {"ok": 0, "fail": 0, "unknown": 0}
                for r in subset:
                    val = str(r.get(guard_fields[name], "") or "").lower()
                    if val not in ("ok", "fail"):
                        val = "unknown"
                    for k in running:
                        running[k] = running[k] + 1 if k == val else 0
                        longest_calc[k] = max(longest_calc[k], running[k])
                for key in ("ok", "fail", "unknown"):
                    if int(longest_expected.get(key, 0) or 0) != longest_calc.get(key, 0):
                        raise SystemExit(
                            f"{latest_path}: guard longest streak mismatch for {name}/{key} (latest={longest_expected.get(key)}, expected={longest_calc.get(key)})"
                        )
        # Guard streaks in latest JSON (if present)
        if guard_streaks:
            for name, streak_calc in recomputed_streaks.items():
                latest_streak = guard_streaks.get(name) or {}
                if int(latest_streak.get("window", window_len) or 0) != window_len:
                    raise SystemExit(
                        f"{latest_path}: guard streak window mismatch for {name} (latest={latest_streak.get('window')}, expected={window_len})"
                    )
                current_latest = latest_streak.get("current", {}) or {}
                current_calc = streak_calc.get("current", {}) or {}
                if (current_latest.get("result") or "unknown").lower() != (current_calc.get("result") or "unknown"):
                    raise SystemExit(
                        f"{latest_path}: guard streak current result mismatch for {name} (latest={current_latest.get('result')}, expected={current_calc.get('result')})"
                    )
                if int(current_latest.get("length", 0) or 0) != int(current_calc.get("length", 0) or 0):
                    raise SystemExit(
                        f"{latest_path}: guard streak current length mismatch for {name} (latest={current_latest.get('length')}, expected={current_calc.get('length')})"
                    )
                longest_latest = latest_streak.get("longest", {}) or {}
                longest_calc = streak_calc.get("longest", {}) or {}
                for key in ("ok", "fail", "unknown"):
                    if int(longest_latest.get(key, 0) or 0) != int(longest_calc.get(key, 0) or 0):
                        raise SystemExit(
                            f"{latest_path}: guard streak longest {key} mismatch for {name} (latest={longest_latest.get(key)}, expected={longest_calc.get(key)})"
                        )
            # Delta check vs previous window when available
            if prev_subset and guard_delta:
                delta_expected = guard_delta.get(name) or {}
                delta_ok = counts.get("ok", 0) - prev_counts.get(name, {}).get("ok", 0)
                delta_fail = counts.get("fail", 0) - prev_counts.get(name, {}).get("fail", 0)
                delta_unknown = counts.get("unknown", 0) - prev_counts.get(name, {}).get("unknown", 0)
                totals_delta["ok"] += delta_ok
                totals_delta["fail"] += delta_fail
                totals_delta["unknown"] += delta_unknown
                for key, val in (("ok", delta_ok), ("fail", delta_fail), ("unknown", delta_unknown)):
                    if int(delta_expected.get(key, 0) or 0) != val:
                        raise SystemExit(
                            f"{latest_path}: guard delta mismatch for {name}/{key} (latest={delta_expected.get(key)}, hist_delta={val})"
                        )
                if int(delta_expected.get("window", window_len) or 0) != window_len:
                    raise SystemExit(
                        f"{latest_path}: guard delta window mismatch for {name} (latest={delta_expected.get('window')}, expected={window_len})"
                    )
                if int(delta_expected.get("delta_window", delta_window_len) or 0) != len(prev_subset):
                    raise SystemExit(
                        f"{latest_path}: guard delta previous window mismatch for {name} (latest={delta_expected.get('delta_window')}, expected={len(prev_subset)})"
                    )
                if prev_counts.get(name):
                    prev_total = sum(prev_counts[name].values()) or 1
                    for pct_key, num_key in (("ok_pct", "ok"), ("fail_pct", "fail"), ("unknown_pct", "unknown")):
                        latest_pct = float(delta_expected.get(pct_key, 0) or 0)
                        recomputed_pct = round((delta_expected.get(num_key, 0) / prev_total * 100), 1)
                        if abs(latest_pct - recomputed_pct) > 0.05:
                            raise SystemExit(
                                f"{latest_path}: guard delta percent mismatch for {name}/{pct_key} (latest={latest_pct}, hist_delta_pct={recomputed_pct})"
                            )
        # Overall check (counts and pct)
        total_all = totals_guard["ok"] + totals_guard["fail"] + totals_guard["unknown"]
        if guard_overall:
            if int(guard_overall.get("window", window_len) or 0) != window_len:
                raise SystemExit(
                    f"{latest_path}: guard overall window mismatch (latest={guard_overall.get('window')}, expected={window_len})"
                )
            for key in ("ok", "fail", "unknown"):
                if int(guard_overall.get(key, 0) or 0) != totals_guard.get(key, 0):
                    raise SystemExit(
                        f"{latest_path}: guard overall mismatch for {key} (latest={guard_overall.get(key)}, hist={totals_guard.get(key)})"
                    )
            if int(guard_overall.get("total", 0) or 0) != total_all:
                raise SystemExit(
                    f"{latest_path}: guard overall total mismatch (latest={guard_overall.get('total')}, hist={total_all})"
                )
            pct_sum_overall = 0.0
            for pct_key, num_key in (("ok_pct", "ok"), ("fail_pct", "fail"), ("unknown_pct", "unknown")):
                latest_pct = float(guard_overall.get(pct_key, 0) or 0)
                recomputed_pct = round((totals_guard.get(num_key, 0) / total_all * 100) if total_all else 0.0, 1)
                pct_sum_overall += latest_pct
                if abs(latest_pct - recomputed_pct) > 0.05:
                    raise SystemExit(
                        f"{latest_path}: guard overall percent mismatch for {pct_key} (latest={latest_pct}, hist={recomputed_pct})"
                    )
            if pct_sum_overall > 100.2 or pct_sum_overall < 99.8:
                raise SystemExit(f"{latest_path}: guard overall percentages do not sum to 100 (got {pct_sum_overall})")
        # Delta overall check
        if guard_delta_overall and prev_subset:
            prev_total_all = sum(sum(prev_counts[name].values()) for name in prev_counts) or 1
            # Recompute delta totals to avoid drift if loop skipped entries
            delta_totals = {"ok": 0, "fail": 0, "unknown": 0}
            for name in guard_fields:
                delta_totals["ok"] += (recomputed[name].get("ok", 0) - prev_counts.get(name, {}).get("ok", 0))
                delta_totals["fail"] += (recomputed[name].get("fail", 0) - prev_counts.get(name, {}).get("fail", 0))
                delta_totals["unknown"] += (recomputed[name].get("unknown", 0) - prev_counts.get(name, {}).get("unknown", 0))
            delta_total_all = delta_totals["ok"] + delta_totals["fail"] + delta_totals["unknown"]
            if int(guard_delta_overall.get("window", window_len) or 0) != window_len:
                raise SystemExit(
                    f"{latest_path}: guard delta overall window mismatch (latest={guard_delta_overall.get('window')}, expected={window_len})"
                )
            if int(guard_delta_overall.get("delta_window", delta_window_len) or 0) != len(prev_subset):
                raise SystemExit(
                    f"{latest_path}: guard delta overall previous window mismatch (latest={guard_delta_overall.get('delta_window')}, expected={len(prev_subset)})"
                )
            for key in ("ok", "fail", "unknown"):
                if int(guard_delta_overall.get(key, 0) or 0) != delta_totals.get(key, 0):
                    raise SystemExit(
                        f"{latest_path}: guard delta overall mismatch for {key} (latest={guard_delta_overall.get(key)}, hist={delta_totals.get(key)})"
                    )
            if int(guard_delta_overall.get("total", 0) or 0) != delta_total_all:
                raise SystemExit(
                    f"{latest_path}: guard delta overall total mismatch (latest={guard_delta_overall.get('total')}, hist={delta_total_all})"
                )
            pct_sum_delta = 0.0
            for pct_key, num_key in (("ok_pct", "ok"), ("fail_pct", "fail"), ("unknown_pct", "unknown")):
                latest_pct = float(guard_delta_overall.get(pct_key, 0) or 0)
                recomputed_pct = round((delta_totals.get(num_key, 0) / prev_total_all * 100), 1)
                pct_sum_delta += latest_pct
                if abs(latest_pct - recomputed_pct) > 0.05:
                    raise SystemExit(
                        f"{latest_path}: guard delta overall percent mismatch for {pct_key} (latest={latest_pct}, hist={recomputed_pct})"
                    )
            if delta_total_all != 0 and (pct_sum_delta > 100.2 or pct_sum_delta < 99.8):
                raise SystemExit(f"{latest_path}: guard delta overall percentages do not sum to 100 (got {pct_sum_delta})")
        # If guard summary CSV exists, ensure it matches recomputed counts
        guard_summary_csv = reports_dir / "log_metrics_guard_summary.csv"
        if guard_summary_csv.exists():
            with guard_summary_csv.open(newline="") as f:
                csv_rows = list(csv.DictReader(f))
            csv_counts = {}
            for r in csv_rows:
                name = r.get("guard")
                if not name:
                    continue
                window_csv = int(r.get("window", 0) or 0)
                csv_counts[name] = {
                    "ok": int(r.get("ok", 0) or 0),
                    "fail": int(r.get("fail", 0) or 0),
                    "unknown": int(r.get("unknown", 0) or 0),
                    "total": int(r.get("total", 0) or 0),
                    "window": window_csv,
                    "ok_pct": float(r.get("ok_pct", 0) or 0),
                    "fail_pct": float(r.get("fail_pct", 0) or 0),
                    "unknown_pct": float(r.get("unknown_pct", 0) or 0),
                    "current_result": r.get("current_result"),
                    "current_len": int(r.get("current_len", 0) or 0),
                    "longest_ok": int(r.get("longest_ok", 0) or 0),
                    "longest_fail": int(r.get("longest_fail", 0) or 0),
                    "longest_unknown": int(r.get("longest_unknown", 0) or 0),
                    "delta_ok": int(r.get("delta_ok", 0) or 0),
                    "delta_fail": int(r.get("delta_fail", 0) or 0),
                    "delta_unknown": int(r.get("delta_unknown", 0) or 0),
                    "delta_ok_pct": float(r.get("delta_ok_pct", 0) or 0),
                    "delta_fail_pct": float(r.get("delta_fail_pct", 0) or 0),
                    "delta_unknown_pct": float(r.get("delta_unknown_pct", 0) or 0),
                    "delta_window": int(r.get("delta_window", 0) or 0),
                }
            for name, counts in recomputed.items():
                expected = csv_counts.get(name, {})
                if expected.get("window", window_len) != window_len:
                    raise SystemExit(
                        f"{guard_summary_csv}: window mismatch for {name} (csv={expected.get('window')}, expected={window_len})"
                    )
                # Streaks if present
                if expected.get("current_result") is not None:
                    streak_expected = {
                        "current_result": (expected.get("current_result") or "unknown").lower(),
                        "current_len": expected.get("current_len", 0),
                        "longest_ok": expected.get("longest_ok", 0),
                        "longest_fail": expected.get("longest_fail", 0),
                        "longest_unknown": expected.get("longest_unknown", 0),
                    }
                    streak_calc = recomputed_streaks.get(name) or {}
                    current_calc = streak_calc.get("current", {})
                    longest_calc = streak_calc.get("longest", {})
                    if streak_expected["current_result"] != (current_calc.get("result") or "unknown"):
                        raise SystemExit(
                            f"{guard_summary_csv}: streak current result mismatch for {name} (csv={streak_expected['current_result']}, expected={current_calc.get('result')})"
                        )
                    if streak_expected["current_len"] != current_calc.get("length", 0):
                        raise SystemExit(
                            f"{guard_summary_csv}: streak current length mismatch for {name} (csv={streak_expected['current_len']}, expected={current_calc.get('length')})"
                        )
                    for key, calc_key in (("longest_ok", "ok"), ("longest_fail", "fail"), ("longest_unknown", "unknown")):
                        if streak_expected[key] != longest_calc.get(calc_key, 0):
                            raise SystemExit(
                                f"{guard_summary_csv}: streak {key} mismatch for {name} (csv={streak_expected[key]}, expected={longest_calc.get(calc_key,0)})"
                            )
                for key in ("ok", "fail", "unknown"):
                    if expected.get(key, 0) != counts.get(key, 0):
                        raise SystemExit(
                            f"{guard_summary_csv}: mismatch for {name}/{key} (csv={expected.get(key)}, hist={counts.get(key)})"
                        )
                if expected.get("total", 0) != sum(counts.values()):
                    raise SystemExit(
                        f"{guard_summary_csv}: mismatch for {name}/total (csv={expected.get('total')}, hist={sum(counts.values())})"
                    )
                pct_sum = expected.get("ok_pct", 0) + expected.get("fail_pct", 0) + expected.get("unknown_pct", 0)
                if pct_sum > 100.2 or pct_sum < 99.8:
                    raise SystemExit(f"{guard_summary_csv}: percentages for {name} do not sum to 100 (got {pct_sum})")
                if prev_subset:
                    prev_total = sum(prev_counts[name].values()) or 1
                    delta_ok = counts.get("ok", 0) - prev_counts.get(name, {}).get("ok", 0)
                    delta_fail = counts.get("fail", 0) - prev_counts.get(name, {}).get("fail", 0)
                    delta_unknown = counts.get("unknown", 0) - prev_counts.get(name, {}).get("unknown", 0)
                    for key, val in (("delta_ok", delta_ok), ("delta_fail", delta_fail), ("delta_unknown", delta_unknown)):
                        if expected.get(key, 0) != val:
                            raise SystemExit(
                                f"{guard_summary_csv}: delta mismatch for {name}/{key} (csv={expected.get(key)}, hist_delta={val})"
                            )
                    if expected.get("delta_window", len(prev_subset)) != len(prev_subset):
                        raise SystemExit(
                            f"{guard_summary_csv}: delta_window mismatch for {name} (csv={expected.get('delta_window')}, expected={len(prev_subset)})"
                        )
                    for pct_key, num_key in (("delta_ok_pct", "delta_ok"), ("delta_fail_pct", "delta_fail"), ("delta_unknown_pct", "delta_unknown")):
                        recomputed_pct = round((expected.get(num_key, 0) / prev_total * 100), 1)
                        if abs(float(expected.get(pct_key, 0) or 0) - recomputed_pct) > 0.05:
                            raise SystemExit(
                                f"{guard_summary_csv}: delta percent mismatch for {name}/{pct_key} (csv={expected.get(pct_key)}, hist_delta_pct={recomputed_pct})"
                            )
        # Validate guard_summary JSON file for consistency (counts/pct/delta windows)
        guard_summary_json_path = reports_dir / "log_metrics_guard_summary.json"
        if guard_summary_json_path.exists():
            try:
                import json

                guard_json = json.loads(guard_summary_json_path.read_text())
            except Exception:
                raise SystemExit(f"{guard_summary_json_path}: unreadable JSON")
            for name, counts in recomputed.items():
                expected = guard_json.get(name) or {}
                if int(expected.get("window", window_len) or 0) != window_len:
                    raise SystemExit(
                        f"{guard_summary_json_path}: window mismatch for {name} (json={expected.get('window')}, expected={window_len})"
                    )
                for key in ("ok", "fail", "unknown"):
                    if int(expected.get(key, 0) or 0) != counts.get(key, 0):
                        raise SystemExit(
                            f"{guard_summary_json_path}: mismatch for {name}/{key} (json={expected.get(key)}, hist={counts.get(key)})"
                        )
                total = sum(counts.values())
                for pct_key, num_key in (("ok_pct", "ok"), ("fail_pct", "fail"), ("unknown_pct", "unknown")):
                    latest_pct = float(expected.get(pct_key, 0) or 0)
                    recomputed_pct = round((counts.get(num_key, 0) / total * 100) if total else 0.0, 1)
                    if abs(latest_pct - recomputed_pct) > 0.05:
                        raise SystemExit(
                            f"{guard_summary_json_path}: percent mismatch for {name}/{pct_key} (json={latest_pct}, hist={recomputed_pct})"
                        )
                if prev_subset:
                    delta_obj = expected.get("delta") or {}
                    prev_total = sum(prev_counts[name].values()) or 1
                    for key, val in (
                        ("ok", counts.get("ok", 0) - prev_counts.get(name, {}).get("ok", 0)),
                        ("fail", counts.get("fail", 0) - prev_counts.get(name, {}).get("fail", 0)),
                        ("unknown", counts.get("unknown", 0) - prev_counts.get(name, {}).get("unknown", 0)),
                    ):
                        if int(delta_obj.get(key, 0) or 0) != val:
                            raise SystemExit(
                                f"{guard_summary_json_path}: delta mismatch for {name}/{key} (json={delta_obj.get(key)}, hist_delta={val})"
                            )
                    if int(delta_obj.get("window", window_len) or 0) != window_len:
                        raise SystemExit(
                            f"{guard_summary_json_path}: delta window mismatch for {name} (json={delta_obj.get('window')}, expected={window_len})"
                        )
                    if int(delta_obj.get("delta_window", len(prev_subset)) or 0) != len(prev_subset):
                        raise SystemExit(
                            f"{guard_summary_json_path}: delta previous window mismatch for {name} (json={delta_obj.get('delta_window')}, expected={len(prev_subset)})"
                        )
                    for pct_key, num_key in (("ok_pct", "ok"), ("fail_pct", "fail"), ("unknown_pct", "unknown")):
                        latest_pct = float(delta_obj.get(pct_key, 0) or 0)
                        recomputed_pct = round((delta_obj.get(num_key, 0) / prev_total * 100), 1)
                        if abs(latest_pct - recomputed_pct) > 0.05:
                            raise SystemExit(
                                f"{guard_summary_json_path}: delta percent mismatch for {name}/{pct_key} (json={latest_pct}, hist_delta_pct={recomputed_pct})"
                            )
                if expected.get("streak"):
                    streak = expected.get("streak") or {}
                    current = streak.get("current", {})
                    longest = streak.get("longest", {})
                    streak_calc = recomputed_streaks.get(name) or {}
                    current_calc = streak_calc.get("current", {})
                    longest_calc = streak_calc.get("longest", {})
                    if (current.get("result") or "unknown").lower() != (current_calc.get("result") or "unknown"):
                        raise SystemExit(
                            f"{guard_summary_json_path}: streak current result mismatch for {name} (json={current.get('result')}, expected={current_calc.get('result')})"
                        )
                    if int(current.get("length", 0) or 0) != current_calc.get("length", 0):
                        raise SystemExit(
                            f"{guard_summary_json_path}: streak current length mismatch for {name} (json={current.get('length')}, expected={current_calc.get('length')})"
                        )
                    for key, calc_key in (("ok", "ok"), ("fail", "fail"), ("unknown", "unknown")):
                        if int(longest.get(key, 0) or 0) != longest_calc.get(calc_key, 0):
                            raise SystemExit(
                                f"{guard_summary_json_path}: streak longest {key} mismatch for {name} (json={longest.get(key)}, expected={longest_calc.get(calc_key,0)})"
                            )
    # Badge state validation (if thresholds present)
    badge_thresholds = data.get("badge_thresholds") or {}
    badge_warn = float(badge_thresholds.get("warn", 50))
    badge_danger = float(badge_thresholds.get("danger", 80))
    badge_state = data.get("badge_state")
    overloaded_ratio = float(totals.get("overloaded_ratio", 0) or 0)
    expected_state = "ok"
    if len(anomalies) > 0 or overloaded_ratio >= badge_danger:
        expected_state = "alert"
    elif overloaded_ratio >= badge_warn:
        expected_state = "warn"
    if badge_state is not None and badge_state != expected_state:
        raise SystemExit(f"{latest_path}: badge_state mismatch (expected {expected_state}, got {badge_state})")

    artifacts = data.get("artifacts", {})
    for key, rel in artifacts.items():
        if rel is None:
            continue
        path = reports_dir / rel
        if not path.exists():
            raise SystemExit(f"{latest_path}: artifact {key} missing at {rel}")


def main():
    parser = argparse.ArgumentParser(description="Validate metrics artifacts (presence + Totals).")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix (pattern_topN)")
    parser.add_argument(
        "--mode",
        choices=["full", "standard", "minimal"],
        default="full",
        help="Validation strictness: full (tout), standard (sans exigence HTML optionnelle), minimal (pas d'HTML portail/trend/stats/summary/anomalies/index/overview).",
    )
    args = parser.parse_args()

    reports_dir = Path(args.reports)
    if not reports_dir.exists():
        raise SystemExit(f"Reports directory {reports_dir} not found")

    base = reports_dir / f"log_metrics_snapshot.{args.suffix}"
    required = {
        "CSV": Path(f"{base}.csv"),
        "JSON": Path(f"{base}.json"),
        "JSONL": Path(f"{base}.jsonl"),
        "Markdown": Path(f"{base}.md"),
        "HTML": Path(f"{base}.html"),
        "History": reports_dir / "log_metrics_history.csv",
        "Trend": reports_dir / "log_metrics_trend.md",
        "Trend HTML": reports_dir / "log_metrics_trend.html",
        "Index MD": reports_dir / "index.md",
        "Index HTML": reports_dir / "index.html",
        "Bundle": reports_dir / "log_metrics_bundle.tar.gz",
        "Summary": Path(f"{base}.summary.md"),
        "Stats": reports_dir / "log_metrics_stats.md",
        "Stats HTML": reports_dir / "log_metrics_stats.html",
        "Anomalies": reports_dir / "log_metrics_anomalies.md",
        "Anomalies HTML": reports_dir / "log_metrics_anomalies.html",
        "Anomalies JSON": reports_dir / "log_metrics_anomalies.json",
        "Portal": reports_dir / "portal.html",
        "Manifest": reports_dir / "log_metrics_manifest.json",
        "Summary HTML": Path(f"{base}.summary.html"),
        "Checksums": reports_dir / "log_metrics_checksums.txt",
        "Overview": reports_dir / "log_metrics_overview.md",
        "Overview HTML": reports_dir / "log_metrics_overview.html",
        "Latest JSON": reports_dir / "log_metrics_latest.json",
        "Latest HTML": reports_dir / "log_metrics_latest.html",
        "Latest MD": reports_dir / "log_metrics_latest.md",
        "Badge history": reports_dir / "log_metrics_badge_history.csv",
        "Badge": reports_dir / "log_metrics_badge.svg",
        "Badge history md": reports_dir / "log_metrics_badge_history.md",
        "Badge history html": reports_dir / "log_metrics_badge_history.html",
        "Guard summary": reports_dir / "log_metrics_guard_summary.md",
        "Guard summary html": reports_dir / "log_metrics_guard_summary.html",
        "Guard summary json": reports_dir / "log_metrics_guard_summary.json",
        "Guard summary csv": reports_dir / "log_metrics_guard_summary.csv",
    }

    # Badge history artifacts are optional; only enforce if present
    for optional_badge in ["Badge history", "Badge history md", "Badge history html"]:
        path = required.get(optional_badge)
        if path and not path.exists():
            required.pop(optional_badge, None)
    # Guard summary optional if no badge history
    if not required.get("Badge history"):
        for opt in ["Guard summary", "Guard summary html", "Guard summary json"]:
            required.pop(opt, None)

    if args.mode == "minimal":
        # En mode minimal on ne requiert pas les rendus HTML optionnels ni le portail.
        for optional in [
            "Trend HTML",
            "Index HTML",
            "Bundle",
            "Stats HTML",
            "Anomalies HTML",
            "Portal",
            "Summary HTML",
            "Overview HTML",
            "Latest HTML",
            "Latest MD",
            "Bundle",
            "Badge history",
            "Badge",
            "Guard summary",
            "Guard summary html",
            "Guard summary json",
        ]:
            required.pop(optional, None)
    elif args.mode == "standard":
        # Mode standard conserve tout sauf le portail/bundle ? On garde le portail/bundle pour cohérence,
        # mais on tolère l'absence des rendus HTML secondaires.
        for optional in [
            "Trend HTML",
            "Stats HTML",
            "Anomalies HTML",
            "Summary HTML",
            "Overview HTML",
            "Index HTML",
            "Latest JSON",
            "Latest HTML",
            "Latest MD",
            "Badge history",
            "Badge",
            "Guard summary",
            "Guard summary html",
            "Guard summary json",
        ]:
            required.pop(optional, None)

    missing = [name for name, path in required.items() if not path.exists()]
    if missing:
        raise SystemExit(f"Missing artifacts: {', '.join(missing)}")

    check_csv(required["CSV"])
    check_json(required["JSON"])
    # JSONL: just ensure non-empty
    jsonl_path = required["JSONL"]
    if jsonl_path.stat().st_size == 0:
        raise SystemExit(f"{jsonl_path}: empty JSONL")

    check_summary(required["Summary"])
    check_stats(required["Stats"])
    check_portal(required["Portal"])
    check_trend_html(required["Trend HTML"])
    check_stats_html(required["Stats HTML"])
    check_anomalies(required["Anomalies"])
    check_anomalies_html(required["Anomalies HTML"])
    check_anomalies_json(required["Anomalies JSON"])
    if not required["Summary HTML"].exists():
        raise SystemExit(f"{required['Summary HTML']}: missing summary HTML")
    if not required["Checksums"].exists():
        raise SystemExit(f"{required['Checksums']}: missing checksums")
    if not required["Overview"].exists():
        raise SystemExit(f"{required['Overview']}: missing overview md")
    if not required["Overview HTML"].exists():
        raise SystemExit(f"{required['Overview HTML']}: missing overview HTML")
    if "Latest JSON" in required and required["Latest JSON"].exists():
        check_latest(required["Latest JSON"], required["CSV"], reports_dir)
    if "Latest HTML" in required and required["Latest HTML"].exists():
        if "Latest Metrics Summary" not in required["Latest HTML"].read_text():
            raise SystemExit(f"{required['Latest HTML']}: missing latest HTML content")
    if "Latest MD" in required and required["Latest MD"].exists():
        if "# Latest Metrics Summary" not in required["Latest MD"].read_text():
            raise SystemExit(f"{required['Latest MD']}: missing latest Markdown header")
    if "Badge" in required and required["Badge"].exists():
        if "<svg" not in required["Badge"].read_text():
            raise SystemExit(f"{required['Badge']}: missing SVG content")
    if "Badge history" in required and required["Badge history"].exists():
        with required["Badge history"].open() as f:
            lines = [line.strip() for line in f.readlines() if line.strip()]
        if len(lines) < 2:
            raise SystemExit(f"{required['Badge history']}: empty badge history")
    if "Badge history md" in required and required["Badge history md"].exists():
        if "# Badge History" not in required["Badge history md"].read_text():
            raise SystemExit(f"{required['Badge history md']}: missing header")
    if "Badge history html" in required and required["Badge history html"].exists():
        if "<h1>Badge History</h1>" not in required["Badge history html"].read_text():
            raise SystemExit(f"{required['Badge history html']}: missing title")
    if "Guard summary" in required and required["Guard summary"].exists():
        content = required["Guard summary"].read_text()
        if "# Badge Guard Summary" not in content:
            raise SystemExit(f"{required['Guard summary']}: missing header")
    if "Guard summary html" in required and required["Guard summary html"].exists():
        text = required["Guard summary html"].read_text()
        if "<h1>Badge Guard Summary</h1>" not in text:
            raise SystemExit(f"{required['Guard summary html']}: missing header")
    if "Guard summary json" in required and required["Guard summary json"].exists():
        import json as _json
        data = _json.loads(required["Guard summary json"].read_text())
        if not isinstance(data, dict):
            raise SystemExit(f"{required['Guard summary json']}: expected object")
    # If checksums file exists, ensure manifest references it
    manifest = required["Manifest"]
    if manifest.exists():
        import json
        data = json.loads(manifest.read_text())
        c_entry = data.get("paths", {}).get("checksums")
        if not c_entry or not c_entry.get("exists"):
            raise SystemExit(f"{manifest}: manifest missing checksums entry")
    compare_html = reports_dir / "log_metrics_compare.html"
    if compare_html.exists():
        if "Log Metrics Diff" not in compare_html.read_text():
            raise SystemExit(f"{compare_html}: missing diff header")
    check_manifest(required["Manifest"], reports_dir)
    # Ensure checksums file matches manifest entries
    python_path = Path(__file__).resolve()
    checker = python_path.parent / "logs_metrics_verify_checksums.py"
    if checker.exists():
        import subprocess
        res = subprocess.run(
            ["python3", str(checker), "--reports", str(reports_dir), "--suffix", args.suffix],
            capture_output=True,
            text=True,
        )
        if res.returncode != 0:
            raise SystemExit(res.stderr or res.stdout or "checksum verification failed")

    print("Validation OK")


if __name__ == "__main__":
    main()
