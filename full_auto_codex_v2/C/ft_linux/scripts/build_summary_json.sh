#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_JSON="$REPORT_DIR/build_summary.json"

report_result() {
	local file="$1"
	if [ -f "$file" ]; then
		grep -E '^result:' "$file" | head -n 1 | awk '{print $2}'
	else
		echo "missing"
	fi
}

value_from_report() {
	local file="$1" key="$2"
	if [ -f "$file" ]; then
		grep -E "^${key}:" "$file" | head -n 1 | awk '{print $2}'
	fi
}

value_from_section() {
	local file="$1" section="$2" key="$3"
	if [ -f "$file" ]; then
		awk -v sec="[$section]" -v key="$key" '
			$0==sec {in=1; next}
			in && /^\[.*\]/ {in=0}
			in && $1==key":" {print $2; exit}
		' "$file"
	fi
}

status_assessment="$REPORT_DIR/status_assessment.txt"
build_health="$REPORT_DIR/build_health_report.txt"
build_gate="$REPORT_DIR/build_gate.txt"
queue_metrics="$REPORT_DIR/build_queue_metrics.txt"
progress_rollup="$REPORT_DIR/build_progress_rollup.txt"
check_report="$REPORT_DIR/build_check_report.txt"
check_rollup="$REPORT_DIR/build_check_status_rollup.txt"
check_gate="$REPORT_DIR/build_check_gate.txt"
check_stats="$REPORT_DIR/build_check_stats.txt"

overall=$(report_result "$build_health")
gate=$(report_result "$build_gate")
check_gate_result=$(report_result "$check_gate")

queue_ok=$(value_from_report "$queue_metrics" "ok")
queue_fail=$(value_from_report "$queue_metrics" "fail")
queue_timeout=$(value_from_report "$queue_metrics" "timeout")

sys_total=$(value_from_section "$progress_rollup" "build_system" "manifest_total")
sys_done=$(value_from_section "$progress_rollup" "build_system" "state_done")
mini_total=$(value_from_section "$progress_rollup" "mini_system" "manifest_total")
mini_done=$(value_from_section "$progress_rollup" "mini_system" "state_done")
check_failures=$(value_from_report "$check_report" "check_failures")
check_fail_ignored=$(value_from_report "$check_report" "check_fail_ignored")
check_missing=$(value_from_report "$check_report" "check_missing")
check_fail_rate=$(value_from_report "$check_stats" "fail_rate")
check_ignored_rate=$(value_from_report "$check_stats" "ignored_rate")

check_groups="{}"
if [ -f "$check_rollup" ]; then
	check_groups=$(awk '
		/^\[group:/ {
			g=$0; sub(/^\[group:/,"",g); sub(/\]$/,"",g); groups[g]=1
		}
		$1=="ok:" {ok[g]=$2}
		$1=="fail:" {fail[g]=$2}
		$1=="fail_ignored:" {ign[g]=$2}
		$1=="other:" {other[g]=$2}
		END {
			first=1
			printf "{"
			for (g in groups) {
				if (!first) printf ","
				first=0
				printf "\"%s\": {\"ok\": %d, \"fail\": %d, \"fail_ignored\": %d, \"other\": %d}", g, ok[g]+0, fail[g]+0, ign[g]+0, other[g]+0
			}
			printf "}"
		}
	' "$check_rollup")
fi

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"overall\": \"${overall:-unknown}\","
	echo "  \"gate\": \"${gate:-unknown}\","
	echo "  \"queue\": {"
	echo "    \"ok\": ${queue_ok:-0},"
	echo "    \"fail\": ${queue_fail:-0},"
	echo "    \"timeout\": ${queue_timeout:-0}"
	echo "  },"
	echo "  \"build_system\": {"
	echo "    \"total\": ${sys_total:-0},"
	echo "    \"done\": ${sys_done:-0}"
	echo "  },"
	echo "  \"mini_system\": {"
	echo "    \"total\": ${mini_total:-0},"
	echo "    \"done\": ${mini_done:-0}"
	echo "  },"
	echo "  \"check\": {"
	echo "    \"failures\": ${check_failures:-0},"
	echo "    \"ignored\": ${check_fail_ignored:-0},"
	echo "    \"missing\": ${check_missing:-0}"
	echo "  },"
	echo "  \"check_rates\": {"
	echo "    \"fail_rate\": ${check_fail_rate:-0},"
	echo "    \"ignored_rate\": ${check_ignored_rate:-0}"
	echo "  },"
	echo "  \"check_groups\": $check_groups,"
	echo "  \"check_gate\": \"${check_gate_result:-unknown}\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary JSON generated: $OUT_JSON"
