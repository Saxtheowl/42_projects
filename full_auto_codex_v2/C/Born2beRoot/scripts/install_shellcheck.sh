#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_DIR="${PROJECT_ROOT}/.tools/shellcheck"
BIN_PATH="${INSTALL_DIR}/shellcheck"
VERSION="${1:-v0.9.0}"
ARCHIVE="shellcheck-${VERSION}.linux.x86_64.tar.xz"
URL="https://github.com/koalaman/shellcheck/releases/download/${VERSION}/${ARCHIVE}"

if [ -x "${BIN_PATH}" ]; then
    echo "shellcheck already installed at ${BIN_PATH}" >&2
    exit 0
fi

mkdir -p "${INSTALL_DIR}"
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

curl -fsSL "${URL}" -o "${tmpdir}/${ARCHIVE}"
tar -C "${tmpdir}" -xf "${tmpdir}/${ARCHIVE}"
install "${tmpdir}/shellcheck-${VERSION}/shellcheck" "${BIN_PATH}"
chmod +x "${BIN_PATH}"

echo "shellcheck installed to ${BIN_PATH}" >&2
