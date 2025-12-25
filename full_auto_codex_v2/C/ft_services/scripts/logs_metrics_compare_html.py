#!/usr/bin/env python3
"""
Compare two metrics CSV snapshots and produce an HTML diff report.
Usage: logs_metrics_compare_html.py --base reports/log_metrics_snapshot.status_top2.csv --target reports/log_metrics_snapshot.status_top2.csv [--output reports/log_metrics_compare.html]
"""
import argparse
import csv
from pathlib import Path

FIELDS = ["status_checks", "connections", "overloaded", "overloaded_ratio"]


def load_csv(path: Path):
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = {row["log_file"]: row for row in reader}
    if "Totals" not in rows:
        raise SystemExit(f"Missing Totals in {path}")
    return rows


def diff(base_rows, target_rows):
    all_keys = set(base_rows.keys()) | set(target_rows.keys())
    entries = []
    for key in sorted(all_keys):
        base = base_rows.get(key)
        target = target_rows.get(key)
        entry = {"log_file": key}
        for field in FIELDS:
            b_val = float(base.get(field, 0)) if base else 0.0
            t_val = float(target.get(field, 0)) if target else 0.0
            entry[f"{field}_base"] = b_val
            entry[f"{field}_target"] = t_val
            entry[f"{field}_delta"] = t_val - b_val
        entries.append(entry)
    return entries


def write_html(entries, base_path, target_path, output_path):
    headers = [
        "log_file",
        "status_base",
        "status_target",
        "Δstatus",
        "connections_base",
        "connections_target",
        "Δconnections",
        "overloaded_base",
        "overloaded_target",
        "Δoverloaded",
        "ratio_base",
        "ratio_target",
        "Δratio",
    ]
    head = "<tr>" + "".join(f"<th>{h}</th>" for h in headers) + "</tr>"
    body = "\n".join(
        "<tr>"
        + "".join(f"<td>{e.get('log_file') if h=='log_file' else e.get(h.replace('Δ','delta').replace('status','status_checks'), ''):.2f if isinstance(e.get(h.replace('Δ','delta').replace('status','status_checks'),''), (int,float)) else e.get(h.replace('Δ','delta').replace('status','status_checks'),'')}</td>" for h in headers)
        + "</tr>"
        for e in entries
    )
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Log Metrics Diff</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 24px; }}
    h1 {{ margin-bottom: 0; }}
    .meta {{ color: #555; margin-bottom: 16px; }}
    table {{ border-collapse: collapse; width: 100%; }}
    th, td {{ border: 1px solid #ddd; padding: 6px; text-align: left; }}
    th {{ background: #f4f4f4; }}
  </style>
</head>
<body>
  <h1>Log Metrics Diff</h1>
  <div class="meta">Base: {base_path} | Target: {target_path}</div>
  <table>
    {head}
    {body}
  </table>
</body>
</html>
"""
    Path(output_path).write_text(html)
    print(f"Diff HTML written to {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Compare two metrics CSV snapshots and output an HTML diff.")
    parser.add_argument("--base", required=True, help="Base CSV snapshot")
    parser.add_argument("--target", required=True, help="Target CSV snapshot")
    parser.add_argument("--output", help="Output HTML file (default: reports/log_metrics_compare.html)")
    args = parser.parse_args()

    base_path = Path(args.base)
    target_path = Path(args.target)
    if not base_path.exists():
        raise SystemExit(f"Base file {base_path} not found")
    if not target_path.exists():
        raise SystemExit(f"Target file {target_path} not found")

    output = Path(args.output) if args.output else Path("reports/log_metrics_compare.html")
    base_rows = load_csv(base_path)
    target_rows = load_csv(target_path)
    entries = diff(base_rows, target_rows)
    write_html(entries, base_path, target_path, output)


if __name__ == "__main__":
    main()
