# ft_hangouts

## Synthèse préliminaire
Le sujet `ft_hangouts` décrit une application de messagerie/notification pour l’écosystème 42 (inspiré du réseau HipChat/Slack). L’objectif est de concevoir une API et des clients capables de faciliter la communication entre étudiants : gestion des utilisateurs, salons, messages, notifications. Le sujet impose de couvrir l’analyse fonctionnelle, la modélisation et la présentation du produit final (approche plus produit/UX que purement technique).

## Dossier actuel
- `docs/personas.md` — profils Alice/Ben/Clara et leurs besoins.
- `docs/user_journeys.md` — parcours clés (onboarding, création hangout, messagerie).
- `docs/architecture.md` — proposition Android (Kotlin, MVVM, SQLite, services) + CLI.
- `docs/api.md` — endpoints REST/WebSocket envisagés.
- `PLAN.md` — feuille de route détaillée (UX → build → tests).
- `scripts/run_demo.sh` — script d’installation APK sur émulateur.
- `tests_realisation/SCENARIOS.md` — cas de validation fonctionnels.
- `src/mock_app.py` — prototype CLI (gestion contacts/SMS, FR/EN) + `scripts/run_tests.sh` pour parcours minimal.
- `scripts/load_seed.sh` — charge `data/seed_contacts.json` dans le store JSON.

## Prototype CLI
- `python3 src/mock_app.py contacts add ...` — ajoute un contact persisté dans `data/store.json`.
- `python3 src/mock_app.py messages send/receive ...` — envoie/reçoit des messages mockés.
- `scripts/run_tests.sh` — réinitialise les données et rejoue un scénario basique (logs + snapshot JSON).
- `scripts/load_seed.sh` — importe des contacts depuis `data/seed_contacts.json`.

## Étapes prochaines
1. Prototyper UI (maquettes -> écrans Android Studio).
2. Initialiser projet Android (`app/`) avec structure MVVM/Room.
3. Implémenter CRUD contact/messagerie côté Android (en s’appuyant sur la logique CLI).
4. Simuler flux SMS entrants via WorkManager + notifications.
5. Documenter API/endpoint (si backend exposé) et livrer captures démonstratives.
