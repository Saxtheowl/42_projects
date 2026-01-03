#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
LAYOUT="${LAYOUT:-$ROOT/configs/rootfs_layout.tsv}"
DRY_RUN=0

usage() {
	cat <<EOF
Usage: $0 [--layout <file>] [--lfs <dir>] [--dry-run]

Options:
  --layout <file>  Fichier TSV de layout (default: $LAYOUT)
  --lfs <dir>      Racine cible (default: $LFS)
  --dry-run        Affiche les actions sans ecrire.
EOF
	exit 1
}

trim() {
	printf '%s' "$1" | xargs
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--layout)
			LAYOUT="${2:-}"
			[ -n "$LAYOUT" ] || usage
			shift 2
			;;
		--lfs)
			LFS="${2:-}"
			[ -n "$LFS" ] || usage
			shift 2
			;;
		--dry-run)
			DRY_RUN=1
			shift
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

if [ ! -f "$LAYOUT" ]; then
	echo "[ERR] Layout introuvable: $LAYOUT" >&2
	exit 1
fi

mkdir -p "$LFS"

apply_dir() {
	local path="$1" mode="$2"
	local target="$LFS/${path#/}"
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] mkdir -p $target"
	else
		mkdir -p "$target"
	fi
	if [ -n "$mode" ]; then
		if [ "$DRY_RUN" -eq 1 ]; then
			echo "[dry-run] chmod $mode $target"
		else
			chmod "$mode" "$target"
		fi
	fi
}

apply_symlink() {
	local path="$1" target="$2"
	local link="$LFS/${path#/}"
	local dir
	dir=$(dirname "$link")
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] mkdir -p $dir"
		echo "[dry-run] ln -snf $target $link"
	else
		mkdir -p "$dir"
		ln -snf "$target" "$link"
	fi
}

apply_file() {
	local path="$1" mode="$2" content="$3"
	local dest="$LFS/${path#/}"
	local dir
	dir=$(dirname "$dest")
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] mkdir -p $dir"
		echo "[dry-run] write $dest"
	else
		mkdir -p "$dir"
		printf '%s\n' "$content" >"$dest"
	fi
	if [ -n "$mode" ]; then
		if [ "$DRY_RUN" -eq 1 ]; then
			echo "[dry-run] chmod $mode $dest"
		else
			chmod "$mode" "$dest"
		fi
	fi
}

while IFS= read -r line || [ -n "$line" ]; do
	case "$line" in
		""|\#*) continue ;;
	esac
	IFS='|' read -r raw_type raw_path raw_mode raw_target <<<"$line"
	raw_type=$(trim "$raw_type")
	raw_path=$(trim "$raw_path")
	raw_mode=$(trim "$raw_mode")
	raw_target=$(trim "$raw_target")
	case "$raw_type" in
		dir)
			apply_dir "$raw_path" "$raw_mode"
			;;
		symlink)
			if [ -z "$raw_target" ]; then
				echo "[ERR] Symlink sans cible: $raw_path" >&2
				exit 1
			fi
			apply_symlink "$raw_path" "$raw_target"
			;;
		file)
			apply_file "$raw_path" "$raw_mode" "$raw_target"
			;;
		*)
			echo "[ERR] Type inconnu: $raw_type" >&2
			exit 1
			;;
	esac
done <"$LAYOUT"

echo "[OK] Rootfs initialisee sous $LFS"
