#!/usr/bin/env python3
"""Generate a small HTML report from the validation summary JSON."""

from __future__ import annotations

import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
JSON_PATH = BASE_DIR / "docs" / "validation_summary.json"
HTML_PATH = BASE_DIR / "docs" / "validation_summary.html"


def format_number(value: float | int | None) -> str:
    if value is None:
        return "n/a"
    if isinstance(value, int):
        return str(value)
    return f"{value:.2f}"


def render_html(data: dict[str, str | float | int | None]) -> str:
    return f"""<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>Validation summary</title>
  <style>
    body {{ font-family: system-ui, sans-serif; padding: 1rem; }}
    table {{ border-collapse: collapse; width: min(28rem, 100%); }}
    th, td {{ border: 1px solid #444; padding: 0.5rem 0.75rem; }}
    th {{ background: #f4f4f4; text-align: left; }}
  </style>
</head>
<body>
  <h1>Validation summary snapshot</h1>
  <p>Extrait généré depuis <code>{JSON_PATH.name}</code>.</p>
  <table>
    <tr><th>Metric</th><th>Value</th></tr>
    <tr><td>Timestamp</td><td>{data["timestamp"]}</td></tr>
    <tr><td>Fold count</td><td>{data["fold_count"]}</td></tr>
    <tr><td>Best RMSE</td><td>{format_number(data.get("best_rmse"))}</td></tr>
    <tr><td>Worst RMSE</td><td>{format_number(data.get("worst_rmse"))}</td></tr>
    <tr><td>Average RMSE</td><td>{format_number(data.get("average_rmse"))}</td></tr>
    <tr><td>Median RMSE</td><td>{format_number(data.get("median_rmse"))}</td></tr>
    <tr><td>Stddev RMSE</td><td>{format_number(data.get("stddev_rmse"))}</td></tr>
    <tr><td>Bootstrap samples</td><td>{format_number(data.get("bootstrap_samples"))}</td></tr>
    <tr><td>Bootstrap average RMSE</td><td>{format_number(data.get("bootstrap_average_rmse"))}</td></tr>
  </table>
</body>
</html>
"""


def main() -> int:
    if not JSON_PATH.exists():
        raise SystemExit(f"{JSON_PATH} missing")
    data = json.loads(JSON_PATH.read_text())
    HTML_PATH.write_text(render_html(data), encoding="utf-8")
    print(f"Wrote {HTML_PATH.relative_to(BASE_DIR)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
