# Logs Metrics Helper

## Lire rapidement les logs
- Commande principale : `./scripts/logs_metrics.sh [log_dir [top_n [pattern]]]`.
- Par défaut, `log_dir=tests/env/logs` (surchargé par `LOG_METRICS_DIR`), `top_n=0` (tous les fichiers), `pattern` vide.
- Le script affiche `Log file | Status | Connections | Overloaded` puis une ligne `Totals`. Un `top_n` positif trie par `overloaded` décroissant, un `top_n` négatif montre les moins chargés.
- Exemple :
  ```
  $ ./scripts/logs_metrics.sh tests/env/logs 1
  Log metrics for directory tests/env/logs
  Log file                           Status    Connections      Overloaded
  --------                           ------    -----------      -----------
  tests/env/logs/sample_b.log            2            3               3
  tests/env/logs/sample_a.log            2            2               1
  Totals                                  4            5               4

  Top 1 logs by overloaded count:
  tests/env/logs/sample_b.log            2            3               3
  ```
- Astuce : `export LOG_METRICS_DIR=tests/env/logs && alias logmetrics='./scripts/logs_metrics.sh'` pour réutiliser le même dossier, puis `logmetrics 2 status` pour filtrer uniquement les fichiers contenant `status`.

## Exporter vers CSV/JSON
- `./scripts/logs_metrics_export.sh --dir DIR --topn N --pattern NAME --format csv|json`
- Le format est validé (`csv` ou `json`), le timestamp est appliqué une fois pour toutes les lignes, et le tri suit `overloaded` (ordre inverse si `topn` négatif).
- Exemple :
  ```
  $ ./scripts/logs_metrics_export.sh --dir tests/env/logs --topn 2 --pattern status --format csv > reports/log_metrics_snapshot.csv
  $ ./scripts/logs_metrics_export.sh --dir tests/env/logs --topn 2 --pattern status --format json > reports/log_metrics_snapshot.json
  ```
- Colonnes exportées : `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` (ratio = `overloaded/status_checks` si `status_checks>0` sinon 0). Une ligne finale `Totals` est ajoutée pour agréger l’ensemble des fichiers listés.

## Run summary (JSON + Markdown + HTML)
- La pipeline génère `reports/log_metrics_run_summary.json` (statuts guard/checksums/validation/compare + badge/anomalies/ratio), `reports/log_metrics_run_summary.md` (aperçu lisible) et `reports/log_metrics_run_summary.html` (vue HTML compacte).
- Les trois fichiers sont inclus dans l’index, le portail HTML, le manifest et les checksums. Flags pour couper les rendus : `--no-run-summary-md`, `--no-run-summary-html`.
- Après validation finale, la pipeline régénère JSON/MD/HTML puis les checksums pour refléter l’état définitif du run.
- Un sitemap Markdown global `reports/log_metrics_sitemap.md` liste les artefacts (chemin, présence, taille, sha256 via le manifest) et ajoute un résumé (total/presents/manquants/poids) ; flag `--no-sitemap` pour le désactiver. La variante HTML `reports/log_metrics_sitemap.html` (flag `--no-sitemap-html`) inclut le même résumé et est lisible directement depuis le portail/index. La variante JSON `reports/log_metrics_sitemap.json` (flag `--no-sitemap-json`) expose les mêmes données pour les intégrations, avec la liste des chemins manquants et une option `--fail-on-missing` (ou `--fail-on-missing-sitemap` dans la pipeline). L’option `--optional <liste>` (pipeline : `--sitemap-optional`) ignore certains artefacts dans les totaux/manquants.

## Vérifier un snapshot (CSV + JSON)
- Nouveau helper : `./scripts/verify_snapshot.sh [--format csv|json|both] [--pattern PATTERN] [--topn N] [--dir LOG_DIR]`.
- Par défaut : `pattern=status`, `topn=2`, `dir=$LOG_METRICS_DIR` ou `tests/env/logs`.
- Produit :
  - `reports/log_metrics_snapshot.status_top2.csv` (tail automatique des 5 dernières lignes).
  - `reports/log_metrics_snapshot.status_top2.json` (lecture `jq '.[-1]'` si disponible).
