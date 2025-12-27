#!/usr/bin/env python3
"""
Generate a Markdown sitemap of generated artifacts using the manifest if available.
"""
import argparse
import json
from pathlib import Path
from typing import List, Dict, Any


def load_manifest(path: Path) -> Dict[str, Any]:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text())
    except Exception:
        return {}


def row(path_label: str, exists: bool, size: int, sha: str) -> str:
    size_kb = f"{size/1024:.1f} KB" if size else "0 KB"
    sha_display = sha[:12] + "…" if sha else "-"
    link = f"`{path_label}`" if not exists else f"[`{path_label}`]({path_label})"
    return f"| {link} | {exists} | {size_kb} | {sha_display} |"


def format_size(bytes_count: int) -> str:
    if bytes_count >= 1024 * 1024:
        return f"{bytes_count / (1024 * 1024):.2f} MB"
    if bytes_count >= 1024:
        return f"{bytes_count / 1024:.1f} KB"
    return f"{bytes_count} B"


def main():
    parser = argparse.ArgumentParser(description="Generate a Markdown sitemap of metrics artifacts.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--manifest", default=None, help="Manifest JSON path (default: reports/log_metrics_manifest.json)")
    parser.add_argument("--output", default=None, help="Output Markdown path (default: reports/log_metrics_sitemap.md)")
    parser.add_argument(
        "--optional",
        default="compare_md,compare_html,checksums_guard",
        help="Comma-separated optional artifacts to ignore in totals/missing (default: compare_md,compare_html,checksums_guard)",
    )
    args = parser.parse_args()

    reports = Path(args.reports)
    manifest_path = Path(args.manifest) if args.manifest else reports / "log_metrics_manifest.json"
    output_path = Path(args.output) if args.output else reports / "log_metrics_sitemap.md"

    manifest = load_manifest(manifest_path)
    paths = manifest.get("paths", {}) if isinstance(manifest, dict) else {}
    optional = set(filter(None, [part.strip() for part in args.optional.split(",")]))

    total = 0
    present = 0
    total_size = 0
    lines: List[str] = [
        "# Metrics Sitemap",
        "",
        f"- Reports dir: `{reports}`",
        f"- Manifest: `{manifest_path}`" if manifest else "- Manifest: not found",
        "",
        "| Artifact | Exists | Size | sha256 |",
        "| --- | --- | --- | --- |",
    ]

    if paths:
        for name, entry in sorted(paths.items()):
            path_label = entry.get("path") or name
            exists = bool(entry.get("exists"))
            size = int(entry.get("size") or 0)
            sha = entry.get("sha256") or ""
            lines.append(row(path_label, exists, size, sha))
            if name in optional:
                continue
            total_size += size
            total += 1
            present += 1 if exists else 0
    else:
        lines.append("| (manifest absent) | false | 0 KB | - |")
    missing = max(total - present, 0) if paths else 0
    lines += [
        "",
        "## Totals",
        f"- Artifacts (required): {total}",
        f"- Present: {present}",
        f"- Missing: {missing}",
        f"- Total size: {format_size(total_size)}",
        f"- Optional (ignored in counts): {', '.join(sorted(optional)) if optional else 'none'}",
    ]

    output_path.write_text("\n".join(lines) + "\n")
    print(f"Sitemap written to {output_path}")


if __name__ == "__main__":
    main()
