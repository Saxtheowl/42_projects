#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG="${IMG:-$ROOT/work/disk.raw}"
MEM="${MEM:-2048}"
CPUS="${CPUS:-2}"
UEFI=0
KERNEL=""
INITRD=""
APPEND=""
NOGRAPHIC=0
DRY_RUN=0
ENABLE_SSH=0
SSH_PORT="2222"

usage() {
	cat <<EOF
Usage: $0 [--img <file>] [--mem <mb>] [--cpus <n>] [--uefi] [--kernel <path>] [--initrd <path>] [--append <args>] [--nographic] [--dry-run] [--enable-ssh] [--ssh-port <port>]

Example (SSH):
  $0 --enable-ssh --ssh-port 2222

Defaults:
  IMG=$IMG
  MEM=$MEM
  CPUS=$CPUS
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--img)
			IMG="${2:-}"
			[ -n "$IMG" ] || usage
			shift 2
			;;
		--mem)
			MEM="${2:-}"
			[ -n "$MEM" ] || usage
			shift 2
			;;
		--cpus)
			CPUS="${2:-}"
			[ -n "$CPUS" ] || usage
			shift 2
			;;
		--uefi)
			UEFI=1
			shift
			;;
		--kernel)
			KERNEL="${2:-}"
			[ -n "$KERNEL" ] || usage
			shift 2
			;;
		--initrd)
			INITRD="${2:-}"
			[ -n "$INITRD" ] || usage
			shift 2
			;;
		--append)
			APPEND="${2:-}"
			[ -n "$APPEND" ] || usage
			shift 2
			;;
		--nographic)
			NOGRAPHIC=1
			shift
			;;
		--dry-run)
			DRY_RUN=1
			shift
			;;
		--enable-ssh)
			ENABLE_SSH=1
			shift
			;;
		--ssh-port)
			SSH_PORT="${2:-}"
			[ -n "$SSH_PORT" ] || usage
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

command -v qemu-system-x86_64 >/dev/null 2>&1 || {
	echo "[ERR] qemu-system-x86_64 introuvable." >&2
	exit 1
}

if [ ! -f "$IMG" ]; then
	echo "[ERR] Image introuvable: $IMG" >&2
	exit 1
fi

img_format="raw"
case "$IMG" in
	*.qcow2) img_format="qcow2" ;;
esac

QEMU_ARGS=(
	-m "$MEM"
	-smp "$CPUS"
	-drive "file=$IMG,format=$img_format,if=virtio"
)

if [ "$ENABLE_SSH" -eq 1 ]; then
	QEMU_ARGS+=(-netdev "user,id=net0,hostfwd=tcp::${SSH_PORT}-:22")
else
	QEMU_ARGS+=(-netdev "user,id=net0")
fi
QEMU_ARGS+=(-device "virtio-net,netdev=net0")

if [ "$UEFI" -eq 1 ]; then
	if [ -n "${OVMF_CODE:-}" ] && [ -f "$OVMF_CODE" ]; then
		QEMU_ARGS+=(-drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE")
	else
		echo "[WARN] UEFI demande mais OVMF_CODE non defini; utilisation BIOS." >&2
	fi
fi

if [ -n "$KERNEL" ]; then
	QEMU_ARGS+=(-kernel "$KERNEL")
	[ -n "$INITRD" ] && QEMU_ARGS+=(-initrd "$INITRD")
	[ -n "$APPEND" ] && QEMU_ARGS+=(-append "$APPEND")
fi

if [ "$NOGRAPHIC" -eq 1 ]; then
	QEMU_ARGS+=(-nographic)
fi

CMD=(qemu-system-x86_64 "${QEMU_ARGS[@]}")

echo "[i] ${CMD[*]}"
if [ "$DRY_RUN" -eq 1 ]; then
	exit 0
fi
exec "${CMD[@]}"
