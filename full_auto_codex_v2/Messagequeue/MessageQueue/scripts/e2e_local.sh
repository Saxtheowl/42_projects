#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

QUEUE="${QUEUE:-food_application}"
PAYLOAD_FILE="${PAYLOAD_FILE:-docs/sample_student.json}"
DOC_TYPE="${DOC_TYPE:-${QUEUE}}"
PDF_OUTPUT_DIR="${PDF_OUTPUT_DIR:-}"
EXCHANGE="${EXCHANGE:-}"
ROUTING_KEY="${ROUTING_KEY:-}"
ACK_MODE="${ACK_MODE:-ack_requeue_false}"
PURGE_QUEUE="${PURGE_QUEUE:-0}"
VALIDATE_PAYLOAD="${VALIDATE_PAYLOAD:-1}"
COUNT="${COUNT:-1}"
INDEX="${INDEX:-0}"
OUTPUT="${OUTPUT:-single}"
CHECK_RABBITMQ="${CHECK_RABBITMQ:-1}"

silent=0
json_output=0
dry_run=0
for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'USAGE'
Usage: ./scripts/e2e_local.sh [--help] [--silent] [--json] [--dry-run]

Environment:
  QUEUE          Queue name to consume from (default: food_application)
  EXCHANGE       Exchange to publish to (default: inferred from QUEUE)
  ROUTING_KEY    Routing key (default: derived by publish_test_message.sh)
  PAYLOAD_FILE   Payload JSON (default: docs/sample_student.json)
  DOC_TYPE       Document type for PDF naming (default: QUEUE)
  PDF_OUTPUT_DIR Output dir for dummy PDF (default: temp dir)
  ACK_MODE       ack_requeue_false|ack_requeue_true (default: ack_requeue_false)
  PURGE_QUEUE    Purge queue before publish (default: 0)
  VALIDATE_PAYLOAD Validate payload before publish (default: 1)
  COUNT          Messages to fetch (default: 1)
  INDEX          Message index to process (default: 0)
  OUTPUT         single|all (default: single)
  CHECK_RABBITMQ Run check_rabbitmq.sh before publish (default: 1)
USAGE
    exit 0
  elif [[ "${arg}" == "--silent" ]]; then
    silent=1
  elif [[ "${arg}" == "--json" ]]; then
    json_output=1
    silent=1
  elif [[ "${arg}" == "--dry-run" ]]; then
    dry_run=1
  else
    echo "Unknown option: ${arg}" >&2
    exit 1
  fi
done

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required." >&2
  exit 1
fi

if [[ -z "${EXCHANGE}" ]]; then
  case "${QUEUE}" in
    food_application|financial_assistance_application|transportation_costs_application)
      EXCHANGE="${SOCIAL_EXCHANGE:-SOCIAL_ASSISTANCE_EXCHANGE}"
      ;;
    *)
      EXCHANGE="${GRANT_EXCHANGE:-GRANT_EXCHANGE}"
      ;;
  esac
fi

if [[ -z "${ROUTING_KEY}" && "${EXCHANGE}" == "${SOCIAL_EXCHANGE:-SOCIAL_ASSISTANCE_EXCHANGE}" ]]; then
  ROUTING_KEY=""
fi

case "${OUTPUT}" in
  single|all)
    ;;
  *)
    echo "Unknown OUTPUT: ${OUTPUT} (use single or all)" >&2
    exit 1
    ;;
esac

case "${ACK_MODE}" in
  ack_requeue_false|ack_requeue_true)
    ;;
  *)
    echo "Unknown ACK_MODE: ${ACK_MODE} (use ack_requeue_false or ack_requeue_true)" >&2
    exit 1
    ;;
esac

case "${PURGE_QUEUE}" in
  0|1)
    ;;
  *)
    echo "Unknown PURGE_QUEUE: ${PURGE_QUEUE} (use 0 or 1)" >&2
    exit 1
    ;;
esac

