#!/usr/bin/env python3
"""
Validate that the snapshot CSV/JSON are aligned and that totals are consistent.

Checks performed:
- Required columns present in CSV and JSON.
- `Totals` row exists in both formats.
- Sum(status_checks/connections/overloaded) matches the Totals row.
- Non-total rows match between CSV and JSON (same log_file keys, same numbers).
- Overloaded ratio equals overloaded / connections when connections > 0.
"""
import argparse
import csv
import json
from pathlib import Path
from typing import Any, Dict, List, Tuple


REQUIRED_FIELDS = ["timestamp", "log_file", "status_checks", "connections", "overloaded", "overloaded_ratio"]


def parse_number(value: Any) -> Tuple[float, int]:
    """Return both float and int representations where possible."""
    f = float(value)
    try:
        i = int(value)
    except Exception:
        i = int(f)
    return f, i


def load_csv(path: Path) -> List[Dict[str, Any]]:
    if not path.exists():
        raise FileNotFoundError(f"CSV not found: {path}")
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        missing = set(REQUIRED_FIELDS) - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"CSV missing required fields: {', '.join(sorted(missing))}")
        rows = []
        for row in reader:
            parsed = {k: row[k] for k in REQUIRED_FIELDS}
            parsed["status_checks"], _ = parse_number(row["status_checks"])
            parsed["connections"], _ = parse_number(row["connections"])
            parsed["overloaded"], _ = parse_number(row["overloaded"])
            parsed["overloaded_ratio"] = float(row["overloaded_ratio"])
            rows.append(parsed)
        if not rows:
            raise ValueError(f"CSV is empty: {path}")
        return rows


def load_json(path: Path) -> List[Dict[str, Any]]:
    if not path.exists():
        raise FileNotFoundError(f"JSON not found: {path}")
    data = json.loads(path.read_text())
    if not isinstance(data, list):
        raise ValueError("JSON snapshot must be a list of rows")
    rows: List[Dict[str, Any]] = []
    for row in data:
        if not isinstance(row, dict):
            raise ValueError("JSON rows must be objects")
        missing = set(REQUIRED_FIELDS) - set(row.keys())
        if missing:
            raise ValueError(f"JSON row missing fields: {', '.join(sorted(missing))}")
        parsed = {k: row[k] for k in REQUIRED_FIELDS}
        parsed["status_checks"], _ = parse_number(row["status_checks"])
        parsed["connections"], _ = parse_number(row["connections"])
        parsed["overloaded"], _ = parse_number(row["overloaded"])
        parsed["overloaded_ratio"] = float(row["overloaded_ratio"])
        rows.append(parsed)
    if not rows:
        raise ValueError(f"JSON is empty: {path}")
    return rows


def totals_from_rows(rows: List[Dict[str, Any]]) -> Dict[str, float]:
    total_checks = sum(r["status_checks"] for r in rows if r["log_file"] != "Totals")
    total_conn = sum(r["connections"] for r in rows if r["log_file"] != "Totals")
    total_over = sum(r["overloaded"] for r in rows if r["log_file"] != "Totals")
    ratio = 0.0 if total_conn == 0 else total_over / total_conn
    return {
        "status_checks": total_checks,
        "connections": total_conn,
        "overloaded": total_over,
        "overloaded_ratio": ratio,
    }


def extract_totals(rows: List[Dict[str, Any]]) -> Dict[str, Any]:
    for row in rows:
        if str(row.get("log_file")) == "Totals":
            return row
    raise ValueError("Totals row not found")


def assert_close(lhs: float, rhs: float, tolerance: float, label: str):
    if abs(lhs - rhs) > tolerance:
        raise AssertionError(f"{label} mismatch: expected {rhs}, got {lhs}")


def verify_snapshot(csv_rows: List[Dict[str, Any]], json_rows: List[Dict[str, Any]], tolerance: float):
    csv_totals = extract_totals(csv_rows)
    json_totals = extract_totals(json_rows)
    computed = totals_from_rows(csv_rows)

    # Totals alignment between formats and computed sums
    for key in ("status_checks", "connections", "overloaded", "overloaded_ratio"):
        assert_close(csv_totals[key], json_totals[key], tolerance, f"Totals {key} csv/json")
        assert_close(csv_totals[key], computed[key], tolerance, f"Totals {key} vs computed")

    # Per-log rows alignment (excluding Totals)
    csv_map = {r["log_file"]: r for r in csv_rows if r["log_file"] != "Totals"}
    json_map = {r["log_file"]: r for r in json_rows if r["log_file"] != "Totals"}
    if set(csv_map.keys()) != set(json_map.keys()):
        raise AssertionError(f"Row set mismatch between CSV and JSON: {csv_map.keys()} vs {json_map.keys()}")
    for log_file, csv_row in csv_map.items():
        json_row = json_map[log_file]
        for key in ("status_checks", "connections", "overloaded", "overloaded_ratio"):
            assert_close(csv_row[key], json_row[key], tolerance, f"{log_file} {key}")
        expected_ratio = 0.0 if csv_row["connections"] == 0 else csv_row["overloaded"] / csv_row["connections"]
        assert_close(csv_row["overloaded_ratio"], expected_ratio, tolerance, f"{log_file} overloaded_ratio")


def main():
    parser = argparse.ArgumentParser(description="Check snapshot CSV/JSON consistency.")
    parser.add_argument("--reports", default=None, help="Reports directory (used when csv/json not provided)")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix (default: status_top2)")
    parser.add_argument("--csv", default=None, help="Path to snapshot CSV")
    parser.add_argument("--json", default=None, help="Path to snapshot JSON")
    parser.add_argument("--tolerance", type=float, default=1e-6, help="Numeric tolerance for comparisons")
    args = parser.parse_args()

    reports_dir = Path(args.reports) if args.reports else None
    csv_path = Path(args.csv) if args.csv else None
    json_path = Path(args.json) if args.json else None

    if reports_dir:
        csv_path = csv_path or reports_dir / f"log_metrics_snapshot.{args.suffix}.csv"
        json_path = json_path or reports_dir / f"log_metrics_snapshot.{args.suffix}.json"

    if not csv_path or not json_path:
        raise SystemExit("Provide --reports or both --csv and --json")

    csv_rows = load_csv(csv_path)
    json_rows = load_json(json_path)
    verify_snapshot(csv_rows, json_rows, args.tolerance)
    print(f"Snapshot OK: {csv_path} / {json_path}")


if __name__ == "__main__":
    main()
