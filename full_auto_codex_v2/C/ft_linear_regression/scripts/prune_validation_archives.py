#!/usr/bin/env python3
"""Remove archived validation summary HTML snapshots older than X days."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
from pathlib import Path

ARCHIVE_DIR = Path(__file__).resolve().parent.parent / "docs" / "archive"


def main() -> int:
    parser = argparse.ArgumentParser(description="Clean old validation summary archives")
    parser.add_argument(
        "--days",
        type=int,
        default=30,
        help="Keep snapshots newer than this number of days (default: 30)",
    )
    args = parser.parse_args()
    if not ARCHIVE_DIR.exists():
        print("archive directory missing; nothing to prune")
        return 0
    threshold = datetime.now(timezone.utc).timestamp() - args.days * 86400
    removed = []
    for path in ARCHIVE_DIR.glob("validation_summary_*.html"):
        if path.stat().st_mtime < threshold:
            removed.append(path.name)
            path.unlink()
    if removed:
        print("pruned archives:")
        for name in sorted(removed):
            print(f"- {name}")
        return 0
    print("no archives older than threshold")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
