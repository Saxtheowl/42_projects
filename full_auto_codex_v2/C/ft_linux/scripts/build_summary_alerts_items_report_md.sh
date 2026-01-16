#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TXT="$REPORT_DIR/build_summary_alerts_items_report.txt"
OUT_MD="$REPORT_DIR/build_summary_alerts_items_report.md"

usage() {
	cat <<EOF
Usage: $0 [--in <file>] [--out <file>]

Genere un rapport Markdown pour les alertes items.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--in) IN_TXT="$2"; shift 2 ;;
		--out) OUT_MD="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

if [ ! -f "$IN_TXT" ]; then
	cat >"$OUT_MD" <<EOF
# Build summary alerts items report

_missing_inputs_

Source: $IN_TXT
EOF
	echo "[OK] Build summary alerts items report MD generated: $OUT_MD"
	exit 0
fi

get_value() {
	local key="$1"
	grep -E "^${key}:" "$IN_TXT" | head -n 1 | awk '{print $2}'
}

get_value_rest() {
	local key="$1"
	grep -E "^${key}:" "$IN_TXT" | head -n 1 | cut -d' ' -f2-
}

items_total=$(get_value "items_total")
items_unique=$(get_value "items_unique")
items_mode=$(get_value "items_mode")
items_top=$(get_value_rest "items_top")
trend_avg_total=$(get_value "trend_avg_total")
trend_avg_unique=$(get_value "trend_avg_unique")
trend_warn=$(get_value "trend_warn")
trend_result=$(get_value "trend_result")
delta_total=$(get_value "delta_total")
delta_unique=$(get_value "delta_unique")
delta_result=$(get_value "delta_result")
delta_top_changed=$(get_value "delta_top_changed")
delta_mode_changed=$(get_value "delta_mode_changed")
result=$(get_value "result")

items_total="${items_total:-0}"
items_unique="${items_unique:-0}"
items_mode="${items_mode:-unknown}"
items_top="${items_top:-none}"
trend_avg_total="${trend_avg_total:-0}"
trend_avg_unique="${trend_avg_unique:-0}"
trend_warn="${trend_warn:-0}"
trend_result="${trend_result:-unknown}"
delta_total="${delta_total:-0}"
delta_unique="${delta_unique:-0}"
delta_result="${delta_result:-unknown}"
delta_top_changed="${delta_top_changed:-false}"
delta_mode_changed="${delta_mode_changed:-false}"
result="${result:-unknown}"

cat >"$OUT_MD" <<EOF
# Build summary alerts items report

## Snapshot
- items_total: $items_total
- items_unique: $items_unique
- items_mode: $items_mode
- items_top: $items_top

## Trend
- avg_total_items: $trend_avg_total
- avg_unique_items: $trend_avg_unique
- warn: $trend_warn
- result: $trend_result

## Delta
- delta_total_items: $delta_total
- delta_unique_items: $delta_unique
- top_text_changed: $delta_top_changed
- items_mode_changed: $delta_mode_changed
- result: $delta_result

## Result
- result: $result

_source: $IN_TXT_
EOF

echo "[OK] Build summary alerts items report MD generated: $OUT_MD"