case "${VALIDATE_PAYLOAD}" in
  0|1)
    ;;
  *)
    echo "Unknown VALIDATE_PAYLOAD: ${VALIDATE_PAYLOAD} (use 0 or 1)" >&2
    exit 1
    ;;
esac

case "${CHECK_RABBITMQ}" in
  0|1)
    ;;
  *)
    echo "Unknown CHECK_RABBITMQ: ${CHECK_RABBITMQ} (use 0 or 1)" >&2
    exit 1
    ;;
esac

if [[ -z "${DOC_TYPE}" ]]; then
  echo "DOC_TYPE must be non-empty." >&2
  exit 1
fi
if ! [[ "${DOC_TYPE}" =~ ^[A-Za-z0-9_.-]+$ ]]; then
  echo "DOC_TYPE must use only letters, numbers, dot, underscore, or hyphen." >&2
  exit 1
fi
if [[ ${#DOC_TYPE} -gt 255 ]]; then
  echo "DOC_TYPE must be 255 characters or less." >&2
  exit 1
fi
if [[ -z "${QUEUE}" ]]; then
  echo "QUEUE must be non-empty." >&2
  exit 1
fi
if ! [[ "${QUEUE}" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "QUEUE must use only letters, numbers, dot, underscore, or hyphen." >&2
  exit 1
fi
if [[ ${#QUEUE} -gt 255 ]]; then
  echo "QUEUE must be 255 characters or less." >&2
  exit 1
fi
if [[ -z "${EXCHANGE}" ]]; then
  echo "EXCHANGE must be non-empty." >&2
  exit 1
fi
if ! [[ "${EXCHANGE}" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "EXCHANGE must use only letters, numbers, dot, underscore, or hyphen." >&2
  exit 1
fi
if [[ ${#EXCHANGE} -gt 255 ]]; then
  echo "EXCHANGE must be 255 characters or less." >&2
  exit 1
fi
if [[ -n "${ROUTING_KEY}" && ! "${ROUTING_KEY}" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "ROUTING_KEY must use only letters, numbers, dot, underscore, or hyphen." >&2
  exit 1
fi
if [[ -n "${ROUTING_KEY}" && ${#ROUTING_KEY} -gt 255 ]]; then
  echo "ROUTING_KEY must be 255 characters or less." >&2
  exit 1
fi
if [[ -n "${ROUTING_KEY}" && "${EXCHANGE}" == "${SOCIAL_EXCHANGE:-SOCIAL_ASSISTANCE_EXCHANGE}" ]]; then
  echo "ROUTING_KEY must be empty for SOCIAL_ASSISTANCE_EXCHANGE." >&2
  exit 1
fi
if ! [[ "${COUNT}" =~ ^[0-9]+$ ]]; then
  echo "COUNT must be a positive integer." >&2
  exit 1
fi
if ! [[ "${INDEX}" =~ ^-?[0-9]+$ ]]; then
  echo "INDEX must be an integer." >&2
  exit 1
fi
if [[ "${COUNT}" -lt 1 ]]; then
  echo "COUNT must be >= 1." >&2
  exit 1
fi
if [[ "${INDEX}" -lt 0 ]]; then
  echo "INDEX must be >= 0." >&2
  exit 1
fi
if [[ "${OUTPUT}" == "single" && "${INDEX}" -ge "${COUNT}" ]]; then
  echo "INDEX must be < COUNT when OUTPUT=single." >&2
  exit 1
fi
if [[ "${OUTPUT}" == "all" && "${json_output}" -ne 1 ]]; then
  echo "OUTPUT=all requires --json." >&2
  exit 1
fi
if [[ "${OUTPUT}" == "all" && "${INDEX}" -ne 0 ]]; then
  echo "INDEX must be 0 when OUTPUT=all." >&2
  exit 1
fi
if [[ "${OUTPUT}" == "all" && "${COUNT}" -lt 2 ]]; then
  echo "COUNT must be >= 2 when OUTPUT=all." >&2
  exit 1
fi

resolved_payload="${PAYLOAD_FILE}"
if [[ -f "${PAYLOAD_FILE}" ]]; then
  :
elif [[ -f "${ROOT_DIR}/${PAYLOAD_FILE}" ]]; then
  resolved_payload="${ROOT_DIR}/${PAYLOAD_FILE}"
fi

pdf_output_missing=0
if [[ -n "${PDF_OUTPUT_DIR}" && "${PDF_OUTPUT_DIR}" != /* ]]; then
  echo "PDF_OUTPUT_DIR must be an absolute path: ${PDF_OUTPUT_DIR}" >&2
  exit 1
fi
if [[ -n "${PDF_OUTPUT_DIR}" ]]; then
  if [[ -d "${PDF_OUTPUT_DIR}" ]]; then
    if [[ ! -w "${PDF_OUTPUT_DIR}" ]]; then
      echo "PDF_OUTPUT_DIR must be writable: ${PDF_OUTPUT_DIR}" >&2
      exit 1
    fi
  elif [[ -e "${PDF_OUTPUT_DIR}" ]]; then
    echo "PDF_OUTPUT_DIR must be a directory: ${PDF_OUTPUT_DIR}" >&2
    exit 1
  elif [[ "${dry_run}" -eq 1 ]]; then
    pdf_output_missing=1
  else
    mkdir -p "${PDF_OUTPUT_DIR}" || {
      echo "Failed to create PDF_OUTPUT_DIR: ${PDF_OUTPUT_DIR}" >&2
      exit 1
    }
    if [[ ! -w "${PDF_OUTPUT_DIR}" ]]; then
      echo "PDF_OUTPUT_DIR must be writable: ${PDF_OUTPUT_DIR}" >&2
      exit 1
    fi
  fi
fi
if [[ ! -f "${resolved_payload}" ]]; then
  echo "Payload file not found: ${resolved_payload}" >&2
  exit 1
fi
if [[ "${resolved_payload}" != *.json ]]; then
  echo "Payload file must be a .json file: ${resolved_payload}" >&2
  exit 1
fi
if [[ ! -s "${resolved_payload}" ]]; then
  echo "Payload file must be non-empty: ${resolved_payload}" >&2
  exit 1
fi
if [[ ! -r "${resolved_payload}" ]]; then
  echo "Payload file must be readable: ${resolved_payload}" >&2
  exit 1
fi

if [[ -z "${ROUTING_KEY}" && "${EXCHANGE}" != "${SOCIAL_EXCHANGE:-SOCIAL_ASSISTANCE_EXCHANGE}" ]]; then
  ROUTING_KEY=$(python3 - "${resolved_payload}" <<'PY'
import json,sys
path=sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    payload=json.load(fh)
print(payload.get("grantType",""))
PY
)
  if [[ -z "${ROUTING_KEY}" ]]; then
    ROUTING_KEY="grant.1.contract"
    if [[ "${silent}" -eq 0 && "${json_output}" -eq 0 ]]; then
      echo "Warning: ROUTING_KEY not set and payload has no grantType; using ${ROUTING_KEY}." >&2
    fi
  fi
fi

validate_status="skipped"
if [[ "${dry_run}" -eq 1 ]]; then
  if [[ -n "${PDF_OUTPUT_DIR}" ]]; then
    pdf_dir_json="${PDF_OUTPUT_DIR}"
    if [[ "${pdf_output_missing}" -eq 1 ]]; then
      pdf_dir_display="${PDF_OUTPUT_DIR} (missing)"
    else
      pdf_dir_display="${PDF_OUTPUT_DIR}"
    fi
  else
    pdf_dir_json="<temp>"
    pdf_dir_display="<temp>"
  fi
  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' "{\"status\":\"dry_run\",\"queue\":\"${QUEUE}\",\"exchange\":\"${EXCHANGE}\",\"routing_key\":\"${ROUTING_KEY}\",\"payload_file\":\"${resolved_payload}\",\"doc_type\":\"${DOC_TYPE}\",\"pdf_output_dir\":\"${pdf_dir_json}\",\"pdf_output_dir_missing\":\"${pdf_output_missing}\",\"purge_queue\":\"${PURGE_QUEUE}\",\"ack_mode\":\"${ACK_MODE}\",\"validate_payload\":\"${VALIDATE_PAYLOAD}\",\"count\":\"${COUNT}\",\"index\":\"${INDEX}\",\"output\":\"${OUTPUT}\",\"check_rabbitmq\":\"${CHECK_RABBITMQ}\"}"
  elif [[ "${silent}" -eq 0 ]]; then
    echo "Dry run: QUEUE=${QUEUE} EXCHANGE=${EXCHANGE} ROUTING_KEY=${ROUTING_KEY}"
    echo "PAYLOAD_FILE=${resolved_payload} DOC_TYPE=${DOC_TYPE} PDF_OUTPUT_DIR=${pdf_dir_display}"
    echo "PURGE_QUEUE=${PURGE_QUEUE} ACK_MODE=${ACK_MODE} VALIDATE_PAYLOAD=${VALIDATE_PAYLOAD} COUNT=${COUNT} INDEX=${INDEX} OUTPUT=${OUTPUT} CHECK_RABBITMQ=${CHECK_RABBITMQ}"
  fi
  exit 0
fi

cleanup_dir=""
cleanup() {
  if [[ -n "${cleanup_dir}" && -z "${PDF_OUTPUT_DIR}" ]]; then
    rm -rf "${cleanup_dir}"
  fi
}
trap cleanup EXIT

if [[ -z "${PDF_OUTPUT_DIR}" ]]; then
  cleanup_dir=$(mktemp -d)
  PDF_OUTPUT_DIR="${cleanup_dir}"
elif [[ ! -d "${PDF_OUTPUT_DIR}" ]]; then
  echo "PDF_OUTPUT_DIR must be an existing directory: ${PDF_OUTPUT_DIR}" >&2
  exit 1
fi

PAYLOAD_FILE="${resolved_payload}"

if [[ "${CHECK_RABBITMQ}" == "1" ]]; then
  if ! "${ROOT_DIR}/scripts/check_rabbitmq.sh" --silent; then
    echo "RabbitMQ management API is not reachable. Start the broker and try again." >&2
    exit 1
  fi
fi

if [[ "${VALIDATE_PAYLOAD}" == "1" ]]; then
  if [[ "${silent}" -eq 1 || "${json_output}" -eq 1 ]]; then
    PAYLOAD_FILE="${PAYLOAD_FILE}" "${ROOT_DIR}/scripts/validate_payload.py" --json >/dev/null
  else
    PAYLOAD_FILE="${PAYLOAD_FILE}" "${ROOT_DIR}/scripts/validate_payload.py"
  fi
  validate_status="ok"
fi

if [[ "${PURGE_QUEUE}" == "1" ]]; then
  QUEUES="${QUEUE}" "${ROOT_DIR}/scripts/purge_queues.sh" >/dev/null
fi

EXCHANGE="${EXCHANGE}" ROUTING_KEY="${ROUTING_KEY}" PAYLOAD_FILE="${PAYLOAD_FILE}" \
  "${ROOT_DIR}/scripts/publish_test_message.sh" --silent

response=$(QUEUE="${QUEUE}" COUNT="${COUNT}" ACK_MODE="${ACK_MODE}" \
  "${ROOT_DIR}/scripts/consume_test_message.sh" --json)

payload_path="${PDF_OUTPUT_DIR}/e2e_payload.json"
if [[ "${OUTPUT}" == "all" ]]; then
  export ROOT_DIR DOC_TYPE PDF_OUTPUT_DIR
  export PAYLOAD_PATH="${payload_path}"
  results_json=$(python3 - <<'PY'
import json,os,sys,subprocess,tempfile
root=os.environ["ROOT_DIR"]
response=json.loads(sys.stdin.read())
if not response:
    print("No messages received from queue", file=sys.stderr)
    sys.exit(1)
doc_type=os.environ["DOC_TYPE"]
pdf_dir=os.environ["PDF_OUTPUT_DIR"]
payload_path=os.environ["PAYLOAD_PATH"]
results=[]
for idx, msg in enumerate(response):
    payload=msg.get("payload")
    if payload is None:
        raise SystemExit("Missing payload in message")
    if isinstance(payload, str):
        payload=json.loads(payload)
    with open(payload_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)
    student_id=payload.get("studentId")
    if not isinstance(student_id, str) or not student_id:
        raise SystemExit("studentId missing or invalid")
    env=os.environ.copy()
    env["PAYLOAD_FILE"]=payload_path
    env["DOC_TYPE"]=doc_type
    env["PDF_OUTPUT_DIR"]=pdf_dir
    proc=subprocess.run([f"{root}/scripts/simulate_consumer.py"], env=env, stdout=subprocess.DEVNULL)
    if proc.returncode != 0:
        raise SystemExit("simulate_consumer failed")
    pdf_path=f"{pdf_dir}/{doc_type}_{student_id}.pdf"
    if not os.path.isfile(pdf_path):
        raise SystemExit(f"PDF not generated: {pdf_path}")
    results.append({"index": idx, "student_id": student_id, "pdf_path": pdf_path})
print(json.dumps(results))
PY
<<<"${response}")

  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' "{\"status\":\"ok\",\"queue\":\"${QUEUE}\",\"exchange\":\"${EXCHANGE}\",\"routing_key\":\"${ROUTING_KEY}\",\"payload_validation\":\"${validate_status}\",\"count\":\"${COUNT}\",\"output\":\"${OUTPUT}\",\"results\":${results_json}}"
  elif [[ "${silent}" -eq 0 ]]; then
    echo "E2E OK: ${QUEUE} -> ${COUNT} PDF(s) in ${PDF_OUTPUT_DIR}"
  fi
  exit 0
fi

student_id=$(python3 - <<'PY'
import json,sys
raw=sys.stdin.read()
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON response: {exc}", file=sys.stderr)
    sys.exit(1)
if not data:
    print("No messages received from queue", file=sys.stderr)
    sys.exit(1)
index=int(sys.argv[2])
if index < 0 or index >= len(data):
    print(f"Index out of range: {index}", file=sys.stderr)
    sys.exit(1)
msg=data[index]
payload=msg.get("payload")
if payload is None:
    print("Missing payload in message", file=sys.stderr)
    sys.exit(1)
if isinstance(payload, str):
    try:
        payload=json.loads(payload)
    except json.JSONDecodeError as exc:
        print(f"Invalid payload JSON: {exc}", file=sys.stderr)
        sys.exit(1)
with open(sys.argv[1], "w", encoding="utf-8") as f:
    json.dump(payload, f, indent=2)
student_id=payload.get("studentId")
if not isinstance(student_id, str) or not student_id:
    print("studentId missing or invalid", file=sys.stderr)
    sys.exit(1)
print(student_id)
PY
"${payload_path}" "${INDEX}" <<<"${response}")

PAYLOAD_FILE="${payload_path}" DOC_TYPE="${DOC_TYPE}" PDF_OUTPUT_DIR="${PDF_OUTPUT_DIR}" \
  "${ROOT_DIR}/scripts/simulate_consumer.py" >/dev/null

pdf_path="${PDF_OUTPUT_DIR}/${DOC_TYPE}_${student_id}.pdf"
if [[ ! -f "${pdf_path}" ]]; then
  echo "PDF not generated: ${pdf_path}" >&2
  exit 1
fi

if [[ "${json_output}" -eq 1 ]]; then
  printf '%s\n' "{\"status\":\"ok\",\"queue\":\"${QUEUE}\",\"exchange\":\"${EXCHANGE}\",\"routing_key\":\"${ROUTING_KEY}\",\"student_id\":\"${student_id}\",\"pdf_path\":\"${pdf_path}\",\"payload_validation\":\"${validate_status}\",\"count\":\"${COUNT}\",\"index\":\"${INDEX}\",\"output\":\"${OUTPUT}\"}"
elif [[ "${silent}" -eq 0 ]]; then
  echo "E2E OK: ${QUEUE} -> ${pdf_path}"
fi
