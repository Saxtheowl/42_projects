#!/usr/bin/env python3
"""Run the validation summary + stability check in one go."""

from __future__ import annotations

import subprocess
from pathlib import Path
from sys import exit, executable, stderr

BASE_DIR = Path(__file__).resolve().parent
REPORT_PATH = BASE_DIR.parent / "data" / "validation_report.txt"
SUMMARY_SCRIPT = BASE_DIR / "validation_summary.py"
CHECK_SCRIPT = BASE_DIR / "check_validation_stability.py"

import argparse

SUMMARY_ARGS = [
    SUMMARY_SCRIPT,
    "--report",
    str(REPORT_PATH),
    "--output",
    str(BASE_DIR.parent / "docs" / "validation_summary.txt"),
    "--markdown",
    str(BASE_DIR.parent / "docs" / "validation_summary.md"),
    "--json",
    str(BASE_DIR.parent / "docs" / "validation_summary.json"),
]


def main() -> int:
    parser = argparse.ArgumentParser(description="Run the validation summary + stability check in one go")
    parser.add_argument(
        "--archive",
        action="store_true",
        help="archive the generated HTML snapshot (`scripts/archive_validation_html.py`)",
    )
    args = parser.parse_args()
    if not REPORT_PATH.exists():
        print(f"missing validation report: {REPORT_PATH}", file=stderr)
        return 1
    try:
        subprocess.run([executable, *SUMMARY_ARGS], check=True)
        subprocess.run([executable, str(CHECK_SCRIPT)], check=True)
        if args.archive:
            archive_script = BASE_DIR / "archive_validation_html.py"
            subprocess.run([executable, str(archive_script)], check=True)
    except subprocess.CalledProcessError as exc:
        print(f"validation preview failed: {exc}", file=stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
