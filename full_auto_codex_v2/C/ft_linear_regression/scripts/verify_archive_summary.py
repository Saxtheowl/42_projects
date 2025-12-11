#!/usr/bin/env python3
"""Compare the latest archived HTML summary against the current JSON snapshot."""

from __future__ import annotations

import json
import re
from pathlib import Path
from sys import exit, stderr

ARCHIVE_DIR = Path(__file__).resolve().parent.parent / "docs" / "archive"
JSON_PATH = Path(__file__).resolve().parent.parent / "docs" / "validation_summary.json"

METRIC_PATTERN = re.compile(r"<tr><td>([^<]+)</td><td>([0-9.]+)</td></tr>")


def parse_html(path: Path) -> dict[str, float]:
    if not path.exists():
        raise FileNotFoundError(f"{path} not found")
    text = path.read_text()
    metrics: dict[str, float] = {}
    for match in METRIC_PATTERN.finditer(text):
        label = match.group(1).strip().lower()
        value = float(match.group(2))
        metrics[label] = value
    return metrics


def main() -> int:
    if not JSON_PATH.exists():
        print(f"{JSON_PATH} missing", file=stderr)
        return 1
    if not ARCHIVE_DIR.exists():
        print("no archive directory", file=stderr)
        return 1
    archives = sorted(ARCHIVE_DIR.glob("validation_summary_*.html"))
    if not archives:
        print("no archived summaries to verify", file=stderr)
        return 1
    latest = archives[-1]
    archive_metrics = parse_html(latest)
    data = json.loads(JSON_PATH.read_text())
    expected = {
        "best rmse": float(data["best_rmse"]),
        "worst rmse": float(data["worst_rmse"]),
        "average rmse": float(data["average_rmse"]),
    }
    mismatch = False
    for key, value in expected.items():
        archived = archive_metrics.get(key)
        if archived is None or abs(archived - value) > 0.01:
            print(f"mismatch {key}: json={value:.2f} html={archived!r}", file=stderr)
            mismatch = True
    if mismatch:
        return 1
    print(f"{latest.name} matches {JSON_PATH.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
