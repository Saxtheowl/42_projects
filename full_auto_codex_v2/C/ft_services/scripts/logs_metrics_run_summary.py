#!/usr/bin/env python3
"""
Build a concise run summary JSON for CI/reporting.

Example:
python3 scripts/logs_metrics_run_summary.py \
  --reports reports --suffix status_top2 \
  --guard-check ok --checksums ok --validation ok --validation-mode full \
  --latest reports/log_metrics_latest.json --output reports/log_metrics_run_summary.json
"""
import argparse
import json
from pathlib import Path
from datetime import datetime, timezone
from typing import Dict, Any


def load_latest(latest_path: Path) -> Dict[str, Any]:
    if not latest_path.exists():
        return {}
    try:
        return json.loads(latest_path.read_text())
    except Exception:
        return {}


def main():
    parser = argparse.ArgumentParser(description="Write a concise run summary JSON.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix")
    parser.add_argument("--latest", default=None, help="Path to latest JSON (default: reports/log_metrics_latest.json)")
    parser.add_argument("--guard-check", default="skipped", choices=["ok", "skipped"], help="Guard check status")
    parser.add_argument("--checksums", default="skipped", choices=["ok", "skipped"], help="Checksums verification status")
    parser.add_argument("--validation", default="skipped", choices=["ok", "skipped"], help="Validation status")
    parser.add_argument("--validation-mode", default=None, help="Validation mode if run (full|standard|minimal)")
    parser.add_argument("--compare-status", default="skipped", choices=["ok", "skipped"], help="Compare status")
    parser.add_argument("--compare-md", default=None, help="Path to compare markdown (if generated)")
    parser.add_argument("--compare-html", default=None, help="Path to compare HTML (if generated)")
    parser.add_argument("--manifest", default=None, help="Path to manifest JSON")
    parser.add_argument("--bundle", default=None, help="Path to bundle tar.gz")
    parser.add_argument("--checksums-path", default=None, help="Path to checksums file")
    parser.add_argument("--portal", default=None, help="Path to portal HTML")
    parser.add_argument("--index", default=None, help="Path to index MD")
    parser.add_argument("--sitemap-status", default="skipped", choices=["ok", "skipped"], help="Sitemap verification status")
    parser.add_argument("--sitemap-json", default=None, help="Path to sitemap JSON")
    parser.add_argument("--sitemap-md", default=None, help="Path to sitemap Markdown")
    parser.add_argument("--sitemap-html", default=None, help="Path to sitemap HTML")
    parser.add_argument("--status-json", default=None, help="Path to status JSON snapshot")
    parser.add_argument("--status-overall", default=None, help="Overall status (badge/sitemap/manifest synthesis)")
    parser.add_argument("--status-badge", default=None, help="Path to status badge SVG")
    parser.add_argument("--include-manifest-from-status", action="store_true", help="Pull manifest details from status JSON when available")
    parser.add_argument("--output", default=None, help="Output path (default reports/log_metrics_run_summary.json)")
    args = parser.parse_args()

    reports_dir = Path(args.reports)
    latest_path = Path(args.latest) if args.latest else reports_dir / "log_metrics_latest.json"
    output_path = Path(args.output) if args.output else reports_dir / "log_metrics_run_summary.json"

    latest = load_latest(latest_path)
    status_snapshot_path = Path(args.status_json) if args.status_json else None
    status_payload = load_latest(status_snapshot_path) if status_snapshot_path else {}
    manifest_info: Dict[str, Any] = {}
    if args.include_manifest_from_status and status_payload.get("manifest"):
        manifest = status_payload.get("manifest") or {}
        manifest_info = {
            "status": manifest.get("status"),
            "total": manifest.get("total"),
            "present": manifest.get("present"),
            "missing_count": manifest.get("missing_count"),
            "optional_total": manifest.get("optional_total"),
            "optional_present": manifest.get("optional_present"),
            "optional_missing_count": manifest.get("optional_missing_count"),
            "optional_coverage": manifest.get("optional_coverage"),
            "optional_skipped": manifest.get("optional_skipped", []),
            "size_bytes": manifest.get("size_bytes"),
            "missing_paths": manifest.get("missing_paths", []),
        }

    summary = {
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "reports_dir": str(reports_dir),
        "suffix": args.suffix,
        "badge_state": latest.get("badge_state"),
        "anomalies_count": latest.get("anomalies_count"),
        "overloaded_ratio": (latest.get("totals") or {}).get("overloaded_ratio"),
        "guard_check": args.guard_check,
        "checksums": args.checksums,
        "compare": {
            "status": args.compare_status,
            "md": args.compare_md,
            "html": args.compare_html,
        },
        "validation": {
            "status": args.validation,
            "mode": args.validation_mode,
        },
        "latest_path": str(latest_path) if latest_path.exists() else None,
        "manifest": args.manifest,
        "manifest_summary": manifest_info if manifest_info else None,
        "bundle": args.bundle,
        "checksums_path": args.checksums_path,
        "portal": args.portal,
        "index": args.index,
        "sitemap": {
            "status": args.sitemap_status,
            "json": args.sitemap_json,
            "md": args.sitemap_md,
            "html": args.sitemap_html,
        },
        "status_snapshot": {
            "json": args.status_json,
            "overall": args.status_overall,
            "badge": args.status_badge,
        },
    }
    output_path.write_text(json.dumps(summary, indent=2))
    print(f"Run summary written to {output_path}")


if __name__ == "__main__":
    main()
