#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
MANIFEST="${MANIFEST:-$ROOT/configs/initramfs_manifest.tsv}"
MODULES_LIST="${MODULES_LIST:-$ROOT/configs/initramfs_modules.txt}"
WORK="${WORK:-$ROOT/work/initramfs}"
OUT="${OUT:-$ROOT/work/initramfs.cpio.gz}"
BOOT_DIR="${BOOT_DIR:-$LFS/boot}"
VERSION="${KERNEL_VERSION:-6.6.54}"
INSTALL_BOOT=0
USE_GENERATED=0
GENERATE=0
BINS_LIST="${BINS_LIST:-$ROOT/configs/initramfs_bins.txt}"

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--manifest <file>] [--modules <file>] [--work <dir>] [--out <file>] [--install-boot] [--use-generated] [--generate]
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--lfs)
			LFS="${2:-}"
			[ -n "$LFS" ] || usage
			shift 2
			;;
		--manifest)
			MANIFEST="${2:-}"
			[ -n "$MANIFEST" ] || usage
			shift 2
			;;
		--modules)
			MODULES_LIST="${2:-}"
			[ -n "$MODULES_LIST" ] || usage
			shift 2
			;;
		--work)
			WORK="${2:-}"
			[ -n "$WORK" ] || usage
			shift 2
			;;
		--out)
			OUT="${2:-}"
			[ -n "$OUT" ] || usage
			shift 2
			;;
		--install-boot)
			INSTALL_BOOT=1
			shift
			;;
		--use-generated)
			USE_GENERATED=1
			shift
			;;
		--generate)
			GENERATE=1
			USE_GENERATED=1
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

if [ ! -d "$LFS" ]; then
	echo "[ERR] LFS introuvable: $LFS" >&2
	exit 1
fi

if [ "$GENERATE" -eq 1 ]; then
	"$ROOT/scripts/generate_initramfs_manifest.sh" --lfs "$LFS" --bins "$BINS_LIST" --out "$ROOT/configs/initramfs_manifest.generated.tsv"
fi

if [ "$USE_GENERATED" -eq 1 ]; then
	gen_manifest="$ROOT/configs/initramfs_manifest.generated.tsv"
	if [ -f "$gen_manifest" ]; then
		MANIFEST="$gen_manifest"
	else
		echo "[ERR] Generated manifest missing: $gen_manifest" >&2
		exit 1
	fi
fi

if [ ! -f "$MANIFEST" ]; then
	echo "[ERR] Manifest introuvable: $MANIFEST" >&2
	exit 1
fi

command -v cpio >/dev/null 2>&1 || { echo "[ERR] cpio manquant." >&2; exit 1; }
command -v gzip >/dev/null 2>&1 || { echo "[ERR] gzip manquant." >&2; exit 1; }

rm -rf "$WORK"
mkdir -p "$WORK"

cat >"$WORK/init" <<'EOF'
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev 2>/dev/null || mount -t tmpfs tmpfs /dev

echo "[initramfs] booting..."

if [ -f /etc/modules ]; then
	while read -r mod; do
		[ -z "$mod" ] && continue
		modprobe "$mod" 2>/dev/null || true
	done </etc/modules
fi

if [ -x /sbin/init ]; then
	exec /sbin/init
fi
if [ -x /bin/sh ]; then
	exec /bin/sh
fi
echo "[initramfs] no init found."
exec sh
EOF
chmod +x "$WORK/init"

trim() {
	printf '%s' "$1" | xargs
}

missing=0
while IFS= read -r line || [ -n "$line" ]; do
	case "$line" in
		""|\#*) continue ;;
	esac
	IFS='|' read -r raw_type raw_path raw_target <<<"$line"
	raw_type=$(trim "$raw_type")
	raw_path=$(trim "$raw_path")
	raw_target=$(trim "$raw_target")
	case "$raw_type" in
		dir)
			mkdir -p "$WORK/$raw_path"
			;;
		file)
			if [ -f "$LFS/$raw_path" ]; then
				mkdir -p "$WORK/$(dirname "$raw_path")"
				cp -a "$LFS/$raw_path" "$WORK/$raw_path"
			else
				echo "[WARN] file missing: $LFS/$raw_path" >&2
				missing=$((missing + 1))
			fi
			;;
		symlink)
			if [ -z "$raw_target" ]; then
				echo "[ERR] symlink target missing: $raw_path" >&2
				exit 1
			fi
			mkdir -p "$WORK/$(dirname "$raw_path")"
			ln -snf "$raw_target" "$WORK/$raw_path"
			;;
		*)
			echo "[ERR] Type inconnu: $raw_type" >&2
			exit 1
			;;
	esac
done <"$MANIFEST"

if [ -f "$MODULES_LIST" ]; then
	mkdir -p "$WORK/etc"
	cp -f "$MODULES_LIST" "$WORK/etc/modules"
fi

if [ "$(id -u)" -eq 0 ]; then
	mkdir -p "$WORK/dev"
	mknod -m 600 "$WORK/dev/console" c 5 1 2>/dev/null || true
	mknod -m 666 "$WORK/dev/null" c 1 3 2>/dev/null || true
else
	echo "[WARN] root requis pour /dev/console et /dev/null." >&2
fi

(
	cd "$WORK"
	find . -print0 | cpio --null -ov --format=newc 2>/dev/null | gzip -9 >"$OUT"
)

if [ "$missing" -ne 0 ]; then
	echo "[WARN] initramfs generated with missing files: $missing"
fi
echo "[OK] initramfs created: $OUT"

if [ "$INSTALL_BOOT" -eq 1 ]; then
	mkdir -p "$BOOT_DIR"
	BOOT_IMG="$BOOT_DIR/initramfs-$VERSION-ftlinux.img"
	cp -f "$OUT" "$BOOT_IMG"
	echo "[OK] initramfs installed: $BOOT_IMG"
fi
