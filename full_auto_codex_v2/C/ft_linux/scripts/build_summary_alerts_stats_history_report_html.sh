#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_report.txt"
OUT_HTML="$REPORT_DIR/build_summary_alerts_stats_history_report.html"

usage() {
	cat <<USAGE
Usage: $0 [--report <file>] [--out <file>]

Genere un rapport HTML pour l'historique stats alertes.
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
<title>Build Summary Alerts Stats History</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.card { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats History</h1>
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
last_date=$(get_value "last_date")
last_alerts=$(get_value "last_alerts_total")
last_score=$(get_value "last_bundle_score")
last_result=$(get_value "last_result")
alerts_min=$(get_value "alerts_total_min")
alerts_max=$(get_value "alerts_total_max")
alerts_avg=$(get_value "alerts_total_avg")
score_min=$(get_value "bundle_score_min")
score_max=$(get_value "bundle_score_max")
score_avg=$(get_value "bundle_score_avg")
ok_count=$(get_value "result_ok")
warn_count=$(get_value "result_warn")
unknown_count=$(get_value "result_unknown")
other_count=$(get_value "result_other")
result=$(get_value "result")

entries="${entries:-0}"
last_date="${last_date:-unknown}"
last_alerts="${last_alerts:-0}"
last_score="${last_score:-0}"
last_result="${last_result:-unknown}"
alerts_min="${alerts_min:-0}"
alerts_max="${alerts_max:-0}"
alerts_avg="${alerts_avg:-0}"
score_min="${score_min:-0}"
score_max="${score_max:-0}"
score_avg="${score_avg:-0}"
ok_count="${ok_count:-0}"
warn_count="${warn_count:-0}"
unknown_count="${unknown_count:-0}"
other_count="${other_count:-0}"
result="${result:-unknown}"

cat <<EOF >"$OUT_HTML"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Build Summary Alerts Stats History</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; }
.card { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
.card h2 { margin-top: 0; font-size: 18px; }
.kv { display: flex; justify-content: space-between; }
.badge { padding: 2px 8px; border-radius: 10px; background: #eee; }
.badge.warn { background: #fdd; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats History</h1>
<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
<p>Result: <span class="badge ${result}">$result</span></p>
<div class="grid">
  <div class="card">
    <h2>Overview</h2>
    <div class="kv"><span>entries</span><span>$entries</span></div>
  </div>
  <div class="card">
    <h2>Last Entry</h2>
    <div class="kv"><span>date</span><span>$last_date</span></div>
    <div class="kv"><span>alerts_total</span><span>$last_alerts</span></div>
    <div class="kv"><span>bundle_score</span><span>$last_score</span></div>
    <div class="kv"><span>result</span><span>$last_result</span></div>
  </div>
  <div class="card">
    <h2>Alerts Total</h2>
    <div class="kv"><span>min</span><span>$alerts_min</span></div>
    <div class="kv"><span>max</span><span>$alerts_max</span></div>
    <div class="kv"><span>avg</span><span>$alerts_avg</span></div>
  </div>
  <div class="card">
    <h2>Bundle Score</h2>
    <div class="kv"><span>min</span><span>$score_min</span></div>
    <div class="kv"><span>max</span><span>$score_max</span></div>
    <div class="kv"><span>avg</span><span>$score_avg</span></div>
  </div>
  <div class="card">
    <h2>Results</h2>
    <div class="kv"><span>ok</span><span>$ok_count</span></div>
    <div class="kv"><span>warn</span><span>$warn_count</span></div>
    <div class="kv"><span>unknown</span><span>$unknown_count</span></div>
    <div class="kv"><span>other</span><span>$other_count</span></div>
  </div>
</div>
</body>
</html>
EOF

echo "[OK] Build summary alerts stats history report HTML generated: $OUT_HTML"
