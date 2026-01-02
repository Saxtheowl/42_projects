# ft_hangouts

Statut : DONE (prototype CLI enrichi, auto-création contact SMS inconnu, thème CLI configurable, avatars contacts, import/export CSV, appels).

Dernière mise à jour (2026-01-02 20:19:04) : projet stabilisé (CLI complet, docs/tests à jour).

## Synthèse
Le sujet `ft_hangouts` décrit une application de messagerie/notification pour l’écosystème 42 (inspiré du réseau HipChat/Slack). L’objectif est de concevoir une API et des clients capables de faciliter la communication entre étudiants : gestion des utilisateurs, salons, messages, notifications. Le dossier contient un prototype CLI gérant contacts, messagerie, statut lu/non lu et résumé de notifications.

## Architecture CLI
- Stockage local JSON dans `data/store.json`.
- Entités : contacts (tags, campus, avatar, mute/pin), messages (IN/OUT, read).
- Commandes CLI pour CRUD contacts, conversations, notifications, exports.
- Tests automatisés via `tests_realisation/run_tests.sh`.

## Dossier actuel
- `docs/personas.md` — profils Alice/Ben/Clara et leurs besoins.
- `docs/user_journeys.md` — parcours clés (onboarding, réception SMS inconnu, sauvegarde).
- `docs/architecture.md` — proposition Android (Kotlin, MVVM, SQLite, services) + CLI.
- `docs/api.md` — endpoints REST/WebSocket envisagés.
- `PLAN.md` — feuille de route détaillée (UX → build → tests).
- `scripts/run_demo.sh` — script d’installation APK sur émulateur.
- `tests_realisation/SCENARIOS.md` — cas de validation fonctionnels.
- `tests_realisation/run_tests.sh` — scénario automatisé (contacts, messages, notifications, mark-read, export/delete, conversations, mute/unmute, pin/unpin, recherche, stats, backup/restore).
- `src/mock_app.py` — prototype CLI (contacts, messagerie, notifications/unread, filtres, JSON, export/delete, résumé conversations, recherche, mute/unmute, pin/unpin, stats, backup/restore).
- `scripts/load_seed.sh` — charge `data/seed_contacts.json` dans le store JSON.
- `docs/guide_utilisateur.md` — guide CLI complet (contacts, messages, notifications, exports).

## Installation rapide
```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

## Usage CLI
```bash
python3 src/mock_app.py contacts add --first-name Alice --last-name V --phone 0600000001 --email alice@42.fr --campus Paris --tags dev staff
python3 src/mock_app.py messages receive --phone 0600000003 --first-name Chloe --last-name Z --auto-create --body "Salut"
python3 src/mock_app.py contacts export --output contacts.csv
```

## Tests
```bash
./tests_realisation/run_tests.sh
```

## Prototype CLI
- `python3 src/mock_app.py contacts add ...` — ajoute un contact persisté dans `data/store.json`.
- `python3 src/mock_app.py contacts list`
- `python3 src/mock_app.py messages send/receive ...` — envoie/reçoit des messages mockés.
- `python3 src/mock_app.py messages receive --phone 06... --auto-create --first-name ...` — reçoit un message depuis un numéro inconnu et crée automatiquement le contact.
- `python3 src/mock_app.py messages list --contact-id 1` — affiche les messages avec statut lu (✓) / non lu (•).
- `python3 src/mock_app.py messages list --contact-id 1 --unread-only` — filtre les messages non lus.
- `python3 src/mock_app.py messages mark-read --contact-id 1` — marque les messages du contact comme lus.
- `python3 src/mock_app.py messages delete --message-id 2` — supprime un message.
- `python3 src/mock_app.py contacts list [--tag dev] [--campus Paris]` — filtre les contacts (avatar affiché).
- `python3 src/mock_app.py contacts set-avatar --contact-id 2 --avatar bob.jpg` — ajoute/modifie l’avatar d’un contact.
- `python3 src/mock_app.py contacts export --output contacts.csv` / `contacts import --input contacts.csv` — export/import CSV des contacts.
- `python3 src/mock_app.py calls log --contact-id 1 --direction OUT --duration 120` — journalise un appel.
- `python3 src/mock_app.py calls list --missed-only` — liste les appels manqués.
- `python3 src/mock_app.py calls stats --json` — stats d'appels.
- `python3 src/mock_app.py calls export --output calls.json` / `calls import --input calls.json` — export/import des appels.
- `python3 src/mock_app.py notifications [--as-background] [--json]` — résumé des notifications non lues, option JSON et trace de la dernière sync.
- `python3 src/mock_app.py messages export --contact-id 2 --unread-only --output out.json` — exporte les messages en JSON (fichier).
- `python3 src/mock_app.py conversations [--json]` — résumé des conversations (dernier message + unread).
- `python3 src/mock_app.py contacts mute|unmute --contact-id 2` — met en sourdine/réactive un contact (les notifications ignorent les contacts mutés).
- `python3 src/mock_app.py messages search --query ping [--contact-id 2]` — recherche dans les messages (tous ou par contact).
- `python3 src/mock_app.py storage export --output backup.json` / `storage import --input backup.json` — backup/restore complet du store.
- `python3 src/mock_app.py contacts pin|unpin --contact-id 1` — épingle un contact (priorisé dans les listes/conversations).
- `python3 src/mock_app.py settings set-theme --color green` / `settings show` — change le thème CLI (simule le menu couleur header).
- `python3 src/mock_app.py stats [--json]` — stats synthétiques (contacts, muted/pinned, messages/unread).
- `tests_realisation/run_tests.sh` — réinitialise les données et rejoue un scénario basique (logs + snapshot JSON).
- `scripts/load_seed.sh` — importe des contacts depuis `data/seed_contacts.json`.

## Étapes prochaines
1. Prototyper UI (maquettes -> écrans Android Studio).
2. Initialiser projet Android (`app/`) avec structure MVVM/Room.
3. Implémenter CRUD contact/messagerie côté Android (en s’appuyant sur la logique CLI).
4. Simuler flux SMS entrants via WorkManager + notifications.
5. Documenter API/endpoint (si backend exposé) et livrer captures démonstratives.
