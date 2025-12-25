#!/usr/bin/env python3
"""Generate a markdown index of archived validation summaries."""

from __future__ import annotations

import re
from datetime import datetime
from pathlib import Path

ARCHIVE_DIR = Path(__file__).resolve().parent.parent / "docs" / "archive"
OUTPUT = ARCHIVE_DIR / "index.md"

TABLE_PATTERN = re.compile(r"<tr><td>([^<]+)</td><td>([0-9.]+)</td></tr>")


def extract_metrics(path: Path) -> dict[str, float]:
    text = path.read_text()
    metrics: dict[str, float] = {}
    for match in TABLE_PATTERN.finditer(text):
        label = match.group(1).strip()
        value = float(match.group(2))
        metrics[label] = value
    return metrics


def main() -> int:
    entries = sorted(ARCHIVE_DIR.glob("validation_summary_*.html"))
    if not entries:
        raise SystemExit("no archives found")
    lines = [
        "# Archive index",
        "",
        "| File | Timestamp | Best RMSE | Worst RMSE | Average RMSE |",
        "| --- | --- | --- | --- | --- |",
    ]
    for entry in entries:
        stamp = entry.stem.split("_")[-1]
        dt = datetime.strptime(stamp, "%Y%m%dT%H%M%SZ")
        metrics = extract_metrics(entry)
        best = metrics.get("Best RMSE", 0.0)
        worst = metrics.get("Worst RMSE", 0.0)
        avg = metrics.get("Average RMSE", 0.0)
        lines.append(
            f"| [{entry.name}]({entry.name}) | {dt.isoformat()}Z | {best:.2f} | {worst:.2f} | {avg:.2f} |"
        )
    OUTPUT.write_text("\n".join(lines))
    print(f"Wrote archive index to {OUTPUT.relative_to(ARCHIVE_DIR.parent)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
