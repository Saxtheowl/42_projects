# ft_hangouts

Statut : DONE (prototype CLI complet, tests automatisés).

Dernière mise à jour (2025-12-26 05:47:49) : validation finale (backup/restore, stats, pin/unpin, recherche, notifications filtrées, export/suppression, conversations) et scénario de test automatisé.

## Synthèse préliminaire
Le sujet `ft_hangouts` décrit une application de messagerie/notification pour l’écosystème 42 (inspiré du réseau HipChat/Slack). L’objectif est de concevoir une API et des clients capables de faciliter la communication entre étudiants : gestion des utilisateurs, salons, messages, notifications. Le dossier contient un prototype CLI gérant contacts, messagerie, statut lu/non lu et résumé de notifications.

## Dossier actuel
- `docs/personas.md` — profils Alice/Ben/Clara et leurs besoins.
- `docs/user_journeys.md` — parcours clés (onboarding, création hangout, messagerie).
- `docs/architecture.md` — proposition Android (Kotlin, MVVM, SQLite, services) + CLI.
- `docs/api.md` — endpoints REST/WebSocket envisagés.
- `PLAN.md` — feuille de route détaillée (UX → build → tests).
- `scripts/run_demo.sh` — script d’installation APK sur émulateur.
- `tests_realisation/SCENARIOS.md` — cas de validation fonctionnels.
- `tests_realisation/run_tests.sh` — scénario automatisé (contacts, messages, notifications, mark-read, export/delete, conversations, mute/unmute, pin/unpin, recherche, stats, backup/restore).
- `src/mock_app.py` — prototype CLI (contacts, messagerie, notifications/unread, filtres, JSON, export/delete, résumé conversations, recherche, mute/unmute, pin/unpin, stats, backup/restore).
- `scripts/load_seed.sh` — charge `data/seed_contacts.json` dans le store JSON.

## Prototype CLI
- `python3 src/mock_app.py contacts add ...` — ajoute un contact persisté dans `data/store.json`.
- `python3 src/mock_app.py contacts list`
- `python3 src/mock_app.py messages send/receive ...` — envoie/reçoit des messages mockés.
- `python3 src/mock_app.py messages list --contact-id 1` — affiche les messages avec statut lu (✓) / non lu (•).
- `python3 src/mock_app.py messages list --contact-id 1 --unread-only` — filtre les messages non lus.
- `python3 src/mock_app.py messages mark-read --contact-id 1` — marque les messages du contact comme lus.
- `python3 src/mock_app.py messages delete --message-id 2` — supprime un message.
- `python3 src/mock_app.py contacts list [--tag dev] [--campus Paris]` — filtre les contacts.
- `python3 src/mock_app.py notifications [--as-background] [--json]` — résumé des notifications non lues, option JSON et trace de la dernière sync.
- `python3 src/mock_app.py messages export --contact-id 2 --unread-only --output out.json` — exporte les messages en JSON (fichier).
- `python3 src/mock_app.py conversations [--json]` — résumé des conversations (dernier message + unread).
- `python3 src/mock_app.py contacts mute|unmute --contact-id 2` — met en sourdine/réactive un contact (les notifications ignorent les contacts mutés).
- `python3 src/mock_app.py messages search --query ping [--contact-id 2]` — recherche dans les messages (tous ou par contact).
- `python3 src/mock_app.py storage export --output backup.json` / `storage import --input backup.json` — backup/restore complet du store.
- `python3 src/mock_app.py contacts pin|unpin --contact-id 1` — épingle un contact (priorisé dans les listes/conversations).
- `python3 src/mock_app.py stats [--json]` — stats synthétiques (contacts, muted/pinned, messages/unread).
- `tests_realisation/run_tests.sh` — réinitialise les données et rejoue un scénario basique (logs + snapshot JSON).
- `scripts/load_seed.sh` — importe des contacts depuis `data/seed_contacts.json`.

## Étapes prochaines
1. Prototyper UI (maquettes -> écrans Android Studio).
2. Initialiser projet Android (`app/`) avec structure MVVM/Room.
3. Implémenter CRUD contact/messagerie côté Android (en s’appuyant sur la logique CLI).
4. Simuler flux SMS entrants via WorkManager + notifications.
5. Documenter API/endpoint (si backend exposé) et livrer captures démonstratives.
