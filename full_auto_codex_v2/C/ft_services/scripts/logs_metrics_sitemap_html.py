#!/usr/bin/env python3
"""
Generate an HTML sitemap of generated artifacts using the manifest if available.
"""
import argparse
import json
from pathlib import Path
from typing import Dict, Any, List


def load_manifest(path: Path) -> Dict[str, Any]:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text())
    except Exception:
        return {}


def row(path_label: str, exists: bool, size: int, sha: str) -> str:
    sha_display = (sha[:12] + "…") if sha else "-"
    size_kb = f"{size/1024:.1f} KB" if size else "0 KB"
    link = f"<a href='{path_label}'>{path_label}</a>" if exists else path_label
    return f"<tr><td>{link}</td><td>{'true' if exists else 'false'}</td><td>{size_kb}</td><td>{sha_display}</td></tr>"


def format_size(bytes_count: int) -> str:
    if bytes_count >= 1024 * 1024:
        return f"{bytes_count / (1024 * 1024):.2f} MB"
    if bytes_count >= 1024:
        return f"{bytes_count / 1024:.1f} KB"
    return f"{bytes_count} B"


def main():
    parser = argparse.ArgumentParser(description="Generate an HTML sitemap of metrics artifacts.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--manifest", default=None, help="Manifest JSON path (default: reports/log_metrics_manifest.json)")
    parser.add_argument("--output", default=None, help="Output HTML path (default: reports/log_metrics_sitemap.html)")
    parser.add_argument(
        "--optional",
        default="compare_md,compare_html,checksums_guard",
        help="Comma-separated optional artifacts to ignore in totals/missing (default: compare_md,compare_html,checksums_guard)",
    )
    args = parser.parse_args()

    reports = Path(args.reports)
    manifest_path = Path(args.manifest) if args.manifest else reports / "log_metrics_manifest.json"
    output_path = Path(args.output) if args.output else reports / "log_metrics_sitemap.html"

    manifest = load_manifest(manifest_path)
    paths = manifest.get("paths", {}) if isinstance(manifest, dict) else {}
    optional = set(filter(None, [part.strip() for part in args.optional.split(",")]))

    rows: List[str] = []
    total_size = 0
    present = 0
    total = 0
    if paths:
        for name, entry in sorted(paths.items()):
            path_label = entry.get("path") or name
            exists = bool(entry.get("exists"))
            size = int(entry.get("size") or 0)
            sha = entry.get("sha256") or ""
            rows.append(row(path_label, exists, size, sha))
            if name in optional:
                continue
            total += 1
            total_size += size
            present += 1 if exists else 0
    else:
        rows.append("<tr><td>(manifest absent)</td><td>false</td><td>0 KB</td><td>-</td></tr>")
    missing = max(total - present, 0) if paths else 0

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Metrics Sitemap</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 1.5rem; }}
    table {{ border-collapse: collapse; width: 100%; max-width: 960px; }}
    th, td {{ border: 1px solid #ddd; padding: 8px; }}
    th {{ background: #f2f2f2; text-align: left; }}
    tbody tr:nth-child(every) {{ background: #fafafa; }}
  </style>
</head>
<body>
  <h1>Metrics Sitemap</h1>
  <p>Reports dir: <code>{reports}</code></p>
  <p>Manifest: <code>{manifest_path}</code></p>
  <ul>
    <li>Artifacts (required): {total}</li>
    <li>Present: {present}</li>
    <li>Missing: {missing}</li>
    <li>Total size: {format_size(total_size)}</li>
    <li>Optional (ignored in counts): {', '.join(sorted(optional)) if optional else 'none'}</li>
  </ul>
  <table>
    <thead>
      <tr><th>Artifact</th><th>Exists</th><th>Size</th><th>sha256</th></tr>
    </thead>
    <tbody>
      {' '.join(rows)}
    </tbody>
  </table>
</body>
</html>
"""
    output_path.write_text(html)
    print(f"Sitemap HTML written to {output_path}")


if __name__ == "__main__":
    main()
