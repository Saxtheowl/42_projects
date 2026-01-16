#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS_DIR="$ROOT/scripts"

echo "[INFO] Vérification des permissions d'exécution dans $SCRIPTS_DIR..."

missing=0
while IFS= read -r -d '' file; do
  if [[ ! -x "$file" ]]; then
    echo "[WARN] Script sans permission d'exécution : ${file#$ROOT/}"
    chmod +x "$file"
    missing=$((missing + 1))
  fi
done < <(find "$SCRIPTS_DIR" -maxdepth 1 -type f -name '*.sh' -print0)

if [[ $missing -gt 0 ]]; then
  echo "[OK] $(printf '%s' "$missing") scripts corrigés avec chmod +x."
else
  echo "[OK] Toutes les permissions sont déjà correctes."
fi

echo "[INFO] Vous pouvez relancer ./scripts/run_reports.sh."
