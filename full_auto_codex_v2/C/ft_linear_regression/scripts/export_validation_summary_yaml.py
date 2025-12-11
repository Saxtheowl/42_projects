#!/usr/bin/env python3
"""Export the validation summary JSON to YAML for copy/paste reports."""

from __future__ import annotations

import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
JSON_PATH = BASE_DIR / "docs" / "validation_summary.json"
YAML_PATH = BASE_DIR / "docs" / "validation_summary.yaml"


def main() -> int:
    if not JSON_PATH.exists():
        raise SystemExit(f"{JSON_PATH} missing (run validation_summary.py first)")
    data = json.loads(JSON_PATH.read_text())
    lines = [
        "validation_summary:",
        f"  timestamp: {data['timestamp']}",
        f"  fold_count: {data['fold_count']}",
        f"  best_rmse: {data['best_rmse']}",
        f"  worst_rmse: {data['worst_rmse']}",
        f"  average_rmse: {data['average_rmse']}",
    ]
    YAML_PATH.write_text("\n".join(lines))
    print(f"Wrote {YAML_PATH.relative_to(BASE_DIR)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
