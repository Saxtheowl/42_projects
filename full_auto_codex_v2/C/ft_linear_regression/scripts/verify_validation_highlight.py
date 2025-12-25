#!/usr/bin/env python3
"""Verify that highlight metrics match the logged validation history."""
from pathlib import Path
import re

HIST_PATTERN = re.compile(r"- \[(.*?)\].*avg=(.*?)$")
HIGHLIGHT_PATTERN = re.compile(r"- (latest|best|worst) average: (.*?) -> (.*)$")


def parse_history(path: Path):
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        match = HIST_PATTERN.search(line)
        if match:
            timestamp, avg = match.groups()
            rows.append((timestamp, float(avg)))
    return rows


def parse_highlight(path: Path):
    rows = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        match = HIGHLIGHT_PATTERN.match(line.strip())
        if match:
            label, timestamp, rest = match.groups()
            value = float(rest.split()[0])
            rows[label] = (timestamp, value)
    return rows


def main():
    root = Path(__file__).resolve().parent.parent
    history = root / "docs" / "validation_history.md"
    highlight = root / "docs" / "validation_history_highlight.md"
    if not history.exists() or not highlight.exists():
        raise SystemExit("missing history or highlight file")

    history_rows = parse_history(history)
    highlight_rows = parse_highlight(highlight)
    if not history_rows or len(highlight_rows) < 3:
        raise SystemExit("insufficient data")

    history_by_avg = sorted(history_rows, key=lambda x: x[1])
    expected_best = history_by_avg[0]
    expected_worst = history_by_avg[-1]
    latest = history_rows[-1]

    checks = [
        ("latest", latest),
        ("best", expected_best),
        ("worst", expected_worst),
    ]
    for label, expected in checks:
        actual = highlight_rows.get(label)
        if not actual:
            raise SystemExit(f"highlight missing {label}")
        if abs(actual[1] - expected[1]) > 1e-6:
            raise SystemExit(f"{label} avg mismatch: highlight {actual[1]} vs history {expected[1]}")
    print("highlight verified")


if __name__ == "__main__":
    main()
