#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
PREFLIGHT_TXT="$REPORT_DIR/preflight.txt"
TOOLCHAIN_TXT="$REPORT_DIR/build_toolchain_report.txt"
OUT_TXT="$REPORT_DIR/build_toolchain_session_report.txt"
OUT_JSON="$REPORT_DIR/build_toolchain_session_report.json"

usage() {
	cat <<EOF
Usage: $0 [--preflight <file>] [--toolchain <file>] [--out <file>] [--json <file>]

Genere un rapport de session toolchain (preflight + toolchain).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--preflight) PREFLIGHT_TXT="$2"; shift 2 ;;
		--toolchain) TOOLCHAIN_TXT="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_toolchain_session_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "preflight: $PREFLIGHT_TXT"
	echo "toolchain: $TOOLCHAIN_TXT"
	echo "json: $OUT_JSON"
	echo ""
} >"$OUT_TXT"

preflight_result="missing"
preflight_warns="0"
preflight_missing=0
if [ -f "$PREFLIGHT_TXT" ]; then
	preflight_result=$(grep -E '^result:' "$PREFLIGHT_TXT" | head -n 1 | awk '{print $2}')
	preflight_warns=$(grep -E '^warn_count:' "$PREFLIGHT_TXT" | head -n 1 | awk '{print $2}')
	preflight_result="${preflight_result:-unknown}"
	preflight_warns="${preflight_warns:-0}"
else
	preflight_missing=1
	echo "missing_preflight: $PREFLIGHT_TXT" >>"$OUT_TXT"
fi

toolchain_result="missing"
toolchain_state="missing"
toolchain_missing=0
if [ -f "$TOOLCHAIN_TXT" ]; then
	toolchain_result=$(grep -E '^result:' "$TOOLCHAIN_TXT" | head -n 1 | awk '{print $2}')
	toolchain_state=$(grep -E '^state_result:' "$TOOLCHAIN_TXT" | head -n 1 | awk '{print $2}')
	toolchain_result="${toolchain_result:-unknown}"
	toolchain_state="${toolchain_state:-unknown}"
else
	toolchain_missing=1
	echo "missing_toolchain: $TOOLCHAIN_TXT" >>"$OUT_TXT"
fi

overall="ok"
if [ "$preflight_result" != "ok" ] || [ "$toolchain_result" != "ok" ]; then
	overall="warn"
fi
if [ "$preflight_missing" -eq 1 ] || [ "$toolchain_missing" -eq 1 ]; then
	overall="fail"
fi

{
	echo "preflight_result: $preflight_result"
	echo "preflight_warns: $preflight_warns"
	echo "toolchain_result: $toolchain_result"
	echo "toolchain_state: $toolchain_state"
	echo "missing_preflight: $preflight_missing"
	echo "missing_toolchain: $toolchain_missing"
	echo "result: $overall"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"preflight\": {"
	echo "    \"source\": \"$PREFLIGHT_TXT\","
	echo "    \"result\": \"$preflight_result\","
	echo "    \"missing\": $preflight_missing,"
	echo "    \"warn_count\": ${preflight_warns:-0}"
	echo "  },"
	echo "  \"toolchain\": {"
	echo "    \"source\": \"$TOOLCHAIN_TXT\","
	echo "    \"result\": \"$toolchain_result\","
	echo "    \"missing\": $toolchain_missing,"
	echo "    \"state_result\": \"$toolchain_state\""
	echo "  },"
	echo "  \"result\": \"$overall\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build toolchain session report generated: $OUT_TXT"
