#!/usr/bin/env python3
"""
Generate an SVG badge summarising the overall status snapshot.
Usage: logs_metrics_status_badge.py --status-json reports/log_metrics_status.json --output reports/log_metrics_status_badge.svg [--label status] [--gate warn|alert]
"""
import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Tuple


def text_width(text: str, min_width: int = 60) -> int:
    # Rough monospace estimation (good enough for badge layout)
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


def classify(overall: str) -> Tuple[str, str]:
    if overall == "alert":
        return overall, "#d9534f"
    if overall == "warn":
        return overall, "#f0ad4e"
    if overall == "ok":
        return overall, "#4c1"
    if overall == "missing":
        return overall, "#9e9e9e"
    return overall or "unknown", "#5bc0de"


def format_message(data: dict) -> str:
    parts = [f"overall {data.get('overall_state', 'n/a')}"]
    badge_state = data.get("badge_state")
    if badge_state:
        parts.append(f"badge {badge_state}")
    overloaded = data.get("overloaded_ratio")
    if overloaded is not None:
        try:
            parts.append(f"{float(overloaded):.1f}% overloaded")
        except Exception:
            pass
    anomalies = data.get("anomalies_count")
    if anomalies is not None:
        parts.append(f"{anomalies} anomalies")
    sitemap = data.get("sitemap", {})
    if isinstance(sitemap, dict) and sitemap.get("status"):
        parts.append(f"sitemap {sitemap.get('status')}")
    manifest = data.get("manifest", {})
    if isinstance(manifest, dict) and manifest.get("status"):
        parts.append(f"manifest {manifest.get('status')}")
    validation = data.get("validation", {})
    if isinstance(validation, dict) and validation.get("status"):
        mode = validation.get("mode")
        mode_part = f" ({mode})" if mode else ""
        parts.append(f"validation {validation.get('status')}{mode_part}")
    return " · ".join(parts)


def main():
    parser = argparse.ArgumentParser(description="Generate a status SVG badge from log_metrics_status.json.")
    parser.add_argument("--status-json", default="reports/log_metrics_status.json", help="Status JSON path")
    parser.add_argument("--output", default=None, help="Output SVG (default reports/log_metrics_status_badge.svg)")
    parser.add_argument("--label", default="status", help="Badge label (default: status)")
    parser.add_argument("--gate", choices=["warn", "alert"], help="Exit non-zero if overall status >= gate")
    args = parser.parse_args()

    status_path = Path(args.status_json)
    output = Path(args.output) if args.output else status_path.with_name("log_metrics_status_badge.svg")

    if not status_path.exists():
        raise SystemExit(f"status JSON not found: {status_path}")
    try:
        data = json.loads(status_path.read_text())
    except Exception as exc:  # pragma: no cover - defensive
        raise SystemExit(f"failed to read {status_path}: {exc}")

    overall = data.get("overall_state") or data.get("badge_state") or "unknown"
    overall_label, color = classify(overall)
    message = format_message(data)
    generated_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    badge = build_badge(args.label, message, color, generated_at)
    output.write_text(badge)
    print(f"Status badge written to {output}")

    if args.gate:
        order = {"ok": 0, "warn": 1, "missing": 1, "alert": 2}
        if order.get(overall_label, 0) >= order.get(args.gate, 1):
            raise SystemExit(f"gate failed: overall_state={overall_label} >= {args.gate}")


if __name__ == "__main__":
    main()
