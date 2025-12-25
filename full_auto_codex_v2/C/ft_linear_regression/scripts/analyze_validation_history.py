#!/usr/bin/env python3
"""Summarize metrics from docs/validation_history.md."""

from __future__ import annotations

from pathlib import Path
from typing import Iterable

HISTORY_PATH = Path(__file__).resolve().parent.parent / "docs" / "validation_history.md"


def iter_metrics(lines: Iterable[str]) -> Iterable[dict[str, float]]:
    for line in lines:
        if not line.strip() or line.startswith("| ---"):
            continue
        if "|" in line:
            parts = [part.strip() for part in line.split("|") if part.strip()]
            if len(parts) != 4:
                continue
            _, best_str, worst_str, avg_str = parts
            try:
                yield {
                    "best": float(best_str.split("=")[1]),
                    "worst": float(worst_str.split("=")[1]),
                    "average": float(avg_str.split("=")[1]),
                }
            except (IndexError, ValueError):
                continue


def main() -> int:
    if not HISTORY_PATH.exists():
        raise SystemExit(f"{HISTORY_PATH} missing")
    metrics = list(iter_metrics(HISTORY_PATH.read_text().splitlines()))
    if not metrics:
        print("no metrics found")
        return 1
    avg_values = [m["average"] for m in metrics]
    best_values = [m["best"] for m in metrics]
    worst_values = [m["worst"] for m in metrics]
    print("validation history summary:")
    print(f"- recorded entries: {len(metrics)}")
    print(f"- best RMSE seen: {min(best_values):.2f}")
    print(f"- worst RMSE seen: {max(worst_values):.2f}")
    print(f"- average RMSE range: {min(avg_values):.2f} .. {max(avg_values):.2f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
