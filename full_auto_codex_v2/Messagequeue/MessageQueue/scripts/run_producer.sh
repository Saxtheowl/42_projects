#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${ROOT_OVERRIDE:-}" ]]; then
  ROOT="${ROOT_OVERRIDE}"
fi

list_only=0
for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/run_producer.sh [--help] [--list]

Notes:
  - Runs mvn spring-boot:run in services/producer.
EOF
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
mvn spring-boot:run
