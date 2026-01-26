#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${ROOT_OVERRIDE:-}" ]]; then
  ROOT="${ROOT_OVERRIDE}"
fi

for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/run_consumer.sh <consumer_dir> | --list | --help

Examples:
  food_application | financial_assistance | transportation_costs | contracts | grant_other_documents
EOF
      exit 0
      ;;
    --list)
      ;;
    -*)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

list_consumers() {
  ls -1 "${ROOT}/services/consumers"
}

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <consumer_dir>" >&2
  echo "Examples: food_application | financial_assistance | transportation_costs | contracts | grant_other_documents" >&2
  echo "" >&2
  echo "Available consumers:" >&2
  list_consumers >&2
  exit 1
fi

if [[ "$1" == "list" || "$1" == "--list" ]]; then
  list_consumers
  exit 0
fi

if ! command -v mvn >/dev/null 2>&1; then
  echo "mvn is required." >&2
  exit 1
fi

consumer="$1"
cd "${ROOT}/services/consumers/${consumer}"
mvn spring-boot:run
