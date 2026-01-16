#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_report.txt"
OUT_HTML="$REPORT_DIR/build_summary_alerts_stats_report.html"

usage() {
	cat <<EOF
Usage: $0 [--report <file>] [--out <file>]

Genere un rapport HTML pour les stats alertes.
EOF
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
<title>Build Summary Alerts Stats</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.card { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats</h1>
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

alerts_total=$(get_value "alerts_total")
bundle_score=$(get_value "bundle_score")
stats_result=$(get_value "stats_result")
trend_avg_alerts=$(get_value "trend_avg_alerts")
trend_avg_score=$(get_value "trend_avg_score")
trend_warn=$(get_value "trend_warn")
trend_result=$(get_value "trend_result")
alerts_delta=$(get_value "alerts_delta")
score_delta=$(get_value "score_delta")
delta_result=$(get_value "delta_result")
rollup_entries=$(get_value "rollup_entries")
rollup_window=$(get_value "rollup_window")
rollup_delta_alerts=$(get_value "rollup_delta_alerts")
rollup_delta_score=$(get_value "rollup_delta_score")
rollup_result=$(get_value "rollup_result")
rollup_score=$(get_value "rollup_score")
rollup_score_result=$(get_value "rollup_score_result")
result=$(get_value "result")

alerts_total="${alerts_total:-0}"
bundle_score="${bundle_score:-0}"
stats_result="${stats_result:-unknown}"
trend_avg_alerts="${trend_avg_alerts:-0}"
trend_avg_score="${trend_avg_score:-0}"
trend_warn="${trend_warn:-0}"
trend_result="${trend_result:-unknown}"
alerts_delta="${alerts_delta:-0}"
score_delta="${score_delta:-0}"
delta_result="${delta_result:-unknown}"
rollup_entries="${rollup_entries:-0}"
rollup_window="${rollup_window:-0}"
rollup_delta_alerts="${rollup_delta_alerts:-0}"
rollup_delta_score="${rollup_delta_score:-0}"
rollup_result="${rollup_result:-unknown}"
rollup_score="${rollup_score:-0}"
rollup_score_result="${rollup_score_result:-unknown}"
result="${result:-unknown}"

cat <<EOF >"$OUT_HTML"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Build Summary Alerts Stats</title>
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
<h1>Build Summary Alerts Stats</h1>
<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
<p>Result: <span class="badge ${result}">$result</span></p>
<div class="grid">
  <div class="card">
    <h2>Stats</h2>
    <div class="kv"><span>alerts_total</span><span>$alerts_total</span></div>
    <div class="kv"><span>bundle_score</span><span>$bundle_score</span></div>
    <div class="kv"><span>result</span><span>$stats_result</span></div>
  </div>
  <div class="card">
    <h2>Trend</h2>
    <div class="kv"><span>avg_alerts</span><span>$trend_avg_alerts</span></div>
    <div class="kv"><span>avg_bundle_score</span><span>$trend_avg_score</span></div>
    <div class="kv"><span>warn</span><span>$trend_warn</span></div>
    <div class="kv"><span>result</span><span>$trend_result</span></div>
  </div>
  <div class="card">
    <h2>Delta</h2>
    <div class="kv"><span>alerts_delta</span><span>$alerts_delta</span></div>
    <div class="kv"><span>score_delta</span><span>$score_delta</span></div>
    <div class="kv"><span>result</span><span>$delta_result</span></div>
  </div>
  <div class="card">
    <h2>Rollup</h2>
    <div class="kv"><span>entries</span><span>$rollup_entries</span></div>
    <div class="kv"><span>window</span><span>$rollup_window</span></div>
    <div class="kv"><span>delta_alerts</span><span>$rollup_delta_alerts</span></div>
    <div class="kv"><span>delta_score</span><span>$rollup_delta_score</span></div>
    <div class="kv"><span>result</span><span>$rollup_result</span></div>
  </div>
  <div class="card">
    <h2>Rollup Score</h2>
    <div class="kv"><span>score</span><span>$rollup_score</span></div>
    <div class="kv"><span>result</span><span>$rollup_score_result</span></div>
  </div>
</div>
</body>
</html>
EOF

echo "[OK] Build summary alerts stats report HTML generated: $OUT_HTML"
