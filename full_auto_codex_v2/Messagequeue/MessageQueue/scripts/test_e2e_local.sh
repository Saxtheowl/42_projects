#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

json_output=0
QUEUE="${QUEUE:-food_application}"
COUNT="${COUNT:-2}"
INDEX="${INDEX:-0}"
OUTPUT="${OUTPUT:-all}"
for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/test_e2e_local.sh [--help] [--json]

Runs e2e_local.sh in dry-run JSON mode and validates the output shape.

Environment:
  QUEUE   Queue name (default: food_application)
  COUNT   Messages to fetch (default: 2)
  INDEX   Message index to validate (default: 0)
  OUTPUT  single|all (default: all)
EOF
    exit 0
  elif [[ "${arg}" == "--json" ]]; then
    json_output=1
  else
    echo "Unknown option: ${arg}" >&2
    exit 1
  fi
done

if OUTPUT=all "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected OUTPUT=all without --json to fail." >&2
  exit 1
fi

if COUNT=1 INDEX=1 OUTPUT=single "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected INDEX >= COUNT to fail when OUTPUT=single." >&2
  exit 1
fi

if COUNT=0 OUTPUT=single "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected COUNT=0 to fail." >&2
  exit 1
fi

if INDEX=-1 OUTPUT=single "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected INDEX=-1 to fail." >&2
  exit 1
fi

if OUTPUT=invalid "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected OUTPUT=invalid to fail." >&2
  exit 1
fi

if ! OUTPUT="" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected OUTPUT empty to default and succeed." >&2
  exit 1
fi

if ! OUTPUT="single" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected OUTPUT=single to succeed." >&2
  exit 1
fi

if ! COUNT=1 INDEX=0 OUTPUT="single" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected COUNT=1 INDEX=0 OUTPUT=single to succeed." >&2
  exit 1
fi

if ! COUNT=2 INDEX=1 OUTPUT="single" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected COUNT=2 INDEX=1 OUTPUT=single to succeed." >&2
  exit 1
fi

if ! COUNT=3 INDEX=0 OUTPUT="single" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected COUNT=3 INDEX=0 OUTPUT=single to succeed." >&2
  exit 1
fi

if COUNT=foo OUTPUT=single "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected COUNT=foo to fail." >&2
  exit 1
fi

if COUNT=1.5 OUTPUT=single "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected COUNT=1.5 to fail." >&2
  exit 1
fi

if INDEX=foo OUTPUT=single "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected INDEX=foo to fail." >&2
  exit 1
fi

if INDEX=1.5 OUTPUT=single "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected INDEX=1.5 to fail." >&2
  exit 1
fi

if ! INDEX=0000 OUTPUT=single "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected INDEX with leading zeros to succeed." >&2
  exit 1
fi

if COUNT=-1 OUTPUT=single "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected COUNT=-1 to fail." >&2
  exit 1
fi

if ! COUNT=0001 OUTPUT=single "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected COUNT with leading zeros to succeed." >&2
  exit 1
fi

if ACK_MODE=bad "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected ACK_MODE=bad to fail." >&2
  exit 1
fi

if ! ACK_MODE="ack_requeue_true" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected ACK_MODE=ack_requeue_true to succeed." >&2
  exit 1
fi

if PURGE_QUEUE=2 "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected PURGE_QUEUE=2 to fail." >&2
  exit 1
fi

if ! PURGE_QUEUE=1 "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected PURGE_QUEUE=1 to succeed." >&2
  exit 1
fi

if VALIDATE_PAYLOAD=2 "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected VALIDATE_PAYLOAD=2 to fail." >&2
  exit 1
fi

if ! VALIDATE_PAYLOAD=0 "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected VALIDATE_PAYLOAD=0 to succeed." >&2
  exit 1
fi

if CHECK_RABBITMQ=2 "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected CHECK_RABBITMQ=2 to fail." >&2
  exit 1
fi

if ! CHECK_RABBITMQ=0 "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected CHECK_RABBITMQ=0 to succeed." >&2
  exit 1
fi

tmp_pdf_dir=$(mktemp)
if PDF_OUTPUT_DIR="${tmp_pdf_dir}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected PDF_OUTPUT_DIR file path to fail." >&2
  rm -f "${tmp_pdf_dir}"
  exit 1
