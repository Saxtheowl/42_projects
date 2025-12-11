#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

DOCS_DIR = Path(__file__).resolve().parent.parent / "docs"
SUMMARY_TEXT_PATH = DOCS_DIR / "validation_summary.txt"
SUMMARY_JSON_PATH = DOCS_DIR / "validation_summary.json"

BEST_PATTERN = re.compile(r"best fold\s*[:]*\s*\d+\s*\(RMSE=([0-9.]+)\)", re.IGNORECASE)
WORST_PATTERN = re.compile(r"worst fold\s*[:]*\s*\d+\s*\(RMSE=([0-9.]+)\)", re.IGNORECASE)
AVG_PATTERN = re.compile(r"average\s+RMSE[:=]\s*([0-9.]+)", re.IGNORECASE)


def parse_summary(path: Path) -> tuple[float | None, float | None, float | None]:
    if not path.is_file():
        raise FileNotFoundError(f"{path} not found")
    best: float | None = None
    worst: float | None = None
    avg: float | None = None
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        if best is None:
            m = BEST_PATTERN.search(line)
            if m:
                best = float(m.group(1))
        if worst is None:
            m = WORST_PATTERN.search(line)
            if m:
                worst = float(m.group(1))
        if avg is None:
            m = AVG_PATTERN.search(line)
            if m:
                avg = float(m.group(1))
    return best, worst, avg


def parse_json_summary(path: Path) -> tuple[float, float, float]:
    if not path.is_file():
        raise FileNotFoundError(f"{path} not found")
    data = json.loads(path.read_text())
    return (float(data["best_rmse"]), float(data["worst_rmse"]), float(data["average_rmse"]))


def main() -> None:
    summary_source = "text"
    try:
        if SUMMARY_JSON_PATH.is_file():
            best, worst, avg = parse_json_summary(SUMMARY_JSON_PATH)
            summary_source = "json"
        else:
            best, worst, avg = parse_summary(SUMMARY_TEXT_PATH)
    except FileNotFoundError as exc:
        print(exc, file=sys.stderr)
        sys.exit(1)
    if avg is None:
        print("average RMSE missing in summary", file=sys.stderr)
        sys.exit(1)
    print(
        f"Validation summary (avg={avg:.2f}) best={best:.2f} worst={worst:.2f} "
        f"(source={summary_source})"
    )
    if avg > 1200:
        print(
            "Warning: average RMSE exceeded 1200 (consider rerunning with lower lr or early-stop)",
            file=sys.stderr,
        )
        sys.exit(1)
    sys.exit(0)


if __name__ == "__main__":
    main()
