# ft_communication – Tests

## Automatisés
- `./scripts/run_tests.sh`  
  - Vérifie que l’assistant de session affiche bien l’aide (`--help`).  
  - Lance le mode `--non-interactif` pour s’assurer que le déroulé complet s’imprime sans bloquer.

## Manuels
1. `./scripts/run_session.py --participants "Alice,Bob"` — guide interactif ; simuler une session en appuyant sur Entrée à chaque étape.
2. `./scripts/run_session.py --participants "Alice,Bob" --log notes.md` — génère un compte rendu Markdown (à supprimer/archiver manuellement après usage).
3. Partager `docs/fiche_participant.md` avec les étudiants et suivre `docs/guide_animateur.md` pendant une vraie session.

> Les notes produites par le script sont destinées à un usage privé. Supprimez-les ou stockez-les en lieu sûr après la session pour respecter la confidentialité.