- Vérification approfondie : `python3 ./scripts/logs_metrics_snapshot_check.py --reports reports --suffix status_top2` s’assure que CSV/JSON contiennent les mêmes lignes, que la ligne `Totals` est présente et que les sommes/ratios sont cohérents (`overloaded / connections`).
- La pipeline (`logs_metrics_pipeline.sh`) et la validation (`logs_metrics_validate.py`) exécutent ce checker par défaut (désactivable via `--no-snapshot-check`, tolérance réglable via `--snapshot-tolerance`).
- Le wrapper `./scripts/log_metrics_verify.sh [format]` reste disponible et s’appuie désormais sur `verify_snapshot.sh`.
- Commande type pour vos notes de revue :
  ```
  ./scripts/verify_snapshot.sh --format both
  tail -n 5 reports/log_metrics_snapshot.status_top2.csv
  jq '.[-1]' reports/log_metrics_snapshot.status_top2.json
  python3 ./scripts/logs_metrics_snapshot_check.py --reports reports --suffix status_top2
  ```
  Ces trois lignes prouvent que le même sous-ensemble `pattern=status/top_n=2` apparaît dans les deux formats et que la ligne `Totals` est obligatoire (le helper échoue si elle manque).

Dans vos notes de revue, reprenez cette recette en mentionnant les deux vérifications explicites (`tail` + `jq`) et la source documentaire :
```
./scripts/verify_snapshot.sh --format both
tail -n 5 reports/log_metrics_snapshot.status_top2.csv
jq '.[-1]' reports/log_metrics_snapshot.status_top2.json
```
Expliquez que ces commandes illustrent la sélection `pattern=status`/`top_n=2` dans le CSV et le JSON, citant `C/ft_services/docs/logs_metrics.md` (cette page) pour rappeler que la séquence helper + tail/jq est la recette de référence. Précisez que les mêmes colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` s’affichent dans les deux sorties, ce qui rassure les relecteurs qui ne relancent pas le helper.

Exemple de note de revue :
```
./scripts/verify_snapshot.sh --format both
tail -n 5 reports/log_metrics_snapshot.status_top2.csv
jq '.[-1]' reports/log_metrics_snapshot.status_top2.json
Voir C/ft_services/docs/logs_metrics.md pour la recette helper + tail/jq ; ces commandes confirment que `pattern=status`/`top_n=2` produit les colonnes attendues dans le CSV et le JSON simultanément.
```
Cela donne aux approbateurs un modèle simple à copier puis à valider manuellement si le helper n’est pas relancé.

## Générer un rapport Markdown
- Commande : `./scripts/logs_metrics_report.sh --input reports/log_metrics_snapshot.status_top2.csv` (ou tout autre CSV exporté).
- Produit un fichier `.md` (même base) contenant un tableau Markdown (`log_file`, `status_checks`, `connections`, `overloaded`, `overloaded_ratio`, `timestamp`) incluant la ligne `Totals`.
- Options : `--output` pour fixer le fichier de destination, `--help` pour l’usage.

## Générer un rapport HTML
- Commande : `python3 scripts/logs_metrics_report_html.py --input reports/log_metrics_snapshot.status_top2.csv` (ajoutez `--output` si besoin).
- Vérifie la présence de la ligne `Totals`, puis génère un tableau HTML avec les colonnes `log_file`, `status_checks`, `connections`, `overloaded`, `overloaded_ratio`, `timestamp` (la ligne Totals est en gras).
- Utile pour partager la synthèse dans un wiki ou un rapport sans retraiter le CSV/JSON.

## Pipeline complet (snapshot + rapports)
- Commande : `./scripts/logs_metrics_pipeline.sh --dir tests/env/logs` (options `--pattern/--topn/--reports/--compare` disponibles).
- Étapes : exécute `verify_snapshot` (CSV/JSON avec contrôles et Totals), génère le rapport Markdown et HTML correspondants à partir du CSV produit, exporte un JSONL, historise (`log_metrics_history.csv`), produit la tendance (`log_metrics_trend.md` + `log_metrics_trend.html`), calcule les stats (`log_metrics_stats.md` + `log_metrics_stats.html`), applique `logs_metrics_alerts` si `--threshold` est fourni, génère un résumé (`...summary.md`), écrit les index md/html, rend le portail HTML, produit un overview (md + html), écrit un manifest JSON puis construit le bundle tar.gz (désactivable), régénère le manifest, génère les checksums (vérification incluse), puis optionnellement compare/prune.
- Résultats : `reports/log_metrics_snapshot.<pattern>_top<topn>.{csv,json,jsonl,md,html,summary.md,summary.html}`, `reports/log_metrics_history.csv`, `reports/log_metrics_trend.{md,html}`, `reports/log_metrics_stats.{md,html}`, `reports/log_metrics_compare.{md,html}` (si compare), `reports/index.{md,html}`, `reports/portal.html`, `reports/log_metrics_overview.{md,html}`, `reports/log_metrics_manifest.json`, `reports/log_metrics_checksums.txt`, `reports/log_metrics_bundle.tar.gz`, `reports/log_metrics_latest.{json,html,md}` et le badge `reports/log_metrics_badge.svg` prêts à partager, avec la checklist `tail`/`jq` validée et la possibilité de bloquer sur un seuil d’overload.
- Options principales : `--threshold`, `--dir`, `--prune-keep`, `--no-summary`, `--no-summary-html`, `--no-stats`, `--no-stats-html`, `--no-anomalies`, `--no-anomalies-html`, `--no-anomalies-json`, `--anomalies-strict`, `--anomaly-threshold`, `--no-manifest`, `--no-manifest-hash`, `--no-checksums`, `--no-verify-checksums`, `--compare`, `--no-portal`, `--no-trend-html`, `--no-overview`, `--no-overview-html`, `--no-bundle`, `--no-latest`, `--no-latest-html`, `--no-latest-md`, `--no-badge`.

## Comparer deux snapshots
- Script : `python3 scripts/logs_metrics_compare.py --base reports/log_metrics_snapshot.status_top2.csv --target reports/log_metrics_snapshot.status_top2.csv --output reports/log_metrics_compare.md`
- Le script vérifie que chaque CSV possède `Totals`, calcule les deltas (base → target) pour `status_checks`, `connections`, `overloaded`, `overloaded_ratio`, et écrit un tableau Markdown (incluant `Totals`).
- Version HTML : `python3 scripts/logs_metrics_compare_html.py --base ... --target ... --output reports/log_metrics_compare.html` pour disposer d’un diff prêt à publier dans un portail/CI.
- Le portail HTML embarque automatiquement le compare md/html si présents, ce qui permet de partager deltas et diff visuellement sans ouvrir les fichiers séparément.
- Idéal pour tracer les écarts entre deux exports successifs sans rouvrir les CSV/JSON dans un tableur.

## Détecter les ratios d’overload
- Script : `python3 scripts/logs_metrics_alerts.py --input reports/log_metrics_snapshot.status_top2.csv --threshold 50`
- Vérifie la présence de `Totals` puis échoue (exit 1) si un `overloaded_ratio` dépasse le seuil (CSV complet ou Totals).
- Utile en CI pour bloquer un rapport si la proportion d’overload est trop élevée.

## Indexer les artefacts
- Script : `python3 scripts/logs_metrics_index.py --reports reports --suffix status_top2 [--compare reports/log_metrics_compare.md]`
- Vérifie la présence des artefacts CSV/JSON/MD/HTML pour le suffixe donné et génère `reports/index.md` avec des liens relatifs (snapshots CSV/JSON/JSONL/MD/HTML/summary, history, trend/stats/anomalies md+html+json, compare md+html si fourni, manifest, portal, bundle).
- Pour une version HTML : `python3 scripts/logs_metrics_index_html.py --reports reports --suffix status_top2 [--output reports/index.html]` (produit `reports/index.html` avec les liens CSV/JSON/JSONL/MD/HTML/summary/history/trend/bundle/compare si présents; `--output` permet de cibler un autre chemin).

## Overview (totaux + deltas + liens)
- Script Markdown : `python3 scripts/logs_metrics_overview.py --reports reports --suffix status_top2 --output reports/log_metrics_overview.md`
- Version HTML : `python3 scripts/logs_metrics_overview_html.py --reports reports --suffix status_top2 --output reports/log_metrics_overview.html`
- Contenu : ligne Totals du snapshot courant, delta vs précédent depuis l’historique, tableau de liens vers tous les artefacts disponibles (CSV/JSON/JSONL/MD/HTML/summary/history/trend/stats/anomalies/compare/index/manifest/checksums/bundle/portal).
- Généré automatiquement par la pipeline (désactivable via `--no-overview` ou `--no-overview-html`) et affiché dans l’index md/html ainsi que dans le portail (iframe HTML + markdown brut).
- Publié dans l’archive `log_metrics_bundle.tar.gz` pour partager rapidement la synthèse sans ouvrir chaque fichier.

## Résumé JSON du dernier run
- Script : `python3 scripts/logs_metrics_latest.py --reports reports --suffix status_top2 --output reports/log_metrics_latest.json`
- Contenu : Totals du snapshot, nombre d’entrées d’historique, nombre d’anomalies (et leur liste si disponible) et chemins des artefacts clés (csv/json/jsonl/md/html/summary/trend/stats/anomalies/index/portal/manifest/bundle/overview/checksums). Les champs badge exposent `badge_state`/`badge_previous_state`, `badge_thresholds`, la fenêtre d’historique (`badge_history` avec counts/streak/état précédent/transition) et le garde-fou `badge_ok_streak_required`.
- Généré automatiquement par la pipeline, intégré au manifest/checksums/bundle et affiché dans le portail et l’index. La validation en mode full vérifie que les Totals du latest correspondent à la ligne Totals du CSV et que les artefacts listés existent.
- Version HTML : `python3 scripts/logs_metrics_latest_html.py --reports reports --suffix status_top2 --output reports/log_metrics_latest.html` (iframe dans le portail, lien dans l’index).
- Version Markdown : `python3 scripts/logs_metrics_latest_md.py --reports reports --suffix status_top2 --output reports/log_metrics_latest.md` (référencé dans l’index/portal + manifest/checksums/bundle).
- Options : `--no-latest` / `--no-latest-html` / `--no-latest-md` (pipeline/CI), profil CI minimal désactive latest json/html/md.

## Badge SVG (état)
- Script : `python3 scripts/logs_metrics_badge.py --reports reports --suffix status_top2 --output reports/log_metrics_badge.svg [--warn-overloaded-ratio 50] [--danger-overloaded-ratio 80] [--label metrics]`.
- Contenu : badge SVG compact (état OK/WARN/ALERT en couleur) incluant le ratio `overloaded`, le nombre d’anomalies, le nombre de runs historisés et le delta de ratio vs run précédent si disponible.
- Généré automatiquement par la pipeline (désactivable via `--no-badge`, profil CI minimal le coupe) et intégré à l’index md/html, au portail, au manifest/bundle/checksums et aux résumés latest (liens).
- Validation full vérifie la présence du SVG et la cohérence manifest/checksums; `make metrics-badge` regénère uniquement le badge depuis les artefacts existants. La validation recalcule aussi guard_overall/delta en agrégation par ligne (aligné avec guard_summary/latest) et croise latest vs guard_summary (counts/pct/streaks).
- Seuils/label configurables dans la pipeline/CI avec `--badge-warn`, `--badge-danger` et `--badge-label` pour coller aux SLO/SLA.
- Les résumés latest (json/html/md) exposent l’état du badge (`badge_state`, `badge_previous_state`, `badge_label`, `badge_thresholds`), la fenêtre d’historique (counts/streak/transition) et les gardes activés (`badge_guards` : gate, ok-streak, no-regression) pour consommation programmatique et affichage (Badge).
- Gate CI : `--badge-gate warn|alert / --badge-ok-streak N (streak OK minimale) et --badge-no-regression (refuse une dégradation vs run précédent via l’historique badge)` (pipeline) échoue si l’état du badge atteint le niveau indiqué (ordre ok < warn < alert), utile pour verrouiller la CI sur un SLO.
- Historique badge (md/html) : la vue md/html affiche la transition précédente -> courante, la fenêtre considérée, les streaks/counts par état et les colonnes de garde (gate/ok/no-reg + résultats) issues de `log_metrics_badge_history.csv` (upgrade auto si ancien format, option `--badge-history-last`) + un tableau de synthèse des gardes (ok/fail/unknown).
- Guard summary MD/HTML/JSON/CSV : `python3 scripts/logs_metrics_guard_summary.py --history reports/log_metrics_badge_history.csv --output reports/log_metrics_guard_summary.md [--last N] [--delta-last M]`, `python3 scripts/logs_metrics_guard_summary_html.py --history ... --output ...`, `python3 scripts/logs_metrics_guard_summary_json.py --history ... --output ...`, `python3 scripts/logs_metrics_guard_summary_csv.py --history ... --output ...` produisent un tableau ok/fail/unknown/total/window/pct par garde (gate/ok/no-reg) avec deltas (valeurs et %) vs une fenêtre précédente configurable (`--delta-last`, par défaut même taille que la fenêtre courante) et incluent aussi les streaks (courante + longest ok/fail/unknown) par garde. La streak globale agrégée (fail si un garde fail, ok si tous ok, sinon unknown) est détaillée en tableau dans la version Markdown (counts/pct/deltas + streak current/longest) et en HTML (counts/pct/deltas + streak); le JSON exporte aussi un bloc `overall` (counts/pct/deltas) en plus de `overall_streak`. Le CSV ajoute désormais deux lignes spéciales : `__overall` (counts/pct/deltas agrégés) et `__overall_streak` (streak agrégée avec deltas), pour faciliter l’ingestion tabulaire. Généré par la pipeline (désactivable via `--no-guard-summary`, option `--guard-delta-last` propagée aux rendus et au latest), inclus dans bundle/manifest/checksums/index/portal/latest/validate. La validation recroise la version CSV/JSON avec badge_history et latest pour counts/pct/deltas/`delta_window` et vérifie également les streaks recalculées (par garde et globales); portail/index/latest affichent pct + deltas (dont delta_overall) et streaks, avec la fenêtre delta utilisée.
- Vérification rapide : `python3 scripts/logs_metrics_guard_summary_check.py --csv reports/log_metrics_guard_summary.csv --json reports/log_metrics_guard_summary.json` compare les blocs agrégés/streak CSV/JSON (overall + overall_streak) et échoue en cas d’écart. Disponible aussi via `make metrics-guard-summary-check`.
- Pipeline/CI : le pipeline lance ce check par défaut (désactivable via `--no-guard-check` sur `logs_metrics_pipeline.sh` ou `logs_metrics_ci.sh`), ce qui garantit que les rendus md/html/index/portal se basent sur des artefacts cohérents.
- Les scripts pipeline/verify résolvent désormais les chemins `--dir/--reports` depuis la racine du dépôt et appellent les outils en absolu, ce qui permet de les lancer depuis n’importe quel répertoire.
- Checksums : `logs_metrics_checksums.sh` normalise aussi `--reports` par rapport à la racine et ignore les artefacts optionnels (compare md/html) lorsqu’ils ne sont pas présents.
- Quick check : `bash scripts/metrics_quick_check.sh --reports reports --suffix status_top2` (ou `make metrics-quick-check`) lance en une commande le check guard_summary CSV/JSON + la vérification des checksums quand les fichiers sont présents. `metrics_smoke.sh` enchaîne pipeline + validation (incluant la cohérence latest/guard_summary) + quick-check pour un smoke complet local.
- Run summary : la pipeline génère `reports/log_metrics_run_summary.json` (guard_check/checksums/validation/badge/anomalies/ratio) pour un état synthétique; inclus dans le manifest.
- Streaks des gardes : le latest JSON expose `badge_guard_streaks` (streak courante résultat/longueur + plus longues streaks ok/fail/unknown par garde sur la fenêtre) et `badge_guard_overall_streak` (agrégation : fail si un garde fail, ok si tous ok, sinon unknown), affichés dans latest md/html, index md/html et portal (table). Validation recalcule les streaks depuis `badge_history` et vérifie fenêtre/longueurs/résultats (par garde et global).
- Latest JSON : expose aussi `badge_guard_summary` (counts ok/fail/unknown par garde) affiché dans latest HTML/MD/portail/index et vérifié par la validation contre badge_history. L’index HTML/md affichent un tableau récapitulatif des gardes et les liens guard_summary md/html.
- Le runner CI relaye `--badge-gate` et les options `--badge-warn/--badge-danger/--badge-label`; les profils s’appliquent comme pour les autres artefacts (profil minimal coupe aussi le badge/gate).
- Index : affiche le badge (lien svg) et l’état/les seuils lus depuis `log_metrics_latest.json`; l’index HTML inclut également l’état du badge.
- Badge history : `logs_metrics_badge_history.py` ajoute une ligne CSV (date/suffix/état/label/seuils/ratio/anomalies) à `log_metrics_badge_history.csv` (généré par la pipeline, inclus manifest/index/bundle/portal/checksums, validation vérifie qu’il n’est pas vide). `logs_metrics_badge_history_md.py` et `logs_metrics_badge_history_html.py` rendent la vue md/html (tables + compteurs d’états, option `--last N`), générées par défaut (flag `--no-badge-history` / option `--badge-history-last` (relayée par la CI) pour tout couper).

## Nettoyer les vieux snapshots
- Script : `./scripts/logs_metrics_prune_reports.sh --reports reports --suffix status_top2 --keep 5 [--dry-run]`
- Conserve les `keep` derniers fichiers par extension (`csv,json,jsonl,md,html`) et supprime les plus anciens pour éviter l’encombrement; `--dry-run` affiche sans supprimer.

## Run CI complet (pipeline + alert + compare + bundle)
- Script : `./scripts/logs_metrics_ci.sh [--dir LOG_DIR] [--pattern PATTERN] [--topn N] [--threshold N] [--compare base.csv] [--suffix pattern_topN] [--anomaly-threshold N] [--anomalies-strict] [--no-anomalies{-html,-json}]`
- Actions : exécute le pipeline (verify + reports + index + history + trend/stats/anomalies/overview), applique l’alerte si `--threshold` est fourni, lance `logs_metrics_compare` si `--compare` est présent, exporte un JSONL, puis génère un bundle tar.gz via `logs_metrics_publish`.
- Les options `--no-checksums/--no-verify-checksums/--no-anomalies{-html,-json}/--anomaly-threshold/--anomalies-strict`, `--no-overview/--no-overview-html`, `--no-portal`, `--no-trend-html`, `--no-stats-html`, `--no-summary-html`, `--no-index-html`, `--no-manifest`, `--no-manifest-hash`, `--no-bundle`, `--no-latest`, `--no-latest-html`, `--no-latest-md`, `--no-badge` sont relayées vers la pipeline pour réduire les artefacts en CI si besoin. Profils : `--profile minimal` (désactive portal/trend-html/stats-html/summary-html/index-html/overview-html + hashes manifest + bundle + latest + badge), `--profile standard` (désactive uniquement les hashes manifest), `--profile full` (défaut).
- Le pipeline génère aussi un portail HTML (`reports/portal.html`) qui regroupe snapshot, summary, history, trend, stats, anomalies, overview (md/html) et checksums/manifest (md/html/json si présent) sauf si désactivé.

## Valider les artefacts produits
- Script : `python3 scripts/logs_metrics_validate.py --reports reports --suffix status_top2 [--mode full|standard|minimal]`
- `--mode full` (défaut) vérifie la présence des artefacts clés (CSV/JSON/JSONL/MD/HTML/history/trend/trend HTML/index/bundle/summary/stats/stats HTML/anomalies/anomalies HTML/portal/overview md+html/manifeste/checksums) et contrôle la présence de la ligne/entrée `Totals` dans CSV/JSON; échoue si un élément manque ou si summary/stats/trend HTML/anomalies (md/html)/portal/overview sont incomplets. La validation recalcule guard_overall/delta en agrégation par ligne et croise latest vs guard_summary (counts/pct/streaks) pour garantir badge_history → guard_summary → latest.
- `--mode standard` tolère l’absence des rendus HTML optionnels (trend/stats/anomalies/summary/index/overview) mais exige le reste.
- `--mode minimal` ne requiert pas les sorties HTML optionnelles ni le portail/bundle, pratique si la CI a utilisé un profil minimal.
- Pipeline : `logs_metrics_pipeline.sh` accepte `--post-validate` (optionnel) pour lancer la validation en fin de pipeline (`--validate-mode full|standard|minimal`), utile en smoke/CI locale. Les flags `--fail-on-missing-sitemap` et `--sitemap-optional` permettent de faire échouer sur sitemap manquant (voir aussi `make metrics-sitemap-verify` / `python3 scripts/logs_metrics_sitemap_verify.py`).
- CI : `logs_metrics_ci.sh` relaie `--post-validate/--validate-mode` vers la pipeline et peut lancer la validation après le bundle/compare. Le run summary est alors produit automatiquement.
- Vérification sitemap : `python3 scripts/logs_metrics_sitemap_verify.py --reports reports --sitemap reports/log_metrics_sitemap.json [--manifest reports/log_metrics_manifest.json] [--optional compare_md,compare_html,checksums_guard] [--strict-summary]` échoue si des artefacts requis manquent (appelé par `make metrics-sitemap-verify` et `make metrics-quick-check`) ; `--optional` autorise un override ponctuel des artefacts ignorés et la vérification recalcule les manquants à partir du manifest si présent, en émettant un warning si les totaux sitemap vs manifest divergent (échec seulement avec `--strict-summary`). `make metrics-sitemap-verify` comprend `SITEMAP_OPTIONAL=...` / `SITEMAP_STRICT=1`, `metrics_quick_check.sh` accepte `--sitemap-optional` / `--sitemap-strict`, et la pipeline relaie `--sitemap-optional/--sitemap-manifest/--sitemap-strict/--fail-on-missing-sitemap` jusqu’à la vérification.
- Statut condensé : `python3 scripts/logs_metrics_status.py --reports reports [--format json|text]` résume badge/anomalies/overload/guard/checksums/validation/compare/sitemap/manifest; utilisé par `make metrics-status` et `metrics_quick_check.sh`.

## Exporter en JSONL pour ingestion
- Script : `python3 scripts/logs_metrics_snapshot_to_jsonl.py --input reports/log_metrics_snapshot.status_top2.csv --output reports/log_metrics_snapshot.status_top2.jsonl`
- Convertit le CSV (avec Totals) en JSONL (un objet par ligne) pour ingestion dans des pipelines ou SIEM, en conservant la ligne `Totals` comme enregistrement séparé.

## Générer un manifest JSON
- Script : `python3 scripts/logs_metrics_manifest.py --reports reports --suffix status_top2 --output reports/log_metrics_manifest.json`
- Liste tous les artefacts (csv/json/jsonl/md/html/summary/history/trend/stats/anomalies/index/portal/bundle/compare) avec taille/présence et sha256 (désactivable via `--no-sha256`) pour faciliter la diffusion ou la vérification CI.
- Appelé automatiquement par la pipeline (désactivable via `--no-manifest`, hashes via `--no-manifest-hash`).
- La validation recroise le manifest avec les fichiers présents (y compris l’entrée checksums) et compare les sha256 lorsqu’ils sont renseignés.

## Checksums sha256
- Script : `./scripts/logs_metrics_checksums.sh --reports reports --suffix status_top2 --output reports/log_metrics_checksums.txt`
- Génère les SHA256 des artefacts présents (CSV/JSON/JSONL/MD/HTML/summary/trend/stats/anomalies/portal/manifest/bundle/compare si présent) et les enregistre dans `log_metrics_checksums.txt` (intégré au publish/index/portal).
- Vérifier : `python3 scripts/logs_metrics_verify_checksums.py --reports reports --suffix status_top2` recalcule les hashes et contrôle la cohérence avec le manifest/checksums; la pipeline/validation l’appellent par défaut (flag `--no-verify-checksums` pour désactiver).
- L’index md/html référence aussi le fichier de checksums pour faciliter le partage.
- Cibles Makefile rapides : `make metrics` (pipeline), `make metrics-latest` (résumé JSON), `make metrics-ci[-minimal|-standard|-full]`, `make metrics-prune`, `make metrics-validate[-standard|-minimal]`, `make metrics-checksums`, `make metrics-verify-checksums`.

## Historiser les runs
- Script : `python3 scripts/logs_metrics_history.py --input reports/log_metrics_snapshot.status_top2.csv --pattern status --topn 2 --history reports/log_metrics_history.csv`
- Appende dans `reports/log_metrics_history.csv` (run_timestamp, pattern, topn, snapshot_timestamp, log_files_count, status_checks, connections, overloaded, overloaded_ratio) pour suivre l’évolution des exports.
- Le pipeline appelle automatiquement ce script après chaque export.

## Suivre la tendance
- Script : `python3 scripts/logs_metrics_trend.py --history reports/log_metrics_history.csv --last 5 --output reports/log_metrics_trend.md`
- Construit un tableau Markdown des derniers runs (delta vs précédent sur status/connections/overloaded/ratio) pour visualiser l’évolution; appelé automatiquement par le pipeline si l’history existe.
- Version HTML : `python3 scripts/logs_metrics_trend_html.py --history reports/log_metrics_history.csv --last 10 --output reports/log_metrics_trend.html` pour partager le même tableau en HTML (deltas inclus), générée automatiquement par le pipeline sauf si `--no-trend-html` est activé.

## Résumé rapide
- Script : `python3 scripts/logs_metrics_summary.py --input reports/log_metrics_snapshot.status_top2.csv --output reports/log_metrics_snapshot.status_top2.summary.md`
- Version HTML : `python3 scripts/logs_metrics_summary_html.py --input reports/log_metrics_snapshot.status_top2.csv --output reports/log_metrics_snapshot.status_top2.summary.html`
- Génère un mini résumé (md + html) à partir de la ligne Totals pour coller dans un ticket/brief ou intégrer un iframe.

## Statistiques agrégées (min/avg/max/latest)
- Script Markdown : `python3 scripts/logs_metrics_stats.py --history reports/log_metrics_history.csv --output reports/log_metrics_stats.md`
- Script HTML : `python3 scripts/logs_metrics_stats_html.py --history reports/log_metrics_history.csv --output reports/log_metrics_stats.html`
- Les deux sont appelés automatiquement par le pipeline (désactivation possible via `--no-stats` ou `--no-stats-html`) et sont intégrés à la publication, au portail et à l’index HTML.

## Détecter les anomalies entre deux runs
- Script : `python3 scripts/logs_metrics_anomalies.py --history reports/log_metrics_history.csv --output reports/log_metrics_anomalies.md --threshold 20`
- Compare la dernière entrée history avec la précédente et marque une anomalie si une métrique augmente d’au moins `threshold` % ; génère un tableau Markdown (status OK/ANOMALY).
- Version HTML : `python3 scripts/logs_metrics_anomalies_html.py --history reports/log_metrics_history.csv --output reports/log_metrics_anomalies.html --threshold 20`.
- Version JSON : `python3 scripts/logs_metrics_anomalies.py --json-output reports/log_metrics_anomalies.json` (écrit automatiquement dans la pipeline).
- Option stricte : `--strict` retourne un code non nul si des anomalies sont détectées (combinable avec `--anomaly-threshold`).
- Appelé automatiquement par la pipeline (options `--no-anomalies`/`--no-anomalies-html`/`--no-anomalies-json`, `--anomaly-threshold` et `--anomalies-strict`) et intégré au portail/index/publish/validate.

## Badge statut global
- Script : `python3 scripts/logs_metrics_status.py --reports reports [--format json|text] [--optional compare_md,...] [--fail-on-badge warn|alert] [--fail-on-missing] [--allow-alert] [--output reports/log_metrics_status.json]` calcule l’état global (badge + sitemap + manifest) pour l’automatisation/CI.
- Badge SVG : `python3 scripts/logs_metrics_status_badge.py --status-json reports/log_metrics_status.json --output reports/log_metrics_status_badge.svg [--label status] [--gate warn|alert]` synthétise l’overall/badge/anomalies/sitemap/manifest ; intégré à l’index/portal/manifest/checksums/bundle.
- Pipeline : `logs_metrics_pipeline.sh` accepte `--fail-on-overall warn|alert` pour faire échouer le run si l’overall_state (issu de `log_metrics_status.json`) dépasse le seuil (warn ou alert). Utile pour verrouiller une CI stricte sur la santé globale.
- Smoke complet : `bash scripts/metrics_smoke.sh --dir tests/env/logs --reports reports --threshold 60 --prune-keep 5 --sitemap-optional compare_md,compare_html,checksums_guard --fail-on-overall alert [--fail-on-badge warn] [--sitemap-strict]` enchaîne pipeline + quick-check avec les mêmes gates, et sort en erreur si l’état global dépasse le seuil.

## Préparer un bundle de publication
- Script : `./scripts/logs_metrics_publish.sh --reports reports --suffix status_top2 --output reports/log_metrics_bundle.tar.gz`
- Emballe CSV/JSON/MD/HTML + index + history/trend (md+html)/summary/stats/overview (md+html)/portal (et diff s’il existe) dans une archive prête à partager en CI ou par email.
## Dossier snapshots
- Les fichiers générés sont placés sous `reports/`. Le suffixe encode le filtre (`status_top2` par défaut).
- Ces snapshots peuvent être partagés directement (tableur, dashboard, revue) sans relancer le parsing des logs, puisque le helper applique les filtres et affiche un aperçu immédiatement.
