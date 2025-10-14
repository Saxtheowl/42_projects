#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_DISK="${PROJECT_ROOT}/born2beroot-lvm.vdi"
DISK_PATH="${1:-${DEFAULT_DISK}}"

if [ ! -f "${DISK_PATH}" ]; then
    echo "Disk image not found: ${DISK_PATH}" >&2
    echo "Usage: $0 [/path/to/virtual-disk.vdi]" >&2
    exit 1
fi

sha1sum "${DISK_PATH}"
