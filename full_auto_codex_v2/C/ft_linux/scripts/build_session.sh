#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
LFS="${LFS:-$ROOT/.lfs}"
OUT_TXT="$REPORT_DIR/build_session.txt"
OUT_JSON="$REPORT_DIR/build_session.json"
SKIP_GATE=0
ALLOW_CHECK_WARN=0
CHECK_MAX_FAIL=""
CHECK_MAX_IGNORED=""
CHECK_MAX_MISSING=""
CHECK_MAX_SEVERITY=""
CHECK_MAX_REGRESSIONS=""
CHECK_MAX_REGRESSION_RATE=""
PREFLIGHT_MAX_WARN=""
PREFLIGHT_MAX_TREND_WARN=""
PREFLIGHT_FAIL_ON_WARN=0
RUN_TOOLCHAIN_SESSION=0

usage() {
	cat <<EOF
Usage: $0 [--toolchain-session] [--toolchain-arg <arg>] [--skip-gate] [--allow-check-warn] [--check-max-fail <n>] [--check-max-ignored <n>] [--check-max-missing <n>] [--check-max-severity <n>] [--check-max-regressions <n>] [--check-max-regression-rate <n>] [--preflight-max-warn <n>] [--preflight-max-trend-warn <n>] [--preflight-fail-on-warn] [--lfs <dir>] [--gate-arg <arg>] [--orchestrator-arg <arg>]...

Orchestre une session complete: toolchain (optionnel) -> gate -> orchestrator -> reports.
EOF
	exit 1
}

ORCH_ARGS=()
GATE_ARGS=()
TOOLCHAIN_ARGS=()
while [ "$#" -gt 0 ]; do
	case "$1" in
		--toolchain-session) RUN_TOOLCHAIN_SESSION=1; shift ;;
		--toolchain-arg) TOOLCHAIN_ARGS+=("$2"); shift 2 ;;
		--skip-gate) SKIP_GATE=1; shift ;;
		--allow-check-warn) ALLOW_CHECK_WARN=1; shift ;;
		--check-max-fail) CHECK_MAX_FAIL="$2"; shift 2 ;;
		--check-max-ignored) CHECK_MAX_IGNORED="$2"; shift 2 ;;
		--check-max-missing) CHECK_MAX_MISSING="$2"; shift 2 ;;
		--check-max-severity) CHECK_MAX_SEVERITY="$2"; shift 2 ;;
		--check-max-regressions) CHECK_MAX_REGRESSIONS="$2"; shift 2 ;;
		--check-max-regression-rate) CHECK_MAX_REGRESSION_RATE="$2"; shift 2 ;;
		--preflight-max-warn) PREFLIGHT_MAX_WARN="$2"; shift 2 ;;
		--preflight-max-trend-warn) PREFLIGHT_MAX_TREND_WARN="$2"; shift 2 ;;
		--preflight-fail-on-warn) PREFLIGHT_FAIL_ON_WARN=1; shift ;;
		--lfs) LFS="$2"; shift 2 ;;
		--gate-arg) GATE_ARGS+=("$2"); shift 2 ;;
		--orchestrator-arg) ORCH_ARGS+=("$2"); shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_session generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "lfs: $LFS"
	echo "toolchain_session: $RUN_TOOLCHAIN_SESSION"
	echo "skip_gate: $SKIP_GATE"
	echo "allow_check_warn: $ALLOW_CHECK_WARN"
	echo "check_max_fail: ${CHECK_MAX_FAIL:-}"
	echo "check_max_ignored: ${CHECK_MAX_IGNORED:-}"
	echo "check_max_missing: ${CHECK_MAX_MISSING:-}"
	echo "check_max_severity: ${CHECK_MAX_SEVERITY:-}"
	echo "check_max_regressions: ${CHECK_MAX_REGRESSIONS:-}"
	echo "check_max_regression_rate: ${CHECK_MAX_REGRESSION_RATE:-}"
	echo "preflight_max_warn: ${PREFLIGHT_MAX_WARN:-}"
	echo "preflight_max_trend_warn: ${PREFLIGHT_MAX_TREND_WARN:-}"
	echo "preflight_fail_on_warn: ${PREFLIGHT_FAIL_ON_WARN:-0}"
	echo ""
} >"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"lfs\": \"$LFS\","
	echo "  \"toolchain_session\": $RUN_TOOLCHAIN_SESSION,"
	echo "  \"skip_gate\": $SKIP_GATE,"
	echo "  \"allow_check_warn\": $ALLOW_CHECK_WARN,"
	echo "  \"check_max_fail\": \"${CHECK_MAX_FAIL}\","
	echo "  \"check_max_ignored\": \"${CHECK_MAX_IGNORED}\","
	echo "  \"check_max_missing\": \"${CHECK_MAX_MISSING}\","
	echo "  \"check_max_severity\": \"${CHECK_MAX_SEVERITY}\","
	echo "  \"check_max_regressions\": \"${CHECK_MAX_REGRESSIONS}\","
	echo "  \"check_max_regression_rate\": \"${CHECK_MAX_REGRESSION_RATE}\","
	echo "  \"preflight_max_warn\": \"${PREFLIGHT_MAX_WARN}\","
	echo "  \"preflight_max_trend_warn\": \"${PREFLIGHT_MAX_TREND_WARN}\","
	echo "  \"preflight_fail_on_warn\": \"${PREFLIGHT_FAIL_ON_WARN}\""
	echo "}"
} >"$OUT_JSON"

