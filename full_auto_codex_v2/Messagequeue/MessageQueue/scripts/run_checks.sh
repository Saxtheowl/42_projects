#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${ROOT_OVERRIDE:-}" ]]; then
  ROOT="${ROOT_OVERRIDE}"
fi

skip_doctor=0
skip_routing=0
silent=0
json_output=0

for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/run_checks.sh [--skip-routing] [--skip-doctor] [--silent] [--json] [--help]

Options:
  --skip-routing  Skip test_routing_matrix.
  --skip-doctor   Skip doctor.sh.
  --silent        Suppress output (errors still shown).
  --json          Output JSON summary.
Environment:
  ROOT_OVERRIDE  Override repository root for tests/stubs
EOF
      exit 0
      ;;
    --skip-doctor)
      skip_doctor=1
      ;;
    --skip-routing)
      skip_routing=1
      ;;
    --silent)
      silent=1
      ;;
    --json)
      json_output=1
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

if [[ "${json_output}" -eq 1 ]]; then
  doctor_result="skipped"
  routing_result="skipped"
  failed=0
  if [[ "${skip_doctor}" -eq 0 ]]; then
    if "${ROOT}/scripts/doctor.sh" --silent; then
      doctor_result="ok"
    else
      doctor_result="error"
      failed=1
    fi
  fi
  if [[ "${skip_routing}" -eq 0 ]]; then
    if "${ROOT}/scripts/test_routing_matrix.sh" --silent; then
      routing_result="ok"
    else
      routing_result="error"
      failed=1
    fi
  fi
  DOCTOR_RESULT="${doctor_result}" ROUTING_RESULT="${routing_result}" python3 - <<'PY'
import json,os
doctor=os.environ.get("DOCTOR_RESULT","skipped")
routing=os.environ.get("ROUTING_RESULT","skipped")
status="ok" if doctor != "error" and routing != "error" else "error"
print(json.dumps({"status": status, "doctor": doctor, "routing_matrix": routing}))
PY
  exit "${failed}"
fi

if [[ "${skip_doctor}" -eq 0 ]]; then
  "${ROOT}/scripts/doctor.sh"
else
  if [[ "${silent}" -eq 0 ]]; then
    echo "Skipping doctor (--skip-doctor)."
  fi
fi
if [[ "${skip_routing}" -eq 0 ]]; then
  "${ROOT}/scripts/test_routing_matrix.sh"
else
  if [[ "${silent}" -eq 0 ]]; then
    echo "Skipping routing matrix (--skip-routing)."
  fi
fi

if [[ "${silent}" -eq 0 ]]; then
  echo "Checks completed."
fi
