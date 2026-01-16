#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLAN="$ROOT/reports/build_plan.sh"
REPORT_DIR="$ROOT/reports"
OUT_DIR="$REPORT_DIR/build_plan_splits"
OUT_TXT="$REPORT_DIR/build_plan_splits.txt"
CHUNK_SIZE=10

usage() {
	cat <<EOF
Usage: $0 [--plan <file>] [--chunk-size <n>] [--out-dir <dir>] [--out <file>]

Decoupe un plan de build en morceaux (scripts executables).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--plan) PLAN="$2"; shift 2 ;;
		--chunk-size) CHUNK_SIZE="$2"; shift 2 ;;
		--out-dir) OUT_DIR="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$OUT_DIR" "$REPORT_DIR"

{
	echo "build_plan_split generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "plan: $PLAN"
	echo "chunk_size: $CHUNK_SIZE"
	echo "out_dir: $OUT_DIR"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$PLAN" ]; then
	echo "result: missing_plan" >>"$OUT_TXT"
	echo "plan missing" >>"$OUT_TXT"
	exit 0
fi

commands_file="$(mktemp)"
grep -v '^[[:space:]]*$' "$PLAN" | grep -v '^[[:space:]]*#' >"$commands_file"
total=$(wc -l <"$commands_file" | tr -d ' ')
if [ "$total" -eq 0 ]; then
	echo "result: empty" >>"$OUT_TXT"
	echo "no commands" >>"$OUT_TXT"
	rm -f "$commands_file"
	exit 0
fi

split_count=0
idx=0
chunk_num=1
chunk_path=""

create_chunk() {
	local num="$1"
	local path="$2"
	{
		echo "#!/usr/bin/env bash"
		echo "set -euo pipefail"
		echo ""
		echo "# chunk $num generated: $(date '+%Y-%m-%d %H:%M:%S')"
	} >"$path"
}

while IFS= read -r cmd || [ -n "$cmd" ]; do
	if [ "$idx" -eq 0 ]; then
		printf -v suffix "%03d" "$chunk_num"
		chunk_path="$OUT_DIR/plan_chunk_$suffix.sh"
		create_chunk "$chunk_num" "$chunk_path"
	fi
	echo "$cmd" >>"$chunk_path"
	idx=$((idx + 1))
	if [ "$idx" -ge "$CHUNK_SIZE" ]; then
		chmod +x "$chunk_path"
		echo "$chunk_path" >>"$OUT_TXT"
		split_count=$((split_count + 1))
		chunk_num=$((chunk_num + 1))
		idx=0
	fi
done <"$commands_file"

if [ "$idx" -gt 0 ]; then
	chmod +x "$chunk_path"
	echo "$chunk_path" >>"$OUT_TXT"
	split_count=$((split_count + 1))
fi

rm -f "$commands_file"

echo "" >>"$OUT_TXT"
echo "chunks: $split_count" >>"$OUT_TXT"
echo "result: ok" >>"$OUT_TXT"

echo "[OK] Build plan split generated: $OUT_TXT"
