# Plan ft_services

## But
Mettre en place un service robuste, documenté et testable (d'après le PDF). Le focus initial est sur la compréhension du sujet, la conformité des scripts, et la structuration des tests.

## Phase 1 – Analyse
- Extraire les exigences clés du sujet (fichiers attendus, contraintes de compilation, arguments CLI, options réseau).
- Identifier les points de sécurité/résilience mentionnés (verrous, gestion des erreurs, logs).
- Noter les artefacts demandés (scripts de configuration, fichier de tests, README) dans ce plan.

## Phase 2 – Documentation & scripts
- Documenter l'architecture envisagée (services, modules, couches réseau) et les outils utilisés.
- Préparer des scripts de démarrage/tests (ex: `scripts/run_tests.sh`, `scripts/check_env.sh`).
- Documenter l’ajout du Makefile pour compilation/nettoyage et l’intégrer dans le pipeline des scripts, en rappelant que `src/main.c` lit `port/backlog/log_path`, crée les répertoires de log et enregistre start/stop via `src/log.c`, que `scripts/args.c` expose `--config`, que `scripts/validate_config.py` contrôle `port/backlog`, et que `scripts/gen_config.py` produit un exemplaire de config de test.
- Noter les nouveaux helpers (`scripts/show_config.sh`, `scripts/clean_log.sh`, `scripts/monitor_status.sh`) et décrire leur rôle dans la démonstration : inspecter les paramètres, effacer les logs, puis enchaîner vérification de santé/COUNT/overload pour garantir un workflow reproductible.
- Documenter aussi `scripts/demo_pipeline.sh`, qui encadre `show_config`, `clean_log` et `monitor_status` sur une liste de configurations pour automatiser la démonstration (toutes les valeurs, logdagen et vérifs). Relier ces notes à `docs/helpers.md` pour présenter la chaîne de bout en bout.
- Citer `scripts/stress_max_connections.sh` et `scripts/log_summary.sh` pour compléter la boîte à outils et montrer les vérifications de la limite/s du log.
- Ajouter `scripts/stress_max_connections.sh` et `scripts/replay_log.sh` à la liste afin de couvrir la stress-test de `max_connections` et la relecture des `status check` dans le log, complétant la boîte à outils des démonstrations FT Services.
- `scripts/run_tests.sh` compilera `src/main.c` et validera l’environnement via `scripts/check_env.sh` avec des fichiers de test (tests/env/*) pour garder la qualité.
- Préparer des scripts de démarrage/tests (ex: `scripts/run_tests.sh`, `scripts/check_env.sh`).
- Ajouter un squelette `src/main.c` qui installe les signaux et reste en pause pour simuler un service.

## Phase 3 – Implémentation
- Commencer par la structure du service (Makefile, dossiers src/include, gestion des arguments).
- Ajouter les tests unitaires de base et la surveillance des logs.
- Itérer sur les bonus (ex: auto-reload, configuration dynamique) si le temps le permet.
