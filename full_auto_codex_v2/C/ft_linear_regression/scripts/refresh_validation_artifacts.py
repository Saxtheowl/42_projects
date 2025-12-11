#!/usr/bin/env python3
"""Refresh all validation summaries (preview, archive, prune, verify)."""

from __future__ import annotations

import subprocess
from pathlib import Path
from sys import executable, exit, stderr

BASE_DIR = Path(__file__).resolve().parent
PREVIEW = BASE_DIR / "preview_validation.py"
PRUNE = BASE_DIR / "prune_validation_archives.py"
VERIFY = BASE_DIR / "verify_archive_summary.py"
EXPORT = BASE_DIR / "export_validation_summary_csv.py"
EXPORT_YAML = BASE_DIR / "export_validation_summary_yaml.py"


def main() -> int:
    try:
        subprocess.run([executable, str(PREVIEW), "--archive"], check=True)
        subprocess.run([executable, str(PRUNE)], check=True)
        subprocess.run([executable, str(VERIFY)], check=True)
        subprocess.run([executable, str(EXPORT)], check=True)
        subprocess.run([executable, str(EXPORT_YAML)], check=True)
    except subprocess.CalledProcessError as exc:
        print(f"refresh pipeline failed: {exc}", file=stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
