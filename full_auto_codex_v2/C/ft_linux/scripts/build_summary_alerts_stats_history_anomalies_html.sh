#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_anomalies.txt"
ROWS_CSV="$REPORT_DIR/build_summary_alerts_stats_history_anomalies_rows.csv"
OUT_HTML="$REPORT_DIR/build_summary_alerts_stats_history_anomalies.html"
LIMIT=10

usage() {
	cat <<USAGE
Usage: $0 [--report <file>] [--rows <file>] [--out <file>] [--limit <n>]

Genere un rapport HTML pour les anomalies historiques.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_FILE="$2"; shift 2 ;;
		--rows) ROWS_CSV="$2"; shift 2 ;;
		--out) OUT_HTML="$2"; shift 2 ;;
		--limit) LIMIT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

if ! [[ "$LIMIT" =~ ^[0-9]+$ ]]; then
	echo "[ERR] --limit doit etre un entier" >&2
	exit 1
fi

mkdir -p "$REPORT_DIR"

if [ ! -f "$REPORT_FILE" ]; then
	cat <<EOF >"$OUT_HTML"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Build Summary Alerts Stats History Anomalies</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.card { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats History Anomalies</h1>
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
anomalies=$(get_value "anomalies")
max_alerts_delta=$(get_value "max_alerts_delta")
min_score_delta=$(get_value "min_score_delta")
last_date=$(get_value "last_date")
last_alerts=$(get_value "last_alerts_total")
last_score=$(get_value "last_bundle_score")
result=$(get_value "result")

entries="${entries:-0}"
anomalies="${anomalies:-0}"
max_alerts_delta="${max_alerts_delta:-0}"
min_score_delta="${min_score_delta:-0}"
last_date="${last_date:-unknown}"
last_alerts="${last_alerts:-0}"
last_score="${last_score:-0}"
result="${result:-unknown}"

rows=""
if [ -f "$ROWS_CSV" ]; then
	rows=$(tail -n +2 "$ROWS_CSV" | head -n "$LIMIT" | awk -F',' '{printf "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n", $1, $2, $3, $4, $5}')
fi

cat <<EOF >"$OUT_HTML"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Build Summary Alerts Stats History Anomalies</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; }
.card { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
.kv { display: flex; justify-content: space-between; }
table { border-collapse: collapse; width: 100%; margin-top: 16px; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background: #f4f4f4; }
.badge { padding: 2px 8px; border-radius: 10px; background: #eee; }
.badge.warn { background: #fdd; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats History Anomalies</h1>
<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
<p>Result: <span class="badge ${result}">$result</span></p>
<div class="grid">
  <div class="card">
    <h2>Overview</h2>
    <div class="kv"><span>entries</span><span>$entries</span></div>
    <div class="kv"><span>anomalies</span><span>$anomalies</span></div>
    <div class="kv"><span>max_alerts_delta</span><span>$max_alerts_delta</span></div>
    <div class="kv"><span>min_score_delta</span><span>$min_score_delta</span></div>
  </div>
  <div class="card">
    <h2>Last Entry</h2>
    <div class="kv"><span>date</span><span>$last_date</span></div>
    <div class="kv"><span>alerts_total</span><span>$last_alerts</span></div>
    <div class="kv"><span>bundle_score</span><span>$last_score</span></div>
  </div>
</div>
<h2>Top anomalies</h2>
<table>
<thead>
<tr>
<th>date</th>
<th>alerts_delta</th>
<th>score_delta</th>
<th>alerts_total</th>
<th>bundle_score</th>
</tr>
</thead>
<tbody>
${rows}
</tbody>
</table>
</body>
</html>
EOF

echo "[OK] Build summary alerts stats history anomalies HTML generated: $OUT_HTML"
