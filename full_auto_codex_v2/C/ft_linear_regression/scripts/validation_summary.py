#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from functools import reduce
from datetime import datetime
from pathlib import Path


FOLD_PATTERN = re.compile(r"fold\s+(\d+):\s+RMSE=([0-9.]+)", re.IGNORECASE)
AVG_PATTERN = re.compile(r"average\s+RMSE\s+across\s+folds:\s+([0-9.]+)", re.IGNORECASE)


@dataclass
class FoldStat:
    fold: int
    rmse: float


def parse_report(text: str) -> tuple[list[FoldStat], float | None]:
    folds: list[FoldStat] = []
    avg_rmse: float | None = None
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        m = FOLD_PATTERN.search(line)
        if m:
            folds.append(FoldStat(fold=int(m.group(1)), rmse=float(m.group(2))))
            continue
        m = AVG_PATTERN.search(line)
        if m:
            avg_rmse = float(m.group(1))
    return folds, avg_rmse


def summarize(folds: list[FoldStat], average: float | None) -> str:
    if not folds:
        return "No fold stats found."
    best = min(folds, key=lambda f: f.rmse)
    worst = max(folds, key=lambda f: f.rmse)
    lines = [
        f"fold count: {len(folds)}",
        f"best fold: {best.fold} (RMSE={best.rmse:.2f})",
        f"worst fold: {worst.fold} (RMSE={worst.rmse:.2f})",
    ]
    if average is not None:
        lines.append(f"average RMSE: {average:.2f}")
    return "\n".join(lines)


def best_fold(folds: list[FoldStat]) -> FoldStat | None:
    if not folds:
        return None
    return min(folds, key=lambda f: f.rmse)


def worst_fold(folds: list[FoldStat]) -> FoldStat | None:
    if not folds:
        return None
    return max(folds, key=lambda f: f.rmse)


def main() -> None:
    parser = argparse.ArgumentParser(description="Summarize validation report for ft_linear_regression")
    parser.add_argument("--report", type=Path, default=Path("data/validation_report.txt"))
    parser.add_argument("--output", type=Path, default=None)
    parser.add_argument("--markdown", type=Path, default=None)
    parser.add_argument("--json", type=Path, default=None)
    args = parser.parse_args()

    if not args.report.is_file():
        raise SystemExit(f"{args.report} not found")
    content = args.report.read_text()
    folds, avg = parse_report(content)
    summary = summarize(folds, avg)
    timestamp = datetime.fromtimestamp(args.report.stat().st_mtime).isoformat()
    summary_text = f"validation report: {args.report.name} (updated {timestamp})\n{summary}"
    if args.output:
        args.output.write_text(summary_text)
    if args.markdown:
        md_lines = [
            f"# Validation summary ({timestamp})",
            "",
            "| Metric | Value |",
            "| --- | --- |",
            f"| Fold count | {len(folds)} |",
        ]
        best = best_fold(folds)
        worst = worst_fold(folds)
        md_lines.append(f"| Best fold RMSE | {best.rmse:.2f} |" if best else "| Best fold RMSE | n/a |")
        md_lines.append(f"| Worst fold RMSE | {worst.rmse:.2f} |" if worst else "| Worst fold RMSE | n/a |")
        if avg is not None:
            md_lines.append(f"| Average RMSE | {avg:.2f} |")
        args.markdown.write_text("\n".join(md_lines))
    if args.json:
        payload = {
            "timestamp": timestamp,
            "fold_count": len(folds),
            "best_rmse": best.rmse if best else None,
            "worst_rmse": worst.rmse if worst else None,
            "average_rmse": avg,
        }
        args.json.write_text(json.dumps(payload, indent=2))
        html_script = Path(__file__).resolve().parent / "validation_summary_html.py"
        try:
            subprocess.run([sys.executable, str(html_script)], check=True)
        except subprocess.CalledProcessError as exc:
            raise SystemExit(f"validation_summary_html failed: {exc}")
    print(summary_text)


if __name__ == "__main__":
    main()
