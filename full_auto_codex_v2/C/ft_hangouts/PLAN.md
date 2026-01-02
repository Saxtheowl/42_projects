# Plan de mise en œuvre ft_hangouts

## Étape 1 – Analyse
- [x] Lire `Sujet_ft_hangouts.pdf` (mobile app contacts + messagerie SMS).
- [x] Définir le périmètre MVP : création/édition/suppression de contacts (≥5 champs), envoi/réception SMS simulés, multi-langue, changement couleur header, persistance SQLite locale.
- [x] Identifier les contraintes techniques (pas de bibliothèques externes, Android Studio recommandé, compatibilité portrait/paysage).

## Étape 2 – Conception UX/UI
- [x] Définir les écrans clés (liste contacts, fiche contact, messagerie, menu paramètres).
- [x] Préparer maquettes basse fidélité (`docs/maquettes.md`).
- [x] Lister user stories/personas (docs/personas.md / docs/user_journeys.md).

## Étape 3 – Architecture technique
- [x] Choisir plateforme principale (Android Kotlin/Java).
- [x] Décrire schéma SQLite (table contacts, table messages) dans `docs/architecture.md`.
- [x] Définir modules: persistance, repository, view models, activités/fragments.

## Étape 4 – Implémentation
- [ ] Initialiser projet Android (ou structure alternative si CLI mock) **→ prototype CLI en place (`src/mock_app.py`)**.
- [ ] Implémenter CRUD contacts (CLI prêt, version Android à faire).
- [ ] Implémenter thread/Service simulation SMS (stockage + notifications toast) **(CLI : `messages receive`)**.
- [ ] Gérer internationalisation (strings.xml fr/en) **(CLI: support FR/EN pour les messages)**.
- [x] Implémenter menu pour couleur header, sauvegarde du timestamp background (CLI : `settings set-theme` + `notifications --as-background`).

## Étape 5 – Tests & démos
- [x] `scripts/run_tests.sh` : parcours CLI automatisé (CRUD + messagerie mock).
- [ ] `scripts/run_demo.sh` : lancement émulateur Android (à finaliser avec APK).
- [x] `tests_realisation/SCENARIOS.md` : scénarios pas à pas.
- [ ] Captures d'écran/GIF pour documentation finale.

## Étape 6 – Documentation
- [x] Compléter `README.md` : synthèse, architecture, étapes build, usage.
- [x] Rédiger guide utilisateur (docs/guide_utilisateur.md).
- [ ] Mettre à jour `progress.md` selon l’avancement.

## Étape 7 – Bonus (optionnel)
- [x] Ajout photo contact (CLI: avatars via `contacts add/set-avatar`).
- [x] Création auto contact à réception SMS inconnu.
- [x] Support appel téléphonique (CLI : `calls log/list/stats`).
- [ ] Design Material amélioré.
