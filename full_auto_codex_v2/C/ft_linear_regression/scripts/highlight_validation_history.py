#!/usr/bin/env python3
"""Highlight the top/bottom validation averages for quick review."""
from pathlib import Path
import re


def parse_history(path: Path):
    pattern = re.compile(r"- \[(.*?)\]\(.*?\) \| best=(.*?) \| worst=(.*?) \| avg=(.*?)$")
    entries = []
    for line in path.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line.strip())
        if not match:
            continue
        timestamp, best, worst, avg = match.groups()
        entries.append({
            "timestamp": timestamp,
            "best": float(best),
            "worst": float(worst),
            "average": float(avg),
        })
    return entries


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    history = root / "docs" / "validation_history.md"
    if not history.exists():
        raise SystemExit("validation history not found")

    entries = parse_history(history)
    if not entries:
        raise SystemExit("no history entries")

    best_avg = min(entries, key=lambda e: e["average"])
    worst_avg = max(entries, key=lambda e: e["average"])
    latest = entries[-1]

    print("validation history highlights")
    print("----------------------------")
    print(f"latest (avg): {latest['timestamp']} -> {latest['average']:.2f}")
    print(f"best average: {best_avg['timestamp']} -> {best_avg['average']:.2f} (best={best_avg['best']:.2f}, worst={best_avg['worst']:.2f})")
    print(f"worst average: {worst_avg['timestamp']} -> {worst_avg['average']:.2f} (best={worst_avg['best']:.2f}, worst={worst_avg['worst']:.2f})")

    highlight_path = root / "docs" / "validation_history_highlight.md"
    content = [
        "# Validation history highlights",
        "",
        f"- latest average: {latest['timestamp']} -> {latest['average']:.2f}",
        f"- best average: {best_avg['timestamp']} -> {best_avg['average']:.2f} (best={best_avg['best']:.2f}, worst={best_avg['worst']:.2f})",
        f"- worst average: {worst_avg['timestamp']} -> {worst_avg['average']:.2f} (best={worst_avg['best']:.2f}, worst={worst_avg['worst']:.2f})",
    ]
    highlight_path.write_text("\n".join(content), encoding="utf-8")
    print(f"Wrote {highlight_path}")


if __name__ == "__main__":
    main()
