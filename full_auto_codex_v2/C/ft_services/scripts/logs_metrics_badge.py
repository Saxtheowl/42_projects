#!/usr/bin/env python3
"""
Generate a compact SVG badge from the latest metrics snapshot.
Usage: logs_metrics_badge.py --reports reports --suffix status_top2 --output reports/log_metrics_badge.svg [--warn-overloaded-ratio 50] [--danger-overloaded-ratio 80] [--label metrics]
"""
import argparse
import csv
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Any, Tuple


def load_totals(csv_path: Path) -> Dict[str, Any]:
    with csv_path.open(newline="") as f:
        rows = list(csv.DictReader(f))
    if not rows:
        raise SystemExit(f"{csv_path}: empty CSV")
    totals = rows[-1]
    if totals.get("log_file") != "Totals":
        raise SystemExit(f"{csv_path}: missing Totals row")
    return {
        "timestamp": totals.get("timestamp"),
        "status_checks": float(totals.get("status_checks", 0) or 0),
        "connections": float(totals.get("connections", 0) or 0),
        "overloaded": float(totals.get("overloaded", 0) or 0),
        "overloaded_ratio": float(totals.get("overloaded_ratio", 0) or 0),
    }


def load_history(history_path: Path):
    if not history_path.exists():
        return []
    with history_path.open(newline="") as f:
        return list(csv.DictReader(f))


def load_anomalies_count(anomalies_json: Path) -> int:
    if not anomalies_json.exists():
        return 0
    try:
        data = json.loads(anomalies_json.read_text())
    except Exception:
        return 0
    return len(data) if isinstance(data, list) else 0


def classify_state(overloaded_ratio: float, anomalies: int, warn: float, danger: float) -> Tuple[str, str]:
    if anomalies > 0 or overloaded_ratio >= danger:
        return ("alerts", "#d9534f")  # red
    if overloaded_ratio >= warn:
        return ("warn", "#f0ad4e")  # orange
    return ("ok", "#4c1")  # green


def text_width(text: str, min_width: int = 60) -> int:
    # Rough monospace estimation (works well for badge layout)
    return max(min_width, int(len(text) * 7) + 12)


def build_badge(label: str, value: str, color: str, generated_at: str) -> str:
    left_w = text_width(label, 64)
    right_w = text_width(value, 120)
    width = left_w + right_w
    height = 20
    left_color = "#555"
    font_family = "DejaVu Sans,Verdana,Geneva,sans-serif"
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" role="img" aria-label="{label}: {value} (generated {generated_at})">
  <linearGradient id="s" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <mask id="m"><rect width="{width}" height="{height}" rx="3" fill="#fff"/></mask>
  <g mask="url(#m)">
    <rect width="{left_w}" height="{height}" fill="{left_color}"/>
    <rect x="{left_w}" width="{right_w}" height="{height}" fill="{color}"/>
    <rect width="{width}" height="{height}" fill="url(#s)"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="{font_family}" font-size="11">
    <text x="{left_w/2}" y="14" fill="#fff">{label}</text>
    <text x="{left_w + right_w/2}" y="14" fill="#fff">{value}</text>
  </g>
  <metadata>generated_at={generated_at}</metadata>
</svg>
"""


def main():
    parser = argparse.ArgumentParser(description="Generate an SVG badge from the latest metrics snapshot.")
    parser.add_argument("--reports", default="reports", help="Reports directory")
    parser.add_argument("--suffix", default="status_top2", help="Snapshot suffix (pattern_topN)")
    parser.add_argument("--output", default=None, help="Output SVG (default reports/log_metrics_badge.svg)")
    parser.add_argument("--warn-overloaded-ratio", type=float, default=50.0, help="Warn threshold for overloaded_ratio")
    parser.add_argument("--danger-overloaded-ratio", type=float, default=80.0, help="Danger threshold for overloaded_ratio")
    parser.add_argument("--label", default="metrics", help="Badge label (default: metrics)")
    parser.add_argument("--badge-gate", choices=["warn", "alert"], help="Optional gate: exit 1 if badge state >= gate")
    args = parser.parse_args()

    reports = Path(args.reports)
    base = reports / f"log_metrics_snapshot.{args.suffix}"
    csv_path = Path(f"{base}.csv")
    history_path = reports / "log_metrics_history.csv"
    anomalies_json = reports / "log_metrics_anomalies.json"
    output = Path(args.output) if args.output else reports / "log_metrics_badge.svg"

    if not csv_path.exists():
        raise SystemExit(f"CSV not found: {csv_path}")

    totals = load_totals(csv_path)
    history = load_history(history_path)
    anomalies_count = load_anomalies_count(anomalies_json)

    delta_ratio = None
    if len(history) >= 2:
        prev, curr = history[-2], history[-1]
        try:
            delta_ratio = float(curr.get("overloaded_ratio", 0) or 0) - float(prev.get("overloaded_ratio", 0) or 0)
        except Exception:
            delta_ratio = None

    state, color = classify_state(
        totals.get("overloaded_ratio", 0.0),
        anomalies_count,
        args.warn_overloaded_ratio,
        args.danger_overloaded_ratio,
    )

    message_parts = [
        f"{state} · {totals.get('overloaded_ratio', 0.0):.1f}% overloaded",
        f"{anomalies_count} anomalies" if anomalies_count else "0 anomalies",
        f"{len(history)} runs",
    ]
    if delta_ratio is not None:
        message_parts.append(f"Δ {delta_ratio:+.1f} pts")

    generated_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    svg = build_badge(args.label, " · ".join(message_parts), color, generated_at)
    output.write_text(svg)
    print(f"Badge written to {output}")

    if args.badge_gate:
        order = {"ok": 0, "warn": 1, "alerts": 2}
        gate_order = order.get(args.badge_gate, 1)
        state_order = order.get(state, 0)
        if state_order >= gate_order:
            raise SystemExit(f"badge_gate failed: state={state}, gate={args.badge_gate}")


if __name__ == "__main__":
    main()
