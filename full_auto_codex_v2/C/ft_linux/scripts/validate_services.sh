#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
MANIFEST="${MANIFEST:-$ROOT/configs/services_manifest.tsv}"
REPORT_DIR="$ROOT/reports"
OUT="$REPORT_DIR/services_report.txt"

mkdir -p "$REPORT_DIR"

trim() {
	printf '%s' "$1" | xargs
}

if [ ! -f "$MANIFEST" ]; then
	echo "[ERR] Manifest introuvable: $MANIFEST" >&2
	exit 1
fi

missing=0

{
	echo "Services report for $LFS"
	echo "manifest: $MANIFEST"
	echo ""
	while IFS= read -r line || [ -n "$line" ]; do
		case "$line" in
			""|\#*) continue ;;
		esac
		IFS='|' read -r raw_name raw_start raw_kill raw_sp raw_kp <<<"$line"
		raw_name=$(trim "$raw_name")
		raw_start=$(trim "$raw_start")
		raw_kill=$(trim "$raw_kill")
		raw_sp=$(trim "$raw_sp")
		raw_kp=$(trim "$raw_kp")
		echo "service: $raw_name"
		if [ ! -x "$LFS/etc/rc.d/init.d/$raw_name" ]; then
			echo "  init_script: missing"
			missing=$((missing + 1))
		else
			echo "  init_script: ok"
		fi
		if [ "$raw_start" = "S" ]; then
			link="$LFS/etc/rc.d/rcS.d/S${raw_sp}${raw_name}"
			if [ -L "$link" ]; then
				echo "  rcS link: ok"
			else
				echo "  rcS link: missing"
				missing=$((missing + 1))
			fi
		else
			for lvl in $(echo "$raw_start" | fold -w1); do
				link="$LFS/etc/rc.d/rc${lvl}.d/S${raw_sp}${raw_name}"
				if [ -L "$link" ]; then
					echo "  rc${lvl} link: ok"
				else
					echo "  rc${lvl} link: missing"
					missing=$((missing + 1))
				fi
			done
		fi
		if [ "$raw_kill" = "K" ]; then
			link="$LFS/etc/rc.d/rcS.d/K${raw_kp}${raw_name}"
			if [ -L "$link" ]; then
				echo "  rcS kill link: ok"
			else
				echo "  rcS kill link: missing"
			fi
		else
			for lvl in $(echo "$raw_kill" | fold -w1); do
				link="$LFS/etc/rc.d/rc${lvl}.d/K${raw_kp}${raw_name}"
				if [ -L "$link" ]; then
					echo "  rc${lvl} kill link: ok"
				else
					echo "  rc${lvl} kill link: missing"
				fi
			done
		fi
		echo ""
	done <"$MANIFEST"
	echo "result: $( [ "$missing" -eq 0 ] && echo OK || echo MISSING\($missing\) )"
} >"$OUT"

echo "[OK] Services report generated: $OUT"
