#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLAN="$ROOT/reports/build_plan.sh"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_plan_validation.txt"
OUT_CSV="$REPORT_DIR/build_plan_validation.csv"

SYSTEM_MANIFEST="$ROOT/configs/build_system_manifest.tsv"
MINI_MANIFEST="$ROOT/configs/mini_system_manifest.tsv"

usage() {
	cat <<EOF
Usage: $0 [--plan <file>] [--system-manifest <file>] [--mini-manifest <file>]

Valide que le plan de build reference des paquets connus des manifests.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--plan) PLAN="$2"; shift 2 ;;
		--system-manifest) SYSTEM_MANIFEST="$2"; shift 2 ;;
		--mini-manifest) MINI_MANIFEST="$2"; shift 2 ;;
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

known_names() {
	{ manifest_names "$SYSTEM_MANIFEST"; manifest_names "$MINI_MANIFEST"; } | sort -u
}

extract_plan_pkgs() {
	grep -v '^[[:space:]]*$' "$PLAN" | grep -v '^[[:space:]]*#' | while IFS= read -r line; do
		case "$line" in
			*"build_system.sh"*pkg*)
				echo "$line" | awk -F'pkg' '{print $2}' | sed 's/[\"'\'' ]//g'
				;;
			*"build_mini_system.sh"*)
				echo "$line" | awk '{print $NF}' | sed 's/[\"'\'' ]//g'
				;;
		esac
	done
}

{
	echo "build_plan_validation generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "plan: $PLAN"
	echo ""
} >"$OUT_TXT"

echo "package,status" >"$OUT_CSV"

if [ ! -f "$PLAN" ]; then
	echo "result: missing_plan" >>"$OUT_TXT"
	echo "plan missing" >>"$OUT_TXT"
	echo "[WARN] Plan introuvable." >>"$OUT_TXT"
	exit 0
fi

unknown=0
unknown_list=""
known_file="$(mktemp)"
plan_file="$(mktemp)"
known_names >"$known_file"
extract_plan_pkgs | sort -u >"$plan_file"
while IFS= read -r pkg; do
	if grep -Fxq "$pkg" "$known_file"; then
		echo "$pkg,ok" >>"$OUT_CSV"
	else
		echo "$pkg,unknown" >>"$OUT_CSV"
		unknown=$((unknown + 1))
		unknown_list+="${pkg}"$'\n'
	fi
done <"$plan_file"
rm -f "$known_file" "$plan_file"

if [ "$unknown" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
	echo "unknown_count: $unknown" >>"$OUT_TXT"
	echo "unknown_list:" >>"$OUT_TXT"
	printf '%s' "$unknown_list" >>"$OUT_TXT"
fi

echo "[OK] Build plan validation generated: $OUT_TXT $OUT_CSV"
