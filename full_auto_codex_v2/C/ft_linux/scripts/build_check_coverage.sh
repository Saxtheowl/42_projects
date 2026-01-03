#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_check_coverage.txt"
LOGDIR="$ROOT/logs/system"
CSV_FILE="$REPORT_DIR/build_check_status.csv"

SYSTEM_MANIFEST="$ROOT/configs/build_system_manifest.tsv"
MINI_MANIFEST="$ROOT/configs/mini_system_manifest.tsv"
SYSTEM_STATE="$ROOT/work/build_system.state"
MINI_STATE="$ROOT/work/mini_system.state"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--system-manifest <file>] [--mini-manifest <file>] [--system-state <file>] [--mini-state <file>]

Couverture des checks: manifest vs status CSV.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) CSV_FILE="$2"; shift 2 ;;
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

status_from_csv() {
	local name="$1"
	[ -f "$CSV_FILE" ] || return 1
	awk -F'|' -v name="$name" '$3==name {ts=$1; res=$4} END {if (res!="") print res}' "$CSV_FILE"
}

{
	echo "build_check_coverage generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV_FILE"
	echo ""
} >"$OUT_TXT"

total=0
ok=0
fail=0
fail_ignored=0
other=0
missing=0

record_missing() {
	echo "missing: $1" >>"$OUT_TXT"
}

record_fail() {
	echo "fail: $1 ($2)" >>"$OUT_TXT"
}

for name in $(manifest_names "$SYSTEM_MANIFEST"); do
	if state_has "$SYSTEM_STATE" "$name" || [ -f "$LOGDIR/$name.install.log" ]; then
		total=$((total + 1))
		status=$(status_from_csv "$name" || true)
		if [ -z "$status" ]; then
			missing=$((missing + 1))
			record_missing "$name"
		elif [ "$status" = "ok" ]; then
			ok=$((ok + 1))
		elif [ "$status" = "fail" ]; then
			fail=$((fail + 1))
			record_fail "$name" "$status"
		elif [ "$status" = "fail_ignored" ]; then
			fail_ignored=$((fail_ignored + 1))
			record_fail "$name" "$status"
		else
			other=$((other + 1))
		fi
	fi
done

for name in $(manifest_names "$MINI_MANIFEST"); do
	if state_has "$MINI_STATE" "$name" || [ -f "$LOGDIR/$name.install.log" ]; then
		total=$((total + 1))
		status=$(status_from_csv "$name" || true)
		if [ -z "$status" ]; then
			missing=$((missing + 1))
			record_missing "$name"
		elif [ "$status" = "ok" ]; then
			ok=$((ok + 1))
		elif [ "$status" = "fail" ]; then
			fail=$((fail + 1))
			record_fail "$name" "$status"
		elif [ "$status" = "fail_ignored" ]; then
			fail_ignored=$((fail_ignored + 1))
			record_fail "$name" "$status"
		else
			other=$((other + 1))
		fi
	fi
done

{
	echo ""
	echo "total: $total"
	echo "ok: $ok"
	echo "fail: $fail"
	echo "fail_ignored: $fail_ignored"
	echo "other: $other"
	echo "missing: $missing"
	if [ "$total" -gt 0 ]; then
		rate=$(awk -v a="$ok" -v b="$total" 'BEGIN{printf "%.2f", (a*100)/b}')
		missing_rate=$(awk -v a="$missing" -v b="$total" 'BEGIN{printf "%.2f", (a*100)/b}')
		echo "coverage_rate: $rate"
		echo "missing_rate: $missing_rate"
	else
		echo "coverage_rate: 0.00"
		echo "missing_rate: 0.00"
	fi
} >>"$OUT_TXT"

if [ "$fail" -eq 0 ] && [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check coverage generated: $OUT_TXT"
