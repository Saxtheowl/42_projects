# Plan ft_services

## But
Mettre en place un service robuste, documenté et testable (d'après le PDF). Le focus initial est sur la compréhension du sujet, la conformité des scripts, et la structuration des tests.

## Approche dédiée à `status_top2`
1. Décrire la chaîne entière `status_top2` : réglage du pattern/status, `topn=2`, exécution de `logs_metrics`, export des données, vérifications et inspection des snapshots.
2. Répertorier la suite de scripts impliqués : alias `logmetrics`, `logs_metrics`, `logs_metrics_export.sh`, `logs_metrics_verify.sh`, `verify_snapshot.sh`, `log_summary*` (diff/multi/report) ainsi que les helpers (connexion, surcharge, replay, stress).
3. Assurer la traçabilité des commandes d’export et de vérification avec `reports/log_metrics_snapshot.status_top2.csv`/`.json`.

## Phase 2 – Documentation status_top2
- Intégrer la commande d’export :
  ```bash
  ./scripts/logs_metrics_export.sh --pattern status --topn 2
  ```
  Décrire les colonnes produites (`timestamp`, `log_file`, `status_checks`, `connections`, `overloaded`, `overloaded_ratio`) et rappeler les formats CSV/JSON.
- Détailler les vérifications suivantes :
  ```bash
  ./scripts/verify_snapshot.sh --format both
  ./scripts/logs_metrics_verify.sh csv
  ./scripts/logs_metrics_verify.sh json
  ```
  Ces commandes valident la création des snapshots `reports/log_metrics_snapshot.status_top2.{csv,json}`.
- Documenter les contrôles rapides (`tail`/`jq`) après export pour confirmer la correspondance :
  ```bash
  tail -n 5 reports/log_metrics_snapshot.status_top2.csv
  jq '.[-1]' reports/log_metrics_snapshot.status_top2.json
  ```
  Le helper échoue si l’entrée `Totals` est absente (CSV/JSON) pour garantir l’agrégation.
- Expliquer le workflow complet :
  - Préparer `alias logmetrics='./scripts/logs_metrics.sh'` et définir `LOG_METRICS_DIR`.
  - Lancer `logmetrics pattern/status top_n=2` pour produire les données filtrées.
  - Enchaîner avec `./scripts/log_summary_diff.sh ...`, `./scripts/log_summary_multi.sh ...`, et `./scripts/log_summary_report.sh` pour bâtir la synthèse des résultats.
  - Terminer avec `./scripts/logs_metrics_export.sh --topn 2 --format csv` puis vérifier les snapshots (CSV/JSON) via `verify_snapshot` et `tail`/`jq`.
- Fournir un exemple de commentaire d’exécution automatique indiquant que `./scripts/logs_metrics_export.sh --topn 2 --format csv` reprend les mêmes filtres `pattern=status` et `top_n=2`.
- Mentionner que des scripts de stress/replay (`scripts/stress_max_connections.sh`, `scripts/replay_log.sh`) peuvent précéder le workflow `status_top2`, afin de générer les logs les plus chargés ou relancer des checks.

## Phase 3 – Implémentation et vérification
- Compiler via `scripts/run_tests.sh` (qui fait appel à `scripts/check_env.sh`) pour s’assurer que `status_top2` reste utilisable lors des tests.
- Ajouter `src/main.c` (que le plan décrit comme en stall avec logs/arguments) pour fournir la base du service, tout en s’assurant que la génération de logs obéit aux colonnes attendues.
- Utiliser `scripts/monitor_status.sh` pour surveiller continuellement `status_top2`, puis `scripts/logs_metrics.sh` et les exports afin de respecter la boîte à outils de démonstration.

## Phase 4 – Démonstration et partage
- Documenter `scripts/demo_pipeline.sh` pour automatiser la combinaison `show_config`, `clean_log`, `monitor_status`, la commande `logmetrics` avec `pattern=status`/`top_n=2`, les `log_summary` et la génération des snapshots via `logs_metrics_export`.
- Mettre en évidence la possibilité de déclencher `scripts/health_report.sh` et `scripts/log_summary_report.sh` en complément pour résumer l’état de `status_top2` avant la diffusion des métriques.
