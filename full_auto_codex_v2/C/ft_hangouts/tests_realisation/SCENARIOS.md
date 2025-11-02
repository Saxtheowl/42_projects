# Scénarios de validation ft_hangouts

## S1 – CRUD Contact
1. Ouvrir l'application (langue FR par défaut).
2. Créer un nouveau contact (≥5 champs) puis sauvegarder.
3. Éditer le contact, changer couleur header via menu et relancer l'app → vérifier persistance.
4. Supprimer le contact et confirmer disparition.

## S2 – Messagerie
1. Depuis la fiche contact, envoyer un SMS (mock). (CLI : `python3 src/mock_app.py messages send ...`).
2. Simuler réception (service background) → message IN + notification (`messages receive`).
3. Option bonus : création auto d'un contact pour numéro inconnu.

## S3 – Internationalisation
1. Passer téléphone en anglais.
2. Relancer : UI EN, Toast affiche timestamp background.

## S4 – Paramètres
1. Menu > changer thème (3 couleurs).
2. Mise en arrière-plan puis retour : Toast + thème conservé.

## S5 – Orientation
1. Passer en paysage sur contact et conversation → layout responsive.

## Données de test
- Prévoir `data/seed_contacts.json` pour import (via `scripts/load_seed.sh`).
- CLI : `scripts/run_tests.sh` réinitialise `data/store.json` et exécute un parcours minimal.
