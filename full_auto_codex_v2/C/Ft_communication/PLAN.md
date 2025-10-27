# Plan de mise en œuvre ft_communication

## Étape 1 – Analyse & cadrage
- [x] Lire `Sujet_ft_communication.pdf` et clarifier les objectifs : favoriser les échanges entre étudiants via trois exercices (présentation, passé, futur) sans rendu de code.
- [x] Identifier les livrables pertinents pour faciliter l’exercice (guides, fiches, outils de suivi).
- [x] Lister les contraintes : aucune remise officielle, temps de session suffisant, interdiction de lire un script mot à mot pendant la review.

## Étape 2 – Documentation pédagogique
- [x] Rédiger un guide animateur décrivant le déroulé de la session (préparation, déroulé, relances).
- [x] Fournir un aide-mémoire pour les participants (questions clés, conseils pour se présenter).
- [x] Préparer un modèle de prise de notes personnel (respectant l’interdiction de lecture).

## Étape 3 – Outils de facilitation
- [x] Créer un script CLI (`scripts/run_session.py`) qui guide l’animateur : rappels des questions, enregistrement facultatif de notes locales.
- [x] Prévoir un export léger (markdown) pour synthétiser les échanges, à usage interne.
- [x] Documenter la procédure de stockage sécurisé/suppression des notes (respect de la vie privée).

## Étape 4 – Tests & validation
- [x] Fournir un scénario de test manuel décrivant comment simuler une session (solo) pour vérifier le script.
- [x] Ajouter un test automatisé simple (exécution non interactive avec `--help`).
- [x] Intégrer ces tests dans `scripts/run_tests.sh`.

## Étape 5 – Rendu & suivi
- [x] Mettre à jour `README.md` avec la synthèse finale, l’usage du script, les conseils pour la review.
- [x] Mettre à jour `tests_realisation/COMMANDS.md` avec les commandes de tests.
- [x] Actualiser `progress.md` une fois les livrables prêts.
