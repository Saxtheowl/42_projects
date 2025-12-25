# FT Services Helpers Reference

Ce document regroupe tous les scripts d'assistance pour la revue :

## 1. Vérifier la configuration
- `scripts/show_config.sh [config]`: affiche `port`, `backlog`, `log_path` et `max_connections` afin de confirmer que les autres helpers exécutent les mêmes paramètres que le démon.

## 2. Nettoyer le log
- `scripts/clean_log.sh [config]`: efface et recrée le `log_path` défini par le fichier de configuration, garantissant que chaque démonstration commence avec un journal vierge.

## 3. Workflow santé + charge
- `scripts/monitor_status.sh [config [max]]`: nettoie le log, attend `STATUS: OK`, consulte `COUNT` puis déclenche `test_max_connections.sh` (par défaut 10 `STATUS`). C’est la démonstration principale de la santé, du compteur et de la surcharge.
- `scripts/stress_max_connections.sh [config [max]]`: repose sur `nc` pour envoyer une série de `STATUS` jusqu’à produire `overloaded: <n>`, ce qui prouve rapidement que `max_connections` peut être atteint.
- `scripts/replay_log.sh [config [lines]]`: affiche les dernières `lines` du `log_path` configuré et filtre les `status check` pour revoir l’historique de la vérification.
`scripts/log_summary.sh [config]`: compte combien de `status check`, `connections:` et `overloaded` sont écrits dans le log afin de résumer l’activité après un run.
`scripts/log_summary_multi.sh [config1 [config2 ...]]`: ... (existing text) ...
`scripts/log_summary_diff.sh [config_a [config_b]]`: compare `status check`/`connections:`/`overloaded` lorsque vous exécutez deux configs et affiche la différence `config_b - config_a`, ce qui aide à repérer une session qui n’a pas accumulé autant de vérifications.
  ```bash
  ./scripts/log_summary_multi.sh tests/env/ft_services_status.conf tests/env/ft_services.conf
  ```
  
  Chaque bloc de résumé affiche trois lignes (`status checks`, `count replies`, `overload notices`). Si vous inscrivez plusieurs configs, vous obtenez autant de blocs, puis la ligne `Totals: status checks=<n> connections=<n> overloaded=<n>` qui accumule toutes les métriques, ce qui clarifie quelles sessions ont tourné pendant la revue.
  Cette commande produit deux blocs de résumé, puis une ligne `Totals: status check=<n> connections=<n> overloaded=<n>` qui facilite la revue de plusieurs démonstrations successives.
`scripts/log_summary_diff.sh [config_a [config_b]]`: compare deux configurations et affiche les mêmes métriques en plus d’un `Difference (config_b - config_a)` pour tester que la seconde session n’a pas moins de `status check` ou `overload notices` que la première. Exemple `./scripts/log_summary_diff.sh tests/env/ft_services_status.conf tests/env/ft_services.conf` pour s’assurer que la seconde configuration a au moins autant d’événements que la première.
  - Des configs de test (`tests/env/sample_a.conf` et `tests/env/sample_b.conf`) pointent vers des logs `tests/env/logs/sample_a.log` et `tests/env/logs/sample_b.log` contenant des exemples de `status check`, `connections:` et `overloaded`, ce qui permet de faire tourner `log_summary_diff.sh` sans service en cours.
  - Lancez `./scripts/log_summary_diff.sh tests/env/sample_a.conf tests/env/sample_b.conf` pour constater l’écart `Difference (config_b - config_a)` (positive pour les `overloaded` par exemple) sans toucher au démon.
`scripts/health_report.sh [config [max]]`: enchaîne `show_config`, `clean_log`, `monitor_status`, `log_summary` et `stress_max_connections` pour appliquer toute la chaîne de vérifications + synthèse du log en une seule commande.
  Ce résumé aide à comparer la fréquence des vérifications santé et des réponses `COUNT` avant/après l’exécution de `stress_max_connections.sh` lors d’une démonstration.
