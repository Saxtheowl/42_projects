#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_SH="$REPORT_DIR/build_plan.sh"
OUT_TXT="$REPORT_DIR/build_plan.txt"

SYSTEM_MANIFEST="$ROOT/configs/build_system_manifest.tsv"
SYSTEM_STATE="$ROOT/work/build_system.state"
MINI_MANIFEST="$ROOT/configs/mini_system_manifest.tsv"
MINI_STATE="$ROOT/work/mini_system.state"
WITH_CHECK=0
CHECK_ALLOW_FAIL=0

usage() {
	cat <<EOF
Usage: $0 [--system-manifest <file>] [--system-state <file>] [--mini-manifest <file>] [--mini-state <file>] [--out <file>] [--text <file>] [--with-check] [--check-allow-fail]

Genere un plan de build (commandes) a partir des manifests et states.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--system-manifest) SYSTEM_MANIFEST="$2"; shift 2 ;;
		--system-state) SYSTEM_STATE="$2"; shift 2 ;;
		--mini-manifest) MINI_MANIFEST="$2"; shift 2 ;;
		--mini-state) MINI_STATE="$2"; shift 2 ;;
		--out) OUT_SH="$2"; shift 2 ;;
		--text) OUT_TXT="$2"; shift 2 ;;
		--with-check) WITH_CHECK=1; shift ;;
		--check-allow-fail) CHECK_ALLOW_FAIL=1; shift ;;
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

pending_list() {
	local manifest="$1" state="$2"
	manifest_names "$manifest" | while IFS= read -r name; do
		if [ -f "$state" ] && grep -Fxq "$name" "$state"; then
			continue
		fi
		echo "$name"
	done
}

SYSTEM_PENDING=$(pending_list "$SYSTEM_MANIFEST" "$SYSTEM_STATE" || true)
MINI_PENDING=$(pending_list "$MINI_MANIFEST" "$MINI_STATE" || true)

{
	echo "#!/usr/bin/env bash"
	echo "set -euo pipefail"
	echo ""
	echo "# Build plan generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "# system manifest: $SYSTEM_MANIFEST"
	echo "# mini manifest: $MINI_MANIFEST"
	echo "# with_check: $WITH_CHECK"
	echo "# check_allow_fail: $CHECK_ALLOW_FAIL"
	echo ""
	if [ -n "$SYSTEM_PENDING" ]; then
		echo "# build_system"
		while IFS= read -r name; do
			[ -n "$name" ] || continue
			if [ "$WITH_CHECK" -eq 1 ]; then
				if [ "$CHECK_ALLOW_FAIL" -eq 1 ]; then
					echo "\"$ROOT/scripts/build_system.sh\" --check --check-allow-fail pkg \"$name\""
				else
					echo "\"$ROOT/scripts/build_system.sh\" --check pkg \"$name\""
				fi
			else
				echo "\"$ROOT/scripts/build_system.sh\" pkg \"$name\""
			fi
		done <<<"$SYSTEM_PENDING"
		echo ""
	fi
	if [ -n "$MINI_PENDING" ]; then
		echo "# mini_system"
		while IFS= read -r name; do
			[ -n "$name" ] || continue
			if [ "$WITH_CHECK" -eq 1 ]; then
				if [ "$CHECK_ALLOW_FAIL" -eq 1 ]; then
					echo "\"$ROOT/scripts/build_mini_system.sh\" --check --check-allow-fail \"$name\""
				else
					echo "\"$ROOT/scripts/build_mini_system.sh\" --check \"$name\""
				fi
			else
				echo "\"$ROOT/scripts/build_mini_system.sh\" \"$name\""
			fi
		done <<<"$MINI_PENDING"
		echo ""
	fi
} >"$OUT_SH"

{
	echo "build_plan generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "system_manifest: $SYSTEM_MANIFEST"
	echo "mini_manifest: $MINI_MANIFEST"
	echo ""
	echo "[build_system]"
	if [ -n "$SYSTEM_PENDING" ]; then
		echo "$SYSTEM_PENDING"
	else
		echo "none"
	fi
	echo ""
	echo "[mini_system]"
	if [ -n "$MINI_PENDING" ]; then
		echo "$MINI_PENDING"
	else
		echo "none"
	fi
} >"$OUT_TXT"

chmod +x "$OUT_SH"
echo "[OK] Build plan generated: $OUT_SH $OUT_TXT"
