#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
REPO_ROOT=$(cd "$ROOT_DIR/.." && pwd)
SUBJECT_PDF="$REPO_ROOT/organized_subjects/C/Minishell.pdf"

if [ -f "$SUBJECT_PDF" ]; then
	echo "Sujet trouvé : $SUBJECT_PDF"
else
	echo "Sujet Minishell introuvable dans organized_subjects (chemin attendu : $SUBJECT_PDF)" >&2
	exit 1
fi
