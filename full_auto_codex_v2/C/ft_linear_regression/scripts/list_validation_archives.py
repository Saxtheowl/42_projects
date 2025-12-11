#!/usr/bin/env python3
"""List archived validation summary HTML snapshots."""

from __future__ import annotations

from pathlib import Path

ARCHIVE_DIR = Path(__file__).resolve().parent.parent / "docs" / "archive"


def main() -> int:
    if not ARCHIVE_DIR.is_dir():
        print("no archive directory yet", file=__import__("sys").stderr)
        return 1
    entries = sorted(ARCHIVE_DIR.glob("validation_summary_*.html"))
    if not entries:
        print("archive directory empty", file=__import__("sys").stderr)
        return 1
    print("Archived validation snapshots:")
    for entry in entries:
        print(f"- {entry.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
