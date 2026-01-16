#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
TABLE_CSV="$REPORT_DIR/build_summary_alerts_stats_history_table.csv"
OUT_HTML="$REPORT_DIR/build_summary_alerts_stats_history_table.html"

usage() {
	cat <<USAGE
Usage: $0 [--csv <file>] [--out <file>]

Genere un tableau HTML depuis la table historique stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) TABLE_CSV="$2"; shift 2 ;;
		--out) OUT_HTML="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

if [ ! -f "$TABLE_CSV" ]; then
	cat <<EOF >"$OUT_HTML"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Build Summary Alerts Stats History Table</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
.card { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats History Table</h1>
<div class="card">
<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
<p>Result: missing</p>
</div>
</body>
</html>
EOF
	exit 0
fi

rows=$(tail -n +2 "$TABLE_CSV" | awk -F',' '
	NF >= 4 {
		printf "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n", $1, $2, $3, $4
	}
')

cat <<EOF >"$OUT_HTML"
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Build Summary Alerts Stats History Table</title>
<style>
body { font-family: Arial, sans-serif; margin: 24px; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background: #f4f4f4; }
</style>
</head>
<body>
<h1>Build Summary Alerts Stats History Table</h1>
<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>
<table>
<thead>
<tr>
<th>date</th>
<th>alerts_total</th>
<th>bundle_score</th>
<th>result</th>
</tr>
</thead>
<tbody>
${rows}
</tbody>
</table>
</body>
</html>
EOF

echo "[OK] Build summary alerts stats history table HTML generated: $OUT_HTML"
