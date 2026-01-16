#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.csv"
OUT_HTML="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.html"

usage() {
	cat <<USAGE
Usage: $0 [--csv <file>] [--out <file>]

Genere un tableau HTML depuis l'historique rollup stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) HISTORY_CSV="$2"; shift 2 ;;
		--out) OUT_HTML="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

if [ ! -f "$HISTORY_CSV" ]; then
	cat <<EOF >"$OUT_HTML"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Build Summary Alerts Stats History Rollup History</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.card { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats History Rollup History</h1>
<div class="card">
<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
<p>Result: missing</p>
</div>
</body>
</html>
EOF
	exit 0
fi

rows=$(tail -n +2 "$HISTORY_CSV" | awk -F',' '
	NF >= 8 {
		printf "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n", $1, $2, $3, $4, $5, $6, $7, $8
	}
')

cat <<EOF >"$OUT_HTML"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Build Summary Alerts Stats History Rollup History</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background: #f4f4f4; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats History Rollup History</h1>
<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
<table>
<thead>
<tr>
<th>date</th>
<th>entries</th>
<th>window</th>
<th>delta_alerts</th>
<th>delta_score</th>
<th>rollup_result</th>
<th>score</th>
<th>score_result</th>
</tr>
</thead>
<tbody>
${rows}
</tbody>
</table>
</body>
</html>
EOF

echo "[OK] Build summary alerts stats history rollup history HTML generated: $OUT_HTML"
