#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_HTML="$REPORT_DIR/build_check_regressions_report.html"
SUMMARY_TXT="$REPORT_DIR/build_check_regressions_summary.txt"
TOP_TXT="$REPORT_DIR/build_check_regressions_top.txt"
TREND_TXT="$REPORT_DIR/build_check_regressions_trend.txt"
GROUPS_TXT="$REPORT_DIR/build_check_regressions_groups.txt"

usage() {
	cat <<EOF
Usage: $0 [--out <file>]

Genere un rapport HTML des regressions checks.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--out) OUT_HTML="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

escape_html() {
	sed -e 's/&/\\&amp;/g' -e 's/</\\&lt;/g' -e 's/>/\\&gt;/g'
}

{
	echo "<!doctype html>"
	echo "<html lang=\"fr\">"
	echo "<head>"
	echo "<meta charset=\"utf-8\">"
	echo "<title>build_check regressions report</title>"
	echo "<style>"
	echo "body{font-family:Arial,Helvetica,sans-serif;margin:24px;background:#f6f7fb;color:#1b1e2b}"
	echo "h1,h2{color:#232a4d}"
	echo "pre{background:#fff;border:1px solid #d7dbe8;padding:12px;overflow:auto}"
	echo ".card{background:#fff;border:1px solid #d7dbe8;padding:12px;margin-bottom:16px}"
	echo ".muted{color:#6b7280}"
	echo "</style>"
	echo "</head>"
	echo "<body>"
	echo "<h1>build_check regressions report</h1>"
	echo "<div class=\"muted\">generated: $(date '+%Y-%m-%d %H:%M:%S')</div>"
	echo ""
	echo "<div class=\"card\">"
	echo "<h2>Summary</h2>"
	if [ -f "$SUMMARY_TXT" ]; then
		echo "<pre>"
		grep -E '^(regressions|recoveries|total_compared|worst_group|worst_rate|last_pair|last_regressions|result):' "$SUMMARY_TXT" | escape_html
		echo "</pre>"
	else
		echo "<div class=\"muted\">missing: $SUMMARY_TXT</div>"
	fi
	echo "</div>"
	echo ""
	echo "<div class=\"card\">"
	echo "<h2>Top groups</h2>"
	if [ -f "$TOP_TXT" ]; then
		echo "<pre>"
		sed -n '1,80p' "$TOP_TXT" | escape_html
		echo "</pre>"
	else
		echo "<div class=\"muted\">missing: $TOP_TXT</div>"
	fi
	echo "</div>"
	echo ""
	echo "<div class=\"card\">"
	echo "<h2>Trend</h2>"
	if [ -f "$TREND_TXT" ]; then
		echo "<pre>"
		sed -n '1,120p' "$TREND_TXT" | escape_html
		echo "</pre>"
	else
		echo "<div class=\"muted\">missing: $TREND_TXT</div>"
	fi
	echo "</div>"
	echo ""
	echo "<div class=\"card\">"
	echo "<h2>Groups</h2>"
	if [ -f "$GROUPS_TXT" ]; then
		echo "<pre>"
		sed -n '1,160p' "$GROUPS_TXT" | escape_html
		echo "</pre>"
	else
		echo "<div class=\"muted\">missing: $GROUPS_TXT</div>"
	fi
	echo "</div>"
	echo "</body>"
	echo "</html>"
} >"$OUT_HTML"

echo "[OK] Build check regressions HTML report generated: $OUT_HTML"
