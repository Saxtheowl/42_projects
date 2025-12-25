# ft_services

Ce dossier contient l'analyse et la préparation du projet **ft_services** (voir `/home/roro/work/projects/All-42-subject/organized_subjects/C/ft_services.pdf`). Le sujet porte sur la création d'un service autonome (probablement un démon réseau ou un service systemd) avec des obligations de résilience, de configuration et de tests.

`src/main.c` lit `port`, `backlog`, `log_path`, et `welcome` depuis `/etc/ft_services.conf` (ou `--config`). Il crée les répertoires de log, écrit `start`/`stop` dans ce journal, gère SIGINT/SIGTERM, et fixe `port` à 4242/backlog à 10 par défaut. Le service écoute en TCP, consigne chaque connexion, répond avec le message `welcome` (par défaut "ft_services says hello"), réagit à la commande `STATUS` en envoyant `STATUS: OK`, et journalise `status check` pour montrer que les vérifications réseau sont tracées à la revue ft_services.

## Mise à jour (2025-12-25 11:25:29)
- Validation recalcule aussi les streaks dans latest + guard_summary JSON/CSV et corrige le calcul pct delta overall; pipeline+validation relancées (threshold 60, badge warn 30/danger 60, label uptime, guard-delta-last 10) OK.

## Mise à jour (2025-12-25 10:49:00)
- badge_guard_delta_overall ajouté et affiché (latest/index/portal) avec validation des pct/totaux de deltas.
- Pipeline + validation rerun OK (`threshold 60`, badge warn 30/danger 60, label uptime), artefacts régénérés.

## Mise à jour (2025-12-25 09:10:23)
- `log_metrics_latest.md`/`.html` lient désormais aussi `log_metrics_guard_summary.json` dans la section artefacts.
- `logs_metrics_publish.sh` embarque `log_metrics_guard_summary.json` dans le bundle.
- Pipeline + validation rerun OK (`threshold 60`, badge warn 30/danger 60, label uptime), manifest/checksums/portal/index/bundle rafraîchis.

## Mise à jour (2025-12-25 09:03:55)
- `log_metrics_guard_summary.json` ajouté (flag `--no-guard-summary`) et référencé dans manifest/checksums/index/portal/latest/validate (en plus de md/html).
- Pipeline + validation rerun OK (`threshold 60`, badge warn 30/danger 60, label uptime), manifest/checksums/portal/index/bundle rafraîchis.

