#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TAR="$REPORT_DIR/build_summary_bundle.tar.gz"
OUT_TXT="$REPORT_DIR/build_summary_bundle_index.txt"
OUT_JSON="$REPORT_DIR/build_summary_bundle_index.json"

usage() {
	cat <<EOF
Usage: $0 [--tar <file>] [--out <file>] [--json <file>]

Indexe le contenu du build_summary bundle.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--tar) IN_TAR="$2"; shift 2 ;;
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
	echo "build_summary_bundle_index generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "tar: $IN_TAR"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$IN_TAR" ]; then
	echo "result: missing_bundle" >>"$OUT_TXT"
	echo "bundle missing" >>"$OUT_TXT"
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"bundle\": \"$IN_TAR\","
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	exit 0
fi

contents=$(tar -tzf "$IN_TAR")
count=$(printf '%s\n' "$contents" | wc -l | tr -d ' ')

echo "files: $count" >>"$OUT_TXT"
printf '%s\n' "$contents" >>"$OUT_TXT"
echo "result: ok" >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"bundle\": \"$IN_TAR\","
	echo "  \"files\": $count,"
	echo "  \"items\": ["
	first=1
	while IFS= read -r file; do
		[ -z "$file" ] && continue
		if [ "$first" -eq 0 ]; then
			echo "    ,\"$file\""
		else
			echo "    \"$file\""
			first=0
		fi
	done <<<"$contents"
	echo "  ],"
	echo "  \"result\": \"ok\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary bundle index generated: $OUT_TXT"
