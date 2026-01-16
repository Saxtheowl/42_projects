#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/manifest_coverage.txt"
OUT_CSV="$REPORT_DIR/manifest_coverage.csv"

SYSTEM_MANIFEST="$ROOT/configs/build_system_manifest.tsv"
MINI_MANIFEST="$ROOT/configs/mini_system_manifest.tsv"
LOGDIR="$ROOT/logs/system"

usage() {
	cat <<EOF
Usage: $0 [--system-manifest <file>] [--mini-manifest <file>] [--logdir <dir>]

Mesure la couverture des manifests par les logs d'installation.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--system-manifest) SYSTEM_MANIFEST="$2"; shift 2 ;;
		--mini-manifest) MINI_MANIFEST="$2"; shift 2 ;;
		--logdir) LOGDIR="$2"; shift 2 ;;
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

log_present() {
	local name="$1"
	[ -s "$LOGDIR/$name.install.log" ]
}

TOTAL_MISSING=0
TOTAL_PACKAGES=0

coverage_group() {
	local label="$1" manifest="$2"
	local total covered missing
	total=$(manifest_names "$manifest" | wc -l | tr -d ' ')
	covered=0
	missing=0
	while IFS= read -r name; do
		[ -n "$name" ] || continue
		if log_present "$name"; then
			covered=$((covered + 1))
		else
			missing=$((missing + 1))
		fi
	done < <(manifest_names "$manifest")
	TOTAL_MISSING=$((TOTAL_MISSING + missing))
	TOTAL_PACKAGES=$((TOTAL_PACKAGES + total))
	printf '%s,%s,%s,%s\n' "$label" "$total" "$covered" "$missing" >>"$OUT_CSV"
	{
		echo "[$label]"
		echo "manifest: $manifest"
		echo "total: $total"
		echo "covered: $covered"
		echo "missing: $missing"
		echo ""
	} >>"$OUT_TXT"
}

{
	echo "manifest_coverage generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "logdir: $LOGDIR"
	echo ""
} >"$OUT_TXT"

echo "group,total,covered,missing" >"$OUT_CSV"

coverage_group "build_system" "$SYSTEM_MANIFEST"
coverage_group "mini_system" "$MINI_MANIFEST"

if [ "$TOTAL_MISSING" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: partial" >>"$OUT_TXT"
	echo "missing_total: $TOTAL_MISSING" >>"$OUT_TXT"
	echo "total_packages: $TOTAL_PACKAGES" >>"$OUT_TXT"
fi

echo "[OK] Manifest coverage generated: $OUT_TXT $OUT_CSV"
