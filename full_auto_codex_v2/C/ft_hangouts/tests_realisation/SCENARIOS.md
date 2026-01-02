# Scénarios de validation ft_hangouts

## S1 – CRUD Contact
1. Ouvrir l'application (langue FR par défaut).
2. Créer un nouveau contact (≥5 champs) puis sauvegarder (CLI: `contacts add --avatar ...`).
3. Éditer le contact, changer couleur header via menu et relancer l'app → vérifier persistance.
4. Supprimer le contact et confirmer disparition.
5. Exporter les contacts en CSV puis réimporter (CLI: `contacts export` / `contacts import`).

## S2 – Messagerie
1. Depuis la fiche contact, envoyer un SMS (mock). (CLI : `python3 src/mock_app.py messages send ...`).
2. Simuler réception (service background) → message IN + notification (`messages receive`).
3. Option bonus : création auto d'un contact pour numéro inconnu (`messages receive --phone ... --auto-create`).

## S3 – Internationalisation
1. Passer téléphone en anglais.
2. Relancer : UI EN, Toast affiche timestamp background.

## S4 – Paramètres
1. Menu > changer thème (3 couleurs). (CLI : `python3 src/mock_app.py settings set-theme --color green`)
2. Mise en arrière-plan puis retour : Toast + thème conservé.

## S6 – Appels (bonus)
1. Enregistrer un appel sortant de 2 minutes : `calls log --contact-id 1 --direction OUT --duration 120`.
2. Simuler un appel manqué : `calls log --contact-id 2 --direction IN --missed`.
3. Lister l'historique et les appels manqués : `calls list` / `calls list --missed-only`.
4. Consulter les stats d'appel : `calls stats --json`.
5. Export/import JSON : `calls export --output calls.json` puis `calls import --input calls.json`.
## S5 – Orientation
1. Passer en paysage sur contact et conversation → layout responsive.

## Données de test
- Prévoir `data/seed_contacts.json` pour import (via `scripts/load_seed.sh`).
- CLI : `scripts/run_tests.sh` réinitialise `data/store.json` et exécute un parcours minimal.
