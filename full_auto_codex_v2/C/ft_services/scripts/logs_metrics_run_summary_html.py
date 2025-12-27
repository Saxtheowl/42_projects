#!/usr/bin/env python3
"""
Render a simple HTML view of log_metrics_run_summary.json.
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
    parser = argparse.ArgumentParser(description="Render an HTML view of log_metrics_run_summary.json.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--run-summary", default=None, help="Path to log_metrics_run_summary.json (default: reports/log_metrics_run_summary.json)")
    parser.add_argument("--output", default=None, help="Output path (default: reports/log_metrics_run_summary.html)")
    args = parser.parse_args()

    reports = Path(args.reports)
    run_summary_path = Path(args.run_summary) if args.run_summary else reports / "log_metrics_run_summary.json"
    output_path = Path(args.output) if args.output else reports / "log_metrics_run_summary.html"

    data = load_json(run_summary_path)

    badge = data.get("badge_state", "n/a")
    anomalies = data.get("anomalies_count", "n/a")
    ratio = data.get("overloaded_ratio", "n/a")
    guard = data.get("guard_check", "skipped")
    checksums = data.get("checksums", "skipped")
    validation = (data.get("validation") or {})
    validation_status = validation.get("status", "skipped")
    validation_mode = validation.get("mode", "n/a")
    compare = (data.get("compare") or {})
    compare_status = compare.get("status", "skipped")
    sitemap = (data.get("sitemap") or {})
    sitemap_status = sitemap.get("status", "skipped")
    status_snapshot = data.get("status_snapshot") or {}
    status_overall = status_snapshot.get("overall", "n/a")
    status_badge = status_snapshot.get("badge")
    manifest_summary = data.get("manifest_summary") or {}

    def manifest_html():
        if not manifest_summary:
            return ""
        req_total = manifest_summary.get("total", "n/a")
        req_present = manifest_summary.get("present", "n/a")
        missing = manifest_summary.get("missing_count", "n/a")
        size_bytes = manifest_summary.get("size_bytes", "n/a")
        opt_block = ""
        if manifest_summary.get("optional_total") is not None:
            opt_block = (
                f"<li>Optional: {manifest_summary.get('optional_present','n/a')}/"
                f"{manifest_summary.get('optional_total','n/a')} "
                f"(ignored: {manifest_summary.get('optional_missing_count','n/a')})</li>"
            )
        skipped = manifest_summary.get("optional_skipped") or []
        skipped_html = f"<li>Optional ignored: {', '.join(skipped)}</li>" if skipped else ""
        missing_paths = manifest_summary.get("missing_paths") or []
        missing_html = f"<li>Missing paths: {', '.join(missing_paths)}</li>" if missing_paths else ""
        coverage_html = ""
        if manifest_summary.get("optional_coverage") is not None:
            coverage_html = f"<li>Optional coverage: {manifest_summary.get('optional_coverage')}%</li>"
        return (
            "<h3>Manifest</h3><ul>"
            f"<li>Required: {req_present}/{req_total} (missing: {missing})</li>"
            f"<li>Size: {size_bytes} bytes</li>"
            f"{opt_block}"
            f"{coverage_html}"
            f"{skipped_html}"
            f"{missing_html}"
            "</ul>"
        )

    html = f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Run Summary</title>
  <style>
    body {{ font-family: sans-serif; margin: 24px; }}
    .card {{ border: 1px solid #ddd; padding: 16px; border-radius: 8px; max-width: 720px; }}
    .grid {{ display: grid; grid-template-columns: 1fr 1fr; gap: 8px 16px; }}
    h1 {{ margin-top: 0; }}
    .muted {{ color: #666; font-size: 0.9em; }}
  </style>
</head>
<body>
  <div class="card">
    <h1>Run Summary</h1>
    <p class="muted">Generated at: {data.get('generated_at', 'n/a')}</p>
    <div class="grid">
      <div><strong>Badge</strong></div><div>{badge}</div>
      <div><strong>Anomalies</strong></div><div>{anomalies}</div>
      <div><strong>Overloaded ratio</strong></div><div>{ratio}</div>
      <div><strong>Guard check</strong></div><div>{guard}</div>
      <div><strong>Checksums</strong></div><div>{checksums}</div>
      <div><strong>Validation</strong></div><div>{validation_status} (mode: {validation_mode})</div>
      <div><strong>Compare</strong></div><div>{compare_status}</div>
      <div><strong>Sitemap</strong></div><div>{sitemap_status}</div>
      <div><strong>Overall</strong></div><div>{status_overall}</div>
    </div>
    <h3>Artifacts</h3>
    <ul>
      {"<li>Latest JSON: " + str(data.get("latest_path")) + "</li>" if data.get("latest_path") else ""}
      {"<li>Manifest: " + str(data.get("manifest")) + "</li>" if data.get("manifest") else ""}
      {"<li>Bundle: " + str(data.get("bundle")) + "</li>" if data.get("bundle") else ""}
      {"<li>Checksums: " + str(data.get("checksums_path")) + "</li>" if data.get("checksums_path") else ""}
      {"<li>Portal: " + str(data.get("portal")) + "</li>" if data.get("portal") else ""}
      {"<li>Index: " + str(data.get("index")) + "</li>" if data.get("index") else ""}
      {"<li>Compare (md/html): " + str(compare.get("md")) + " / " + str(compare.get("html")) + "</li>" if compare else ""}
      {("<li>Status JSON: " + str(status_snapshot.get("json")) + "</li>") if status_snapshot.get("json") else ""}
      {("<li>Status badge: " + str(status_badge) + "</li>") if status_badge else ""}
      {("<li>Sitemap JSON: " + str(sitemap.get("json")) + "</li>") if sitemap.get("json") else ""}
      {("<li>Sitemap MD: " + str(sitemap.get("md")) + "</li>") if sitemap.get("md") else ""}
      {("<li>Sitemap HTML: " + str(sitemap.get("html")) + "</li>") if sitemap.get("html") else ""}
    </ul>
    {manifest_html()}
  </div>
</body>
</html>
"""
    output_path.write_text(html)
    print(f"Run summary HTML written to {output_path}")


if __name__ == "__main__":
    main()
