#!/usr/bin/env python3
"""
Check that guard summary JSON stays aligned with the latest JSON (counts + streaks).

Usage:
    python3 scripts/logs_metrics_guard_latest_check.py \
        --latest reports/log_metrics_latest.json \
        --guard-summary reports/log_metrics_guard_summary.json
"""
import argparse
import json
from pathlib import Path
from typing import Any, Dict, Optional


def load_json(path: Path) -> Dict[str, Any]:
    if not path.exists():
        raise SystemExit(f"Missing file: {path}")
    try:
        return json.loads(path.read_text())
    except Exception as exc:  # pragma: no cover
        raise SystemExit(f"Unable to read {path}: {exc}")


def compare_counts(label: str, expected: Dict[str, Any], actual: Dict[str, Any], tol: float) -> Optional[str]:
    if expected is None or actual is None:
        return f"{label}: missing counts (expected? {expected is not None}, actual? {actual is not None})"
    for key in ("ok", "fail", "unknown", "total", "window"):
        if int(expected.get(key, 0) or 0) != int(actual.get(key, 0) or 0):
            return f"{label}: mismatch {key} expected={expected.get(key)} actual={actual.get(key)}"
    for key in ("ok_pct", "fail_pct", "unknown_pct"):
        exp = float(expected.get(key, 0) or 0.0)
        act = float(actual.get(key, 0) or 0.0)
        if abs(exp - act) > tol:
            return f"{label}: mismatch {key} expected={exp} actual={act} tol={tol}"
    return None


def compare_streak(label: str, expected: Dict[str, Any], actual: Dict[str, Any]) -> Optional[str]:
    if expected is None or actual is None:
        return f"{label}: missing streak (expected? {expected is not None}, actual? {actual is not None})"
    exp_cur = (expected.get("current", {}) or {})
    act_cur = (actual.get("current", {}) or {})
    exp_long = (expected.get("longest", {}) or {})
    act_long = (actual.get("longest", {}) or {})
    exp_res = str(exp_cur.get("result", "unknown")).lower()
    act_res = str(act_cur.get("result", "unknown")).lower()
    if exp_res != act_res:
        return f"{label}: current result mismatch expected={exp_res} actual={act_res}"
    if int(exp_cur.get("length", 0) or 0) != int(act_cur.get("length", 0) or 0):
        return f"{label}: current length mismatch expected={exp_cur.get('length')} actual={act_cur.get('length')}"
    for key in ("ok", "fail", "unknown"):
        if int(exp_long.get(key, 0) or 0) != int(act_long.get(key, 0) or 0):
            return f"{label}: longest {key} mismatch expected={exp_long.get(key)} actual={act_long.get(key)}"
    if int(expected.get("window", 0) or 0) != int(actual.get("window", 0) or 0):
        return f"{label}: window mismatch expected={expected.get('window')} actual={actual.get('window')}"
    return None


def main():
    parser = argparse.ArgumentParser(description="Check guard summary JSON against latest JSON.")
    parser.add_argument("--latest", default="reports/log_metrics_latest.json", help="Latest JSON path")
    parser.add_argument("--guard-summary", default="reports/log_metrics_guard_summary.json", help="Guard summary JSON path")
    parser.add_argument("--tolerance", type=float, default=0.05, help="Tolerance for pct comparisons")
    args = parser.parse_args()

    latest = load_json(Path(args.latest))
    guard_summary = load_json(Path(args.guard_summary))

    latest_counts = latest.get("badge_guard_summary") or {}
    latest_streaks = latest.get("badge_guard_streaks") or {}
    latest_overall = latest.get("badge_guard_overall")
    latest_overall_streak = latest.get("badge_guard_overall_streak")

    errors = []

    # Overall counts/streak
    overall_expected = guard_summary.get("overall")
    if overall_expected is None:
        errors.append("guard_summary: missing overall block")
    else:
        err = compare_counts("overall", overall_expected, latest_overall, args.tolerance)
        if err:
            errors.append(err)

    overall_streak_expected = guard_summary.get("overall_streak")
    if overall_streak_expected is None:
        errors.append("guard_summary: missing overall_streak block")
    else:
        err = compare_streak("overall_streak", overall_streak_expected, latest_overall_streak)
        if err:
            errors.append(err)

    # Per-guard counts/streaks
    for name, payload in guard_summary.items():
        if name in ("overall", "overall_streak"):
            continue
        expected_counts = payload
        actual_counts = latest_counts.get(name)
        if actual_counts is None:
            errors.append(f"{name}: missing in latest badge_guard_summary")
        else:
            err = compare_counts(name, expected_counts, actual_counts, args.tolerance)
            if err:
                errors.append(err)

        expected_streak = payload.get("streak")
        if expected_streak:
            actual_streak = latest_streaks.get(name)
            if actual_streak is None:
                errors.append(f"{name}: missing streak in latest badge_guard_streaks")
            else:
                err = compare_streak(f"{name} streak", expected_streak, actual_streak)
                if err:
                    errors.append(err)

    if errors:
        raise SystemExit("Guard latest check failed:\n- " + "\n- ".join(errors))

    print("Guard summary and latest JSON are consistent.")


if __name__ == "__main__":
    main()