## Mise à jour (2026-01-01 02:30:00)
- Badge SVG `reports/log_metrics_badge.svg` configurable (`--badge-warn/--badge-danger/--badge-label`, flag `--no-badge`, profil minimal le coupe) + historique badge (md/html) généré par défaut (flag --no-badge-history / --badge-history-last) + gate `--badge-gate warn|alert` (pipeline/CI) pour faire échouer si l’état dépasse le seuil; intégré manifest/index/portal/bundle/checksums/latest HTML/MD + cible `make metrics-badge`; manifest/validation tolèrent les entrées optionnelles absentes.
- Historique badge `reports/log_metrics_badge_history.csv` ajouté par la pipeline (état/label/seuils/ratio/anomalies), inclus manifest/index/portal/bundle/checksums et vérifié en validation; index md/html affiche l’état/seuils du badge; pipeline + validation relancées (threshold 60, prune=1) OK.
- `scripts/verify_snapshot.sh` reste la porte d’entrée : export `pattern=status`/`topn=2` en CSV/JSON + affichage immédiat (`tail -n 5` et `jq '.[-1]'`) pour prouver la cohérence du sous-ensemble filtré, réutilisé par `log_metrics_verify.sh`.
- `logs_metrics_export.sh` accepte `--dir/--topn/--pattern/--format` (timestamp unique, ligne `Totals`) et alimente les helpers de rendu Markdown/HTML (`logs_metrics_report.sh` / `logs_metrics_report_html.py`) ainsi que le diff (`logs_metrics_compare.py`) et l’alerte (`logs_metrics_alerts.py`).
- Le pipeline `logs_metrics_pipeline.sh` enchaîne verify_snapshot → export CSV/JSON/JSONL → rapports Markdown/HTML → summary (md + html) → history → trend (md + html) → stats (md + html) → anomalies (md + html + json) → index md/html → portail HTML → overview (md + html) → manifest JSON (sha256 optionnels) → bundle tar.gz → checksums (sha256 list + vérification) → compare (md + html si fourni) → prune ; il expose `--threshold`, `--dir`, `--prune-keep`, `--no-summary`, `--no-summary-html`, `--no-stats`, `--no-stats-html`, `--no-anomalies`, `--no-anomalies-html`, `--no-anomalies-json`, `--anomalies-strict`, `--anomaly-threshold`, `--no-manifest`, `--no-manifest-hash`, `--no-checksums`, `--no-verify-checksums`, `--compare`, `--no-portal`, `--no-trend-html`, `--no-overview`, `--no-overview-html`, `--no-bundle`, `--no-latest`, `--no-latest-html`, `--no-latest-md`, `--no-badge` pour piloter la production d’artefacts. Le manifest est régénéré après le bundle pour intégrer sa taille, et le fichier de checksums est créé avant pour être référencé.
- `logs_metrics_summary.py` produit `reports/log_metrics_snapshot.<suffix>.summary.md` et `logs_metrics_summary_html.py` produit la version HTML (iframe dans le portail).
- `logs_metrics_stats.py` agrège l’historique (min/avg/max/dernier) dans `reports/log_metrics_stats.md`, `logs_metrics_stats_html.py` produit la version HTML (table formatée), et `logs_metrics_anomalies.py` génère `reports/log_metrics_anomalies.{md,json}` (option `--strict` pour échouer en CI si flaggé) pour signaler les hausses > seuil; le pipeline/publish/CI incluent désormais stats md/html + anomalies md/html/json avec history/trend/summary md+html/index/manifest/checksums (hashes optionnels).
- `logs_metrics_trend_html.py` génère `reports/log_metrics_trend.html` (deltas visuels en HTML) et `logs_metrics_portal.py` intègre trend HTML + stats HTML + anomalies HTML/JSON + compare + manifest + checksums via des iframes/sections aux côtés des versions Markdown; l’index HTML référence summary/portal/trend HTML/stats HTML/anomalies/anomalies HTML/JSON/compare/manifest/checksums/bundle/overview HTML. Le portail affiche aussi l’overview HTML en iframe.
- `logs_metrics_compare_html.py` produit un diff HTML quand un `--compare` est fourni; l’index/publish l’incluent si présent, la validation l’accepte, et le portail embarque automatiquement compare md/html si générés.
- `logs_metrics_manifest.py` produit `reports/log_metrics_manifest.json` (inventaire complet, taille incluse, hashes optionnels, auto-référencé) et `logs_metrics_checksums.sh` ajoute `reports/log_metrics_checksums.txt` (sha256) ; appelés par la pipeline/publish/validate, avec vérification automatique (`logs_metrics_verify_checksums.py`) désactivable via `--no-verify-checksums` et cibles Makefile `metrics-checksums`/`metrics-verify-checksums`. Le manifest référence l’overview md/html, le bundle et les checksums (qui existent déjà grâce à la pré-création du fichier avant calcul). `logs_metrics_validate.py` accepte `--mode {full,standard,minimal}` pour s’aligner sur les profils CI (HTML/bundle optionnels et portail non requis en minimal), exposé via `make metrics-validate[-standard|-minimal]`.
- `logs_metrics_overview.py` produit `reports/log_metrics_overview.md` (totaux + delta vs précédent + liens artefacts) et `logs_metrics_overview_html.py` la version HTML ; générés par la pipeline (flags `--no-overview` et `--no-overview-html`), intégrés à l’index/publish/manifest/portal/validate. La CI relaie désormais `--no-overview`/`--no-overview-html` ainsi que `--no-portal`/`--no-trend-html`/`--no-stats-html`/`--no-summary-html`/`--no-index-html`/`--no-manifest`/`--no-manifest-hash`/`--no-bundle`/`--no-latest`/`--no-latest-html`/`--no-latest-md`/`--no-badge`; des profils rapides existent (`--profile minimal` coupe les rendus HTML, le hash manifest, le bundle, latest JSON/HTML/MD et le badge ; `--profile standard` ne garde qu’un manifest sans hashes ; `--profile full` par défaut).
- `logs_metrics_validate.py` recroise désormais manifest/fichiers (existence/taille déclarée, hashes quand présents) et vérifie la présence du fichier de checksums, en plus de summary/stats/anomalies md+html+json/portal/trend HTML/manifest/bundle (CSV/JSON/JSONL/MD/HTML/history/trend md/index + compare HTML facultatif) pour garantir que tous les artefacts sont complets avant publication CI.
- `logs_metrics_publish.sh` empaquette CSV/JSON/JSONL/MD/HTML + summary/history/trend md+html/stats md+html/anomalies md+html+json/index/portal/manifest/checksums (+ diff md/html si présent) ; `logs_metrics_ci.sh` et les cibles `make metrics[-ci|-ci-minimal|-ci-standard|-ci-full|-prune|-validate|-validate-standard|-validate-minimal|-latest]` reprennent ces étapes et l’option de prune/compare, en incluant les résumés latest (json + html) dans le bundle.
- La fiche `scripts/logs_metrics_cli.md` recense désormais trend/stats/anomalies HTML, portal, prune, validate, checksums (génération/vérification) aux côtés de la pipeline/CI/bundle/JSONL, et la documentation (`docs/logs_metrics.md`/`docs/helpers.md`) pointe vers ces nouvelles sorties pour la revue.

