#!/usr/bin/env python3
"""Ensure every archived HTML summary matches the current JSON metrics."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Sequence

ARCHIVE_DIR = Path(__file__).resolve().parent.parent / "docs" / "archive"
JSON_PATH = Path(__file__).resolve().parent.parent / "docs" / "validation_summary.json"


def parse_metrics_from_html(path: Path) -> dict[str, float]:
    lines = path.read_text().splitlines()
    metrics = {}
    for line in lines:
        line = line.strip()
        if "<tr>" in line and "<td>" in line:
            cols = line.split("<td>")
            if len(cols) >= 3:
                label = cols[1].split("<")[0].strip()
                value = cols[2].split("<")[0].strip()
                try:
                    metrics[label.lower()] = float(value)
                except ValueError:
                    continue
    return metrics


def compare_metrics(archive: Path, expected: dict[str, float]) -> bool:
    metrics = parse_metrics_from_html(archive)
    for key, value in expected.items():
        archived_value = metrics.get(key)
        if archived_value is None or abs(archived_value - value) > 0.01:
            print(f"{archive.name} mismatch {key}: {archived_value} vs {value}")
            return False
    return True


def main(archives: Sequence[Path]) -> int:
    if not JSON_PATH.exists():
        print(f"{JSON_PATH} missing")
        return 1
    data = json.loads(JSON_PATH.read_text())
    expected = {
        "best rmse": float(data["best_rmse"]),
        "worst rmse": float(data["worst_rmse"]),
        "average rmse": float(data["average_rmse"]),
    }
    for archive in archives:
        if not compare_metrics(archive, expected):
            return 1
    print(f"verified {len(archives)} archives")
    return 0


if __name__ == "__main__":
    archives = sorted(ARCHIVE_DIR.glob("validation_summary_*.html"))
    raise SystemExit(main(archives))
