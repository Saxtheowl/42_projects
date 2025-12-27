#!/usr/bin/env python3
"""
Generate a JSON sitemap of metrics artifacts using the manifest if available.
"""
import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Any, List


def load_manifest(path: Path) -> Dict[str, Any]:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text())
    except Exception:
        return {}


def main():
    parser = argparse.ArgumentParser(description="Generate a JSON sitemap of metrics artifacts.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--manifest", default=None, help="Manifest JSON path (default: reports/log_metrics_manifest.json)")
    parser.add_argument("--output", default=None, help="Output JSON path (default: reports/log_metrics_sitemap.json)")
    parser.add_argument("--fail-on-missing", action="store_true", help="Return non-zero if any artifact is missing")
    parser.add_argument(
        "--optional",
        default="compare_md,compare_html,checksums_guard",
        help="Comma-separated optional artifacts to ignore in totals/missing (default: compare_md,compare_html,checksums_guard)",
    )
    args = parser.parse_args()

    reports = Path(args.reports)
    manifest_path = Path(args.manifest) if args.manifest else reports / "log_metrics_manifest.json"
    output_path = Path(args.output) if args.output else reports / "log_metrics_sitemap.json"

    manifest = load_manifest(manifest_path)
    paths = manifest.get("paths", {}) if isinstance(manifest, dict) else {}
    # Optional artifacts are not counted as missing
    optional = set(filter(None, [part.strip() for part in args.optional.split(",")]))

    artifacts: List[Dict[str, Any]] = []
    total_size = 0
    present = 0
    total = 0
    missing_paths: List[str] = []
    for name, entry in sorted(paths.items()):
        path_label = entry.get("path") or name
        exists = bool(entry.get("exists"))
        size = int(entry.get("size") or 0)
        sha = entry.get("sha256") or ""
        if name not in optional:
            total += 1
        artifacts.append(
            {
                "name": name,
                "path": path_label,
                "exists": exists,
                "size": size,
                "sha256": sha,
            }
        )
        if name in optional:
            continue
        total_size += size
        if exists:
            present += 1
        else:
            missing_paths.append(path_label)

    data = {
        "generated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "reports": str(reports),
        "manifest": str(manifest_path),
        "summary": {
            "artifacts": total,
            "present": present,
            "missing": max(total - present, 0),
            "total_size_bytes": total_size,
            "missing_paths": missing_paths,
            "optional_artifacts": sorted(optional),
        },
        "artifacts": artifacts,
    }
    output_path.write_text(json.dumps(data, indent=2))
    print(f"Sitemap JSON written to {output_path}")
    if args.fail_on_missing and missing_paths:
        raise SystemExit(f"Missing artifacts detected: {len(missing_paths)}")


if __name__ == "__main__":
    main()