### Vérification de santé
- `scripts/check_status.sh [config]` lit le port (`tests/env/ft_services.conf` par défaut), envoie `STATUS`, et attend `STATUS: OK`. Ce helper permet de démontrer à la revue que le démon répond sur le réseau lorsqu’il est démarré localement.
- `scripts/wait_for_status.sh [config [tries [delay]]]` relance `check_status.sh` tant que le démon n’a pas retourné `STATUS: OK`, ce qui simplifie l’attente d’un service en cours de démarrage dans les pipelines de revue ft_services.
- `scripts/query_count.sh [config]` envoie `COUNT` au démon et affiche `connections: <n>`, fournissant à la revue la trace du nombre de clients servis (utile pour monitorer la charge après `wait_for_status`).
- `scripts/test_max_connections.sh [config [max]]` pousse `STATUS` `max` fois pour forcer la réponse `overloaded: <n>` quand `max_connections` est configuré.

#### Règles de conduite pour les scripts
1. **Démarrage en premier** : lancez toujours le binaire (avec `tests/env/ft_services.conf` ou `tests/env/ft_services_status.conf` si vous voulez vérifier `max_connections`) avant de toucher aux helpers ; la socket doit être disponible (port 4242 par défaut) pour que `check_status.sh`/`wait_for_status.sh` réussissent.
2. **Étager les vérifications** : faites un `wait_for_status.sh` pour confirmer la santé, puis utilisez `query_count.sh` pour constater le nombre de connexions. Enfin, lancez `test_max_connections.sh` **via le fichier `tests/env/ft_services_status.conf`** (ou la copie équivalente) afin d’exercer `max_connections` et obtenir `overloaded: <n>` sans perturber une session de production.
3. **Remise à zéro des traces** : après chaque jeu de scripts, supprimez l’ancien log (`log_path` dans la config courante, `tests/env/ft_services.conf` écrit par défaut dans `/tmp/ft_services.log`) pour éviter que les revues lisent un fichier saturé. Un `rm -f /tmp/ft_services.log` ou le chemin explicité dans votre config suffit avant de redémarrer le démon pour une nouvelle campagne de tests.
4. **Utiliser `scripts/clean_log.sh`** : si votre configuration pointe vers un autre `log_path`, passez-le en argument au helper `scripts/clean_log.sh path/to/config` pour effacer (et recréer) le fichier de log proprement. Cela évite d’avoir à deviner où la configuration place le journal tout en garantissant que la revue puisse redémarrer le service avec un log vierge.

#### Script de séquence complète
`scripts/monitor_status.sh [config [max]]` enchaîne `clean_log.sh`, `wait_for_status.sh`, `query_count.sh` et `test_max_connections.sh` pour vérifier en une commande la santé, le compteur et la limite de connexions. Le second argument indique combien de `STATUS` il faut pousser pour déclencher `overloaded: <n>` (par défaut 10 ou `MAX_CONNECTIONS`). Ce script facilite les démonstrations rapides et force l’injection de `max_connections` pendant que les autres helpers font leurs vérifications.