`scripts/log_summary_report.sh [config1 config2 ...]`: exécute `log_summary_multi.sh` pour obtenir les totaux puis lance `log_summary_diff.sh` (le premier config contre les autres) afin de présenter d’un seul coup les totaux globaux et les écarts `Difference (config_b - config_a)`. Exemple : `./scripts/log_summary_report.sh tests/env/sample_a.conf tests/env/sample_b.conf tests/env/ft_services.conf`.
`scripts/logs_metrics.sh [log_dir [top_n [pattern]]]`: parcourt `log_dir` (ou `LOG_METRICS_DIR`) et affiche `Log file | Status | Connections | Overloaded` + `Totals`. `top_n` positif trie les logs les plus chargés, `top_n` négatif montre les plus calmes, `pattern` filtre les noms (ex: `status`).
`scripts/logs_metrics_export.sh --dir DIR --topn N --pattern NAME --format csv|json`: exporte les mêmes métriques en CSV/JSON (`timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio`) avec un seul timestamp UTC et une ligne finale `Totals`.
`scripts/verify_snapshot.sh [--format csv|json|both] [--pattern PATTERN] [--topn N] [--dir LOG_DIR]`: helper d’export + vérification. Par défaut `pattern=status`, `topn=2`, il écrit `reports/log_metrics_snapshot.status_top2.csv/.json`, affiche `tail -n 5` (CSV) et `jq '.[-1]'` (JSON) et échoue si la ligne/entrée `Totals` manque. Le wrapper historique `log_metrics_verify.sh` appelle ce nouveau helper.
`scripts/logs_metrics_report.sh [--input CSV] [--output MD]`: transforme le CSV exporté en tableau Markdown (incluant `Totals`), pratique pour coller la synthèse dans une note de revue ou un wiki.
`scripts/logs_metrics_report_html.py --input CSV [--output HTML]`: même idée en HTML, avec vérification de la ligne `Totals` et mise en forme simple (ligne Totals en gras).
`scripts/logs_metrics_pipeline.sh [--pattern PATTERN] [--topn N] [--dir LOG_DIR] [--reports DIR] [--threshold N]`: enchaîne `verify_snapshot` (CSV/JSON + contrôle Totals), le rendu Markdown et HTML, et produit tous les fichiers `reports/log_metrics_snapshot.<pattern>_top<topn>.{csv,json,md,html}` prêts à partager; si `--threshold` est fourni, lance `logs_metrics_alerts` pour refuser un ratio d’overload trop élevé.
`scripts/logs_metrics_compare.py --base CSV --target CSV [--output MD]`: compare deux exports CSV, vérifie la présence de `Totals` et produit un tableau Markdown des deltas (status, connections, overloaded, ratio) pour suivre l’évolution entre deux snapshots.
`scripts/logs_metrics_alerts.py --input CSV --threshold N`: échoue si un `overloaded_ratio` dépasse le seuil (ligne Totals comprise), utile pour alerter en CI avant publication d’un rapport.
`scripts/logs_metrics_index.py --reports DIR --suffix pattern_topN [--compare MD]`: génère `reports/index.md` avec les liens vers CSV/JSON/MD/HTML (et éventuellement le diff).
`scripts/logs_metrics_publish.sh [--reports DIR] [--suffix pattern_topN] [--output archive.tar.gz]`: crée une archive tar.gz incluant CSV/JSON/MD/HTML + index (et diff si présent) pour partager rapidement les artefacts.
`scripts/logs_metrics_ci.sh [--dir LOG_DIR] [--pattern PATTERN] [--topn N] [--threshold N] [--compare base.csv] [--suffix pattern_topN]`: enchaîne pipeline (verify+reports+index+history+trend) + alert + compare + JSONL + bundle pour une exécution CI complète.
`scripts/logs_metrics_snapshot_to_jsonl.py --input CSV [--output JSONL]`: convertit le snapshot CSV (avec Totals) en JSONL (une ligne par enregistrement) pour ingestion SIEM/ETL.
`scripts/logs_metrics_history.py --input CSV --pattern P --topn N [--history PATH]`: ajoute une ligne de synthèse (run_timestamp, pattern, topn, snapshot_timestamp, log_files_count, totals) pour tracer les exports successifs; appelé automatiquement par le pipeline.
`scripts/logs_metrics_trend.py --history PATH [--last N] [--output MD]`: produit un tableau des derniers runs avec les deltas vs run précédent (status, connections, overloaded, ratio) ; généré automatiquement par le pipeline si l’history existe.
`scripts/logs_metrics_index_html.py --reports DIR --suffix pattern_topN`: génère `reports/index.html` avec liens CSV/JSON/JSONL/MD/HTML/history/trend/bundle/compare (si présents).
`scripts/logs_metrics_prune_reports.sh --reports DIR --suffix pattern_topN --keep N [--dry-run]`: supprime les snapshots les plus anciens (csv/json/jsonl/md/html) en conservant les N derniers par extension.
`scripts/logs_metrics_validate.py --reports DIR --suffix pattern_topN`: vérifie la présence des artefacts clés et la ligne `Totals` dans CSV/JSON, échouant si un élément est manquant.
`scripts/logs_metrics_summary.py --input CSV [--output MD]`: génère un résumé Markdown (status, connections, overloaded, ratio) à partir de la ligne Totals, utilisé par le pipeline.
`scripts/logs_metrics_stats.py --history PATH [--output MD]`: calcule min/avg/max/latest pour les métriques issues de `log_metrics_history.csv` et produit `log_metrics_stats.md`.
`scripts/logs_metrics_portal.py --reports DIR --suffix pattern_topN`: construit `reports/portal.html` qui regroupe snapshot, summary, history, trend et stats en une page HTML.
## 4. Démonstration recommandée
1. Démarrez `./ft_services --config tests/env/ft_services_status.conf` dans un terminal (service compilé via le `Makefile`).
2. Dans un second terminal, exécutez `scripts/monitor_status.sh tests/env/ft_services_status.conf 15` pour nettoyer le log, valider santé, regarder le compteur et déclencher l’état `overloaded: <n>`.
3. Lancez `scripts/show_config.sh tests/env/ft_services_status.conf` pour confirmer les paramètres.
4. Ensuite, envoyez des commandes en direct avec `scripts/client_demo.py --config tests/env/ft_services_status.conf --commands STATUS COUNT STATUS` afin de montrer les réponses du démon.
5. Réitérez éventuellement en supprimant le log avec `scripts/clean_log.sh` avant de relancer le workflow pour garder le journal clair.
