#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT="$REPORT_DIR/release_report.txt"
VERSIONS_DOC="$ROOT/docs/versions.md"
MANIFESTS=(
	"$ROOT/configs/build_system_manifest.tsv"
	"$ROOT/configs/mini_system_manifest.tsv"
)

mkdir -p "$REPORT_DIR"

trim() {
	printf '%s' "$1" | xargs
}

{
	echo "ft_linux release report"
	echo "generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	if [ -f "$VERSIONS_DOC" ]; then
		echo "## versions.md"
		sed -n '1,40p' "$VERSIONS_DOC"
		echo ""
	else
		echo "## versions.md"
		echo "missing: $VERSIONS_DOC"
		echo ""
	fi
	for manifest in "${MANIFESTS[@]}"; do
		echo "## $(basename "$manifest")"
		if [ -f "$manifest" ]; then
			while IFS= read -r line || [ -n "$line" ]; do
				case "$line" in
					""|\#*) continue ;;
				esac
				IFS='|' read -r raw_name raw_version raw_cfg raw_extra raw_type <<<"$line"
				raw_name=$(trim "$raw_name")
				raw_version=$(trim "$raw_version")
				raw_type=$(trim "$raw_type")
				printf "%-16s %-10s %s\n" "$raw_name" "$raw_version" "${raw_type:-autotools}"
			done <"$manifest"
		else
			echo "missing: $manifest"
		fi
		echo ""
	done
} >"$OUT"

echo "[OK] Release report generated: $OUT"
