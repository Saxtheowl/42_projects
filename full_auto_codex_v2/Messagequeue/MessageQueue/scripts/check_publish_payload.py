#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
import sys

CONSTRAINTS = {
    "exchange": (r"^[a-z0-9_.-]{1,32}$", "exchange"),
    "routing_key": (r"^[a-z0-9_.-]{1,32}$", "routing_key"),
    "doc_type": (r"^[a-z0-9_.-]{1,32}$", "doc_type"),
}

WHITESPACE_RE = re.compile(r"\s")

parser = argparse.ArgumentParser(description="Validate the JSON payload sent to publish_test_message.")
parser.add_argument("--json", action="store_true", help="Print a JSON summary instead of human output.")
parser.add_argument("--payload", default=os.environ.get("PAYLOAD_FILE", "docs/sample_student.json"), help="Path to the payload JSON file.")
parser.add_argument("--directory", default=os.environ.get("PAYLOAD_DIR", None), help="Optional folder that must exist and be readable.")
args = parser.parse_args()

payload_path = args.payload
if not os.path.isfile(payload_path):
    candidate = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", payload_path)
    if os.path.isfile(candidate):
        payload_path = candidate

try:
    with open(payload_path, "r", encoding="utf-8") as handle:
        data = json.load(handle)
except FileNotFoundError:
    print(f"payload file not found: {payload_path}", file=sys.stderr)
    sys.exit(1)
except json.JSONDecodeError as exc:
    print(f"invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)

errors = []

for key, (pattern, label) in CONSTRAINTS.items():
    value = data.get(key)
    if not isinstance(value, str):
        errors.append(f"{label} must be a non-empty string")
        continue
    if not re.fullmatch(pattern, value):
        errors.append(f"{label} '{value}' does not match {pattern}")

content_type = data.get("content_type")
if not isinstance(content_type, str) or not content_type.strip():
    errors.append("content_type must be a non-empty string")
elif WHITESPACE_RE.search(content_type):
    errors.append("content_type must not contain whitespace")

message_id = data.get("message_id")
if not isinstance(message_id, str) or not message_id:
    errors.append("message_id must be a non-empty string");
else:
    if WHITESPACE_RE.search(message_id):
        errors.append("message_id must not contain whitespace")
    if len(message_id) > 64:
        errors.append("message_id must be at most 64 characters")

payload_dir = args.directory
if payload_dir:
    if not os.path.isdir(payload_dir):
        errors.append(f"payload directory not found: {payload_dir}")
    elif not os.access(payload_dir, os.R_OK):
        errors.append(f"payload directory not readable: {payload_dir}")
else:
    print("payload directory not specified; skipping folder checks.", file=sys.stderr)

status = "ok" if not errors else "error"

summary = {
    "status": status,
    "payload": payload_path,
    "errors": errors,
}

if args.json:
    print(json.dumps(summary))
else:
    if status == "ok":
        print("publish_test_message payload is valid.")
    else:
        print("payload validation failed:")
        for msg in errors:
            print(f" - {msg}")

sys.exit(0 if status == "ok" else 1)
