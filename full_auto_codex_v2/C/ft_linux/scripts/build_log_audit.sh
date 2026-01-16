#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_log_audit.txt"
OUT_CSV="$REPORT_DIR/build_log_audit.csv"

SYSTEM_STATE="$ROOT/work/build_system.state"
MINI_STATE="$ROOT/work/mini_system.state"
LOGDIR="$ROOT/logs/system"

usage() {
	cat <<EOF
Usage: $0 [--system-state <file>] [--mini-state <file>] [--logdir <dir>]

Verifie la coherence entre state de reprise et logs d'installation.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--system-state) SYSTEM_STATE="$2"; shift 2 ;;
		--mini-state) MINI_STATE="$2"; shift 2 ;;
		--logdir) LOGDIR="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

state_names() {
	local state="$1"
	if [ -f "$state" ]; then
		sort -u "$state"
	fi
}

collect_states() {
	{ state_names "$SYSTEM_STATE"; state_names "$MINI_STATE"; } | sort -u
}

log_packages() {
	if [ -d "$LOGDIR" ]; then
		find "$LOGDIR" -maxdepth 1 -type f -name '*.install.log' -printf '%f\n' | sed 's/\.install\.log$//' | sort -u
	fi
}

{
	echo "build_log_audit generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "logdir: $LOGDIR"
	echo ""
} >"$OUT_TXT"

echo "package,has_install_log,has_make_log,has_config_log,notes" >"$OUT_CSV"

missing_install=0
missing_make=0
missing_config=0

while IFS= read -r name; do
	[ -n "$name" ] || continue
	install_log="$LOGDIR/$name.install.log"
	make_log="$LOGDIR/$name.make.log"
	config_log="$LOGDIR/$name.config.log"
	has_install="no"
	has_make="no"
	has_config="no"
	notes=""

	if [ -s "$install_log" ]; then
		has_install="yes"
	else
		notes="missing_install_log"
		missing_install=$((missing_install + 1))
	fi
	if [ -s "$make_log" ]; then
		has_make="yes"
	else
		missing_make=$((missing_make + 1))
	fi
	if [ -s "$config_log" ]; then
		has_config="yes"
	else
		missing_config=$((missing_config + 1))
	fi

	printf '%s,%s,%s,%s,%s\n' "$name" "$has_install" "$has_make" "$has_config" "$notes" >>"$OUT_CSV"
	printf '%s | install=%s make=%s config=%s %s\n' "$name" "$has_install" "$has_make" "$has_config" "$notes" >>"$OUT_TXT"
done < <(collect_states)

echo "" >>"$OUT_TXT"
echo "missing_install_logs: $missing_install" >>"$OUT_TXT"
echo "missing_make_logs: $missing_make" >>"$OUT_TXT"
echo "missing_config_logs: $missing_config" >>"$OUT_TXT"

orphan_count=0
orphan_list=$(comm -23 <(log_packages) <(collect_states) || true)
if [ -n "$orphan_list" ]; then
	orphan_count=$(printf '%s\n' "$orphan_list" | wc -l | tr -d ' ')
	echo "" >>"$OUT_TXT"
	echo "orphan_install_logs: $orphan_count" >>"$OUT_TXT"
	echo "$orphan_list" >>"$OUT_TXT"
else
	echo "" >>"$OUT_TXT"
	echo "orphan_install_logs: 0" >>"$OUT_TXT"
fi

if [ "$missing_install" -eq 0 ] && [ "$orphan_count" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build log audit generated: $OUT_TXT $OUT_CSV"