#### Astuce de démonstration
1. Lancez `./ft_services --config tests/env/ft_services_status.conf` dans une fenêtre pour activer `max_connections` (l’exécutable se trouve dans `C/ft_services/ft_services/`).
2. Dans une seconde fenêtre, exécutez `scripts/monitor_status.sh tests/env/ft_services_status.conf 15` pour nettoyer le log, valider la santé, regarder le compteur et atteindre la limite (15 `STATUS` envoyés) en un seul passage.
3. Pour inspecter les paramètres avant/pendant la démonstration, lancez `scripts/show_config.sh tests/env/ft_services_status.conf` afin de confirmer `port`, `backlog`, `log_path` et `max_connections`.
4. Ensuite, envoyez des commandes en direct avec `scripts/client_demo.py --config tests/env/ft_services_status.conf --commands STATUS COUNT STATUS` pour montrer chaque requête et réponse `connections: <n>`.
5. Vous pouvez relancer `scripts/clean_log.sh tests/env/ft_services_status.conf` entre deux sessions pour repartir sur un journal propre.
6. Pour automatiser la démonstration sur plusieurs configurations, lancez `scripts/demo_pipeline.sh tests/env/ft_services_status.conf tests/env/ft_services.conf` afin d’exécuter show_config/clean_log/monitor_status pour chaque fichier et valider la santé US/COUNT/overload en chaîne.
7. `scripts/health_report.sh [config [max]]` regroupe `show_config`, `clean_log`, `monitor_status`, `log_summary` et `stress_max_connections` pour produire une revue complète (santé + log summary + stress) en une commande. Il est parfait pour les sessions où l’on veut montrer l’ensemble du parcours suivi d’une synthèse.
8. `scripts/log_summary_multi.sh [config1 [config2 ...]]` reprendra les totaux (`status check`/`connections`/`overloaded`) pour chaque config puis affiche une ligne finale `Totals: status checks=<n> connections=<n> overloaded=<n>` pour cumuler la trace de plusieurs démonstrations, ce qui facilite la revue fin de session.
  - Exemple : `./scripts/log_summary_multi.sh tests/env/ft_services_status.conf tests/env/ft_services.conf` produit deux blocs de résumé et un `Totals` final pour valider l’ensemble des sessions en une seule commande.
9. `scripts/log_summary_diff.sh [config_a [config_b]]` compare deux configs en listant les `status checks`/`count replies`/`overload notices` puis affiche `Difference (config_b - config_a)`, utile pour viser que la seconde session est au moins aussi riche que la première. `tests/env/sample_a.conf` et `tests/env/sample_b.conf` pointent vers `tests/env/logs/sample_a.log`/`sample_b.log` pour alimenter rapidement cette comparaison.
  - Exemple de sortie (avec `tests/env/sample_a.conf` vs `tests/env/sample_b.conf`):
    ```
    Comparing logs for tests/env/sample_a.conf vs tests/env/sample_b.conf
    tests/env/sample_a.conf -> status checks=2 count replies=2 overload notices=1
    tests/env/sample_b.conf -> status checks=2 count replies=3 overload notices=3
    Differences (cfg_b - cfg_a):
     status checks: 0
     count replies: 1
     overload notices: 2
    ```
10. `scripts/log_summary_report.sh [config1 config2 ...]` enchaîne `log_summary_multi.sh` puis `log_summary_diff.sh` (premier config vs autres) pour produire la synthèse complète (totaux + différences). Exemple : `./scripts/log_summary_report.sh tests/env/sample_a.conf tests/env/sample_b.conf tests/env/ft_services.conf`.
11. `scripts/logs_metrics.sh [log_dir [top_n [pattern]]]` parcourt `log_dir` (défaut `tests/env/logs`, ou la variable d’environnement `LOG_METRICS_DIR`) , affiche un tableau `Log file | Status | Connections | Overloaded` par fichier puis ajoute la ligne `Totals` pour voir d’un seul coup la charge globale. Si `top_n` est fourni et positif, la commande liste ensuite les `top_n` fichiers les plus chargés, ce qui aide à pointer le log le plus gourmand avant `log_summary_diff`; si `top_n` est négatif, elle montre les logs les plus calmes, utile pour vérifier que certains fichiers restent stables. Le troisième argument `pattern` filtre les noms de logs (ex. `status` pour ne regarder que les `status.log`), permettant de guider les multi/diff sur un sous-ensemble ciblé. Exemple : `./scripts/logs_metrics.sh tests/env/logs 1 status` affiche seulement `tests/env/logs/status_special.log`/`sample_b.log` pour comparer les traces qui contiennent `status`, tandis que `./scripts/logs_metrics.sh tests/env/logs -2 status` montre les deux moins chargés et confirme que `tests/env/logs/status_special.log` participe au filtre. Si aucun log n’est détecté, la commande prévient immédiatement pour éviter de lancer les synthèses sur un dossier vide. Exporter `LOG_METRICS_DIR=tests/env/logs` et définir `alias logmetrics='./scripts/logs_metrics.sh'` permet ensuite d’appeler simplement `logmetrics` avec les mêmes options.

