#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
CONTEXT="${PROJECT_ROOT}/notes/context.md"
QUESTIONS="${PROJECT_ROOT}/notes/questions.md"
DEBRIEF="${PROJECT_ROOT}/notes/debrief.md"
CODE_DIR="${PROJECT_ROOT}/code"

printf '=== ft_helpme checklist ===\n'

if [ ! -s "${CONTEXT}" ]; then
	printf '[!] Compléter %s avec le projet cible et le statut.\n' "${CONTEXT}"
else
	printf '[OK] Contexte renseigné.\n'
fi

if [ ! -s "${QUESTIONS}" ]; then
	printf '[!] Remplir %s avec au moins les questions prioritaires.\n' "${QUESTIONS}"
else
	printf '[OK] Questions prêtes.\n'
fi

tempfile=$(mktemp)
awk 'NF {found=1} END {exit !found}' "${QUESTIONS}" || printf 'Astuce: hiérarchiser vos questions pour optimiser le temps de review.\n'

if [ -d "${CODE_DIR}" ] && [ -n "$(ls -A "${CODE_DIR}" 2>/dev/null)" ]; then
	printf '[OK] Extraits de code disponibles dans %s\n' "${CODE_DIR}"
else
	printf '[!] Aucun extrait dans %s (optionnel mais recommandé).\n' "${CODE_DIR}"
fi

printf '\nAvant la review:\n'
printf '  - Relire dernier commit/test du projet cible.\n'
printf '  - Préparer commands build/test à montrer.\n'
printf '  - Vérifier disponibilité créneaux 30 min.\n'

printf '\nAprès la review:\n  -> Remplir %s\n' "${DEBRIEF}"

if [ -s "${DEBRIEF}" ]; then
	printf '[OK] Debrief documenté dans %s\n' "${DEBRIEF}"
else
	printf '[!] Le debrief %s est encore vide : pensez à le compléter après la session.\n' "${DEBRIEF}"
fi
