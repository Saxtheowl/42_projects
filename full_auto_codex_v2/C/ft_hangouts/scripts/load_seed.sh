#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
CLI="${PROJECT_ROOT}/src/mock_app.py"
SEED="${PROJECT_ROOT}/data/seed_contacts.json"
STORE="${PROJECT_ROOT}/data/store.json"

if [ ! -f "${SEED}" ]; then
	printf 'Seed file %s absent\n' "${SEED}" >&2
	exit 1
fi

rm -f "${STORE}"

python3 - <<'PY'
import json
import subprocess
import pathlib
import sys
from datetime import datetime

project = pathlib.Path(sys.argv[1])
cli = project / "src" / "mock_app.py"
seed = project / "data" / "seed_contacts.json"

def run(args):
    subprocess.run([sys.executable, str(cli)] + args, check=True)

with seed.open("r", encoding="utf-8") as fh:
    contacts = json.load(fh)

for entry in contacts:
    args = [
        "contacts", "add",
        "--first-name", entry.get("first_name", ""),
        "--last-name", entry.get("last_name", ""),
        "--phone", entry.get("phone", ""),
        "--email", entry.get("email", ""),
        "--campus", entry.get("campus", ""),
        "--notes", entry.get("notes", ""),
    ]
    tags = entry.get("tags")
    if tags:
        args.extend(["--tags", *tags])
    run(["--lang", "fr"] + args)

print("Seed contacts loaded")
PY
"${PROJECT_ROOT}"
