#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SUMMARY_JSON="$REPORT_DIR/build_summary.json"
TREND_JSON="$REPORT_DIR/build_summary_trend.json"
OUT_TXT="$REPORT_DIR/build_summary_alerts.txt"

usage() {
	cat <<EOF
Usage: $0 [--summary <file>] [--trend <file>] [--out <file>]

Genere des alertes a partir de build_summary et de sa tendance.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--summary) SUMMARY_JSON="$2"; shift 2 ;;
		--trend) TREND_JSON="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "summary: $SUMMARY_JSON"
	echo "trend: $TREND_JSON"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$SUMMARY_JSON" ]; then
	echo "result: missing_summary" >>"$OUT_TXT"
	echo "summary missing" >>"$OUT_TXT"
	exit 0
fi

get_str() {
	local key="$1"
	grep -E "\"$key\"" "$SUMMARY_JSON" | head -n 1 | awk -F'"' '{print $4}'
}

get_num_section() {
	local section="$1"
	local key="$2"
	grep -E "\"$section\"" -A4 "$SUMMARY_JSON" | grep -E "\"$key\"" | head -n 1 | awk -F':' '{print $2}' | tr -d ' ,'
}

get_str_section() {
	local section="$1"
	local key="$2"
	awk -F'"' -v sec="\"$section\"" -v key="\"$key\"" '
		$0 ~ sec {in=1; depth=0}
		in {
			if ($0 ~ /\{/) depth++
			if ($0 ~ key) {print $4; exit}
			if ($0 ~ /\}/) {depth--; if (depth<=0) exit}
		}
	' "$SUMMARY_JSON"
}

alerts=0
overall=$(get_str "overall")
gate=$(get_str "gate")
gate_warn=$(get_num_section "gate_trend" "warn")
gate_fail=$(get_num_section "gate_trend" "fail")
pre_gate_warn=$(get_num_section "preflight_gate_trend" "warn")
pre_gate_fail=$(get_num_section "preflight_gate_trend" "fail")
check_failures=$(get_num_section "check" "failures")
check_missing=$(get_num_section "check" "missing")
pre_avg_warns=$(get_num_section "preflight_trend" "avg_warns")
bundle_delta_files=$(get_num_section "index_delta" "delta_files")
bundle_delta_result=$(get_str_section "index_delta" "result")
bundle_score=$(get_num_section "index_score" "score")
bundle_score_result=$(get_str_section "index_score" "result")
alerts_items_delta_total=$(get_num_section "summary_alerts_items_delta" "delta_total_items")
alerts_items_delta_unique=$(get_num_section "summary_alerts_items_delta" "delta_unique_items")
alerts_items_delta_result=$(get_str_section "summary_alerts_items_delta" "result")
alerts_items_delta_top_changed=$(get_str_section "summary_alerts_items_delta" "top_text_changed")
alerts_items_delta_mode_changed=$(get_str_section "summary_alerts_items_delta" "items_mode_changed")

if [ "$overall" = "warn" ] || [ "$gate" = "warn" ]; then
	echo "- gate: build gate en warn (verifier preflight/checks)" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi
if [ "${gate_fail:-0}" -gt 0 ]; then
	echo "- gate_trend: ${gate_fail} echec(s) recents" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi
if [ "${pre_gate_fail:-0}" -gt 0 ]; then
	echo "- preflight_gate_trend: ${pre_gate_fail} echec(s) recents" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi
if [ "${pre_gate_warn:-0}" -gt 0 ]; then
	echo "- preflight_gate_trend: ${pre_gate_warn} warn(s) recents" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi
if [ "${check_failures:-0}" -gt 0 ]; then
	echo "- checks: ${check_failures} echec(s) make check" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi
if [ "${check_missing:-0}" -gt 0 ]; then
	echo "- checks: ${check_missing} logs manquants" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi
if [ "${pre_avg_warns:-0}" -gt 0 ]; then
	echo "- preflight: moyenne warnings=${pre_avg_warns}" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi
if [ "${bundle_delta_files:-0}" -lt 0 ]; then
	echo "- bundle_index_delta: delta_files=${bundle_delta_files}" >>"$OUT_TXT"
	alerts=$((alerts + 1))
elif [ "${bundle_delta_result:-unknown}" != "ok" ] && [ -n "${bundle_delta_result:-}" ]; then
	echo "- bundle_index_delta: result=${bundle_delta_result}" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi
if [ "${bundle_score_result:-unknown}" != "ok" ] && [ -n "${bundle_score_result:-}" ]; then
	echo "- bundle_index_score: result=${bundle_score_result} score=${bundle_score:-0}" >>"$OUT_TXT"
	alerts=$((alerts + 1))
elif [ "${bundle_score:-0}" -lt 70 ]; then
	echo "- bundle_index_score: score=${bundle_score:-0}" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi
if [ "${alerts_items_delta_total:-0}" -lt 0 ] || [ "${alerts_items_delta_unique:-0}" -lt 0 ]; then
	echo "- alerts_items_delta: total=${alerts_items_delta_total:-0} unique=${alerts_items_delta_unique:-0}" >>"$OUT_TXT"
	alerts=$((alerts + 1))
elif [ "${alerts_items_delta_result:-unknown}" != "ok" ] && [ -n "${alerts_items_delta_result:-}" ]; then
	echo "- alerts_items_delta: result=${alerts_items_delta_result}" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi
if [ "${alerts_items_delta_top_changed:-false}" = "true" ]; then
	echo "- alerts_items_delta: top_text_changed" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi
if [ "${alerts_items_delta_mode_changed:-false}" = "true" ]; then
	echo "- alerts_items_delta: items_mode_changed" >>"$OUT_TXT"
	alerts=$((alerts + 1))
fi

if [ "$alerts" -eq 0 ]; then
	echo "- aucun" >>"$OUT_TXT"
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build summary alerts generated: $OUT_TXT"
