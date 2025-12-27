#!/usr/bin/env python3
"""
Verify that the sitemap JSON has no missing required artifacts.
Returns non-zero if missing > 0 or the file is invalid.
"""
import argparse
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description="Verify sitemap JSON has no missing required artifacts.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--sitemap", default=None, help="Sitemap JSON path (default: reports/log_metrics_sitemap.json)")
    parser.add_argument(
        "--manifest",
        default=None,
        help="Manifest JSON path (default: derived from the sitemap 'manifest' field or reports/log_metrics_manifest.json)",
    )
    parser.add_argument(
        "--optional",
        default=None,
        help="Comma-separated optional artifact names to ignore when computing missing (overrides the summary optional list)",
    )
    parser.add_argument(
        "--strict-summary",
        action="store_true",
        help="Fail if manifest recompute does not match the sitemap summary (required/present). By défaut, un écart est affiché en warning.",
    )
    args = parser.parse_args()

    reports_dir = Path(args.reports)
    sitemap_path = Path(args.sitemap) if args.sitemap else reports_dir / "log_metrics_sitemap.json"
    if not sitemap_path.exists():
        raise SystemExit(f"{sitemap_path}: not found")

    try:
        data = json.loads(sitemap_path.read_text())
    except Exception as exc:
        raise SystemExit(f"{sitemap_path}: invalid JSON ({exc})")

    summary = data.get("summary") or {}
    missing_paths = summary.get("missing_paths") or []
    optional_summary = summary.get("optional_artifacts") or []
    optional_override = []
    if args.optional:
        optional_override = [part.strip() for part in args.optional.split(",") if part.strip()]
    optional_effective = optional_override if optional_override else optional_summary
    optional_key_set = set(optional_effective)
    optional_path_set = {Path(name).name for name in optional_effective}

    filtered_missing = []
    ignored_missing = []
    for path in missing_paths:
        name = Path(path).name
        if name in optional_path_set or name in optional_key_set:
            ignored_missing.append(path)
        else:
            filtered_missing.append(path)
    missing_summary = len(filtered_missing)
    present_summary = summary.get("present") or 0
    artifacts_summary = summary.get("artifacts") or 0

    manifest_path = None
    if args.manifest:
        manifest_path = Path(args.manifest)
    elif data.get("manifest"):
        manifest_field = Path(data["manifest"])
        if manifest_field.is_absolute():
            manifest_path = manifest_field
        elif manifest_field.parts and manifest_field.parts[0] == reports_dir.name:
            manifest_path = reports_dir.parent / manifest_field
        else:
            manifest_path = reports_dir / manifest_field
    else:
        manifest_path = reports_dir / "log_metrics_manifest.json"

    manifest_missing = None
    manifest_present = None
    manifest_required_total = None
    manifest_missing_paths = None
    if manifest_path and manifest_path.exists():
        try:
            manifest_data = json.loads(manifest_path.read_text())
            paths = manifest_data.get("paths") or {}
            manifest_missing_paths = []
            manifest_present = 0
            manifest_required_total = 0
            manifest_size = 0
            for name, info in paths.items():
                path_str = info.get("path") or name
                path_name = Path(path_str).name
                if path_name in optional_path_set or name in optional_key_set:
                    continue
                manifest_required_total += 1
                if info.get("exists"):
                    manifest_size += info.get("size") or 0
                    manifest_present += 1
                else:
                    manifest_missing_paths.append(path_str)
            manifest_missing = len(manifest_missing_paths)
        except Exception as exc:
            print(f"Warning: unable to load manifest {manifest_path}: {exc}")
            manifest_path = None

    print(f"Reports dir: {reports_dir}")
    print(f"Sitemap: {sitemap_path}")
    print(f"Sitemap summary (required): {summary.get('artifacts','n/a')}, present: {summary.get('present','n/a')}, missing: {missing_summary}")
    if optional_effective:
        print(f"Optional (ignored): {', '.join(optional_effective)}")
    if ignored_missing:
        print("Missing paths ignored (optional):")
        for path in ignored_missing:
            print(f"- {path}")
    if filtered_missing:
        print("Missing paths:")
        for path in filtered_missing:
            print(f"- {path}")

    final_missing_paths = filtered_missing
    final_missing = missing_summary

    if manifest_path:
        print(f"Manifest used for recompute: {manifest_path}")
        if manifest_missing_paths is not None:
            print(
                f"Manifest recompute (required): {manifest_required_total}, present: {manifest_present}, missing: {manifest_missing}"
            )
            if manifest_missing_paths:
                print("Missing paths (manifest recompute):")
                for path in manifest_missing_paths:
                    print(f"- {path}")
            final_missing_paths = manifest_missing_paths
            final_missing = manifest_missing
            mismatch = False
            if artifacts_summary != manifest_required_total:
                print(
                    f"WARNING: Sitemap summary required ({artifacts_summary}) != manifest required ({manifest_required_total})"
                )
                mismatch = True
            if present_summary != manifest_present:
                print(
                    f"WARNING: Sitemap summary present ({present_summary}) != manifest present ({manifest_present})"
                )
                mismatch = True
            if mismatch and args.strict_summary:
                raise SystemExit(1)

    if final_missing and final_missing > 0:
        raise SystemExit(1)
    print("Sitemap verification OK (no missing required artifacts).")


if __name__ == "__main__":
    main()
