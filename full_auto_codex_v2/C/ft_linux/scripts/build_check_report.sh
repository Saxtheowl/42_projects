#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_check_report.txt"
LOGDIR="$ROOT/logs/system"
CHECK_STATUS_LOG="$REPORT_DIR/build_check_status.csv"

SYSTEM_MANIFEST="$ROOT/configs/build_system_manifest.tsv"
MINI_MANIFEST="$ROOT/configs/mini_system_manifest.tsv"
SYSTEM_STATE="$ROOT/work/build_system.state"
MINI_STATE="$ROOT/work/mini_system.state"
EXPECT_CHECK=0
STRICT=0
SKIP_OK_NO_LOG=0

usage() {
	cat <<EOF
Usage: $0 [--expect-check] [--strict] [--skip-ok-no-log] [--logdir <dir>] [--system-manifest <file>] [--mini-manifest <file>] [--system-state <file>] [--mini-state <file>]

Analyse les logs de tests (make check) et signale les absences si attendu.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--expect-check) EXPECT_CHECK=1; shift ;;
		--strict) STRICT=1; shift ;;
		--skip-ok-no-log) SKIP_OK_NO_LOG=1; shift ;;
		--logdir) LOGDIR="$2"; shift 2 ;;
		--system-manifest) SYSTEM_MANIFEST="$2"; shift 2 ;;
		--mini-manifest) MINI_MANIFEST="$2"; shift 2 ;;
		--system-state) SYSTEM_STATE="$2"; shift 2 ;;
		--mini-state) MINI_STATE="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

manifest_names() {
	local manifest="$1"
	awk -F'|' 'NF && $1 !~ /^#/ {gsub(/^ +| +$/, "", $1); print $1}' "$manifest"
}

state_has() {
	local state="$1" name="$2"
	if [ -f "$state" ]; then
		grep -Fxq "$name" "$state"
	else
		return 1
	fi
}

{
	echo "build_check_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "logdir: $LOGDIR"
	echo "status_log: $CHECK_STATUS_LOG"
	echo "expect_check: $EXPECT_CHECK"
	echo "strict: $STRICT"
	echo "skip_ok_no_log: $SKIP_OK_NO_LOG"
	echo ""
} >"$OUT_TXT"

fail_count=0
fail_ignored_count=0
missing_count=0

status_from_csv() {
	local name="$1"
	[ -f "$CHECK_STATUS_LOG" ] || return 1
	awk -F'|' -v name="$name" '$3==name {ts=$1; res=$4; log=$5} END {if (res!="") printf "%s|%s|%s", res, ts, log}' "$CHECK_STATUS_LOG"
}

check_log_for() {
	local name="$1"
	local log="$LOGDIR/$name.check.log"
	local status_line status status_ts status_log
	status_line="$(status_from_csv "$name" || true)"
	status=""
	status_ts=""
	status_log=""
	if [ -n "$status_line" ]; then
		IFS='|' read -r status status_ts status_log <<<"$status_line"
	fi

	if [ "$status" = "fail_ignored" ]; then
		echo "check_fail_ignored: $name ($status_log)" >>"$OUT_TXT"
		fail_ignored_count=$((fail_ignored_count + 1))
		return
	fi
	if [ "$status" = "fail" ]; then
		echo "check_fail: $name ($status_log)" >>"$OUT_TXT"
		fail_count=$((fail_count + 1))
		return
	fi
	if [ -f "$log" ]; then
		if grep -Eqi '(FAIL|FAILED|ERROR)' "$log"; then
			echo "check_fail: $name ($log)" >>"$OUT_TXT"
			fail_count=$((fail_count + 1))
		fi
	else
		if [ "$status" = "ok" ]; then
			if [ "$SKIP_OK_NO_LOG" -eq 0 ]; then
				echo "check_status: $name ok_no_log" >>"$OUT_TXT"
			fi
		elif [ "$EXPECT_CHECK" -eq 1 ]; then
			echo "check_missing: $name" >>"$OUT_TXT"
			missing_count=$((missing_count + 1))
		fi
	fi
}

for name in $(manifest_names "$SYSTEM_MANIFEST"); do
	if state_has "$SYSTEM_STATE" "$name" || [ -f "$LOGDIR/$name.install.log" ]; then
		check_log_for "$name"
	fi
done

for name in $(manifest_names "$MINI_MANIFEST"); do
	if state_has "$MINI_STATE" "$name" || [ -f "$LOGDIR/$name.install.log" ]; then
		check_log_for "$name"
	fi
done

echo "" >>"$OUT_TXT"
echo "check_failures: $fail_count" >>"$OUT_TXT"
echo "check_fail_ignored: $fail_ignored_count" >>"$OUT_TXT"
echo "check_missing: $missing_count" >>"$OUT_TXT"

if [ "$STRICT" -eq 1 ] && [ "$fail_ignored_count" -gt 0 ]; then
	echo "result: warn" >>"$OUT_TXT"
elif [ "$fail_count" -eq 0 ] && [ "$fail_ignored_count" -eq 0 ] && [ "$missing_count" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check report generated: $OUT_TXT"
