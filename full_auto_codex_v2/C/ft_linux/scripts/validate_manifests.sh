#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/sources"
MANIFESTS=(
	"$ROOT/configs/build_system_manifest.tsv"
	"$ROOT/configs/mini_system_manifest.tsv"
)

usage() {
	cat <<EOF
Usage: $0 [--manifest <file>]... [--report <file>]
EOF
	exit 1
}

REPORT_OUT=""

while [ "$#" -gt 0 ]; do
	case "$1" in
		--manifest)
			MANIFESTS+=("${2:-}")
			[ -n "${2:-}" ] || usage
			shift 2
			;;
		--report)
			REPORT_OUT="${2:-}"
			[ -n "$REPORT_OUT" ] || usage
			shift 2
			;;
		-h|--help)
			usage
			;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

if [ ! -d "$SRC" ]; then
	echo "[WARN] Sources directory missing: $SRC"
fi

trim() {
	printf '%s' "$1" | xargs
}

check_tarball() {
	local base="$1"
	local ext
	for ext in tar.xz tar.gz tar.bz2 tar.zst; do
		if [ -f "$SRC/$base.$ext" ]; then
			return 0
		fi
	done
	return 1
}

errors=0
report_lines=()
default_report="$ROOT/reports/manifest_report.txt"
declare -A pkg_counts
declare -A pkg_sources

for manifest in "${MANIFESTS[@]}"; do
	if [ ! -f "$manifest" ]; then
		echo "[ERR] Manifest introuvable: $manifest" >&2
		errors=$((errors + 1))
		report_lines+=("missing_manifest,$manifest")
		continue
	fi
	echo "[i] Checking $manifest"
	declare -A seen_in_manifest
	while IFS= read -r line || [ -n "$line" ]; do
		case "$line" in
			""|\#*) continue ;;
		esac
		IFS='|' read -r raw_name raw_version raw_cfg raw_extra raw_type <<<"$line"
		raw_name=$(trim "$raw_name")
		raw_version=$(trim "$raw_version")
		raw_type=$(trim "$raw_type")
		if [ -z "$raw_name" ] || [ -z "$raw_version" ]; then
			echo "[ERR] Ligne invalide (name/version manquant) dans $manifest: $line" >&2
			errors=$((errors + 1))
			report_lines+=("invalid_line,$manifest")
			continue
		fi
		if [ -n "$raw_type" ] && [ "$raw_type" != "autotools" ] && [ "$raw_type" != "makeonly" ]; then
			echo "[ERR] build_type invalide ($raw_type) pour $raw_name" >&2
			errors=$((errors + 1))
			report_lines+=("invalid_build_type,$raw_name")
		fi
		if [ -n "${seen_in_manifest[$raw_name]:-}" ]; then
			echo "[ERR] Doublon dans $manifest: $raw_name" >&2
			errors=$((errors + 1))
			report_lines+=("duplicate_in_manifest,$raw_name")
		else
			seen_in_manifest["$raw_name"]=1
		fi
		if ! check_tarball "$raw_name-$raw_version"; then
			echo "[WARN] Tarball manquant: $raw_name-$raw_version (sources/)" >&2
			report_lines+=("missing_tarball,$raw_name-$raw_version")
		fi
		pkg_counts["$raw_name"]=$(( ${pkg_counts["$raw_name"]:-0} + 1 ))
		if [ -n "${pkg_sources[$raw_name]:-}" ]; then
			pkg_sources["$raw_name"]+=",${manifest##*/}"
		else
			pkg_sources["$raw_name"]="${manifest##*/}"
		fi
	done <"$manifest"
done

for name in "${!pkg_counts[@]}"; do
	if [ "${pkg_counts[$name]}" -gt 1 ]; then
		echo "[WARN] Doublon entre manifests: $name (${pkg_sources[$name]})" >&2
		report_lines+=("duplicate_package,$name")
	fi
done

if [ -z "$REPORT_OUT" ]; then
	REPORT_OUT="$default_report"
fi

if [ -n "$REPORT_OUT" ]; then
	{
		echo "issue,detail"
		if [ "${#report_lines[@]}" -eq 0 ]; then
			echo "ok,none"
		else
			for line in "${report_lines[@]}"; do
				echo "$line"
			done
		fi
	} >"$REPORT_OUT"
fi

if [ "$errors" -ne 0 ]; then
	echo "[ERR] Validation echouee ($errors erreurs)." >&2
	exit 1
fi

echo "[OK] Manifests valides."
