#!/usr/bin/env python3
"""Ensure validation history entries remain chronological."""

from __future__ import annotations

import re
from datetime import datetime
from pathlib import Path
from sys import exit

HISTORY_PATH = Path(__file__).resolve().parent.parent / "docs" / "validation_history.md"
TIMESTAMP_PATTERN = re.compile(r"\|\s*\[(.+?)\]")


def main() -> int:
    if not HISTORY_PATH.exists():
        raise SystemExit(f"{HISTORY_PATH} missing")
    entries = []
    for line in HISTORY_PATH.read_text().splitlines():
        match = TIMESTAMP_PATTERN.search(line)
        if match:
            ts = match.group(1)
            entries.append(datetime.fromisoformat(ts.rstrip("Z")))
    if entries != sorted(entries):
        print("validation history entries are not chronological", file=__import__("sys").stderr)
        return 1
    print("validation history is chronological")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
