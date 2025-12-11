#!/usr/bin/env python3
"""Compare two archived validation summary HTML snapshots."""

from __future__ import annotations

import argparse
import difflib
from pathlib import Path
from sys import stderr

ARCHIVE_DIR = Path(__file__).resolve().parent.parent / "docs" / "archive"


def main() -> int:
    parser = argparse.ArgumentParser(description="Diff two archived validation snapshots")
    parser.add_argument("left", type=Path, help="First archive filename")
    parser.add_argument("right", type=Path, help="Second archive filename")
    args = parser.parse_args()
    left = ARCHIVE_DIR / args.left
    right = ARCHIVE_DIR / args.right
    if not left.exists() or not right.exists():
        print("one of the archives is missing", file=stderr)
        return 1
    left_text = left.read_text().splitlines()
    right_text = right.read_text().splitlines()
    diff = difflib.unified_diff(left_text, right_text, fromfile=left.name, tofile=right.name)
    printed = False
    for line in diff:
        printed = True
        print(line)
    if not printed:
        print("no differences found")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
