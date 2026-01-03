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

usage() {
	cat <<EOF
Usage: $0 [--skip-gate] [--allow-check-warn] [--check-max-fail <n>] [--check-max-ignored <n>] [--check-max-missing <n>] [--check-max-severity <n>] [--lfs <dir>] [--gate-arg <arg>] [--orchestrator-arg <arg>]...

Orchestre une session complete: gate -> orchestrator -> reports.
EOF
	exit 1
}

ORCH_ARGS=()
GATE_ARGS=()
while [ "$#" -gt 0 ]; do
	case "$1" in
		--skip-gate) SKIP_GATE=1; shift ;;
		--allow-check-warn) ALLOW_CHECK_WARN=1; shift ;;
		--check-max-fail) CHECK_MAX_FAIL="$2"; shift 2 ;;
		--check-max-ignored) CHECK_MAX_IGNORED="$2"; shift 2 ;;
		--check-max-missing) CHECK_MAX_MISSING="$2"; shift 2 ;;
		--check-max-severity) CHECK_MAX_SEVERITY="$2"; shift 2 ;;
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
	echo "skip_gate: $SKIP_GATE"
	echo "allow_check_warn: $ALLOW_CHECK_WARN"
	echo "check_max_fail: ${CHECK_MAX_FAIL:-}"
	echo "check_max_ignored: ${CHECK_MAX_IGNORED:-}"
	echo "check_max_missing: ${CHECK_MAX_MISSING:-}"
	echo "check_max_severity: ${CHECK_MAX_SEVERITY:-}"
	echo ""
} >"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"lfs\": \"$LFS\","
	echo "  \"skip_gate\": $SKIP_GATE,"
	echo "  \"allow_check_warn\": $ALLOW_CHECK_WARN,"
	echo "  \"check_max_fail\": \"${CHECK_MAX_FAIL}\","
	echo "  \"check_max_ignored\": \"${CHECK_MAX_IGNORED}\","
	echo "  \"check_max_missing\": \"${CHECK_MAX_MISSING}\","
	echo "  \"check_max_severity\": \"${CHECK_MAX_SEVERITY}\""
	echo "}"
} >"$OUT_JSON"

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