fi
rm -f "${tmp_pdf_dir}"

tmp_pdf_dir=$(mktemp -d)
chmod 500 "${tmp_pdf_dir}"
if PDF_OUTPUT_DIR="${tmp_pdf_dir}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected PDF_OUTPUT_DIR non-writable to fail." >&2
  chmod 700 "${tmp_pdf_dir}"
  rmdir "${tmp_pdf_dir}"
  exit 1
fi
chmod 700 "${tmp_pdf_dir}"
rmdir "${tmp_pdf_dir}"

tmp_pdf_dir=$(mktemp -d)
if ! PDF_OUTPUT_DIR="${tmp_pdf_dir}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected writable PDF_OUTPUT_DIR to succeed." >&2
  rmdir "${tmp_pdf_dir}"
  exit 1
fi
rmdir "${tmp_pdf_dir}"

rel_pdf_dir=$(mktemp -d -p "${ROOT_DIR}" relpdf.XXXX)
rel_pdf_name=$(basename "${rel_pdf_dir}")
if PDF_OUTPUT_DIR="${rel_pdf_name}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected relative PDF_OUTPUT_DIR to fail." >&2
  rmdir "${rel_pdf_dir}"
  exit 1
fi
rmdir "${rel_pdf_dir}"

fake_abs_dir="/tmp/nonexistent-e2e-$$"
if ! PDF_OUTPUT_DIR="${fake_abs_dir}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected non-existent PDF_OUTPUT_DIR to succeed in dry-run." >&2
  exit 1
fi
if [[ -d "${fake_abs_dir}" ]]; then
  rmdir "${fake_abs_dir}"
fi

