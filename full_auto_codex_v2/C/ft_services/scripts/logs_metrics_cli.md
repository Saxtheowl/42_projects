# logs_metrics CLI usage

Commandes principales disponibles pour produire, vérifier et diffuser les métriques :

- Export + vérification : `./scripts/logs_metrics_pipeline.sh --dir tests/env/logs --threshold 60 [--compare base.csv] [--no-verify-checksums]`
- Runner CI complet : `./scripts/logs_metrics_ci.sh --dir tests/env/logs --threshold 60`
- Index HTML seul : `python3 scripts/logs_metrics_index_html.py --reports reports --suffix status_top2`
- Bundle tar.gz : `./scripts/logs_metrics_publish.sh --reports reports --suffix status_top2 --output reports/log_metrics_bundle.tar.gz`
- Conversion JSONL : `python3 scripts/logs_metrics_snapshot_to_jsonl.py --input reports/log_metrics_snapshot.status_top2.csv`
- Stats + portail : `python3 scripts/logs_metrics_stats.py --history reports/log_metrics_history.csv --output reports/log_metrics_stats.md` puis `python3 scripts/logs_metrics_portal.py --reports reports --suffix status_top2`
- Stats HTML : `python3 scripts/logs_metrics_stats_html.py --history reports/log_metrics_history.csv --output reports/log_metrics_stats.html` (automatique dans la pipeline, désactivable via `--no-stats-html`)
- Trend HTML : `python3 scripts/logs_metrics_trend_html.py --history reports/log_metrics_history.csv --last 10 --output reports/log_metrics_trend.html` (automatique dans la pipeline, désactivable via `--no-trend-html`)
- Anomalies : `python3 scripts/logs_metrics_anomalies.py --history reports/log_metrics_history.csv --output reports/log_metrics_anomalies.md --threshold 20` (automatique dans la pipeline, désactivable via `--no-anomalies`)
- Anomalies HTML : `python3 scripts/logs_metrics_anomalies_html.py --history reports/log_metrics_history.csv --output reports/log_metrics_anomalies.html --threshold 20` (automatique dans la pipeline, désactivable via `--no-anomalies-html`)
- Anomalies JSON : `python3 scripts/logs_metrics_anomalies.py --json-output reports/log_metrics_anomalies.json --threshold 20 --strict` (automatique dans la pipeline sauf `--no-anomalies-json`; `--anomalies-strict` fait échouer en CI si anomalies)
- CI complet avec anomalies : `./scripts/logs_metrics_ci.sh --dir tests/env/logs --threshold 60 --anomaly-threshold 10 --anomalies-strict --prune-keep 1 [--no-checksums] [--no-verify-checksums]`
- Diff HTML : `python3 scripts/logs_metrics_compare_html.py --base reports/log_metrics_snapshot.status_top2.csv --target reports/log_metrics_snapshot.status_top2.csv --output reports/log_metrics_compare.html` (appelé par la CI si `--compare` est fourni)
- Manifest JSON : `python3 scripts/logs_metrics_manifest.py --reports reports --suffix status_top2 --output reports/log_metrics_manifest.json` (appelé par la pipeline, désactivable via `--no-manifest`)
- Checksums : `./scripts/logs_metrics_checksums.sh --reports reports --suffix status_top2 --output reports/log_metrics_checksums.txt` (appelé par la pipeline, désactivable via `--no-checksums`)
- Vérification checksums : `python3 scripts/logs_metrics_verify_checksums.py --reports reports --suffix status_top2` (appelé par la pipeline/validate, peut être court-circuité via `--no-verify-checksums`)
- Overview : `python3 scripts/logs_metrics_overview.py --reports reports --suffix status_top2 --output reports/log_metrics_overview.md` (appelé par la pipeline, désactivable via `--no-overview`)
- Overview HTML : `python3 scripts/logs_metrics_overview_html.py --reports reports --suffix status_top2 --output reports/log_metrics_overview.html` (appelé par la pipeline, désactivable via `--no-overview-html`)
- Bundle tar.gz : `./scripts/logs_metrics_publish.sh --reports reports --suffix status_top2 --output reports/log_metrics_bundle.tar.gz` (appelé automatiquement par la pipeline, désactivable via `--no-bundle`)
- Latest JSON : `python3 scripts/logs_metrics_latest.py --reports reports --suffix status_top2 --output reports/log_metrics_latest.json` (appelé automatiquement par la pipeline, désactivable via `--no-latest`)
- Latest HTML : `python3 scripts/logs_metrics_latest_html.py --reports reports --suffix status_top2 --output reports/log_metrics_latest.html` (appelé automatiquement par la pipeline, désactivable via `--no-latest-html`)
- Latest MD : `python3 scripts/logs_metrics_latest_md.py --reports reports --suffix status_top2 --output reports/log_metrics_latest.md` (liens/deltas/anomalies, désactivable via `--no-latest-md`)
- Badge SVG : `python3 scripts/logs_metrics_badge.py --reports reports --suffix status_top2 --output reports/log_metrics_badge.svg [--warn-overloaded-ratio 50] [--danger-overloaded-ratio 80] [--label metrics]` (OK/WARN/ALERT selon ratio/anomalies, désactivable via `--no-badge`; les résumés latest json/html/md affichent l’état du badge, l’historique (counts/streak/état précédent) et la synthèse des gardes).
- Gate badge : `--badge-gate warn|alert` sur la pipeline/CI pour faire échouer si l’état du badge atteint le seuil (ordre ok < warn < alert), `--badge-ok-streak N` pour exiger une streak OK minimale, et `--badge-no-regression` pour refuser une régression vs le run précédent (basé sur `log_metrics_badge_history.csv`). Les options `--badge-warn/--badge-danger/--badge-label` sont aussi relayées par le runner CI; latest JSON expose `badge_guards` (gate/ok-streak/no-regression) pour les consommateurs.
- Historique badge : `python3 scripts/logs_metrics_badge_history.py --latest reports/log_metrics_latest.json --output reports/log_metrics_badge_history.csv` (ajout automatique par la pipeline) garde trace de l’état/seuils/ratio/anomalies par run; fichier inclus dans manifest/index/portal/bundle/checksums. `logs_metrics_guard_summary.py/html.py/json.py/csv.py` produisent `reports/log_metrics_guard_summary.{md,html,json,csv}` (synthèse ok/fail/unknown/total des gardes) avec une fenêtre delta configurable (`--delta-last`, piloté en pipeline via `--guard-delta-last` et propagé aux latest) et sont générés par la pipeline (désactivable via `--no-guard-summary`). Les streaks de gardes (courante + plus longues streaks ok/fail/unknown par garde) sont exposées dans `badge_guard_streaks` (latest JSON) et dans `log_metrics_guard_summary.{md,html,json,csv}`, affichées dans latest/index/portal; la validation recalcule ces streaks depuis `badge_history` et croise guard_summary JSON/CSV.
- Rendu historique (pipeline/CI) : `python3 scripts/logs_metrics_badge_history_md.py --history reports/log_metrics_badge_history.csv --last 20` (markdown) et `python3 scripts/logs_metrics_badge_history_html.py --history ... --last 20` (HTML), générés automatiquement par la pipeline (désactivables via `--no-badge-history`, réglables via `--badge-history-last`); `make metrics-badge-history` les régénère.
- Cibles Makefile rapides : `make metrics` (pipeline threshold=$(THRESHOLD) prune=$(KEEP)), `make metrics-latest` (résumé JSON), `make metrics-badge` (badge SVG seul), `make metrics-ci`, `make metrics-ci-minimal`, `make metrics-ci-standard`, `make metrics-ci-full`, `make metrics-prune`, `make metrics-validate`, `make metrics-validate-standard`, `make metrics-validate-minimal`
- Résumé rapide : `python3 scripts/logs_metrics_summary.py --input reports/log_metrics_snapshot.status_top2.csv`
- Validation globale : `python3 scripts/logs_metrics_validate.py --reports reports --suffix status_top2`
  - Modes : `--mode full` (par défaut), `--mode standard` (tolère l’absence des rendus HTML optionnels), `--mode minimal` (aucune exigence sur portal/index/trend/stats/summary/anomalies/overview HTML).
