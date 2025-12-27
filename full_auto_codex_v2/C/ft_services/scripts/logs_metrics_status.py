#!/usr/bin/env python3
"""
Summarize key statuses for metrics artifacts (badge/guard/checksums/validation/compare/sitemap/manifest/anomalies).

Usage:
  python3 scripts/logs_metrics_status.py --reports reports [--format json|text]
"""
import argparse
import json
from pathlib import Path
from typing import Any, Dict


def load_json(path: Path) -> Dict[str, Any]:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text())
    except Exception:
        return {}


def manifest_status(manifest_path: Path, optional: set):
    if not manifest_path.exists():
        return {"status": "missing", "total": 0, "present": 0, "missing_count": 0, "size_bytes": 0}
    data = load_json(manifest_path)
    paths = data.get("paths") or {}
    required_total = 0
    optional_total = 0
    required_present = 0
    optional_present = 0
    size_total = 0
    missing = []
    skipped_optional = []
    for name, info in paths.items():
        path_name = info.get("path") or name
        is_optional = Path(path_name).name in optional or name in optional
        exists = bool(info.get("exists"))
        size_total += info.get("size") or 0 if exists else 0
        if is_optional:
            optional_total += 1
            if exists:
                optional_present += 1
            else:
                skipped_optional.append(path_name)
            continue
        required_total += 1
        if exists:
            required_present += 1
        else:
            missing.append(path_name)
    missing_count = len(missing)
    optional_coverage = None
    if optional_total > 0:
        optional_coverage = round(100 * optional_present / optional_total, 2)

    return {
        "status": "ok" if missing_count == 0 else "missing",
        "total": required_total,
        "present": required_present,
        "missing_count": missing_count,
        "size_bytes": size_total,
        "missing_paths": missing,
        "optional_skipped": skipped_optional,
        "optional_total": optional_total,
        "optional_present": optional_present,
        "optional_missing_count": len(skipped_optional),
        "optional_coverage": optional_coverage,
    }


def sitemap_status(sitemap_path: Path):
    data = load_json(sitemap_path)
    summary = data.get("summary") or {}
    missing = summary.get("missing", 0) or 0
    return {
        "status": "ok" if missing == 0 else "missing",
        "required": summary.get("artifacts"),
        "present": summary.get("present"),
        "missing": missing,
        "optional": summary.get("optional_artifacts") or [],
        "missing_paths": summary.get("missing_paths") or [],
    }


def main():
    parser = argparse.ArgumentParser(description="Summarize key statuses for metrics artifacts.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--format", choices=["json", "text"], default="text", help="Output format")
    parser.add_argument("--optional", default=None, help="Comma-separated optional artifact names to ignore (overrides sitemap optional)")
    parser.add_argument("--fail-on-badge", choices=["warn", "alert"], help="Exit non-zero if badge state is worse or equal to the threshold")
    parser.add_argument("--fail-on-missing", action="store_true", help="Exit non-zero if sitemap/manifest report missing required artifacts")
    parser.add_argument("--output", default=None, help="Output file (when set, writes JSON to this path)")
    parser.add_argument("--allow-alert", action="store_true", help="Do not fail on badge=alert (useful for dashboards)")
    args = parser.parse_args()

    reports = Path(args.reports)
    latest = load_json(reports / "log_metrics_latest.json")
    run_summary = load_json(reports / "log_metrics_run_summary.json")
    sitemap = sitemap_status(reports / "log_metrics_sitemap.json")
    optional_set = set()
    if args.optional:
        optional_set = {part.strip() for part in args.optional.split(",") if part.strip()}
    else:
        optional_set = set(sitemap.get("optional", []))
    manifest = manifest_status(reports / "log_metrics_manifest.json", optional_set)

    payload = {
        "badge_state": latest.get("badge_state", "n/a"),
        "anomalies_count": latest.get("anomalies_count", "n/a"),
        "anomaly_threshold": latest.get("anomaly_threshold"),
        "overloaded_ratio": (latest.get("totals") or {}).get("overloaded_ratio"),
        "guard_check": latest.get("guard_check", run_summary.get("guard_check", "n/a")),
        "checksums": run_summary.get("checksums", "n/a"),
        "validation": run_summary.get("validation", {}),
        "compare": run_summary.get("compare", {}),
        "sitemap": sitemap,
        "manifest": manifest,
    }
    # Overall state: alert if manifest/sitemap missing, else badge state
    overall_state = "ok"
    if manifest.get("missing_count", 0) > 0 or sitemap.get("missing", 0) > 0:
        overall_state = "alert"
    else:
        overall_state = str(payload["badge_state"]).lower()
    payload["overall_state"] = overall_state

    exit_code = 0
    if args.fail_on_badge and not (args.allow_alert and payload["badge_state"] == "alert"):
        order = {"ok": 0, "warn": 1, "alert": 2}
        badge_state = str(payload["badge_state"]).lower()
        threshold = args.fail_on_badge
        if order.get(badge_state, 0) >= order.get(threshold, 0):
            exit_code = 1
    if args.fail_on_missing:
        if payload["sitemap"].get("missing", 0) or payload["manifest"].get("missing_count", 0):
            exit_code = 1

    if args.output:
        Path(args.output).write_text(json.dumps(payload, indent=2))
        print(f"Status written to {args.output}")
    if args.format == "json" and not args.output:
        print(json.dumps(payload, indent=2))
    else:
        manifest_info = payload["manifest"]
        optional_missing = manifest_info.get("optional_missing_count", len(manifest_info.get("optional_skipped", [])))
        optional_coverage = manifest_info.get("optional_coverage")
        lines = [
            f"Badge: {payload['badge_state']}",
            f"Anomalies: {payload['anomalies_count']} (threshold: {payload.get('anomaly_threshold','n/a')})",
            f"Overloaded ratio: {payload['overloaded_ratio']}",
            f"Guard check: {payload['guard_check']}",
            f"Checksums: {payload['checksums']}",
            f"Validation: {(payload['validation'] or {}).get('status','n/a')} (mode: {(payload['validation'] or {}).get('mode','n/a')})",
            f"Compare: {(payload['compare'] or {}).get('status','n/a')}",
            f"Sitemap: {payload['sitemap']['status']} (required={payload['sitemap'].get('required')}, present={payload['sitemap'].get('present')}, missing={payload['sitemap'].get('missing')})",
            (
                "Manifest: "
                f"{manifest_info.get('status')} "
                f"(required={manifest_info.get('total')}, present={manifest_info.get('present')}, missing={manifest_info.get('missing_count')}, "
                f"optional_present={manifest_info.get('optional_present', 0)}/{manifest_info.get('optional_total', 0)}, "
                f"optional_ignored={optional_missing}"
                f"{'' if optional_coverage is None else f', optional_coverage={optional_coverage}%'}"
                ")"
            ),
        ]
        print("\n".join(lines))
    if exit_code:
        raise SystemExit(exit_code)


if __name__ == "__main__":
    main()
