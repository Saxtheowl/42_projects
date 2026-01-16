#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.txt"
OUT_HTML="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.html"

usage() {
	cat <<USAGE
Usage: $0 [--report <file>] [--out <file>]

Genere un rapport HTML pour le score rollup historique.
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
<title>Build Summary Alerts Stats History Rollup Score</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.card { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats History Rollup Score</h1>
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
delta_alerts=$(get_value "delta_alerts")
delta_score=$(get_value "delta_score")
score=$(get_value "score")
result=$(get_value "result")

entries="${entries:-0}"
window="${window:-0}"
delta_alerts="${delta_alerts:-0}"
delta_score="${delta_score:-0}"
score="${score:-0}"
result="${result:-unknown}"

cat <<EOF >"$OUT_HTML"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Build Summary Alerts Stats History Rollup Score</title>
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
<h1>Build Summary Alerts Stats History Rollup Score</h1>
<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
<p>Result: <span class="badge">$result</span></p>
<div class="grid">
  <div class="card">
    <h2>Overview</h2>
    <div class="kv"><span>entries</span><span>$entries</span></div>
    <div class="kv"><span>window</span><span>$window</span></div>
    <div class="kv"><span>score</span><span>$score</span></div>
  </div>
  <div class="card">
    <h2>Deltas</h2>
    <div class="kv"><span>delta_alerts</span><span>$delta_alerts</span></div>
    <div class="kv"><span>delta_score</span><span>$delta_score</span></div>
  </div>
</div>
<h2>Details</h2>
<table>
<thead>
<tr>
<th>delta_alerts</th>
<th>delta_score</th>
</tr>
</thead>
<tbody>
<tr><td>$delta_alerts</td><td>$delta_score</td></tr>
</tbody>
</table>
</body>
</html>
EOF

echo "[OK] Build summary alerts stats history rollup score HTML generated: $OUT_HTML"