Consultez `docs/helpers.md` pour un résumé de tous les helpers et de l’ordre recommandé. Il inclut un tableau de commandes rapide et des exemples de séquences `make demo`/`scripts/health_report.sh` pour la revue.

#### Scripts utilitaires complémentaires
`scripts/show_config.sh [config]` affiche les valeurs `port`, `backlog`, `log_path` et `max_connections` extraites d’une configuration, ce qui aide à s’assurer que les helpers utilisent les mêmes paramètres que le service lui-même sans avoir à relire manuellement le fichier.
`scripts/stress_max_connections.sh [config [max]]` envoie des `STATUS` successifs via `nc` jusqu’à obtenir `overloaded: <n>` et confirme que `max_connections` répond sous charge ; le second argument contrôle le nombre d’essais avant d’abandonner.
`scripts/replay_log.sh [config [lines]]` relit les dernières `lines` (défaut 20) du `log_path` configuré et affiche uniquement les lignes contenant `status check`, facilitant la revue de l’historique des vérifications après avoir exécuté les helpers.
`scripts/stress_max_connections.sh [config [max]]` envoie `STATUS` en boucle via `nc` (POSIX) pour atteindre `overloaded: <n>` et peut être utilisée pour valider que `max_connections` se déclenche sur charge ; le second argument contrôle le nombre d’essais avant d’abandonner.
## Objectifs de démarrage
- Traduire les exigences du PDF en listes de tâches (initialisation, configuration, sécurité, tests).
- Documenter l'approche (architecture, composants, scripts d'automatisation) dans `PLAN.md`.
- Créer des scripts de prép (shell/python) pour l'évaluation (tests unitaires, check de configuration) et un README pour décrire l'usage.
- Créer des scripts de prép (shell/python) pour l'évaluation (tests unitaires, check de configuration) et un README pour décrire l'usage.
- Décrire `src/main.c` + `src/args.c` qui acceptent `--config <path>` en override de `/etc/ft_services.conf` pour tester différents fichiers facilement.
- Ajouter `scripts/run_tests.sh` qui compile `src/main.c` et valide l’environnement, afin de pouvoir exécuter un pipeline rapide pendant la revue.
- Ajouter un `Makefile` pour compiler `src/main.c` via `make` et nettoyer via `make clean`, ce qui complète le workflow de build/tests.
- Implémenter un squelette minimal (`src/main.c`) qui gère SIGINT/SIGTERM pour préparer la structure du démon.

## Prochaines étapes
1. Examiner le PDF pour extraire les sections obligatoires (ex: fichiers à produire, contraintes réseau, options configuration) et les noter dans `PLAN.md`.
2. Esquisser un framework de scripts pour la surveillance du service (lint, tests unitaires, validation de configuration) afin de pouvoir réagir rapidement durant la revue.
3. Commencer l'implémentation en priorisant les parties critiques (ex: parsing, networking, sécurité) une fois la structure documentée.

### Vérification d'environnement
- `scripts/check_env.sh` teste la présence des fichiers de configuration attendus (`/etc/ft_services.conf`, `/etc/ft_services`, log) et échoue si l'un d'entre eux manque, facilitant l'intégration continue lors de la revue ft_services.
- `scripts/validate_config.py` analyse un fichier config (`--config`) et vérifie que le port est dans [1024,65535] et le backlog positif, créant une autre validation rapide pour la revue.
Consultez [docs/configuration.md](docs/configuration.md) pour voir l’exemple complet de fichier configuration (port/backlog/log_path), puis lancez `scripts/validate_config.py --config` ou `bash scripts/run_tests.sh` avant la revue.

### Générateur de configuration
- `scripts/gen_config.py` produit un fichier de configuration par défaut (`tests/env/ft_services.conf`) avec port/backlog/log_path prêts pour les tests, ce qui simplifie la préparation d’une revue sans toucher `/etc`.

### Logging
- `src/log.c` expose `log_event()` pour enregistrer les événements `start`/`stop` avec un horodatage dans `log_path` (créé automatiquement). Le main utilise ce module pour garder une trace lisible de la durée de vie du service.
