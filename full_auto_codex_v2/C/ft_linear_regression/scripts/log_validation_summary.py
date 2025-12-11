#!/usr/bin/env python3
"""Log the current validation summary into docs/validation_history.md."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
JSON_PATH = BASE_DIR / "docs" / "validation_summary.json"
HISTORY_PATH = BASE_DIR / "docs" / "validation_history.md"


def main() -> int:
    if not JSON_PATH.exists():
        raise SystemExit(f"{JSON_PATH} missing")
    data = json.loads(JSON_PATH.read_text())
    timestamp = datetime.fromisoformat(data["timestamp"]).astimezone(timezone.utc)
    line = (
        f"- [{timestamp.isoformat()}Z](./validation_summary.html) | "
        f"best={data['best_rmse']:.2f} | worst={data['worst_rmse']:.2f} | avg={data['average_rmse']:.2f}"
    )
    if HISTORY_PATH.exists():
        history = HISTORY_PATH.read_text()
    else:
        history = "# Validation history\n\n| Timestamp | Best RMSE | Worst RMSE | Average RMSE |\n| --- | --- | --- | --- |\n"
    if line not in history:
        history += line + "\n"
        HISTORY_PATH.write_text(history)
        print(f"Logged validation summary to {HISTORY_PATH.relative_to(BASE_DIR)}")
    else:
        print("Current summary already logged")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
