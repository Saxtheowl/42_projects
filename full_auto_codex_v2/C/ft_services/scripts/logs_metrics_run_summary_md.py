#!/usr/bin/env python3
"""
Render a human-readable Markdown view of log_metrics_run_summary.json.
"""
import argparse
import json
from pathlib import Path


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text())
    except Exception:
        return {}


def main():
    parser = argparse.ArgumentParser(description="Render a Markdown summary from log_metrics_run_summary.json.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--run-summary", default=None, help="Path to log_metrics_run_summary.json (default: reports/log_metrics_run_summary.json)")
    parser.add_argument("--output", default=None, help="Output path (default: reports/log_metrics_run_summary.md)")
    args = parser.parse_args()

    reports = Path(args.reports)
    run_summary_path = Path(args.run_summary) if args.run_summary else reports / "log_metrics_run_summary.json"
    output_path = Path(args.output) if args.output else reports / "log_metrics_run_summary.md"

    data = load_json(run_summary_path)
    if not data:
        output_path.write_text("# Run Summary\n\nAucun run summary JSON n'a été trouvé ou il est illisible.\n")
        print(f"Run summary MD written to {output_path} (empty source)")
        return

    badge = data.get("badge_state", "n/a")
    anomalies = data.get("anomalies_count", "n/a")
    ratio = data.get("overloaded_ratio", "n/a")
    guard = data.get("guard_check", "skipped")
    checksums = data.get("checksums", "skipped")
    validation = data.get("validation", {}) or {}
    validation_status = validation.get("status", "skipped")
    validation_mode = validation.get("mode", "n/a")
    compare = data.get("compare", {}) or {}
    compare_status = compare.get("status", "skipped")
    sitemap = data.get("sitemap", {}) or {}
    sitemap_status = sitemap.get("status", "skipped")
    status_snapshot = data.get("status_snapshot", {}) or {}
    status_overall = status_snapshot.get("overall", "n/a")
    status_badge = status_snapshot.get("badge")

    lines = [
        "# Run Summary",
        "",
        f"- Generated at: `{data.get('generated_at', 'n/a')}`",
        f"- Reports dir: `{data.get('reports_dir', 'reports')}`",
        f"- Suffix: `{data.get('suffix', 'status_top2')}`",
        "",
        "## Status",
        f"- Badge: **{badge}**",
        f"- Anomalies: **{anomalies}**",
        f"- Overloaded ratio: **{ratio}**",
        f"- Guard check: **{guard}**",
        f"- Checksums: **{checksums}**",
        f"- Validation: **{validation_status}** (mode: {validation_mode})",
        f"- Compare: **{compare_status}**",
        f"- Sitemap: **{sitemap_status}**",
        f"- Overall: **{status_overall}**",
        "",
    ]

    def link(label: str, key: str):
        path = data.get(key)
        if path:
            lines.append(f"- {label}: `{path}`")

    lines.append("## Artifacts")
    link("Latest JSON", "latest_path")
    link("Manifest", "manifest")
    link("Bundle", "bundle")
    link("Checksums", "checksums_path")
    link("Portal", "portal")
    link("Index", "index")
    link("Compare MD", "md")
    link("Compare HTML", "html")
    if sitemap:
        if sitemap.get("json"):
            lines.append(f"- Sitemap JSON: `{sitemap.get('json')}`")
        if sitemap.get("md"):
            lines.append(f"- Sitemap MD: `{sitemap.get('md')}`")
        if sitemap.get("html"):
            lines.append(f"- Sitemap HTML: `{sitemap.get('html')}`")
    if status_snapshot.get("json"):
        lines.append(f"- Status JSON: `{status_snapshot.get('json')}`")
    if status_badge:
        lines.append(f"- Status badge: `{status_badge}`")

    manifest_summary = data.get("manifest_summary") or {}
    if manifest_summary:
        lines.append("")
        lines.append("## Manifest details")
        lines.append(
            f"- Required: **{manifest_summary.get('present','n/a')}/{manifest_summary.get('total','n/a')}**, "
            f"Missing: **{manifest_summary.get('missing_count','n/a')}**, Size: **{manifest_summary.get('size_bytes','n/a')} bytes**"
        )
        if manifest_summary.get("optional_total") is not None:
            lines.append(
                f"- Optional: **{manifest_summary.get('optional_present','n/a')}/{manifest_summary.get('optional_total','n/a')}** "
                f"(ignored: {manifest_summary.get('optional_missing_count','n/a')})"
            )
        if manifest_summary.get("optional_coverage") is not None:
            lines.append(f"- Optional coverage: **{manifest_summary.get('optional_coverage')}%**")
        if manifest_summary.get("optional_skipped"):
            lines.append(f"- Optional ignored: {', '.join(manifest_summary.get('optional_skipped'))}")
        if manifest_summary.get("missing_paths"):
            lines.append(f"- Missing paths: {', '.join(manifest_summary.get('missing_paths'))}")

    output_path.write_text("\n".join(lines) + "\n")
    print(f"Run summary MD written to {output_path}")


if __name__ == "__main__":
    main()
