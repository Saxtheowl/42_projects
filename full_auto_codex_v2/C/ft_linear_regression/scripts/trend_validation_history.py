#!/usr/bin/env python3
"""Analyze the validation history to detect drift in RMSE averages."""
from pathlib import Path
import re
import statistics


def parse_history(path: Path):
    pattern = re.compile(
        r"- \[(.*?)\]\(.*?\) \| best=(.*?) \| worst=(.*?) \| avg=(.*?)$"
    )
    rows = []
    for line in path.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line.strip())
        if not match:
            continue
        timestamp, best, worst, avg = match.groups()
        rows.append({
            "timestamp": timestamp,
            "best": float(best),
            "worst": float(worst),
            "average": float(avg),
        })
    return rows


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    history = root / "docs" / "validation_history.md"
    if not history.exists():
        raise SystemExit("validation history not found")

    entries = parse_history(history)
    if len(entries) < 2:
        raise SystemExit("not enough entries to analyze")

    avg_deltas = [
        entries[i]["average"] - entries[i - 1]["average"]
        for i in range(1, len(entries))
    ]
    rising = sum(1 for d in avg_deltas if d > 0)
    falling = sum(1 for d in avg_deltas if d < 0)
    mean_delta = statistics.mean(avg_deltas)

    best = min(entry["best"] for entry in entries)
    latest = entries[-1]
    worst = max(entry["worst"] for entry in entries)

    print("validation history trend")
    print("-------------------------")
    print(f"entries: {len(entries)}")
    print(f"latest timestamp: {latest['timestamp']}")
    print(f"best ever RMSE: {best:.2f}   worst ever RMSE: {worst:.2f}")
    print(f"average RMSE trend (latest - previous mean): {mean_delta:+.2f}")
    print(f"improvements: {falling}, regressions: {rising}")

    if mean_delta > 0.5:
        print("warning: average RMSE has increased significantly")
        raise SystemExit(1)
    elif mean_delta < -0.5:
        print("info: RMSE is trending downward")
    else:
        print("info: RMSE trend is stable")


if __name__ == "__main__":
    main()
