#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SESSION_SCRIPT="${SCRIPT_DIR}/run_session.py"

printf '[1/2] Vérification de l’aide\n'
if ! "${SESSION_SCRIPT}" --help >/dev/null; then
	printf '[FAIL] Impossible d’afficher --help\n' >&2
	exit 1
fi
printf '[OK] --help\n'

printf '[2/2] Mode non interactif\n'
if ! "${SESSION_SCRIPT}" --non-interactif >/dev/null; then
	printf '[FAIL] Mode non interactif en échec\n' >&2
	exit 1
fi
printf '[OK] Mode non interactif\n'

printf '[3/3] Exports Markdown/JSON\n'
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT
md_path="${TMP_DIR}/notes.md"
json_path="${TMP_DIR}/recap.json"
if ! printf '\n\n\n\n' | "${SESSION_SCRIPT}" --log "${md_path}" --json "${json_path}" >/dev/null; then
	printf '[FAIL] Export Markdown/JSON en échec\n' >&2
	exit 1
fi
if [[ ! -s "${md_path}" || ! -s "${json_path}" ]]; then
	printf '[FAIL] Export Markdown/JSON manquant\n' >&2
	exit 1
fi
printf '[OK] Export Markdown/JSON\n'

printf 'Tests ft_communication passés ✅\n'
