#!/usr/bin/env python3
import json
import os
import sys

payload_file = os.environ.get("PAYLOAD_FILE", "docs/sample_student.json")

required = {
    "studentId": str,
    "firstName": str,
    "lastName": str,
    "email": str,
}

optional = {
    "program": str,
    "year": int,
    "incomeBracket": str,
    "needsTransportationAssistance": bool,
    "grantType": str,
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

if errors:
    print("Payload validation failed:")
    for err in errors:
        print(f"- {err}")
    sys.exit(1)

print("Payload validation OK.")
