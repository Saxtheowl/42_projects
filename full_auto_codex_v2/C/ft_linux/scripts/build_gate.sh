#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
LFS="${LFS:-$ROOT/.lfs}"
OUT_TXT="$REPORT_DIR/build_gate.txt"
OUT_JSON="$REPORT_DIR/build_gate.json"
ALLOW_WARN=0
ALLOW_CHECK_WARN=0
CHECK_MAX_FAIL=""
CHECK_MAX_IGNORED=""
CHECK_MAX_MISSING=""
CHECK_MAX_SEVERITY=""

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--out <file>] [--json <file>] [--allow-warn] [--allow-check-warn] [--check-max-fail <n>] [--check-max-ignored <n>] [--check-max-missing <n>] [--check-max-severity <n>]

Gate de pre-build: toolchain, manifests, files et etats critiques.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--lfs) LFS="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		--allow-warn) ALLOW_WARN=1; shift ;;
		--allow-check-warn) ALLOW_CHECK_WARN=1; shift ;;
		--check-max-fail) CHECK_MAX_FAIL="$2"; shift 2 ;;
		--check-max-ignored) CHECK_MAX_IGNORED="$2"; shift 2 ;;
		--check-max-missing) CHECK_MAX_MISSING="$2"; shift 2 ;;
		--check-max-severity) CHECK_MAX_SEVERITY="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

write_json() {
	local result="$1"
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"lfs\": \"$LFS\","
		echo "  \"result\": \"$result\""
		echo "}"
	} >"$OUT_JSON"
}

{
	echo "build_gate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "lfs: $LFS"
	echo "allow_warn: $ALLOW_WARN"
	echo "allow_check_warn: $ALLOW_CHECK_WARN"
	echo "check_max_fail: ${CHECK_MAX_FAIL:-}"
	echo "check_max_ignored: ${CHECK_MAX_IGNORED:-}"
	echo "check_max_missing: ${CHECK_MAX_MISSING:-}"
	echo "check_max_severity: ${CHECK_MAX_SEVERITY:-}"
	echo ""
} >"$OUT_TXT"

fail=0
warn=0

if ! "$ROOT/scripts/validate_toolchain.sh" --lfs "$LFS" >/dev/null 2>&1; then
	echo "toolchain: fail" >>"$OUT_TXT"
	fail=$((fail + 1))
else
	echo "toolchain: ok" >>"$OUT_TXT"
fi

if "$ROOT/scripts/validate_manifests.sh" >/dev/null 2>&1; then
	echo "manifests: ok" >>"$OUT_TXT"
else
	echo "manifests: fail" >>"$OUT_TXT"
	fail=$((fail + 1))
fi

"$ROOT/scripts/build_queue.sh" --status >/dev/null 2>&1 || true
if [ -f "$REPORT_DIR/build_queue_status.txt" ]; then
	result=$(grep -E '^result:' "$REPORT_DIR/build_queue_status.txt" | awk '{print $2}')
	if [ "$result" = "ok" ]; then
		echo "build_queue: ok" >>"$OUT_TXT"
	else
		echo "build_queue: warn" >>"$OUT_TXT"
		warn=$((warn + 1))
	fi
else
	echo "build_queue: missing" >>"$OUT_TXT"
	warn=$((warn + 1))
fi

"$ROOT/scripts/validate_build_plan.sh" >/dev/null 2>&1 || true
if [ -f "$REPORT_DIR/build_plan_validation.txt" ]; then
	result=$(grep -E '^result:' "$REPORT_DIR/build_plan_validation.txt" | awk '{print $2}')
	if [ "$result" = "ok" ]; then
		echo "build_plan: ok" >>"$OUT_TXT"
	else
		echo "build_plan: warn" >>"$OUT_TXT"
		warn=$((warn + 1))
	fi
else
	echo "build_plan: missing" >>"$OUT_TXT"
	warn=$((warn + 1))
fi

"$ROOT/scripts/validate_build_queue_state.sh" >/dev/null 2>&1 || true
if [ -f "$REPORT_DIR/build_queue_state_validation.txt" ]; then
	result=$(grep -E '^result:' "$REPORT_DIR/build_queue_state_validation.txt" | awk '{print $2}')
	if [ "$result" = "ok" ]; then
		echo "queue_state: ok" >>"$OUT_TXT"
	else
		echo "queue_state: warn" >>"$OUT_TXT"
		warn=$((warn + 1))
	fi
else
	echo "queue_state: missing" >>"$OUT_TXT"
	warn=$((warn + 1))
fi

CHECK_GATE_ARGS=()
if [ -n "$CHECK_MAX_FAIL" ]; then
	CHECK_GATE_ARGS+=("--max-fail" "$CHECK_MAX_FAIL")
fi
if [ -n "$CHECK_MAX_IGNORED" ]; then
	CHECK_GATE_ARGS+=("--max-ignored" "$CHECK_MAX_IGNORED")
fi
if [ -n "$CHECK_MAX_MISSING" ]; then
	CHECK_GATE_ARGS+=("--max-missing" "$CHECK_MAX_MISSING")
fi
if [ -n "$CHECK_MAX_SEVERITY" ]; then
	CHECK_GATE_ARGS+=("--max-severity" "$CHECK_MAX_SEVERITY")
fi

"$ROOT/scripts/build_check_gate.sh" "${CHECK_GATE_ARGS[@]}" >/dev/null 2>&1 || true
if [ -f "$REPORT_DIR/build_check_gate.txt" ]; then
	result=$(grep -E '^result:' "$REPORT_DIR/build_check_gate.txt" | awk '{print $2}')
	if [ "$result" = "ok" ]; then
		echo "build_check: ok" >>"$OUT_TXT"
	else
		echo "build_check: warn" >>"$OUT_TXT"
		if [ "$ALLOW_CHECK_WARN" -eq 0 ]; then
			warn=$((warn + 1))
		fi
	fi
else
	echo "build_check: missing" >>"$OUT_TXT"
	if [ "$ALLOW_CHECK_WARN" -eq 0 ]; then
		warn=$((warn + 1))
	fi
fi

if [ "$fail" -gt 0 ]; then
	echo "result: fail" >>"$OUT_TXT"
	write_json "fail"
	exit 1
fi

if [ "$warn" -gt 0 ] && [ "$ALLOW_WARN" -eq 0 ]; then
	echo "result: warn" >>"$OUT_TXT"
	write_json "warn"
	exit 1
fi

if [ "$warn" -gt 0 ]; then
	echo "result: warn" >>"$OUT_TXT"
	write_json "warn"
else
	echo "result: ok" >>"$OUT_TXT"
	write_json "ok"
fi

echo "[OK] Build gate generated: $OUT_TXT"
