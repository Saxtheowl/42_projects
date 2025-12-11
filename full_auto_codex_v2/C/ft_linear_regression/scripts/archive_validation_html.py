#!/usr/bin/env python3
"""Archive the latest validation HTML snapshot for reference."""

from __future__ import annotations

import shutil
from datetime import datetime, timezone
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
HTML_PATH = BASE_DIR / "docs" / "validation_summary.html"
ARCHIVE_DIR = BASE_DIR / "docs" / "archive"


def main() -> int:
    if not HTML_PATH.exists():
        raise SystemExit(f"{HTML_PATH} missing (run validation_summary.py first)")
    ARCHIVE_DIR.mkdir(exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    dest = ARCHIVE_DIR / f"validation_summary_{stamp}.html"
    shutil.copy2(HTML_PATH, dest)
    print(f"Archived {dest.relative_to(BASE_DIR)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