if [ "$RUN_TOOLCHAIN_SESSION" -eq 1 ]; then
	if ! "$ROOT/scripts/build_toolchain_session.sh" --lfs "$LFS" "${TOOLCHAIN_ARGS[@]}"; then
		echo "result: fail" >>"$OUT_TXT"
		echo "[ERR] build_toolchain_session a echoue." >>"$OUT_TXT"
		exit 1
	fi
fi

if [ "$SKIP_GATE" -eq 0 ]; then
	if [ "$ALLOW_CHECK_WARN" -eq 1 ]; then
		GATE_ARGS+=("--allow-check-warn")
	fi
	if [ -n "$CHECK_MAX_FAIL" ]; then
		GATE_ARGS+=("--check-max-fail" "$CHECK_MAX_FAIL")
	fi
	if [ -n "$CHECK_MAX_IGNORED" ]; then
		GATE_ARGS+=("--check-max-ignored" "$CHECK_MAX_IGNORED")
	fi
	if [ -n "$CHECK_MAX_MISSING" ]; then
		GATE_ARGS+=("--check-max-missing" "$CHECK_MAX_MISSING")
	fi
	if [ -n "$CHECK_MAX_SEVERITY" ]; then
		GATE_ARGS+=("--check-max-severity" "$CHECK_MAX_SEVERITY")
	fi
	if [ -n "$CHECK_MAX_REGRESSIONS" ]; then
		GATE_ARGS+=("--check-max-regressions" "$CHECK_MAX_REGRESSIONS")
	fi
	if [ -n "$CHECK_MAX_REGRESSION_RATE" ]; then
		GATE_ARGS+=("--check-max-regression-rate" "$CHECK_MAX_REGRESSION_RATE")
	fi
	if [ -n "$PREFLIGHT_MAX_WARN" ]; then
		GATE_ARGS+=("--preflight-max-warn" "$PREFLIGHT_MAX_WARN")
	fi
	if [ -n "$PREFLIGHT_MAX_TREND_WARN" ]; then
		GATE_ARGS+=("--preflight-max-trend-warn" "$PREFLIGHT_MAX_TREND_WARN")
	fi
	if [ "$PREFLIGHT_FAIL_ON_WARN" -ne 0 ]; then
		GATE_ARGS+=("--preflight-fail-on-warn")
	fi
	if ! "$ROOT/scripts/build_gate.sh" --lfs "$LFS" "${GATE_ARGS[@]}"; then
		echo "result: fail" >>"$OUT_TXT"
		echo "[ERR] build_gate a echoue." >>"$OUT_TXT"
		exit 1
	fi
fi

if ! "$ROOT/scripts/build_orchestrator.sh" --lfs "$LFS" "${ORCH_ARGS[@]}"; then
	echo "result: fail" >>"$OUT_TXT"
	echo "[ERR] build_orchestrator a echoue." >>"$OUT_TXT"
	exit 1
fi

"$ROOT/scripts/run_reports.sh" --lfs "$LFS" || true

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Build session completed: $OUT_TXT"
