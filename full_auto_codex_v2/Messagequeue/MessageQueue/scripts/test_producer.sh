#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${ROOT_OVERRIDE:-}" ]]; then
  ROOT="${ROOT_OVERRIDE}"
fi

usage() {
  cat <<'EOF'
Usage: ./scripts/test_producer.sh [--help] [--list]

Environment:
  MODULES  Unused (producer only)
  ROOT_OVERRIDE  Override repository root for tests/stubs
EOF
}

list_only=0
for arg in "$@"; do
  case "${arg}" in
    --help)
      usage
      exit 0
      ;;
    --list)
      list_only=1
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

if [[ "${list_only}" -eq 1 ]]; then
  echo "services/producer"
  exit 0
fi

if ! command -v mvn >/dev/null 2>&1; then
  echo "mvn is required." >&2
  exit 1
fi

cd "${ROOT}/services/producer"
mvn test