- Nettoyage des anciens snapshots : `./scripts/logs_metrics_prune_reports.sh --reports reports --keep 5`

Artifacts produits (par défaut `suffix=status_top2`) :
- `reports/log_metrics_snapshot.status_top2.{csv,json,jsonl,md,html}`
- `reports/log_metrics_snapshot.status_top2.summary.md`
- `reports/log_metrics_snapshot.status_top2.summary.html`
- `reports/log_metrics_history.csv` (historique)
- `reports/log_metrics_trend.md` (deltas vs run précédent)
- `reports/log_metrics_stats.md` (min/avg/max/dernier)
- `reports/log_metrics_trend.html` (trend en HTML avec deltas)
- `reports/log_metrics_stats.html` (stats en HTML)
- `reports/log_metrics_anomalies.html` (delta last vs previous run en HTML)
- `reports/index.md` et `reports/index.html`
- `reports/portal.html` (snapshot + summary + history + trend + stats)
- `reports/log_metrics_anomalies.md` (delta last vs previous run)
- `reports/log_metrics_anomalies.json` (deltas sérialisés pour CI/ingestion)
- `reports/log_metrics_compare.html` (diff HTML si compare exécuté)
- `reports/log_metrics_bundle.tar.gz` (CSV/JSON/JSONL/MD/HTML/index/bundle/diff si présent)
- `reports/log_metrics_compare.md` si `logs_metrics_compare` est invoqué
- `reports/log_metrics_manifest.json` (inventaire des artefacts)
- `reports/log_metrics_checksums.txt` (sha256 des artefacts présents)
- `reports/log_metrics_overview.md` (totaux + deltas + liens)
- `reports/log_metrics_overview.html` (overview HTML prêt pour portail/index)
- `reports/log_metrics_bundle.tar.gz` (bundle complet généré par la pipeline)
- `reports/log_metrics_latest.{json,html,md}` (résumé JSON/HTML/MD du dernier run)
- `reports/log_metrics_badge.svg` (badge état/ratio/anomalies/deltas)

Options CI additionnelles :
- `--no-overview` / `--no-overview-html` : relaient vers la pipeline pour sauter les vues overview md/html lorsque la CI n’en a pas besoin.
- `--no-portal`, `--no-trend-html`, `--no-stats-html`, `--no-summary-html`, `--no-index-html` : désactivent les rendus HTML correspondants dans la pipeline CI.
- `--no-manifest`, `--no-manifest-hash` : permettent de sauter le manifest ou ses sha256 en CI si un run allégé est voulu.
- `--no-bundle` : saute la génération de l’archive tar.gz (bundle) dans la pipeline CI.
- `--no-latest` / `--no-latest-html` / `--no-latest-md` : désactivent les résumés latest JSON/HTML/MD.
- `--no-badge` : désactive le badge SVG (profil minimal coupe latest + badge).
- Profils CI : `--profile minimal|standard|full` (défaut full). `minimal` coupe portal/trend-html/stats-html/summary-html/index-html/overview-html + bundle/latest (json/html) + badge et les sha256 du manifest ; `standard` garde tout mais désactive les hashes du manifest pour accélérer.
