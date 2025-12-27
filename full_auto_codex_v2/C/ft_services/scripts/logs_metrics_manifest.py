#!/usr/bin/env python3
"""
Generate a JSON manifest listing all metrics artifacts for a given suffix (with sizes and hashes).
Usage: logs_metrics_manifest.py --reports reports --suffix status_top2 --output reports/log_metrics_manifest.json [--no-sha256]
"""
import argparse
import json
from pathlib import Path
from datetime import datetime, timezone
import hashlib


def compute_sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def build_manifest(reports: Path, suffix: str, output_path: Path, with_hashes: bool):
    base = reports / f"log_metrics_snapshot.{suffix}"
    manifest = {
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "suffix": suffix,
        "paths": {},
    }
    files = {
        "csv": Path(f"{base}.csv"),
        "json": Path(f"{base}.json"),
        "jsonl": Path(f"{base}.jsonl"),
        "md": Path(f"{base}.md"),
        "html": Path(f"{base}.html"),
        "summary": Path(f"{base}.summary.md"),
        "history": reports / "log_metrics_history.csv",
        "trend_md": reports / "log_metrics_trend.md",
        "trend_html": reports / "log_metrics_trend.html",
        "stats_md": reports / "log_metrics_stats.md",
        "stats_html": reports / "log_metrics_stats.html",
        "anomalies_md": reports / "log_metrics_anomalies.md",
        "anomalies_html": reports / "log_metrics_anomalies.html",
        "anomalies_json": reports / "log_metrics_anomalies.json",
        "index_md": reports / "index.md",
        "index_html": reports / "index.html",
        "portal": reports / "portal.html",
        "bundle": reports / "log_metrics_bundle.tar.gz",
        "compare_md": reports / "log_metrics_compare.md",
        "compare_html": reports / "log_metrics_compare.html",
        "overview": reports / "log_metrics_overview.md",
        "manifest": output_path,
        "checksums": reports / "log_metrics_checksums.txt",
        "overview_md": reports / "log_metrics_overview.md",
        "overview_html": reports / "log_metrics_overview.html",
        "latest_json": reports / "log_metrics_latest.json",
        "latest_html": reports / "log_metrics_latest.html",
        "latest_md": reports / "log_metrics_latest.md",
        "run_summary_html": reports / "log_metrics_run_summary.html",
        "run_summary_md": reports / "log_metrics_run_summary.md",
        "run_summary": reports / "log_metrics_run_summary.json",
        "sitemap": reports / "log_metrics_sitemap.md",
        "sitemap_html": reports / "log_metrics_sitemap.html",
        "sitemap_json": reports / "log_metrics_sitemap.json",
        "badge_svg": reports / "log_metrics_badge.svg",
        "badge_history": reports / "log_metrics_badge_history.csv",
        "badge_history_md": reports / "log_metrics_badge_history.md",
        "badge_history_html": reports / "log_metrics_badge_history.html",
        "status_badge": reports / "log_metrics_status_badge.svg",
        "status_json": reports / "log_metrics_status.json",
        "overall_history": reports / "log_metrics_overall_history.csv",
        "guard_summary_md": reports / "log_metrics_guard_summary.md",
        "guard_summary_html": reports / "log_metrics_guard_summary.html",
        "guard_summary_json": reports / "log_metrics_guard_summary.json",
        "guard_summary_csv": reports / "log_metrics_guard_summary.csv",
        "guard_summary_streaks": reports / "log_metrics_guard_summary.json",
        "checksums_guard": reports / "log_metrics_guard_summary.md.sha256",
        "run_summary_md": reports / "log_metrics_run_summary.md",
    }
    for name, path in files.items():
        exists = path.exists() or name == "manifest"
        # Preserve relative paths when possible, otherwise fall back to absolute (e.g., --output outside reports dir)
        if path.exists() or name == "manifest":
            try:
                rel_path = str(path.relative_to(reports))
            except ValueError:
                rel_path = str(path)
        else:
            rel_path = None
        size = path.stat().st_size if path.exists() else 0
        entry = {"path": rel_path, "exists": exists, "size": size}
        if with_hashes and path.exists() and name not in {"manifest", "checksums"}:
            entry["sha256"] = compute_sha256(path)
        manifest["paths"][name] = entry
    return manifest


def main():
    parser = argparse.ArgumentParser(description="Generate a JSON manifest of metrics artifacts.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix")
    parser.add_argument("--output", default=None, help="Output manifest path (default reports/log_metrics_manifest.json)")
    parser.add_argument("--no-sha256", action="store_true", help="Do not compute sha256 hashes")
    args = parser.parse_args()

    reports = Path(args.reports)
    if not reports.exists():
        raise SystemExit(f"Reports directory {reports} not found")
    output = Path(args.output) if args.output else reports / "log_metrics_manifest.json"

    manifest = build_manifest(reports, args.suffix, output, with_hashes=not args.no_sha256)
    output.write_text(json.dumps(manifest, indent=2))
    # Update size for manifest entry now that the file exists
    manifest["paths"]["manifest"]["size"] = output.stat().st_size
    output.write_text(json.dumps(manifest, indent=2))
    print(f"Manifest written to {output}")


if __name__ == "__main__":
    main()
