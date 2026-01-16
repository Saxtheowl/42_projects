#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
JSON_FILE="$REPORT_DIR/build_summary.json"
OUT_TXT="$REPORT_DIR/build_summary_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--json <file>] [--out <file>]

Valide la presence des champs cles dans build_summary.json.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--json) JSON_FILE="$2"; shift 2 ;;
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
	echo "build_summary_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "json: $JSON_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$JSON_FILE" ]; then
	echo "result: missing_json" >>"$OUT_TXT"
	echo "json missing" >>"$OUT_TXT"
	exit 0
fi

missing=0
for field in generated overall gate gate_validate gate_trend queue build_system mini_system check check_groups check_gate check_rates toolchain_session preflight_gate preflight_gate_validate preflight_gate_trend preflight_trend summary_alerts summary_alerts_trend summary_alerts_stats summary_alerts_stats_history_report summary_alerts_stats_history_table summary_alerts_stats_history_score summary_alerts_stats_history_anomalies summary_alerts_stats_history_rollup summary_alerts_stats_history_rollup_score summary_alerts_stats_history_rollup_bundle summary_alerts_stats_history_rollup_overview summary_alerts_stats_history_rollup_history summary_alerts_stats_history_rollup_trend summary_alerts_stats_trend summary_alerts_stats_delta summary_alerts_stats_report summary_alerts_stats_export summary_alerts_items_trend summary_alerts_items_delta summary_alerts_items_report summary_alerts_items_overview summary_bundle; do
	if ! grep -q "\"$field\"" "$JSON_FILE"; then
		echo "missing_field: $field" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if grep -q "\"gate_trend\"" "$JSON_FILE"; then
	for field in warn fail; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: gate_trend.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"preflight_gate_trend\"" "$JSON_FILE"; then
	for field in warn fail; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: preflight_gate_trend.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"preflight_trend\"" "$JSON_FILE"; then
	if ! grep -q "\"avg_warns\"" "$JSON_FILE"; then
		echo "missing_field: preflight_trend.avg_warns" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
fi

if grep -q "\"summary_alerts\"" "$JSON_FILE"; then
	for field in result alerts; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_trend\"" "$JSON_FILE"; then
	if ! grep -q "\"avg_alerts\"" "$JSON_FILE"; then
		echo "missing_field: summary_alerts_trend.avg_alerts" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
fi

if grep -q "\"summary_alerts_stats\"" "$JSON_FILE"; then
	for field in total gate checks preflight bundle alerts_items other bundle_score bundle_score_result result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_stats_history_report\"" "$JSON_FILE"; then
	for field in entries last_alerts_total last_bundle_score result json_result validate md_validate html_validate; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_history_report.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi
if grep -q "\"summary_alerts_stats_history_table\"" "$JSON_FILE"; then
	for field in entries result validate md_validate html_validate; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_history_table.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi
if grep -q "\"summary_alerts_stats_history_score\"" "$JSON_FILE"; then
	for field in score result validate; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_history_score.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi
if grep -q "\"summary_alerts_stats_history_anomalies\"" "$JSON_FILE"; then
	for field in entries anomalies max_alerts_delta min_score_delta result json_result validate md_validate html_validate; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_history_anomalies.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_stats_history_rollup\"" "$JSON_FILE"; then
	for field in entries window prev_present last_avg_alerts last_avg_score prev_avg_alerts prev_avg_score delta_alerts delta_score result json_result validate md_validate html_validate; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_history_rollup.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_stats_history_rollup_score\"" "$JSON_FILE"; then
	for field in score result json_result validate md_validate html_validate; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_history_rollup_score.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_stats_history_rollup_bundle\"" "$JSON_FILE"; then
	for field in files missing_count result validate; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_history_rollup_bundle.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_stats_history_rollup_overview\"" "$JSON_FILE"; then
	for field in result rollup_result score_result bundle_validate json_result validate md_validate html_validate; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_history_rollup_overview.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_stats_history_rollup_history\"" "$JSON_FILE"; then
	for field in entries last_date last_delta_alerts last_delta_score last_score result validate md_validate html_validate; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_history_rollup_history.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_stats_history_rollup_trend\"" "$JSON_FILE"; then
	for field in entries avg_delta_alerts avg_delta_score avg_score warn_rollup warn_score result json_result validate md_validate html_validate; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_history_rollup_trend.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_stats_trend\"" "$JSON_FILE"; then
	for field in avg_alerts avg_bundle_score warn result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_trend.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_stats_delta\"" "$JSON_FILE"; then
	for field in alerts_delta score_delta result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_delta.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_stats_report\"" "$JSON_FILE"; then
	for field in result json_result md_validate html_validate; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_stats_report.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_stats_export\"" "$JSON_FILE"; then
	if ! grep -q "\"validate\"" "$JSON_FILE"; then
		echo "missing_field: summary_alerts_stats_export.validate" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
fi

if grep -q "\"summary_alerts_items_trend\"" "$JSON_FILE"; then
	for field in avg_total_items avg_unique_items warn result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_items_trend.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_items_delta\"" "$JSON_FILE"; then
	for field in delta_total_items delta_unique_items top_text_changed items_mode_changed result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_items_delta.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_items_report\"" "$JSON_FILE"; then
	for field in items_mode items_top result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_items_report.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_alerts_items_overview\"" "$JSON_FILE"; then
	for field in items_mode items_top result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_alerts_items_overview.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"summary_bundle\"" "$JSON_FILE"; then
	for field in result missing index_trend index_delta index_overview index_score; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_bundle.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"index_trend\"" "$JSON_FILE"; then
	for field in entries avg_files warn result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_bundle.index_trend.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"index_delta\"" "$JSON_FILE"; then
	for field in delta_files result last_generated previous_generated last_files previous_files; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_bundle.index_delta.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"index_overview\"" "$JSON_FILE"; then
	for field in result trend_result delta_result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_bundle.index_overview.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"index_score\"" "$JSON_FILE"; then
	for field in score result warn delta_files; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: summary_bundle.index_score.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"check_groups\"" "$JSON_FILE" && ! grep -q "\"check_gate\"" "$JSON_FILE"; then
	echo "missing_field: check_gate" >>"$OUT_TXT"
	missing=$((missing + 1))
fi

if [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build summary validate generated: $OUT_TXT"
