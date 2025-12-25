#!/usr/bin/env python3
"""
Verify that a checksums file matches actual files (and manifest entries).
Usage: logs_metrics_verify_checksums.py --reports reports --suffix status_top2 --checksums reports/log_metrics_checksums.txt --manifest reports/log_metrics_manifest.json
"""
import argparse
import hashlib
import json
from pathlib import Path
from typing import Dict


def load_checksums(path: Path) -> Dict[str, str]:
    table: Dict[str, str] = {}
    with path.open() as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split()
            if len(parts) < 2:
                raise SystemExit(f"{path}: malformed line '{line}'")
            digest, file_path = parts[0], " ".join(parts[1:])
            table[file_path] = digest
    return table


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def verify_manifest(manifest: Path, checksums: Dict[str, str], reports_dir: Path):
    data = json.loads(manifest.read_text())
    paths = data.get("paths", {})
    missing_entries = []
    mismatches = []
    for key, entry in paths.items():
        if key == "checksums":
            continue
        rel_path = entry.get("path")
        exists = entry.get("exists")
        if not exists or not rel_path:
            continue
        abs_path = reports_dir / rel_path
        if not abs_path.exists():
            missing_entries.append(rel_path)
            continue
        if rel_path not in checksums:
            missing_entries.append(rel_path)
            continue
        expected = checksums[rel_path]
        actual = sha256(abs_path)
        if expected != actual:
            mismatches.append((rel_path, expected, actual))
    if missing_entries:
        raise SystemExit(f"Checksums missing for: {', '.join(missing_entries)}")
    if mismatches:
        msgs = [f"{path} (expected {exp}, got {act})" for path, exp, act in mismatches]
        raise SystemExit("Checksum mismatch: " + "; ".join(msgs))


def main():
    parser = argparse.ArgumentParser(description="Verify checksums file against actual files and manifest.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix")
    parser.add_argument("--checksums", default=None, help="Checksums file (default reports/log_metrics_checksums.txt)")
    parser.add_argument("--manifest", default=None, help="Manifest file (default reports/log_metrics_manifest.json)")
    args = parser.parse_args()

    reports_dir = Path(args.reports)
    checksums_path = Path(args.checksums) if args.checksums else reports_dir / "log_metrics_checksums.txt"
    manifest_path = Path(args.manifest) if args.manifest else reports_dir / "log_metrics_manifest.json"

    if not checksums_path.exists():
        raise SystemExit(f"Checksums file not found: {checksums_path}")
    if not manifest_path.exists():
        raise SystemExit(f"Manifest file not found: {manifest_path}")

    checksums = load_checksums(checksums_path)
    verify_manifest(manifest_path, checksums, reports_dir)
    print("Checksums verification OK")


if __name__ == "__main__":
    main()
