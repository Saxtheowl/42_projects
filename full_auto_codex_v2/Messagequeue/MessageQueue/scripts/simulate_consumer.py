#!/usr/bin/env python3
import json
import os
import subprocess
import sys

payload_file = os.environ.get("PAYLOAD_FILE", "docs/sample_student.json")
doc_type = os.environ.get("DOC_TYPE", "food_application")

try:
    with open(payload_file, "r", encoding="utf-8") as f:
        data = json.load(f)
except FileNotFoundError:
    print(f"Payload file not found: {payload_file}", file=sys.stderr)
    sys.exit(1)
except json.JSONDecodeError as exc:
    print(f"Invalid JSON: {exc}", file=sys.stderr)
    sys.exit(1)

student_id = data.get("studentId")
if not isinstance(student_id, str) or not student_id:
    print("studentId missing or invalid", file=sys.stderr)
    sys.exit(1)

pdf_name = f"{doc_type}_{student_id}.pdf"
text = f"{doc_type} for {student_id}"

env = os.environ.copy()
env["PDF_NAME"] = pdf_name
env["PDF_TEXT"] = text

result = subprocess.run(
    ["./scripts/generate_dummy_pdf.py"],
    cwd=os.path.dirname(os.path.abspath(__file__)) + "/..",
    env=env,
    check=False,
)

if result.returncode != 0:
    sys.exit(result.returncode)

print("Simulated consumer OK.")
