#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup.txt"
OUT_HTML="$REPORT_DIR/build_summary_alerts_stats_history_rollup.html"

usage() {
	cat <<USAGE
Usage: $0 [--report <file>] [--out <file>]

Genere un rapport HTML pour le rollup historique des stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_FILE="$2"; shift 2 ;;
		--out) OUT_HTML="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

if [ ! -f "$REPORT_FILE" ]; then
	cat <<EOF >"$OUT_HTML"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Build Summary Alerts Stats History Rollup</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.card { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats History Rollup</h1>
<div class="card">
<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
<p>Result: missing</p>
</div>
</body>
</html>
EOF
	exit 0
fi

get_value() {
	local key="$1"
	grep -E "^${key}:" "$REPORT_FILE" | head -n 1 | awk '{print $2}'
}

entries=$(get_value "entries")
window=$(get_value "window")
prev_present=$(get_value "prev_present")
last_avg_alerts=$(get_value "last_avg_alerts")
last_avg_score=$(get_value "last_avg_score")
prev_avg_alerts=$(get_value "prev_avg_alerts")
prev_avg_score=$(get_value "prev_avg_score")
delta_alerts=$(get_value "delta_alerts")
delta_score=$(get_value "delta_score")
result=$(get_value "result")

entries="${entries:-0}"
window="${window:-0}"
prev_present="${prev_present:-0}"
last_avg_alerts="${last_avg_alerts:-0}"
last_avg_score="${last_avg_score:-0}"
prev_avg_alerts="${prev_avg_alerts:-0}"
prev_avg_score="${prev_avg_score:-0}"
delta_alerts="${delta_alerts:-0}"
delta_score="${delta_score:-0}"
result="${result:-unknown}"

cat <<EOF >"$OUT_HTML"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Build Summary Alerts Stats History Rollup</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; }
.card { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
.kv { display: flex; justify-content: space-between; }
table { border-collapse: collapse; width: 100%; margin-top: 16px; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background: #f4f4f4; }
.badge { padding: 2px 8px; border-radius: 10px; background: #eee; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats History Rollup</h1>
<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
<p>Result: <span class="badge">$result</span></p>
<div class="grid">
  <div class="card">
    <h2>Overview</h2>
    <div class="kv"><span>entries</span><span>$entries</span></div>
    <div class="kv"><span>window</span><span>$window</span></div>
    <div class="kv"><span>prev_present</span><span>$prev_present</span></div>
  </div>
  <div class="card">
    <h2>Delta</h2>
    <div class="kv"><span>delta_alerts</span><span>$delta_alerts</span></div>
    <div class="kv"><span>delta_score</span><span>$delta_score</span></div>
  </div>
</div>
<h2>Averages</h2>
<table>
<thead>
<tr>
<th>scope</th>
<th>avg_alerts</th>
<th>avg_score</th>
</tr>
</thead>
<tbody>
<tr><td>last</td><td>$last_avg_alerts</td><td>$last_avg_score</td></tr>
<tr><td>prev</td><td>$prev_avg_alerts</td><td>$prev_avg_score</td></tr>
</tbody>
</table>
</body>
</html>
EOF

echo "[OK] Build summary alerts stats history rollup HTML generated: $OUT_HTML"