missing_pdf_json=$(PDF_OUTPUT_DIR="${fake_abs_dir}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${missing_pdf_json}" EXPECTED_PDF_DIR="${fake_abs_dir}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
expected=os.environ.get("EXPECTED_PDF_DIR","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("pdf_output_dir_missing") != "1":
    print("pdf_output_dir_missing not set to 1", file=sys.stderr)
    sys.exit(1)
pdf_dir=data.get("pdf_output_dir","")
if not pdf_dir.startswith(expected):
    print("pdf_output_dir does not start with expected path", file=sys.stderr)
    sys.exit(1)
PY

if DOC_TYPE="bad value" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected DOC_TYPE with spaces to fail." >&2
  exit 1
fi

if ! DOC_TYPE="good.type" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected DOC_TYPE with dot to succeed." >&2
  exit 1
fi

long_doc_type=$(printf 'a%.0s' {1..256})
if DOC_TYPE="${long_doc_type}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected DOC_TYPE length > 255 to fail." >&2
  exit 1
fi

doc_type_255=$(printf 'a%.0s' {1..255})
if ! DOC_TYPE="${doc_type_255}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected DOC_TYPE length 255 to succeed." >&2
  exit 1
fi

if PAYLOAD_FILE="docs/missing_payload.json" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected missing PAYLOAD_FILE to fail." >&2
  exit 1
fi

if PAYLOAD_FILE="docs/MessageQueue.pdf" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected non-JSON PAYLOAD_FILE to fail." >&2
  exit 1
fi

if ! PAYLOAD_FILE="docs/sample_student.json" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected relative PAYLOAD_FILE to succeed." >&2
  exit 1
fi

empty_payload=$(mktemp)
if PAYLOAD_FILE="${empty_payload}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected empty PAYLOAD_FILE to fail." >&2
  rm -f "${empty_payload}"
  exit 1
fi
rm -f "${empty_payload}"

unreadable_payload=$(mktemp)
chmod 000 "${unreadable_payload}"
if PAYLOAD_FILE="${unreadable_payload}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected unreadable PAYLOAD_FILE to fail." >&2
  chmod 600 "${unreadable_payload}"
  rm -f "${unreadable_payload}"
  exit 1
fi
chmod 600 "${unreadable_payload}"
rm -f "${unreadable_payload}"

payload_dir=$(mktemp -d)
if PAYLOAD_FILE="${payload_dir}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected directory PAYLOAD_FILE to fail." >&2
  rmdir "${payload_dir}"
  exit 1
fi
rmdir "${payload_dir}"

if QUEUE="bad value" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected QUEUE with spaces to fail." >&2
  exit 1
fi

if ! QUEUE="queue.name_ok" DOC_TYPE="queue_name_ok" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected QUEUE with dot to succeed." >&2
  exit 1
fi

if ! QUEUE="queue_name_ok" DOC_TYPE="queue_name_ok" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected QUEUE with underscore to succeed." >&2
  exit 1
fi

if ! QUEUE="queue-name-ok" DOC_TYPE="queue_name_ok" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected QUEUE with hyphen to succeed." >&2
  exit 1
fi

long_queue=$(printf 'a%.0s' {1..256})
if QUEUE="${long_queue}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected QUEUE length > 255 to fail." >&2
  exit 1
fi

queue_255=$(printf 'a%.0s' {1..255})
if ! QUEUE="${queue_255}" DOC_TYPE="queue_name_ok" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected QUEUE length 255 to succeed." >&2
  exit 1
fi

if EXCHANGE="bad value" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected EXCHANGE with spaces to fail." >&2
  exit 1
fi

if ! EXCHANGE="valid.exchange" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected EXCHANGE with dot to succeed." >&2
  exit 1
fi

if ! EXCHANGE="GRANT_EXCHANGE_2" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected EXCHANGE with underscore to succeed." >&2
  exit 1
fi

if ! EXCHANGE="GRANT-EXCHANGE-2" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected EXCHANGE with hyphen to succeed." >&2
  exit 1
fi

long_exchange=$(printf 'a%.0s' {1..256})
if EXCHANGE="${long_exchange}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected EXCHANGE length > 255 to fail." >&2
  exit 1
fi

exchange_255=$(printf 'a%.0s' {1..255})
if ! EXCHANGE="${exchange_255}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected EXCHANGE length 255 to succeed." >&2
  exit 1
fi

if ROUTING_KEY="bad value" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected ROUTING_KEY with spaces to fail." >&2
  exit 1
fi

if ! EXCHANGE="GRANT_EXCHANGE" ROUTING_KEY="grant.1.test" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected ROUTING_KEY with dot to succeed." >&2
  exit 1
fi

if ! EXCHANGE="GRANT_EXCHANGE" ROUTING_KEY="grant-1-test" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected ROUTING_KEY with hyphen to succeed." >&2
  exit 1
fi

if ! EXCHANGE="GRANT_EXCHANGE" ROUTING_KEY="grant_1_test" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected ROUTING_KEY with underscore to succeed." >&2
  exit 1
fi

if ! EXCHANGE="GRANT_EXCHANGE" ROUTING_KEY="grant-1_test.2" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected ROUTING_KEY with mixed symbols to succeed." >&2
  exit 1
fi

if ! EXCHANGE="GRANT_EXCHANGE" ROUTING_KEY="grant.key-1_2" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected ROUTING_KEY with dot/underscore/hyphen to succeed." >&2
  exit 1
fi

long_key=$(printf 'a%.0s' {1..256})
if ROUTING_KEY="${long_key}" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected ROUTING_KEY length > 255 to fail." >&2
  exit 1
fi

key_255=$(printf 'a%.0s' {1..255})
if ! EXCHANGE="GRANT_EXCHANGE" ROUTING_KEY="${key_255}" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected ROUTING_KEY length 255 to succeed." >&2
  exit 1
fi

if EXCHANGE="SOCIAL_ASSISTANCE_EXCHANGE" ROUTING_KEY="grant.1.test" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected ROUTING_KEY with SOCIAL_ASSISTANCE_EXCHANGE to fail." >&2
  exit 1
fi

if ! EXCHANGE="SOCIAL_ASSISTANCE_EXCHANGE" ROUTING_KEY="" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected empty ROUTING_KEY with SOCIAL_ASSISTANCE_EXCHANGE to succeed." >&2
  exit 1
fi

if COUNT=1 OUTPUT=all "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run >/dev/null 2>&1; then
  echo "Expected COUNT=1 to fail with OUTPUT=all." >&2
  exit 1
fi

if COUNT=2 INDEX=1 OUTPUT=all "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json >/dev/null 2>&1; then
  echo "Expected OUTPUT=all with INDEX=1 to fail." >&2
  exit 1
fi

if COUNT=1 OUTPUT=all "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json >/dev/null 2>&1; then
  echo "Expected COUNT=1 to fail with OUTPUT=all even with --json." >&2
  exit 1
fi

if INDEX=1 OUTPUT=all "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json >/dev/null 2>&1; then
  echo "Expected INDEX=1 to fail with OUTPUT=all." >&2
  exit 1
fi

if ! COUNT=2 INDEX=0 OUTPUT=all "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json >/dev/null 2>&1; then
  echo "Expected OUTPUT=all with COUNT=2 INDEX=0 to succeed." >&2
  exit 1
fi

custom_json=$(VALIDATE_PAYLOAD=0 CHECK_RABBITMQ=0 \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${custom_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("validate_payload") != "0":
    print("validate_payload not overridden to 0", file=sys.stderr)
    sys.exit(1)
if data.get("check_rabbitmq") != "0":
    print("check_rabbitmq not overridden to 0", file=sys.stderr)
    sys.exit(1)
PY

purge_json=$(PURGE_QUEUE=1 "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${purge_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("purge_queue") != "1":
    print("purge_queue not overridden to 1", file=sys.stderr)
    sys.exit(1)
PY

doc_json=$(DOC_TYPE="custom_doc" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${doc_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("doc_type") != "custom_doc":
    print("doc_type not overridden to custom_doc", file=sys.stderr)
    sys.exit(1)
PY

doc_dot_json=$(DOC_TYPE="dot.type" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${doc_dot_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("doc_type") != "dot.type":
    print("doc_type not overridden to dot.type", file=sys.stderr)
    sys.exit(1)
PY

doc_mix_json=$(DOC_TYPE="doc-type_v2.1" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${doc_mix_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("doc_type") != "doc-type_v2.1":
    print("doc_type not overridden to doc-type_v2.1", file=sys.stderr)
    sys.exit(1)
PY

doc_default_json=$(QUEUE="queue_default" DOC_TYPE="" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${doc_default_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("doc_type") != "queue_default":
    print("doc_type not defaulted to QUEUE", file=sys.stderr)
    sys.exit(1)
PY

queue_default_json=$(QUEUE="" EXCHANGE="" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${queue_default_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("queue") != "food_application":
    print("queue not defaulted to food_application", file=sys.stderr)
    sys.exit(1)
if data.get("exchange") != "SOCIAL_ASSISTANCE_EXCHANGE":
    print("exchange not inferred as SOCIAL_ASSISTANCE_EXCHANGE", file=sys.stderr)
    sys.exit(1)
if data.get("routing_key") != "":
    print("routing_key not empty for SOCIAL_ASSISTANCE_EXCHANGE", file=sys.stderr)
    sys.exit(1)
PY

grant_exchange_json=$(QUEUE="grant_contracts" EXCHANGE="" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${grant_exchange_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("exchange") != "GRANT_EXCHANGE":
    print("exchange not inferred as GRANT_EXCHANGE", file=sys.stderr)
    sys.exit(1)
if data.get("routing_key") != "grant.1.contract":
    print("routing_key not derived from payload grantType", file=sys.stderr)
    sys.exit(1)
PY

tmp_payload=$(mktemp --suffix .json)
cat >"${tmp_payload}" <<'EOF'
{"studentId":"S-0002","firstName":"Test","lastName":"User","email":"test.user@example.com","program":"Science","year":1}
EOF
no_grant_json=$(EXCHANGE="GRANT_EXCHANGE" ROUTING_KEY="" PAYLOAD_FILE="${tmp_payload}" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${no_grant_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("routing_key") != "grant.1.contract":
    print("routing_key not defaulted when grantType missing", file=sys.stderr)
    sys.exit(1)
PY
rm -f "${tmp_payload}"

tmp_payload=$(mktemp --suffix .json)
cat >"${tmp_payload}" <<'EOF'
{"studentId":"S-0003","firstName":"Test","lastName":"Grant","email":"grant.user@example.com","program":"Science","year":1,"grantType":"grant.9.test"}
EOF
grant_payload_json=$(EXCHANGE="GRANT_EXCHANGE" ROUTING_KEY="" PAYLOAD_FILE="${tmp_payload}" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${grant_payload_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("routing_key") != "grant.9.test":
    print("routing_key not derived from custom grantType", file=sys.stderr)
    sys.exit(1)
PY
rm -f "${tmp_payload}"

social_exchange_json=$(QUEUE="financial_assistance_application" EXCHANGE="" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${social_exchange_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("exchange") != "SOCIAL_ASSISTANCE_EXCHANGE":
    print("exchange not inferred as SOCIAL_ASSISTANCE_EXCHANGE", file=sys.stderr)
    sys.exit(1)
if data.get("routing_key") != "":
    print("routing_key not empty for SOCIAL_ASSISTANCE_EXCHANGE", file=sys.stderr)
    sys.exit(1)
PY

transport_exchange_json=$(QUEUE="transportation_costs_application" EXCHANGE="" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${transport_exchange_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("exchange") != "SOCIAL_ASSISTANCE_EXCHANGE":
    print("exchange not inferred as SOCIAL_ASSISTANCE_EXCHANGE", file=sys.stderr)
    sys.exit(1)
if data.get("routing_key") != "":
    print("routing_key not empty for SOCIAL_ASSISTANCE_EXCHANGE", file=sys.stderr)
    sys.exit(1)
PY

food_exchange_json=$(QUEUE="food_application" EXCHANGE="" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${food_exchange_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("exchange") != "SOCIAL_ASSISTANCE_EXCHANGE":
    print("exchange not inferred as SOCIAL_ASSISTANCE_EXCHANGE", file=sys.stderr)
    sys.exit(1)
if data.get("routing_key") != "":
    print("routing_key not empty for SOCIAL_ASSISTANCE_EXCHANGE", file=sys.stderr)
    sys.exit(1)
PY

temp_pdf_json=$("${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${temp_pdf_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("pdf_output_dir") != "<temp>":
    print("pdf_output_dir not defaulted to <temp>", file=sys.stderr)
    sys.exit(1)
PY

temp_dir=$(mktemp -d)
custom_pdf_json=$(PDF_OUTPUT_DIR="${temp_dir}" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${custom_pdf_json}" PDF_OUTPUT_DIR="${temp_dir}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
expected=os.environ.get("PDF_OUTPUT_DIR","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if expected and not expected.startswith("/"):
    print("PDF_OUTPUT_DIR override is not absolute", file=sys.stderr)
    sys.exit(1)
if data.get("pdf_output_dir") != expected:
    print("pdf_output_dir not overridden to custom dir", file=sys.stderr)
    sys.exit(1)
PY
rmdir "${temp_dir}"

ack_default_json=$(ACK_MODE="" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${ack_default_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("ack_mode") != "ack_requeue_false":
    print("ack_mode not defaulted to ack_requeue_false", file=sys.stderr)
    sys.exit(1)
PY

ack_override_json=$(ACK_MODE="ack_requeue_true" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${ack_override_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("ack_mode") != "ack_requeue_true":
    print("ack_mode not overridden to ack_requeue_true", file=sys.stderr)
    sys.exit(1)
PY

output_default_json=$(OUTPUT="" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${output_default_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("output") != "single":
    print("output not defaulted to single", file=sys.stderr)
    sys.exit(1)
PY

count_default_json=$(COUNT="" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${count_default_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("count") != "1":
    print("count not defaulted to 1", file=sys.stderr)
    sys.exit(1)
PY

index_default_json=$(INDEX="" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${index_default_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("index") != "0":
    print("index not defaulted to 0", file=sys.stderr)
    sys.exit(1)
PY

validate_default_json=$(VALIDATE_PAYLOAD="" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${validate_default_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("validate_payload") != "1":
    print("validate_payload not defaulted to 1", file=sys.stderr)
    sys.exit(1)
PY

check_default_json=$(CHECK_RABBITMQ="" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${check_default_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("check_rabbitmq") != "1":
    print("check_rabbitmq not defaulted to 1", file=sys.stderr)
    sys.exit(1)
PY

purge_default_json=$(PURGE_QUEUE="" "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)
JSON_OUT="${purge_default_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
if data.get("purge_queue") != "0":
    print("purge_queue not defaulted to 0", file=sys.stderr)
    sys.exit(1)
PY

json_out=$(QUEUE="${QUEUE}" COUNT="${COUNT}" INDEX="${INDEX}" OUTPUT="${OUTPUT}" \
  "${ROOT_DIR}/scripts/e2e_local.sh" --dry-run --json)

JSON_OUT="${json_out}" JSON_OUTPUT="${json_output}" QUEUE="${QUEUE}" COUNT="${COUNT}" INDEX="${INDEX}" OUTPUT="${OUTPUT}" ROOT_DIR="${ROOT_DIR}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("JSON_OUT","")
json_output=os.environ.get("JSON_OUTPUT","0") == "1"
expected_validate=os.environ.get("VALIDATE_PAYLOAD","1")
expected_check=os.environ.get("CHECK_RABBITMQ","1")
expected_doc_type=os.environ.get("DOC_TYPE") or os.environ.get("QUEUE","")
try:
    data=json.loads(raw)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)
required=["status","queue","exchange","routing_key","payload_file","doc_type","pdf_output_dir","pdf_output_dir_missing","purge_queue","ack_mode","validate_payload","count","index","output","check_rabbitmq"]
missing=[k for k in required if k not in data]
if missing:
    print(f"Missing keys: {', '.join(missing)}", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "dry_run":
    print("status is not dry_run", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("status"), str):
    print("status not a string", file=sys.stderr)
    sys.exit(1)
if data.get("status") == "":
    print("status empty string", file=sys.stderr)
    sys.exit(1)
if data.get("queue") != os.environ.get("QUEUE",""):
    print("queue mismatch", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("queue"), str):
    print("queue not a string", file=sys.stderr)
    sys.exit(1)
if data.get("count") != os.environ.get("COUNT",""):
    print("count mismatch", file=sys.stderr)
    sys.exit(1)
if data.get("index") != os.environ.get("INDEX",""):
    print("index mismatch", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("count"), str) or not isinstance(data.get("index"), str):
    print("count/index not strings", file=sys.stderr)
    sys.exit(1)
try:
    count=int(data.get("count",""))
    index=int(data.get("index",""))
except ValueError:
    print("count/index not numeric", file=sys.stderr)
    sys.exit(1)
if count < 1 or index < 0:
    print("count/index out of range", file=sys.stderr)
    sys.exit(1)
if data.get("output") != os.environ.get("OUTPUT",""):
    print("output mismatch", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("output"), str):
    print("output not a string", file=sys.stderr)
    sys.exit(1)
if data.get("output") not in ("single", "all"):
    print("output invalid", file=sys.stderr)
    sys.exit(1)
if data.get("output") == "all":
    if count < 2 or index != 0:
        print("output=all requires count>=2 and index=0", file=sys.stderr)
        sys.exit(1)
if data.get("output") == "single":
    if index >= count:
        print("output=single requires index < count", file=sys.stderr)
        sys.exit(1)
if data.get("pdf_output_dir_missing") != "0":
    print("pdf_output_dir_missing not set to 0", file=sys.stderr)
    sys.exit(1)
root_dir=os.environ.get("ROOT_DIR","")
payload=data.get("payload_file","")
if root_dir and not payload.startswith(root_dir + "/"):
    print("payload_file not absolute under ROOT_DIR", file=sys.stderr)
    sys.exit(1)
if payload.endswith("/docs/sample_student.json") is False:
    print("payload_file not using default sample_student.json", file=sys.stderr)
    sys.exit(1)
if not payload.endswith(".json"):
    print("payload_file not a .json", file=sys.stderr)
    sys.exit(1)
if payload and not os.path.isfile(payload):
    print("payload_file not found on disk", file=sys.stderr)
    sys.exit(1)
if payload and not os.access(payload, os.R_OK):
    print("payload_file not readable", file=sys.stderr)
    sys.exit(1)
if payload and os.path.getsize(payload) == 0:
    print("payload_file empty", file=sys.stderr)
    sys.exit(1)
if data.get("validate_payload") != expected_validate:
    print("validate_payload mismatch", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("validate_payload"), str):
    print("validate_payload not a string", file=sys.stderr)
    sys.exit(1)
if data.get("check_rabbitmq") != expected_check:
    print("check_rabbitmq mismatch", file=sys.stderr)
    sys.exit(1)
if data.get("check_rabbitmq") not in ("0", "1"):
    print("check_rabbitmq invalid", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("check_rabbitmq"), str):
    print("check_rabbitmq not a string", file=sys.stderr)
    sys.exit(1)
if data.get("ack_mode") not in ("ack_requeue_false", "ack_requeue_true"):
    print("ack_mode invalid", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("ack_mode"), str):
    print("ack_mode not a string", file=sys.stderr)
    sys.exit(1)
if data.get("purge_queue") not in ("0", "1"):
    print("purge_queue invalid", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("purge_queue"), str):
    print("purge_queue not a string", file=sys.stderr)
    sys.exit(1)
if data.get("doc_type") != expected_doc_type:
    print("doc_type mismatch", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("doc_type"), str):
    print("doc_type not a string", file=sys.stderr)
    sys.exit(1)
if data.get("doc_type") and not __import__("re").match(r"^[A-Za-z0-9_.-]+$", data.get("doc_type")):
    print("doc_type format invalid", file=sys.stderr)
    sys.exit(1)
if data.get("doc_type") and len(data.get("doc_type")) > 255:
    print("doc_type too long", file=sys.stderr)
    sys.exit(1)
if not data.get("exchange"):
    print("exchange missing", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("exchange"), str):
    print("exchange not a string", file=sys.stderr)
    sys.exit(1)
if data.get("exchange") == "":
    print("exchange empty string", file=sys.stderr)
    sys.exit(1)
if not __import__("re").match(r"^[A-Za-z0-9._-]+$", data.get("exchange")):
    print("exchange format invalid", file=sys.stderr)
    sys.exit(1)
if data.get("exchange") and len(data.get("exchange")) > 255:
    print("exchange too long", file=sys.stderr)
    sys.exit(1)
if "routing_key" not in data:
    print("routing_key missing", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("routing_key"), str):
    print("routing_key not a string", file=sys.stderr)
    sys.exit(1)
if data.get("routing_key") and not __import__("re").match(r"^[A-Za-z0-9._-]+$", data.get("routing_key")):
    print("routing_key format invalid", file=sys.stderr)
    sys.exit(1)
if data.get("routing_key") and len(data.get("routing_key")) > 255:
    print("routing_key too long", file=sys.stderr)
    sys.exit(1)
if not data.get("pdf_output_dir"):
    print("pdf_output_dir missing", file=sys.stderr)
    sys.exit(1)
if not isinstance(data.get("pdf_output_dir"), str):
    print("pdf_output_dir not a string", file=sys.stderr)
    sys.exit(1)
pdf_dir=data.get("pdf_output_dir","")
if pdf_dir != "<temp>" and not os.path.isabs(pdf_dir):
    print("pdf_output_dir not absolute when overridden", file=sys.stderr)
    sys.exit(1)
if pdf_dir != "<temp>" and not os.path.isdir(pdf_dir):
    print("pdf_output_dir not found on disk", file=sys.stderr)
    sys.exit(1)
if data.get("exchange") == "SOCIAL_ASSISTANCE_EXCHANGE" and data.get("routing_key") != "":
    print("routing_key should be empty for SOCIAL_ASSISTANCE_EXCHANGE", file=sys.stderr)
    sys.exit(1)
if data.get("exchange") != "SOCIAL_ASSISTANCE_EXCHANGE" and data.get("routing_key") == "":
    print("routing_key empty for non-social exchange", file=sys.stderr)
    sys.exit(1)
output=data.get("output")
if output == "all":
    if count < 2:
        print("output=all requires count >= 2", file=sys.stderr)
        sys.exit(1)
    if index != 0:
        print("output=all requires index=0", file=sys.stderr)
        sys.exit(1)
payload_file=data.get("payload_file","")
root_dir=os.environ.get("ROOT_DIR","")
if not payload_file:
    print("payload_file missing", file=sys.stderr)
    sys.exit(1)
if not isinstance(payload_file, str):
    print("payload_file not a string", file=sys.stderr)
    sys.exit(1)
if not (os.path.isfile(payload_file) or os.path.isfile(os.path.join(root_dir, payload_file))):
    print("payload_file not found on disk", file=sys.stderr)
    sys.exit(1)
if json_output:
    print(json.dumps({"status":"ok"}))
else:
    print("test_e2e_local OK")
PY
