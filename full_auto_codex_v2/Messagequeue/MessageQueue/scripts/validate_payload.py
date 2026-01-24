#!/usr/bin/env python3
import argparse
import json
import os
import sys

parser = argparse.ArgumentParser(description="Validate a payload JSON file.")
parser.add_argument(
    "--json",
    action="store_true",
    help="Output JSON summary.",
)
args = parser.parse_args()

payload_file = os.environ.get("PAYLOAD_FILE", "docs/sample_student.json")
if not os.path.isfile(payload_file):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    candidate = os.path.join(script_dir, "..", payload_file)
    if os.path.isfile(candidate):
        payload_file = candidate

required = {
    "studentId": str,
    "firstName": str,
    "lastName": str,
    "email": str,
    "grantType": str,
}

optional = {
    "program": str,
    "year": int,
    "incomeBracket": str,
    "needsTransportationAssistance": bool,
    "metadata": dict,
}

try:
    with open(payload_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except FileNotFoundError:
    print(f"Payload file not found: {payload_file}", file=sys.stderr)
    sys.exit(1)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)

errors = []

for key, expected_type in required.items():
    if key not in data:
        errors.append(f"missing required field: {key}")
        continue
    if not isinstance(data[key], expected_type):
        errors.append(f"invalid type for {key}: expected {expected_type.__name__}")

for key, expected_type in optional.items():
    if key in data and not isinstance(data[key], expected_type):
        errors.append(f"invalid type for {key}: expected {expected_type.__name__}")

grant_type = data.get("grantType")
if isinstance(grant_type, str):
    parts = grant_type.split(".")
    if len(parts) < 2 or parts[0] != "grant" or any(not part for part in parts[1:]):
        errors.append("invalid grantType: expected routing key like grant.* or grant.*.*")

if errors:
    if args.json:
        print(
            json.dumps(
                {
                    "status": "error",
                    "payload_file": payload_file,
                    "errors": errors,
                }
            )
        )
    else:
        print("Payload validation failed:")
        for err in errors:
            print(f"- {err}")
    sys.exit(1)

if args.json:
    print(json.dumps({"status": "ok", "payload_file": payload_file}))
else:
    print("Payload validation OK.")
