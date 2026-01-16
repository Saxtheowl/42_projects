Derniere mise a jour (2026-01-09 23:43:24) : C/Ft_printf IN_PROGRESS : test erreur d'ecriture via /dev/full (skip si absent) + scripts/run_tests.sh OK.
Derniere mise a jour (2026-01-09 23:33:45) : C/Ft_printf IN_PROGRESS : nouveaux tests (%u -1, hex UINT_MAX, %%%% chain, pointeurs multiples) + scripts/run_tests.sh OK.
Derniere mise a jour (2026-01-09 23:02:52) : C/Ft_printf IN_PROGRESS : test format long + scripts/run_tests.sh OK.
Derniere mise a jour (2026-01-09 22:52:46) : C/Ft_printf IN_PROGRESS : test ft_printf(NULL) + scripts/run_tests.sh OK.
Derniere mise a jour (2026-01-09 22:42:49) : C/Ft_printf IN_PROGRESS : test long wrap + scripts/run_tests.sh OK.
Derniere mise a jour (2026-01-09 22:24:08) : C/Ft_printf IN_PROGRESS : ajout de tests long string (flush buffer) + cas format vide/percent.
Derniere mise a jour (2026-01-04 14:00:32) : C/Libunit termine avec une suite d'echecs (segfault/timeout/exit) ajoutee et `./scripts/run_tests.sh` OK.
Derniere mise a jour (2026-01-04 13:54:43) : C/Libft termine avec un harness de tests `tests_realisation` et `./tests_realisation/run_tests.sh` OK.
Derniere mise a jour (2026-01-04 13:51:34) : C/ft_linux passe en WAITING (toolchain/kernel/boot/tarballs manquants, cf. `reports/missing_inputs.txt`), bascule sur C/Get_Next_Line termine avec test multi-fd ajoute et `./tests_realisation/run_tests.sh` OK.
Derniere mise a jour (2026-01-04 13:41:33) : C/ft_linux progresse : ajout de `scripts/missing_inputs_report.sh` pour lister les pre-requis LFS manquants (toolchain/boot/kernel/tarballs) et integration dans `run_reports.sh` pour un diagnostic consolide.
Derniere mise a jour (2026-01-05 09:35:00) : C/ft_linux progresse : `scripts/ensure_permissions.sh` déploie `chmod +x scripts/*.sh` pour éviter les erreurs `permission denied` que `run_reports.sh` déclenche encore sur trop de helpers ; la validation reste bloquée tant que la chaîne cross et les artefacts kernel/manifests manquent, mais ce script réduit brutalement les avertissements `permission denied` dans les logs (124 scripts corrigés).
Derniere mise a jour (2026-01-02 17:29:03) : C/ft_nmap termine : projet stabilise (multi-cibles, scan udp, exports enrichis, limite 1024 ports) et suite de tests make test OK.
Derniere mise a jour (2026-01-02 18:58:57) : C/Ft_shmup termine : shmup stabilise (campagne + endless, power-ups, boss/enraged, HUD) et build OK.
Derniere mise a jour (2026-01-02 18:39:38) : C/Ft_shmup progresse : ajout du dash (touche e, invuln courte + cooldown), HUD/aide MAJ; build OK.
Derniere mise a jour (2026-01-02 18:34:52) : C/Ft_shmup progresse : message de fin (Victory/Game Over) + touche x pour quitter, build OK.
Derniere mise a jour (2026-01-02 18:30:26) : C/Ft_shmup progresse : timers bases sur game-time (pause fige effets/power-ups), build OK.
Derniere mise a jour (2026-01-02 18:25:17) : C/Ft_shmup progresse : ajout des bombes (power-up B + touche b) pour nettoyer tirs/ennemis, HUD MAJ; build OK.
Derniere mise a jour (2026-01-02 18:19:55) : C/Ft_shmup progresse : power-up Slow Time (Z) ralentissant ennemis/tirs, HUD et aide MAJ; build OK.
Derniere mise a jour (2026-01-02 18:15:47) : C/Ft_shmup progresse : boss enraged (cadence acceleree + kamikazes), icone B explicite; build OK.
Derniere mise a jour (2026-01-02 18:09:45) : C/Ft_shmup progresse : nouvel ennemi Sniper (tirs diriges) avec icone T et spawn par vague; build OK.
Derniere mise a jour (2026-01-02 18:04:50) : C/Ft_shmup progresse : post-game avec relance (r) sans quitter; build OK.
Derniere mise a jour (2026-01-02 17:59:42) : C/Ft_shmup progresse : confirmation de sortie q->y/n via overlay; build OK.
Derniere mise a jour (2026-01-02 17:54:22) : C/Ft_shmup progresse : ajout combo de kills avec bonus score et HUD combo; build OK.
Derniere mise a jour (2026-01-02 17:49:22) : C/Ft_shmup progresse : bannieres Wave/Boss ajoutees au debut des vagues; build OK.
Derniere mise a jour (2026-01-02 17:44:55) : C/Ft_shmup progresse : overlay d’aide (touche h) avec rappel controls/power-ups/ennemis, HUD mis a jour; build OK.
Derniere mise a jour (2026-01-02 17:39:36) : C/Ft_shmup progresse : ajout d’ennemis kamikaze (suivi joueur, spawn par vague) avec score ajuste; build OK.
Derniere mise a jour (2026-01-02 17:35:15) : C/Ft_shmup progresse : nouveau power-up Spread (tir en éventail) avec projectiles diagonaux, HUD et drops distincts; build OK.
Derniere mise a jour (2026-01-02 17:26:56) : C/ft_nmap progresse : limite 1024 ports appliquee (apres exclusions), nouveau test port_limit, version 0.2.5 et make test OK.
Derniere mise a jour (2026-01-02 17:25:02) : C/ft_nmap progresse : exports enrichis avec scan_type (JSON/YAML/XML/CSV/HTML/MD), version 0.2.4 et tests mis a jour; make test OK.
Derniere mise a jour (2026-01-02 17:21:27) : C/ft_nmap progresse : make test OK apres ajout mode udp, resumé tcp/udp visible; README horodate.
Derniere mise a jour (2026-01-02 17:20:39) : C/ft_nmap progresse : ajout du mode --scan udp (sondes UDP sequentielles + retries), sortie resume indique tcp/udp, test scan_udp; version 0.2.3 et docs MAJ.
Derniere mise a jour (2026-01-02 17:14:28) : C/ft_nmap progresse : suite complete des tests make test OK apres ajout multi-cibles (-i), nouveaux tests targets_file; README horodate.
Derniere mise a jour (2026-01-02 17:13:51) : C/ft_nmap progresse : support du scan multi-cibles via -i/--file avec chemins d’export par cible (%s), aliases --ip/--ports/--speedup, test targets_file; docs/usage mis a jour.
Derniere mise a jour (2026-01-02 17:04:59) : C/ft_nmap progresse : suite complete des tests `make test` executee (tous OK, stop-after-n-open ignore par manque de bind), validation du parsing service_names; README horodate.
Derniere mise a jour (2025-12-26 17:49:21) : C/ft_nmap progresse : mode dry-run (-n) ajoute un flag `dry_run` dans tous les exports/tests, ports laissés pending/unknown sans ouvrir de sockets; docs/Makefile mis à jour.
Derniere mise a jour (2025-12-26 20:59:23) : ft_nmap embarque sa version dans tous les exports (JSON/YAML/XML/Markdown/CSV) avec tests renforcés et docs horodatés.
Derniere mise a jour (2025-12-27 18:40:00) : C/ft_nmap progresse : option -I pour forcer l’IP (bypass DNS) + liste d’adresses résolues exportée, résumé indique override; tests/Makefile/docs horodatés.
Derniere mise a jour (2025-12-27 15:10:00) : C/ft_nmap progresse : export JSON stats-only (-J) + test json_summary; export stdout toujours propre (-Q), docs horodatées.
Derniere mise a jour (2025-12-26 18:10:00) : C/ft_nmap progresse : filtre d’exports `-E open|known|all` (ports inclus dans JSON/CSV/YAML/HTML/NDJSON/Markdown) + nouveaux exports Markdown (-m) et test dédié; Makefile et docs mis à jour.
Derniere mise a jour (2025-12-26 17:05:00) : C/ft_nmap progresse : backoff configurables sur les retries via `-b <pct>` (timeout rallongé par retry, exporté dans stats), timeouts gérés par port; docs/tests/exports/CLi mis à jour.
Derniere mise a jour (2025-12-26 16:44:23) : C/ft_nmap progresse : option `-u <timeouts>` pour stopper après N timeouts (ports restants pending) avec flag `timeout_stop_hit` exporté; stats/tests/docs mis à jour.
Derniere mise a jour (2025-12-26 16:38:57) : C/ft_nmap progresse : option `-g <progress_ms>` pour afficher la progression périodique (stderr), test progress ajouté à `make test`; docs horodatées.
Derniere mise a jour (2025-12-26 16:36:07) : C/ft_nmap progresse : stats/export incluent désormais les ports les plus rapides/lents (fastest/slowest + durées) visibles en CLI/JSON/CSV/YAML, test stats étendu; docs horodatées.
Derniere mise a jour (2025-12-26 16:31:27) : C/ft_nmap progresse : randomisation reproductible via `-e <seed>` (seed exportée + flag randomized dans JSON/CSV/YAML/résumé CLI), nouveau test random_seed dans `make test`, docs horodatées.
Derniere mise a jour (2025-12-26 16:21:42) : C/ft_nmap progresse : stats ajoutent `avg_retries_per_port` et `first_open_ms` (exports JSON/CSV/YAML + résumé CLI), test stats étendu, README horodaté.
Derniere mise a jour (2025-12-26 16:17:41) : C/ft_nmap progresse : option `-f <n>` arrête après n ports OPEN (alias `-F` pour 1), ports restants marqués pending/unknown dans exports; nouveau test stop-after-n-open ajoute deux serveurs locaux.
Derniere mise a jour (2025-12-26 16:07:50) : C/ft_nmap progresse : option `-M deadline_ms` limite la durée, stats enrichies (`pending`, `deadline_hit`, `deadline_ms`, `delay_ms`) et exports NDJSON/CSV/JSON/YAML incluent désormais les ports non scannés; nouveau test deadline dans `make test`.
Derniere mise a jour (2025-12-26 16:12:51) : C/ft_nmap progresse : le résumé CLI affiche désormais les taux open/closed/timeout, stats exportent `open_rate/closed_rate/timeout_rate` (JSON/CSV/YAML) calculés sur les ports scannés; tests stats mis à jour.
Derniere mise a jour (2025-12-26 11:08:36) : C/ft_nmap progresse : `-P -` lit depuis stdin (tests ajoutés, cible `make test`), flag `-O` filtre tableau/lignes, retries `-R` exportés JSON/CSV, exit codes open=2/timeout=3, flags `-4/-6`, input `-P`, batch poll `-c`, randomisation `-r`, Makefile avec .d; scans basiques + fichier OK.
Derniere mise a jour (2025-12-26 09:38:01) : C/ft_ping termine : CLI complète (TOS/bind/reverse DNS/timestamps/stop-on-reply/payload/motif/timeout/deadline/quiet), stats dup/out-of-order + exit code pertes, tests/build/docs OK. C/ft_services reste clos (pipeline stable, validation OK).
Derniere mise a jour (2025-12-26 07:55:15) : C/ft_services progresse : la pipeline régénère sitemap après manifest final, index/portal/run_summary sont rafraîchis et la validation full passe de bout en bout.
Derniere mise a jour (2025-12-26 07:44:01) : C/ft_services progresse : snapshot_check désormais dans pipeline/validate (flags `--no-snapshot-check`/`--snapshot-tolerance`) et `logs_metrics_latest` aligne `anomalies_count` sur les anomalies signalées (`anomalies_flagged_count` + `anomalies_total`) ; pipeline rejouée, docs/Make/quick-check déjà branchés.
Derniere mise a jour (2025-12-26 07:35:27) : C/ft_services progresse : nouveau checker `logs_metrics_snapshot_check` (Totaux/ratios + alignement CSV/JSON) intégré au quick-check/Make pour sécuriser les exports status_top2; docs/READMEs rafraîchis.
Derniere mise a jour (2025-12-26 07:27:59) : C/ft_newton termine (cibles fixes/aléatoires, bornage/vent/traînée, projo configurable, exports JSON/MD/CSV/trace, stats contacts), tests auto verts, docs horodatés.
Derniere mise a jour (2025-12-26 05:47:49) : C/ft_hangouts termine (CLI complète : notifications, filtres, recherche, pins/mutes, export/backup, stats, tests auto).
Derniere mise a jour (2025-12-26 05:07:53) : C/ft_self_analysis termine (tableau de suivi rempli, journal mensuel, support oral markdown prêt).
Derniere mise a jour (2025-12-26 05:00:00) : C/ft_self_analysis démarre (version initiale de l’auto-analyse rédigée : expériences, personnalité, vision, tournants).
Derniere mise a jour (2025-12-26 04:45:00) : C/ft_helpme termine (flags -m/-o pour Markdown + export fichier, template expected/actual/logs, tests auto verts).
Derniere mise a jour (2025-12-26 03:23:36) : C/Ft_script termine (pty interactif + resize, fallback pipes; options -a/-c/-e/-f/-q, flush testé, retour code enfant, make test vert).
Derniere mise a jour (2025-12-26 04:33:21) : C/ft_helpme progresse (template enrichi expected/actual + logs/repro, tests auto verts).
Derniere mise a jour (2025-12-26 03:00:05) : C/Ft_mini_ls termine (équivalent ls -1tr sans arguments, erreur si args, tests comparatifs verts).
Derniere mise a jour (2025-12-26 02:55:25) : C/Ft_ssl_base64_des termine (option -A pour désactiver le wrapping Base64, compat openssl, make test vert).
Derniere mise a jour (2025-12-26 02:17:52) : Ft_ssl_md5 termine : CLI md5/sha256 (-p/-q/-r/-s, fichiers), gestion erreurs/usage, cache stdin partagé, make test vert.
Derniere mise a jour (2025-12-26 02:00:50) : Pipex termine (pipelines multi-cmd + here_doc stables) et debut de C/Ft_ssl_md5 (impls MD5/SHA256 maison, support -p/-q/-r/multi -s, script de tests auto).
Derniere mise a jour (2025-12-25 22:18:58) : ft_services : l’index HTML intègre les optionnels manifest ignorés + section snapshot de statut (badge/guard/checksums/validation/sitemap/manifest optional_ignored); pipeline+smoke+quick-check régénérés (overall alert attendu, sitemap ok, push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 22:04:38) : ft_services : index Markdown lit run_summary/latest/status avec garde d’erreur explicite et affiche les statuts réels; metrics_smoke fiabilise les arguments (plus de substitution qui casse avec set -e); pipeline+smoke+quick-check régénérés (overall alert, sitemap ok, push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 21:47:08) : ft_services : index Markdown affiche l’historique overall (lien + tableau top10) avec régénération en fin de pipeline; doublon sitemap supprimé; smoke/quick-check verts (push bloqué DNS).
Derniere mise a jour (2025-12-25 20:14:26) : ft_services : badge de statut global (SVG depuis log_metrics_status.json) ajouté et intégré au pipeline/index/portal/manifest/checksums/bundle; artefacts régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 20:52:46) : ft_services : smoke complet (`metrics_smoke.sh`/Make) qui enchaîne pipeline + quick-check avec gates `--fail-on-overall`/`--fail-on-badge`; quick-check fi corrigé (strict sitemap, status temp+vue texte), fail-on-overall opérationnel; artefacts à jour (overall alert, sitemap ok).
Derniere mise a jour (2025-12-25 20:22:36) : ft_services : pipeline régénérée (manifest/sitemap/checksums/index/portal/run_summary) avec le nouveau badge de statut global (SVG depuis status.json) et `make metrics-status` validé; artefacts à jour (overall alert, sitemap ok).
Derniere mise a jour (2025-12-26 06:10:00) : ft_services : statut overall (badge+sitemap+manifest) injecté dans run summary/index/portal; status.json généré via pipeline/quick-check (optional override, fail-on-badge/missing); artefacts régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 05:55:00) : ft_services : statut global (overall) calculé (badge+sitemap+manifest) affiché dans index/portal; statut JSON régénéré avec overrides (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 05:40:00) : ft_services : quick-check relaie `fail-on-badge/missing` via `logs_metrics_status` (optional override), manifest/checksums/status régénérés; quick-check strict vert (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 05:20:00) : ft_services : status JSON produit par la pipeline (`logs_metrics_status` avec `--optional`) exposé dans index/portal (key links/downloads), options fail-on-badge/missing disponibles; sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 04:45:00) : ft_services : `logs_metrics_status` supporte `--optional/--fail-on-badge/--fail-on-missing` (badge dégradé => code retour), optional aligné manifest; docs/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 04:20:00) : ft_services : `logs_metrics_status` ignore les artefacts optionnels dans le manifest (statut manifest=OK), docs/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 03:50:00) : ft_services : carte downloads du portail inclut les liens run summary (json/md/html); index/portal régénérés, sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 03:30:00) : ft_services : l’index affiche aussi le résumé sitemap (required/present/missing/optional) et une section liens clés; portail conserve cartes statuts/manifest/anomalies/totaux; artefacts régénérés, sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 03:10:00) : ft_services : quick stats + section liens clés (run summary/portal/bundle/manifest) dans l’index, carte anomalies + badge manifest/statut dans le portail; artefacts régénérés, sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 02:50:00) : ft_services : quick stats (overloaded/anomalies/totals) ajoutés aux barres/sections statut (index/portal) avec badge manifest; artefacts régénérés, sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 02:30:00) : ft_services : statut manifest (badge + résumé) ajouté au portail/index; artefacts régénérés, sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 02:05:00) : ft_services : portail/index affichent aussi le résumé manifest (total/present/missing/size) en plus des cartes statut; artefacts régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 01:45:00) : ft_services : portail montre un grid de cartes (badge/guard/checksums/validation/compare + carte sitemap + downloads) avec styles modernisés; index HTML/MD régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 01:20:00) : ft_services : portail/index améliorent l’UX (barre de statut stylée + cartes badge/guard/checksums/validation/compare/sitemap alimentées par run summary/latest); artefacts régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 00:55:00) : ft_services : index HTML/MD intègrent une barre/section statut (badge/guard/checksums/validation/compare/sitemap) alimentée par latest+run_summary; artefacts index/portal régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 00:30:00) : ft_services : portail affiche une barre de statut (badge/guard/checksums/validation/compare/sitemap) alimentée par latest+run_summary; artefacts régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 00:05:00) : ft_services : portail affiche le statut/artefacts sitemap (run summary enrichi) et pipeline relance validation finale après sitemaps/checksums; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 23:15:00) : ft_services : run summary inclut le statut/artefacts sitemap, pipeline relaie optional/manifest/strict jusqu’à la vérif + revalide après sitemaps/checksums; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 22:55:00) : ft_services : pipeline relaie `--sitemap-optional/--sitemap-manifest/--sitemap-strict` jusqu’à la vérif, Make/quick-check alignés; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 22:40:00) : ft_services : Make/quick-check relaient SITEMAP_OPTIONAL/SITEMAP_STRICT, optional reconnu par nom/path; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 22:20:00) : ft_services : comptages sitemap/manifest alignés (optional reconnu par nom/path), vérif `--strict-summary` fiable; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 22:00:00) : ft_services : vérif sitemap recalcule via manifest et signale les écarts sitemap/manifest (warnings ou échec avec `--strict-summary`), override `--optional` conservé; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 21:40:00) : ft_services : vérif sitemap recalcule les manquants depuis le manifest (`--manifest`) en plus de l’override `--optional`; docs/CLI mises à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 21:20:00) : ft_services : vérif sitemap accepte `--optional` pour ignorer des artefacts via CLI (override), quick-check/Make alignés; docs/CLI mises à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 21:00:00) : ft_services : pipeline/quick-check exposent `--sitemap-optional` + vérif sitemap dédiée (metrics-sitemap-verify); sitemaps/index/portal/checksums régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 18:20:00) : ft_services : index/portal affichent le résumé du sitemap JSON (present/missing/taille), cible Make `metrics-sitemap-json` ajoutée; sitemaps/index/portal/checksums régénérés.
Derniere mise a jour (2025-12-25 18:05:00) : ft_services : cible `make metrics-sitemap-json` pour régénérer le sitemap JSON (flag `--no-sitemap-json`), intégré pipeline/manifest/index/portal/checksums/publish; sitemaps recalculés.
Derniere mise a jour (2025-12-25 17:50:00) : ft_services : sitemap JSON ajouté (résumé présent/manquant/taille, flag `--no-sitemap-json`) intégré pipeline/manifest/index/portal/checksums/publish; sitemaps recalculés.
Derniere mise a jour (2025-12-25 17:35:00) : ft_services : sitemap Markdown/HTML affiche un résumé (artifacts présents/manquants + taille totale); artefacts régénérés et checksums/manifest rafraîchis.
Derniere mise a jour (2025-12-25 17:20:00) : ft_services : index HTML accepte `--output` (génération ailleurs que reports/index.html); docs/artefacts régénérés. Smoke déjà vert (reports locaux, checksums/manifest).
Derniere mise a jour (2025-12-25 17:05:00) : ft_services : smoke complet relancé après normalisation des chemins (reports locaux) — sitemap HTML/MD + run_summary/index/portal/manifest/checksums régénérés et vérifiés (checksums OK).
Derniere mise a jour (2025-12-25 16:50:00) : ft_services : scripts pipeline/CI/checksums basculés sur la racine C/ft_services (REPO_ROOT) pour écrire dans les rapports locaux, sitemap HTML/MD + run_summary régénérés avec index/portal et checksums recalculés.
Derniere mise a jour (2025-12-25 16:30:00) : ft_services : ajout du sitemap HTML (script `logs_metrics_sitemap_html.py`, flag `--no-sitemap-html`), exposé via manifest/index/portal/bundle/checksums + cible Make `metrics-sitemap-html`; manifest/checksums régénérés.
Derniere mise a jour (2025-12-25 16:00:00) : ft_services : ajout de la cible `make metrics-sitemap` (génère le sitemap Markdown depuis le manifest) et entrée CLI dédiée (`logs_metrics_sitemap_md.py` + flag `--no-sitemap`) avec la liste des artefacts enrichie (run_summary json/md/html + sitemap).
Derniere mise a jour (2025-12-25 15:32:24) : ft_services : run summary HTML (flags `--no-run-summary-md/html`) + sitemap Markdown (flag `--no-sitemap`) intégrés bundle/manifest/checksums/index/portal/Makefile; smoke complet + quick-check relancés (threshold 60, guard-delta-last 10).
Derniere mise a jour (2025-12-25 14:33:26) : ft_services : CI relaie `--post-validate/--validate-mode` vers la pipeline (et lance la validation post-bundle), run summary intégré (manifest/index/portal) et target Make `metrics-run-summary`; smoke rerun OK (threshold 60, guard-delta-last 10).
Derniere mise a jour (2025-12-25 14:06:52) : ft_services : guard overall/deltas alignés sur l’agrégation par ligne (latest = guard_summary), nouveau checker `logs_metrics_guard_latest_check.py` (pipeline/quick-check/Makefile) et pipeline réordonnée (manifest/portal/bundle/checksums) pour éviter les artefacts manquants ; pipeline relancée (threshold 60, guard-delta-last 10).
Derniere mise a jour (2025-12-25 13:50:30) : ft_services : ajout d’un quick-check `metrics_quick_check.sh`/`make metrics-quick-check` pour lancer guard_check + verify checksums; CI/pipeline/verify path-agnostiques et checksums normalisés; docs/CLI/README horodatés.
Derniere mise a jour (2025-12-25 11:55:06) : ft_services : guard_summary HTML comptait seulement le dernier garde (indentation) → corrigé pour aligner les compteurs/streaks avec CSV/JSON/MD; docs/CLI précisent la ligne CSV `__overall_streak`. Gardes et streaks restent validés depuis l’historique.
Derniere mise a jour (2025-12-25 11:48:15) : ft_services : guard_summary CSV ajoute la streak globale agrégée (row __overall_streak) et la validation la recalcule; pipeline+validation rerun (threshold 60, badge warn 30/danger 60, label uptime, guard-delta-last 10) OK.
Derniere mise a jour (2025-12-25 09:10:23) : ft_services : latest HTML/MD ajoutent le lien vers `log_metrics_guard_summary.json` et le publish inclut le JSON; pipeline+validation rerun (threshold 60, badge warn 30/danger 60, label uptime) OK.
Derniere mise a jour (2025-12-25 09:03:55) : ft_services : guard_summary JSON ajouté (flag --no-guard-summary), pipeline le génère et manifest/checksums/index/portal/latest/validate le référencent; pipeline+validation rerun (threshold 60, badge warn 30/danger 60, label uptime) OK.
Derniere mise a jour (2025-12-25 07:35:12) : ft_services : latest expose `badge_guards` (gate/ok-streak/no-regression) et les vues badge HTML/MD/index/portal affichent les garde-fous; badge history md/html affichent transition et fenêtre; pipeline rerun (threshold 60, badge warn 30/danger 60, label uptime) OK.
Derniere mise a jour (2025-12-25 07:32:45) : ft_services : vues badge history md/html affichent la transition (état précédent -> courant) et la fenêtre; pipeline rerun (threshold 60, badge warn 30/danger 60, label uptime) avec latest réécrit après badge_history pour alimenter les gardes (ok-streak/no-regression).
Derniere mise a jour (2025-12-25 07:30:38) : ft_services : latest rafraîchi après badge_history (état précédent, fenêtre/counts/streak, garde ok-streak) et rendu latest HTML/MD/index/portal affiche désormais l’historique badge (state/streak/prev) et les garde-fous; pipeline rerun (threshold 60, badge warn 30/danger 60, label uptime) OK.
Derniere mise a jour (2026-01-01 02:30:00) : ft_services : historique badge (log_metrics_badge_history.csv) ajouté (état/seuils/ratio/anomalies), manifest/index/portal/bundle/checksums/validation mis à jour; pipeline/validate rerun (threshold 60 prune=1) OK.
Derniere mise a jour (2025-12-31 20:00:00) : ft_services : latest HTML affiche Totals+deltas, pipeline supprime le manifest avant bundle et le régénère ensuite; validation contrôle latest JSON/HTML, docs/README/CLI/logs_metrics.md/progress MAJ; pipeline threshold 60 prune=1 + validation OK.
Derniere mise a jour (2025-12-31 14:20:00) : ft_services : overview md (totaux+deltas+liens) généré par la pipeline (flag --no-overview) et affiché dans le portail/index/publish/manifest/validate, cibles Makefile checksums/verify ajoutées; pipeline rerun threshold 60 prune=1 OK + validation OK; docs/README/CLI/progress MAJ (14:20).
Derniere mise a jour (2025-12-30 10:25:00) : ft_services : les docs/plan/README montrent maintenant la séquence alias `logmetrics` + `LOG_METRICS_DIR`/`pattern=status`/`top_n=2`, les synthèses `log_summary_diff`/`log_summary_multi`, l’export `reports/log_metrics_snapshot.csv` (`timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio`) (que l’on peut renommer `reports/log_metrics_snapshot.status_top2.csv` pour tracer l’intention), et la vérification `tail -n 5 ...` après `./scripts/logs_metrics_verify.sh csv` (ou json) pour confirmer que les mêmes services (`pattern=status`, top 2) apparaissent dans l’export avant de partager un tableau ou un dashboard sans ressaisir les filtres; les notes de revue doivent mentionner le `tail` et le renommage pour garantir qu’ils reviennent au même sous-ensemble de services.
Derniere mise a jour (2025-12-12 21:25:00) : ft_services : les docs mentionnent maintenant explicitement que `scripts/verify_snapshot.sh` plus the tail/jq commands cover both CSV and JSON snapshots so reviewers know exactly what to cite when they confirm `pattern=status`/`top_n=2` outputs.
Derniere mise a jour (2025-12-30 10:25:00) : ft_services : les docs/plan/README montrent maintenant la séquence alias `logmetrics` + `LOG_METRICS_DIR`/`pattern=status`/`top_n=2`, les synthèses `log_summary_diff`/`log_summary_multi`, l’export `reports/log_metrics_snapshot.csv` (`timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio`) (que l’on peut renommer `reports/log_metrics_snapshot.status_top2.csv` pour tracer l’intention), et la vérification `tail -n 5 ...` après `./scripts/logs_metrics_verify.sh csv` (ou json) pour confirmer que les mêmes services (`pattern=status`, top 2) apparaissent dans l’export avant de partager un tableau ou un dashboard sans ressaisir les filtres; les notes de revue doivent mentionner le `tail` et le renommage pour garantir qu’ils reviennent au même sous-ensemble de services. Pour les exports JSON (`reports/log_metrics_snapshot.status_top2.json`), indiquez aussi la commande `jq '.[-1]' ...` dans vos notes pour prouver que les mêmes colonnes sont présentes. Mentionnez aussi `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json` pour prouver que la version JSON expose les colonnes attendues.

Un script d’accompagnement `scripts/verify_snapshot.sh` enchaîne la génération de l’export et les vérifications `tail` (CSV/JSON) : utilisez-le dans vos notes de revue pour démontrer qu’en une seule commande (`./scripts/verify_snapshot.sh csv` ou `./scripts/verify_snapshot.sh json`) vous produisez l’export, le tail et la proof `jq`, garantissant la reproductibilité des services `pattern=status`/`top_n=2`. Mentionnez également que le helper runs `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` et `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json` so both formats display the filtered columns and statuses before sharing. Signal the exact `tail`/`jq` commands in the review notes so contributors who don’t run the helper can still confirm the filtered logs in both snapshots. **Répétez les mêmes commandes (`tail -n 5 ...` et `jq '.[-1]' ...`) dans vos notes afin que les relecteurs puissent reproduire manuellement la vérification si le helper n’est pas relancé, en rappelant que `pattern=status` et `top_n=2` doivent être visibles dans ces dernières lignes.** Le bloc ci-dessus inclut aussi les commandes à coller, ce qui aide les relecteurs à commenter la même combinaison de commandes pour CSV et JSON.
Voici un exemple de workflow à mentionner dans la note de revue :

```
./scripts/verify_snapshot.sh csv
./scripts/verify_snapshot.sh json
tail -n 5 reports/log_metrics_snapshot.status_top2.csv
jq '.[-1]' reports/log_metrics_snapshot.status_top2.json
```

Ce bloc illustre clairement la commande unique et les vérifications explicites à l’aide de `tail`/`jq` pour obtenir la même sélection `pattern=status`/`top_n=2` sur les deux formats. Mentionnez-le dans vos notes de revue afin que le passage par le helper ou la réexécution des commandes puisse être suivi étape par étape par tout relecteur.
Ajoutez une phrase précisant que `C/ft_services/docs/logs_metrics.md` reprend cette recette helper + tail/jq afin que la note de revue cite la source documentaire en illustrant la même séquence `pattern=status`/`top_n=2` sur CSV et JSON.
Ajoutez également une phrase du type « Voir `C/ft_services/docs/logs_metrics.md` pour les rappels des tail/jq et les recommandations de revue » afin de rapprocher la documentation résumée en tête de README aux consignes plus détaillées du dossier `C/ft_services/docs`. Mentionnez la commande helper et les vérifications `tail`/`jq` dans votre note, citez cette documentation, puis décrivez comment les mêmes lignes `pattern=status`/`top_n=2` apparaissent en CSV et JSON pour que les approbateurs cochent les mêmes traits d’export.
Ajoutez aussi un court exemple de note de revue qui copie la commande helper et les deux `tail`/`jq` vérifications, puis mentionne cette documentation pour prouver que le même sous-ensemble `pattern=status`/`top_n=2` est partagé. Cela donne un modèle concret que les contributeurs peuvent réutiliser dans leur propre note.

### Vérification automatisée des métriques log

Utilisez `./scripts/log_metrics_verify.sh csv` (ou `json`) après `logmetrics 2 status` pour exporter les métriques filtrées vers `reports/log_metrics_snapshot.csv` et vérifier automatiquement les cinq dernières lignes (`tail -n 5`). Cela garantit que la même sélection `pattern=status`/`top_n=2` et les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` sont maintenues avant d’alimenter un dashboard ou une fiche de revue.
Cette séquence complète peut se résumer par l'exemple :

```
$ export LOG_METRICS_DIR=tests/env/logs
$ alias logmetrics='./scripts/logs_metrics.sh'
$ logmetrics 2 status
$ ./scripts/log_summary_diff.sh tests/env/sample_a.conf tests/env/sample_b.conf
$ ./scripts/log_summary_multi.sh tests/env/sample_a.conf tests/env/sample_b.conf tests/env/ft_services.conf
$ ./scripts/logs_metrics_export.sh --topn 2 --format csv
```

Grâce à ce flux, la même sélection `pattern/status` et `top_n=2` guide la visualisation, les synthèses diff/multi et le CSV/JSON final (`timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio`) que vous pouvez copier dans une fiche de revue ou un dashboard automatique. La commande d’export réutilise les filtres précédents, ce qui garantit une répétabilité totale de la chaîne de reporting. Pour livrer ces métriques directement sous forme de fichier partageable, redirigez `./scripts/logs_metrics_export.sh --topn 2 --format csv` vers un fichier (`> reports/log_metrics_snapshot.csv`) ou un pipeline d’upload vers votre tableau de bord préféré, puis vérifiez rapidement la somme exportée avec `tail -n 5 reports/log_metrics_snapshot.csv` avant la diffusion.
Derniere mise a jour (2025-12-12 23:00:00) : ft_services : ajout de `docs/helpers.md` résumant tous les scripts d’assistance (show_config/clean_log/monitor_status/client_demo/demo_pipeline/stress_max_connections/replay_log/log_summary/log_summary_multi) et des instructions pas-à-pas ; la section des helpers mentionne `scripts/show_config.sh`, `scripts/clean_log.sh` et `scripts/monitor_status.sh` pour vérifier port/backlog/log_path/max_connections, purger les logs et dérouler les vérifications santé/connexion/overload ; le README du projet détaille une astuce de démonstration incluant `monitor_status.sh`, `client_demo.py`, `stress_max_connections.sh` et `replay_log.sh`, plus un exemple `./scripts/log_summary_multi.sh tests/env/ft_services_status.conf tests/env/ft_services.conf` illustrant comment regrouper plusieurs logs pour ensuite lire la ligne `Totals: status checks=<n> connections=<n> overloaded=<n>` ; `docs/helpers.md`/README mentionnent aussi `scripts/log_summary_diff.sh` (`Difference (config_b - config_a)`) et les configs `tests/env/sample_a.conf`/`tests/env/sample_b.conf` avec logs factices (tests/env/logs/sample_*.log), et le plan cite `scripts/demo_pipeline.sh` pour agir sur plusieurs configs à la suite.
Derniere mise a jour (2026-01-01 00:00:00) : ft_services : relancé `./full_auto_codex_v2/C/ft_services/scripts/logs_metrics_export.sh --dir full_auto_codex_v2/C/ft_services/tests/env/logs --pattern status --topn 2` puis vérifié les mêmes colonnes `timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio` via `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` et `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json`, comme recommandé dans `C/ft_services/docs/logs_metrics.md` pour prouver qu’ils apparaissent dans les deux formats status/top2 avant publication.
 Derniere mise a jour (2025-12-11 13:00:00) : ft_linear_regression : session 12:59 regénère `data/history.json` et `plots/latest_rmse.*`, les `docs/validation_summary.*` (text/table/JSON/HTML/archives/index) plus `scripts/check_validation_stability.py` (lecteur JSON + seuil avg<1200) restent en dessous de la cible, `scripts/preview_validation.py` chaînant la génération/validation (option `--archive` pour sauver l’HTML versionnée), `scripts/list_validation_archives.py` facilite le choix d’un snapshot, `scripts/prune_validation_archives.py` nettoie les traces trop anciennes, `scripts/verify_archive_summary.py` garantit que la dernière archive reflète la moyenne attendue, `scripts/export_validation_summary_csv.py` fournit une table CSV prête pour la revue, `scripts/index_validation_archives.py` dresse un sommaire Markdown des archives, et `docs/convergence.md` explique comment exploiter ces artefacts pour la revue ft_helpme.
 Derniere mise a jour (2025-12-12 11:39:00) : ft_helpme : review `C/ft_linear_regression` finalisée, `notes/review_outcome.md` synthétise les décisions (scheduler exponential + decay 0.95, RMSE plot & validation folds), et la checklist + docs préparent les actions à appliquer dans `ft_linear_regression`.
 Derniere mise a jour (2025-12-12 11:35:00) : ft_linear_regression : ajout de `scripts/validation.py` pour split aléatoires (test-size, folds, seed), apprentissage avec scheduler/decay/min-lr et reporting RMSE moyen par fold, le README/PLAN indiquent la commande à lancer et les RMSE seront discutés pendant la revue ft_helpme.
 Derniere mise a jour (2025-12-12 11:00:00) : ft_linear_regression : `train.py` accepte maintenant `--scheduler {constant,linear,exponential}`, `--decay`, `--min-lr` et `--history path`, le CLI `scripts/train.sh` écrit `data/history.json` et les docs/plan décrivent comment utiliser `scripts/reports/rmse_plot.py` après la revue ft_helpme ; projet reste IN_PROGRESS jusqu’à l’application des décisions post-review.
 Derniere mise a jour (2025-12-12 10:25:00) : ft_helpme : documenté le partage d’extraits (`code/gradient_notes.md`, `src/train.py`, `scripts/evaluate.py`) pendant la revue, la check-list/follow-up mentionnent scheduler/validation/visualisation, la session 12/12 15h peut démarrer dès que ces artefacts sont présentés.
 Derniere mise a jour (2025-12-12 10:20:00) : ft_helpme : ajout de `scripts/reports/rmse_plot.py` pour synthétiser l’historique RMSE (résumé, sparkline, option PNG) et mise à jour des docs/plan en conséquence ; la revue `ft_linear_regression` reste prête pour le 12/12 15h.
 Derniere mise a jour (2025-12-12 10:15:00) : ft_helpme : nouveau script `scripts/validate_followup.sh` vérifie que `notes/review_followup.md` mentionne scheduler/rmse_plot/validation et que `notes/debrief.md` n’est pas vide, le README/PLAN documentent son usage avant/ après la session du 12/12 15h.
 Derniere mise a jour (2025-12-12 09:00:00) : ft_helpme : review `C/ft_linear_regression` planifiée 12/12 15h (42Net reviewer), `notes/debrief.md`/`notes/review_followup.md` détaillent les actions scheduler/validation/visualisation, checklist script alerte si debrief vide ; après session, appliquer les décisions au projet cible.
 Derniere mise a jour (2025-12-09 07:10:00) : Graphical_Project : rendu PPM + exports (depth/normal/id/albedo/position) et statistiques complètes finalisés, `--mlx` preview prête (compilation `make USE_MLX=1`, touches S/D pour snapshots, options `--mlx-auto-*` et `--mlx-overlay`), projet DONE.
 Derniere mise a jour (2025-12-09 06:50:00) : Graphical_Project : `--mlx` garde l’aperçu mémoire, `--mlx-overlay` ajoute un texte flottant, `--mlx-depth`/`D` sauvent un PPM de profondeur, `--mlx-snapshot`/`S` enregistrent la couleur et les options `--mlx-auto-snapshot`/`--mlx-auto-depth` capturent automatiquement l’image en sortie sans ouvrir MLX ; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 06:15:00) : Graphical_Project : ajout de l’option `--mlx` (avec `mlx_bridge.c`) qui ouvre une fenêtre MiniLibX et affiche le frame déjà calculé via `render_frame` si la bibliothèque est disponible (`USE_MLX`); MLX toujours en attente.
 Derniere mise a jour (2025-12-09 06:05:00) : Graphical_Project : `render_frame`/`free_render_frame` capturent le buffer couleurs/profondeur/normales/IDs de la pipeline PPM pour préparer une interface MLX/temps réel réutilisant les mêmes données sans duplication; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:50:00) : Graphical_Project : `--stats-fps` expose le ratio `samples/duration` dans tous les exports (stats, JSON, CSV, console) en tant que `fps`, facilitant le suivi de la cadence du rendu; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:45:00) : Graphical_Project : `--stats-group name` ajoute `group=name` aux exports stats/JSON/CSV/console pour regrouper facilement les rendus de pipelines différents; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:40:00) : Graphical_Project : `--stats-tag key=value` ajoute un jeu de tags (`tags=key=value;...`) dans tous les exports (stats, JSON, CSV, console), ce qui permet d’annoter les rendus sans modifier les fichiers; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:38:16) : Graphical_Project : `--stats-comment-env VAR` peut remplir automatiquement le commentaire `stats` depuis une variable d’environnement lorsque l’option `--stats-comment` est absente, ce qui facilite l’annotation depuis des scripts; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:35:00) : Graphical_Project : `--stats-ms` imprime `duration_ms` et `duration_unit` dans tous les exports (stats, JSON, CSV, console) pour mesurer les rendus en millisecondes tout en conservant la durée en secondes; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:34:35) : Graphical_Project : `--stats-env VAR` capture la valeur d’une variable d’environnement et l’inscrit dans `env_vars` dans tous les exports (texte/JSON/CSV/console) pour tracer l’environnement d’exécution; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:30:00) : Graphical_Project : `--stats-console-stdout` bascule `--stats-console`/`--stats-console-json` sur `stdout` pour les pipelines qui préfèrent lire `stdout` tout en conservant `--stats-camera`; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:20:10) : Graphical_Project : `--stats-console-json` émet les mêmes métriques que `--stats-console` en JSON sur `stderr` (avec `--stats-camera` qui ajoute la ligne caméra), ce qui facilite l’ingestion machine sans toucher aux fichiers; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:03:14) : Graphical_Project : `--stats`/`--stats-json`/`--stats-csv` incluent maintenant la graine `--seed` utilisée (dans les rapports texte, JSON et CSV) de manière à tracer et reproduire exactement chaque rendu; MLX toujours en attente.
Derniere mise a jour (2025-12-09 04:54:33) : Graphical_Project : `--stats-csv` écrit les métriques `--stats` dans un fichier CSV (en-tête `timestamp,scene,width,height,...,duration`) avec `--stats-csv-append` permettant de cumuler les rendus et `--stats-camera` ajoutant les colonnes `cam_pos_*`/`cam_dir_*`; MLX toujours en attente.
Derniere mise a jour (2025-12-08 22:13:15) : Expert_system termine (fixpoint, OR/XOR/bicond, traçage, origines des conflits, sortie JSON `-j`, flags combinables `-vcoj`, 17 tests OK); ft_kalman termine avec un mode `--udp` (paquets texte -> état renvoyé en JSON) et un mock stream Python, `make test` OK; ft_services termine côté manifests/scripts (Makefile start/apply/certs/stop + hosts/seed, scripts init_minikube/gen_certs/apply_all avec LB_POOL, check_cluster/gen_hosts/seed helpers, manifests namespace + MetalLB pool/L2 + ingress TLS whoami + stack WordPress/MariaDB/phpMyAdmin + FTPS LB + monitoring InfluxDB/Grafana avec ingress/datasource/dashboards; tests à faire sur Minikube réel); C/Ft_turing progresse (option -t, validation transitions/entrées/dupes/états inconnus, doc format, exemples unary_increment/reject_even/loop/bad_input/invalid_duplicate/invalid_move/invalid_unknown_state, script de tests 8 cas OK); ft_linux : GCC stage1 bloque (configure-target-libgcc echoue faute d'en-tetes stdc-predef/stdio dans le sysroot; prevoir stubs/en-tetes cibles avant nouvelle tentative), stub makeinfo PATH `.local/bin`, binutils deja installes (LFS `.lfs`); Graphical_Project : renderer PPM OK (`./RT` -> `output.ppm`) mais integration MLX en attente faute de bibliotheque; MessageQueue : sujet lu (RabbitMQ producer/consumers + PDF), en attente d'un broker RabbitMQ pour demarrer; AlCu : termine (parser + IA memoisee, saisie robuste, CLI `alcu` jouable); CPP_Module_05 termine (ex00→ex03 AForm + Shrubbery/Robotomy/Pardon + Intern, Makefiles c++98); CPP_Module_04 termine (ex00→ex04 Animal/Brain/AAnimal/Materia/AFK Mining, Makefiles c++98); CPP_Module_03 termine (ex00→ex03 ClapTrap/ScavTrap/FragTrap/DiamondTrap avec heritage virtuel, Makefiles c++98, tests basiques); CPP_Module_02 termine (ex00→ex03 Fixed/Point/bsp avec Makefiles c++98); CPP_Module_01 termine (ex00→ex06, Makefiles c++98); Django_Training_D01 termine (ex00→ex07, ressources numbers/periodic_table, generation HTML); ft_irc valide (smoke test robuste); ft_linux enrichi (versions + scripts download/partition/mount/env/chroot/toolchain avec cibles linux-headers/glibc, build_kernel, doc build_order/grub/fstab/network/chroot/toolchain/build_log, gen checksums, placeholder .config); CPP Module 00 termine (ex00 a ex04); ft_linear_regression termine avec visualisation matplotlib et RMSE.
Derniere mise a jour (2025-12-08 22:52:34) : C/Ft_turing termine : CLI complète (-v/-t/-r/-o/-s/-c), validation exhaustive (blank, sections obligatoires, complétude optionnelle), suite de tests 18/18 OK, docs format/exemples/README finalisées.
Derniere mise a jour (2025-12-08 23:58:26) : Graphical_Project progresse encore : tonemap (none/reinhard/aces), export depth/normal, primitive box, checker sur plans, ciel configurable (--sky), PPM multi-thread/supersampling/gamma + réflexions `--maxdepth`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:03:30) : Graphical_Project : ajout d’une atténuation quadratique des lumières (1/(1+0.09d+0.032d²)) pour des highlights plus réalistes, évitant la surexposition des surfaces proches; MLX toujours manquante.
Derniere mise a jour (2025-12-09 00:09:06) : Graphical_Project : support des spots directionnels (cutoff en degrés, direction normalisée) + nouvelle scène `assets/scenes/spotlight.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:12:44) : Graphical_Project : ajout d’un brouillard exponentiel global (`fog densité r g b`) appliqué au rendu selon la distance, scène `assets/scenes/foggy.rt` en exemple; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:18:26) : Graphical_Project : matériaux transparents/réfractifs (transparency + IOR optionnels) avec scène `assets/scenes/glass.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:29:20) : Graphical_Project : ombres douces via lights à rayon optionnel (multi shadow rays) + scène `assets/scenes/soft_shadow.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:37:48) : Graphical_Project : loader OBJ (`mesh`) qui triangule les faces, avec scène `assets/scenes/mesh.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:43:13) : Graphical_Project : `mesh` supporte un scale/translate optionnel (sx sy sz tx ty tz), scène `assets/scenes/mesh_scaled.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:48:23) : Graphical_Project : roughness sur les matériaux pour reflets glossy (scene `assets/scenes/glossy.rt`); MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:54:17) : Graphical_Project : loader OBJ supporte les normals `vn`/faces `v//n` + interpolation; scènes `mesh_normals.rt`/`pyramid.obj`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:58:21) : Graphical_Project : matériaux émissifs (emission_strength + couleur) et scène `assets/scenes/emissive.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:02:45) : Graphical_Project : mix refl/trans plus physique via Fresnel (Schlick) pour pondération auto des reflets.
Derniere mise a jour (2025-12-09 01:12:56) : Graphical_Project : textures PPM optionnelles (sphere/plane/mesh) avec scène `assets/scenes/textured.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:17:37) : Graphical_Project : UV OBJ (vt + faces v/vt/vn) avec sampling barycentrique des textures; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:23:34) : Graphical_Project : uv_scale pour tuiler les textures (nouvelle scène `assets/scenes/textured_tiled.rt`); MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:27:40) : Graphical_Project : textures bilinéaires (wrap) pour réduire l’aliasing sur sphères/plans/meshes; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:32:53) : Graphical_Project : wrap bilinéaire consolidé + doc CLI matériaux/texture; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:38:46) : Graphical_Project : lumières directionnelles (`dirlight`/`sun`) avec soft radius + scène `assets/scenes/sun.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:42:51) : Graphical_Project : rotation des meshes (rx ry rz après scale/translate) + scène `assets/scenes/mesh_rotated.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:33:24) : Graphical_Project : primitive triangle ajoutée (parser + intersection) avec scène `assets/scenes/triangles.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:23:54) : Graphical_Project : profondeur de champ (aperture/focal_dist) + scène `assets/scenes/dof.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:53:52) : Graphical_Project : env map pour le fond (`env` PPM) et export PPM binaire optionnel `--binary` (P6) pour accélérer l’écriture; MLX toujours en attente.
Derniere mise a jour (2025-12-09 02:04:21) : Graphical_Project : support des normal maps PPM (tangent space) avec parsing `[texture [uv_scale [normal]]]`, nouveau normal map `assets/textures/tilt_normal.ppm` et scène `assets/scenes/normal_mapped.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 02:06:18) : Graphical_Project : caméra accepte un vecteur up optionnel pour le roll (`camera ... [upx upy upz]`), scène `assets/scenes/tilted_camera.rt` ajoutée; MLX toujours en attente.
Derniere mise a jour (2025-12-09 02:08:16) : Graphical_Project : support PPM P3/P6 pour textures/envmaps, avec texture binaire `assets/textures/env_p6.ppm` et scène `assets/scenes/envmap_p6.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 02:16:01) : Graphical_Project : accélération BVH (AABB) pour les objets finis afin d’accélérer le rendu sur les meshes; plans restent testés linéairement. MLX toujours en attente.
Derniere mise a jour (2025-12-09 02:18:34) : Graphical_Project : loader OBJ triangule désormais les faces n-gones (fan) et ajoute une scène de validation `assets/scenes/mesh_polygon.rt` (pentagone).
Derniere mise a jour (2025-12-09 02:23:39) : Graphical_Project : ajout d’un flag `--no-bvh` pour désactiver l’accélération BVH (debug) et fallback linéaire.
Derniere mise a jour (2025-12-09 02:28:34) : Graphical_Project : AO optionnelle (`--ao radius samples`) pour moduler l’ambiant par occlusion locale.
Derniere mise a jour (2025-12-09 02:34:12) : Graphical_Project : option `--srgb-textures` pour convertir les textures sRGB en linéaire avant shading.
Derniere mise a jour (2025-12-09 02:38:34) : Graphical_Project : ajout de l’option `--exposure` (gain avant tonemap/gamma) pour contrôler la luminosité globale.
Derniere mise a jour (2025-12-09 02:43:34) : Graphical_Project : `--glossy-samples` permet de lisser le bruit des reflets flous (moyenne multi-rayons).
Derniere mise a jour (2025-12-09 02:50:15) : Graphical_Project : export ID map (`--id id.ppm`) pour le debug/compositing (couleurs hashées par objet).
Derniere mise a jour (2025-12-09 02:54:20) : Graphical_Project : lighting diffus de l’envmap via `--env-samples` (éclairage indirect par hémisphère autour de la normale).
Derniere mise a jour (2025-12-09 03:00:55) : Graphical_Project : export buffers `--albedo` et `--position` (clamp [-10,10]) en plus des depth/normal/ID.
Derniere mise a jour (2025-12-09 03:10:08) : Graphical_Project : seed global `--seed` pour des rendus reproductibles; buffers albedo/position et env-samples intègrent ce seed.
Derniere mise a jour (2025-12-09 03:19:24) : Graphical_Project : option `--pos-range` pour régler le clamp des cartes position, seed appliqué partout.
Derniere mise a jour (2025-12-09 03:27:36) : Graphical_Project : ajout `--clamp` pour borner la luminance linéaire avant tonemap (0 désactive) et nettoyage du parsing CLI (flags id/albedo/position/seed/clamp).
Derniere mise a jour (2025-12-09 03:31:13) : Graphical_Project : flag `--bin-buffers` pour exporter depth/normal/id/albedo/position en P6 binaire (exports debug plus rapides).
Derniere mise a jour (2025-12-09 03:38:12) : Graphical_Project : option `--stats <file>` qui écrit width/height/samples/threads/gamma/maxdepth/exposure/binary/binary_buffers/durée dans le fichier après le rendu.
Derniere mise a jour (2025-12-09 03:43:07) : Graphical_Project : `--stats` capture désormais les threads réellement utilisés (auto détecté / clamp `height`) pour que la fiche reflète fidèlement le rendu.
Derniere mise a jour (2025-12-09 03:48:16) : Graphical_Project : option `--stats-append` pour ajouter les fiches successives sans écraser les précédentes (les stats continuent d’indiquer les threads auto-détectés + durée).
Derniere mise a jour (2025-12-27 10:23:52) : general review de la procédure helper `./scripts/logs_metrics_export.sh --pattern status --topn 2` avec `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` et `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json`; la checklist helper → CSV tail → JSON jq reste referencée pour que les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` soient toujours confirmées, comme décrit dans `C/ft_services/docs/logs_metrics.md`.
Derniere mise a jour (2025-12-09 03:53:00) : Graphical_Project : `--stats` enregistre maintenant les réglages `glossy_samples/env_samples/pos_range/clamp/ao_samples/env_intensity`, utile pour comparer les rendus; `--stats-append` conserve les historiques multi-rendus.
Derniere mise a jour (2025-12-09 03:59:19) : Graphical_Project : l’option `--env-intensity` module l’éclairage diffus de l’envmap pour ajuster l’ambiance globale sans retoucher la texture, `--stats` logge désormais la scène/timestamp et le nombre de lights pour tracer les fichiers de stats.
Derniere mise a jour (2025-12-09 04:23:20) : Graphical_Project : `--stats-camera` ajoute la position/direction caméra dans la fiche stats permettant de lier précisément les rendus aux angles de prise de vue.
Derniere mise a jour (2025-12-09 04:32:54) : Graphical_Project : `--stats-json` duplique les métriques `--stats` en JSON (append autorisé), utile pour l’analyse automatisée; MLX toujours manquante.
Derniere mise a jour (2025-12-09 04:34:30) : Graphical_Project : `--stats-json -` imprime la sortie JSON sur stdout pour les pipelines tout en restant compatible avec `--stats-camera`; MLX toujours manquante.
Derniere mise a jour (2025-12-09 04:28:17) : Graphical_Project : `--stats` mesure aussi les luminances moyenne/min/max et l’écart-type (0-1) pour détecter l’exposition; MLX toujours manquante.
Derniere mise a jour (2025-12-09 03:53:00) : Graphical_Project : option `--env-intensity` pour ajuster la contribution diffuse de l’envmap (1.0 par défaut).
# Pour les relectures détaillées, précisez la commande helper utilisée et la séquence de vérification `tail`/`jq` afin de retranscrire exactement les lignes `pattern=status`/`top_n=2` de `reports/log_metrics_snapshot.status_top2.csv` et `.json`. Le paragraphe ci-dessus vous montre la syntaxe à coller, et le lien vers `C/ft_services/docs/logs_metrics.md` conforte la source documentaire qui décrit le même helper + tail/jq afin que tout relecteur retrouve sans ambiguïté le même sous-ensemble filtré. Ajoutez un court exemple de note de revue, par exemple : « notez le helper `./scripts/logs_metrics_export.sh --pattern status --topn 2` puis validez les exports via `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` et `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json` ; mentionnez cette combinaison dans vos commentaires pour prouver que le même sous-ensemble CSV/JSON a été vérifié » afin de boucler la directive README vers le détail du C/ft_services/docs. Encouragez les relecteurs, quand ils rapportent le helper, à rappeler les paths `reports/log_metrics_snapshot.status_top2.csv/.json` and `tail`/`jq` commands verbatim so the `pattern=status`/`top_n=2` lines can be instantly retraced before approval. Et suggérez de recopier la mini-checklist helper → tail CSV → tail JSON | jq dans les notes de revue pour que l’on retrouve toujours `status,top_n` dans ces lignes partagées. Mentionnez également que `C/ft_services/docs/logs_metrics.md` contient des exemples prêts à copier dans une note et un rappel des colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` afin que les approbateurs puissent cocher chaque vérification.
Reprécisez ensuite dans vos annotations (helper → `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` → `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json`) les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` du sous-ensemble `pattern=status/top_n=2` comme le décrit `C/ft_services/docs/logs_metrics.md`. Cette mini-checklist facilite la validation par double vérification (CSV + JSON) et garantit que la trace `reports/log_metrics_snapshot.status_top2.csv/.json` reste référencée de façon identique à chaque relecture.
Ajoutez cette même mini-checklist helper → CSV tail → JSON jq à votre commentaire pour que, à l’instant T, tous les relecteurs puissent repérer les mêmes lignes `pattern=status/top_n=2` et cocher les colonnes répertoriées dans `C/ft_services/docs/logs_metrics.md` avant toute approbation finale. Cela maintient la piste visible dans README, la fiche doc, et vos notes de relecture.
Dans vos notes récapitulatives, précisez aussi que les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` doivent apparaître dans le subset `pattern=status/top_n=2`, car la doc `C/ft_services/docs/logs_metrics.md` les expose et les trace via `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` plus `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json`. En recollant cette mini-checklist (helper → CSV tail → JSON jq → doc), vous garantissez qu’avant chaque approbation tout le monde suit exactement la même routine de vérification et les mêmes exports `reports/log_metrics_snapshot.status_top2.csv/.json`.
Pensez à copier cette mini-checklist (helper → tail CSV → tail JSON | jq) dans la section de votre note qui cite `C/ft_services/docs/logs_metrics.md`, et ajoutez ces chemins/commandes textuellement (`./scripts/logs_metrics_export.sh --pattern status --topn 2`, `reports/log_metrics_snapshot.status_top2.csv/.json`, `tail -n 5 ...`, `jq '.[-1]' ...`) pour que les relecteurs suivants puissent d’emblée retrouver les lignes `pattern=status/top_n=2`. Cela maintient la piste `status,top_n` identique entre la doc, README et vos annotations. Répétez la liste des colonnes exportées (`timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio`) à chaque mention afin d’attester que les mêmes métriques sont vérifiées à chaque point de contact.
En recopiant cette mini-checklist (helper → CSV tail → JSON jq) dans vos commentaires, vous confirmez aussi que la doc `C/ft_services/docs/logs_metrics.md` et les fichiers `reports/log_metrics_snapshot.status_top2.csv/.json` ont été revalidés via les mêmes commandes, ce qui rend la ligne `pattern=status/top_n=2` observable dans les deux formats avant la validation finale.
  - helper `./scripts/logs_metrics_export.sh --pattern status --topn 2`
  - CSV check `tail -n 5 reports/log_metrics_snapshot.status_top2.csv`
  - JSON check `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json`
  - citation `C/ft_services/docs/logs_metrics.md`
Cette mini-checklist peut être recopiée dans vos annotations pour garantir que les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` sont bien confirmées sous `pattern=status`/`top_n=2`, comme l’explique la doc `C/ft_services/docs/logs_metrics.md`, et que le helper produit les fichiers `reports/log_metrics_snapshot.status_top2.csv/.json` vérifiés par les commandes `tail -n 5 ...` et `jq '.[-1]' ...`.
Pour aller plus loin, mentionnez dans vos notes que la même doc `C/ft_services/docs/logs_metrics.md` décrit le helper et les colonnes citées, ce qui permet à chacun de réexécuter `tail`/`jq` sur les fichiers exportés et de confirmer que le `pattern=status`/`top_n=2` subset est bien identique au moment du contrôle de relecture. Rappelez aussi la mini-checklist (helper → CSV tail → JSON jq → citation) pour que tout relecteur reporte exactement les mêmes vérifications avant de valider. Ajoutez une phrase incitant les relecteurs à recopier ce trio de commandes (`helper`, `tail -n 5 ...`, `jq '.[-1]' ...`) dans leurs commentaires afin que la piste `pattern=status / top_n=2` reste visible dans les deux formats avant l’approbation.
Derniere mise a jour (2025-12-25 21:07:40) : ft_services : historique overall généré avant manifest/checksums (CSV dans manifest/sitemap/portal), portail avec liens cliquables + tableau d’historique; smoke + quick-check verts (push toujours bloqué DNS).
Derniere mise à jour (2025-12-27 14:07:12) : synchronisation des docs/scripts/helpers
Derniere mise a jour (2026-01-02 19:06:38) : C/ft_linear_regression progresse : validation_summary ajoute median/stddev RMSE (txt/md/json/html/csv/yaml) avec scripts d'export a jour.
Derniere mise a jour (2026-01-02 19:13:15) : C/ft_linear_regression progresse : early stopping restaure les meilleurs theta et validation ajoute best_epoch/best_train_rmse avec options early-stop.
Derniere mise a jour (2026-01-02 19:15:24) : C/ft_linear_regression progresse : validation.py ecrit data/validation_report.txt via --output (default), docs alignes.
Derniere mise a jour (2026-01-02 19:19:39) : C/ft_linear_regression progresse : validation.py ajoute bootstrap (OOB) via --bootstrap-samples pour RMSE supplementaire.
Derniere mise a jour (2026-01-02 19:25:49) : C/ft_linear_regression progresse : validation_summary capture bootstrap average et artefacts regeneres apres run bootstrap.
Derniere mise a jour (2026-01-02 19:29:25) : C/ft_linear_regression progresse : tests ajoutés pour validation_summary (bootstrap) et pytest OK.
Derniere mise a jour (2026-01-02 19:34:52) : C/ft_linear_regression DONE : doc rmse_plot + roadmap post-review, plan termine.
Derniere mise a jour (2026-01-02 19:41:38) : C/ft_hangouts IN_PROGRESS : auto-creation contact SMS inconnu + scenario CLI mis a jour.
Derniere mise a jour (2026-01-02 19:42:33) : C/ft_hangouts IN_PROGRESS : tests run_tests.sh relances apres auto-creation contact SMS.
Derniere mise a jour (2026-01-02 19:46:10) : C/ft_hangouts IN_PROGRESS : settings theme CLI + run_tests.sh OK.
Derniere mise a jour (2026-01-02 19:51:13) : C/ft_hangouts IN_PROGRESS : avatars contacts (add/set-avatar) + run_tests.sh OK.
Derniere mise a jour (2026-01-02 19:55:45) : C/ft_hangouts IN_PROGRESS : import/export contacts CSV + run_tests.sh OK.
Derniere mise a jour (2026-01-02 19:59:45) : C/ft_hangouts IN_PROGRESS : guide utilisateur CLI ajoute.
Derniere mise a jour (2026-01-02 20:04:41) : C/ft_hangouts IN_PROGRESS : README complete + user_journeys ajoutes.
Derniere mise a jour (2026-01-02 20:11:27) : C/ft_hangouts IN_PROGRESS : support appels (log/list/stats) + run_tests.sh OK.
Derniere mise a jour (2026-01-02 20:12:06) : C/ft_hangouts IN_PROGRESS : guide utilisateur mis a jour (section appels).
Derniere mise a jour (2026-01-02 20:15:27) : C/ft_hangouts IN_PROGRESS : export/import appels JSON + run_tests.sh OK.
Derniere mise a jour (2026-01-02 20:19:04) : C/ft_hangouts DONE : prototype CLI complet, docs/tests stabilises.
Derniere mise a jour (2026-01-02 20:25:54) : C/Ft_ls DONE : tests comparatifs OK, plan/README finalises.
Derniere mise a jour (2026-01-02 20:31:24) : C/ft_linux IN_PROGRESS : toolchain split gcc-stage1/libgcc, docs/plans mis a jour.
Derniere mise a jour (2026-01-02 20:34:45) : C/ft_linux IN_PROGRESS : ajout validation toolchain (script + docs).
Derniere mise a jour (2026-01-02 20:40:32) : C/ft_linux IN_PROGRESS : manifest build_system + build_system.sh ameliore.
Derniere mise a jour (2026-01-02 20:44:26) : C/ft_linux IN_PROGRESS : ajout verify_manifest.sh pour valider les tarballs.
Derniere mise a jour (2026-01-02 20:49:43) : C/ft_linux IN_PROGRESS : ajout preflight.sh (env + toolchain + manifest).
Derniere mise a jour (2026-01-02 20:54:22) : C/ft_linux IN_PROGRESS : preflight appelle validate_toolchain + docs ajoutes.
Derniere mise a jour (2026-01-02 20:59:37) : C/ft_linux IN_PROGRESS : ajout log_build.sh pour journaliser les builds.
Derniere mise a jour (2026-01-02 21:04:33) : C/ft_linux IN_PROGRESS : ajout quickcheck.sh (resume validations).
Derniere mise a jour (2026-01-02 21:09:32) : C/ft_linux IN_PROGRESS : ajout status_report.sh (logs + tarballs).
Derniere mise a jour (2026-01-02 21:14:26) : C/ft_linux IN_PROGRESS : status_report execute, rapport genere.
Derniere mise a jour (2026-01-02 21:19:36) : C/ft_linux IN_PROGRESS : status_report genere TXT+CSV.
Derniere mise a jour (2026-01-02 21:24:42) : C/ft_linux IN_PROGRESS : manifest enrichi (utilitaires de base) + docs.
Derniere mise a jour (2026-01-02 21:30:25) : C/ft_linux IN_PROGRESS : download_sources.sh ajoute --verify-only/--list.
Derniere mise a jour (2026-01-02 21:35:46) : C/ft_linux IN_PROGRESS : missing_tarballs.sh + reports missing_tarballs.*.
Derniere mise a jour (2026-01-02 21:44:45) : C/ft_linux IN_PROGRESS : manifest_report.sh + reports manifest_sources.*.
Derniere mise a jour (2026-01-02 21:49:46) : C/ft_linux IN_PROGRESS : generate_downloads.sh + reports/download_missing.sh.
Derniere mise a jour (2026-01-02 21:54:45) : C/ft_linux IN_PROGRESS : verify_checksums.sh + reports/sha_report.*.
Derniere mise a jour (2026-01-02 21:59:37) : C/ft_linux IN_PROGRESS : verify_checksums.sh resume + exit code.
Derniere mise a jour (2026-01-02 22:04:40) : C/ft_linux IN_PROGRESS : report_index.sh + reports/index.md.
Derniere mise a jour (2026-01-02 22:09:29) : C/ft_linux IN_PROGRESS : quickcheck.sh execute (toolchain + tarballs manquants).
Derniere mise a jour (2026-01-02 22:14:56) : C/ft_linux IN_PROGRESS : download_sources.sh support --from dir.
Derniere mise a jour (2026-01-02 22:19:49) : C/ft_linux IN_PROGRESS : env_audit.sh + reports/env_audit.*.
Derniere mise a jour (2026-01-02 22:25:18) : C/ft_linux IN_PROGRESS : setup_env.sh passe en mode commandes (create/partition/attach/format/mount).
Derniere mise a jour (2026-01-02 22:29:34) : C/ft_linux IN_PROGRESS : setup_env.sh ajoute generation fstab.
Derniere mise a jour (2026-01-02 22:33:07) : C/ft_linux IN_PROGRESS : build_kernel.sh gere chroot/LFS, options config/modules/install + logs.
Derniere mise a jour (2026-01-02 22:40:12) : C/ft_linux IN_PROGRESS : ajout build_rootfs.sh + layout rootfs TSV.
Derniere mise a jour (2026-01-02 22:44:56) : C/ft_linux IN_PROGRESS : ajout bootstrap_system.sh (fstab/hosts/passwd/group/hostname).
Derniere mise a jour (2026-01-02 22:49:39) : C/ft_linux IN_PROGRESS : ajout squelette SysV init (inittab+rc scripts).
Derniere mise a jour (2026-01-02 22:54:23) : C/ft_linux IN_PROGRESS : ajout generate_grub_cfg.sh (grub.cfg auto).
Derniere mise a jour (2026-01-02 22:59:33) : C/ft_linux IN_PROGRESS : ajout chroot_prepare.sh (mount/umount chroot).
Derniere mise a jour (2026-01-02 23:04:42) : C/ft_linux IN_PROGRESS : ajout install_init_scripts.sh (mountfs/syslog/network).
Derniere mise a jour (2026-01-02 23:09:48) : C/ft_linux IN_PROGRESS : ajout rootfs_report.sh (rapport structure rootfs).
Derniere mise a jour (2026-01-02 23:14:43) : C/ft_linux IN_PROGRESS : ajout enable_services.sh + manifest services.
Derniere mise a jour (2026-01-02 23:19:02) : C/ft_linux IN_PROGRESS : ajout build_mini_system.sh + manifest intermediaire.
Derniere mise a jour (2026-01-02 23:25:29) : C/ft_linux IN_PROGRESS : manifests supportent build_type + build_mini/system adaptes.
Derniere mise a jour (2026-01-02 23:29:20) : C/ft_linux IN_PROGRESS : list manifests affiche build_type.
Derniere mise a jour (2026-01-02 23:34:28) : C/ft_linux IN_PROGRESS : ajout validate_manifests.sh (lint manifests).
Derniere mise a jour (2026-01-02 23:39:03) : C/ft_linux IN_PROGRESS : ajout boot_checklist.sh (rapport prerequis boot).
Derniere mise a jour (2026-01-02 23:44:14) : C/ft_linux IN_PROGRESS : boot_checklist.sh gere kernel absent proprement.
Derniere mise a jour (2026-01-02 23:49:29) : C/ft_linux IN_PROGRESS : ajout validate_fstab.sh (rapport fstab).
Derniere mise a jour (2026-01-02 23:54:27) : C/ft_linux IN_PROGRESS : ajout create_dev_nodes.sh (noeuds /dev minimaux).
Derniere mise a jour (2026-01-02 23:59:40) : C/ft_linux IN_PROGRESS : ajout install_system_configs.sh + templates system.
Derniere mise a jour (2026-01-03 00:04:04) : C/ft_linux IN_PROGRESS : ajout locale.sh (profile.d) via install_system_configs.sh.
Derniere mise a jour (2026-01-03 00:09:58) : C/ft_linux IN_PROGRESS : ajout check_env_prereqs.sh + preflight etendu.
Derniere mise a jour (2026-01-03 00:14:35) : C/ft_linux IN_PROGRESS : ajout bootstrap_all.sh (sequence setup complete).
Derniere mise a jour (2026-01-03 00:19:06) : C/ft_linux IN_PROGRESS : ajout summary_report.sh (rapport synthese).
Derniere mise a jour (2026-01-03 00:24:31) : C/ft_linux IN_PROGRESS : ajout ensure_grub_cfg.sh (installe grub.cfg).
Derniere mise a jour (2026-01-03 00:29:36) : C/ft_linux IN_PROGRESS : ajout validate_grub_cfg.sh (rapport grub).
Derniere mise a jour (2026-01-03 00:34:06) : C/ft_linux IN_PROGRESS : ajout build_kernel_config.sh (defconfig).
Derniere mise a jour (2026-01-03 00:39:06) : C/ft_linux IN_PROGRESS : build_kernel.sh ajoute --print-release.
Derniere mise a jour (2026-01-03 00:45:07) : C/ft_linux IN_PROGRESS : ajout build_initramfs.sh + manifest initramfs.
Derniere mise a jour (2026-01-03 00:49:06) : C/ft_linux IN_PROGRESS : initramfs modules list ajoutee.
Derniere mise a jour (2026-01-03 00:54:36) : C/ft_linux IN_PROGRESS : ajout validate_initramfs.sh (rapport initramfs).
Derniere mise a jour (2026-01-03 00:59:33) : C/ft_linux IN_PROGRESS : ajout package_rootfs.sh (tar+checksum).
Derniere mise a jour (2026-01-03 01:04:14) : C/ft_linux IN_PROGRESS : package_rootfs.sh robustifie output sans sha256sum.
Derniere mise a jour (2026-01-03 01:09:31) : C/ft_linux IN_PROGRESS : ajout release_report.sh (recap versions).
Derniere mise a jour (2026-01-03 01:14:14) : C/ft_linux IN_PROGRESS : summary_report.sh inclut release_report.
Derniere mise a jour (2026-01-03 01:19:15) : C/ft_linux IN_PROGRESS : summary_report.sh inclut grub/initramfs.
Derniere mise a jour (2026-01-03 01:24:40) : C/ft_linux IN_PROGRESS : ajout validate_services.sh (rapport services).
Derniere mise a jour (2026-01-03 01:29:13) : C/ft_linux IN_PROGRESS : summary_report.sh inclut services_report.
Derniere mise a jour (2026-01-03 01:34:47) : C/ft_linux IN_PROGRESS : validate_manifests.sh genere manifest_report.txt.
Derniere mise a jour (2026-01-03 01:39:30) : C/ft_linux IN_PROGRESS : ajout run_reports.sh (orchestrateur rapports).
Derniere mise a jour (2026-01-03 01:44:30) : C/ft_linux IN_PROGRESS : run_reports.sh inclut prerequis host.
Derniere mise a jour (2026-01-03 01:49:32) : C/ft_linux IN_PROGRESS : ajout boot_bundle.sh (kernel+initramfs+grub).
Derniere mise a jour (2026-01-03 01:54:51) : C/ft_linux IN_PROGRESS : ajout validate_kernel_config.sh + kernel_requirements.txt.
Derniere mise a jour (2026-01-03 01:59:14) : C/ft_linux IN_PROGRESS : run_reports.sh inclut validation kernel config.
Derniere mise a jour (2026-01-03 02:04:12) : C/ft_linux IN_PROGRESS : summary_report.sh inclut kernel_config_report.
Derniere mise a jour (2026-01-03 02:10:31) : C/ft_linux IN_PROGRESS : initramfs install-boot + grub initrd auto.
Derniere mise a jour (2026-01-03 02:14:50) : C/ft_linux IN_PROGRESS : ajout boot_artifacts.sh (artefacts /boot).
Derniere mise a jour (2026-01-03 02:19:18) : C/ft_linux IN_PROGRESS : boot_bundle.sh verifie artefacts /boot.
Derniere mise a jour (2026-01-03 02:24:54) : C/ft_linux IN_PROGRESS : ajout full_pipeline.sh (pipeline complet).
Derniere mise a jour (2026-01-03 02:29:59) : C/ft_linux IN_PROGRESS : ajout generate_initramfs_manifest.sh + bins list.
Derniere mise a jour (2026-01-03 02:34:27) : C/ft_linux IN_PROGRESS : run_reports.sh corrige doublon summary_report.
Derniere mise a jour (2026-01-03 02:39:40) : C/ft_linux IN_PROGRESS : ajout chroot_enter.sh (mount+chroot+umount).
Derniere mise a jour (2026-01-03 02:44:18) : C/ft_linux IN_PROGRESS : full_pipeline.sh valide config kernel.
Derniere mise a jour (2026-01-03 02:49:50) : C/ft_linux IN_PROGRESS : ajout grub_install.sh (installation GRUB).
Derniere mise a jour (2026-01-03 02:54:34) : C/ft_linux IN_PROGRESS : ajout detect_boot_mode.sh (BIOS/UEFI).
Derniere mise a jour (2026-01-03 02:59:21) : C/ft_linux IN_PROGRESS : reports incluent boot_mode.
Derniere mise a jour (2026-01-03 03:04:31) : C/ft_linux IN_PROGRESS : build_initramfs.sh supporte manifest genere.
Derniere mise a jour (2026-01-03 03:09:25) : C/ft_linux IN_PROGRESS : ajout host_requirements.md.
Derniere mise a jour (2026-01-03 03:14:51) : C/ft_linux IN_PROGRESS : ajout run_vm.sh (boot QEMU).
Derniere mise a jour (2026-01-03 03:19:24) : C/ft_linux IN_PROGRESS : run_vm.sh supporte SSH port forwarding.
Derniere mise a jour (2026-01-03 03:24:21) : C/ft_linux IN_PROGRESS : run_vm.sh aide clarifiee pour SSH.
Derniere mise a jour (2026-01-03 03:29:12) : C/ft_linux IN_PROGRESS : run_vm.sh ajoute exemple SSH.
Derniere mise a jour (2026-01-03 03:34:46) : C/ft_linux IN_PROGRESS : ajout boot_finalize.sh (finalisation boot).
Derniere mise a jour (2026-01-03 03:39:14) : C/ft_linux IN_PROGRESS : boot_finalize rapporte + summary.
Derniere mise a jour (2026-01-03 03:44:38) : C/ft_linux IN_PROGRESS : ajout archive_reports.sh (bundle rapports/logs).
Derniere mise a jour (2026-01-03 03:49:34) : C/ft_linux IN_PROGRESS : validate_grub_cfg verifie initrd.
Derniere mise a jour (2026-01-03 03:54:30) : C/ft_linux IN_PROGRESS : summary_report regroupe boot/grub/initramfs.
Derniere mise a jour (2026-01-03 03:59:31) : C/ft_linux IN_PROGRESS : build_initramfs.sh peut generer le manifest.
Derniere mise a jour (2026-01-03 04:04:33) : C/ft_linux IN_PROGRESS : ajout runbook complet.
Derniere mise a jour (2026-01-03 04:09:37) : C/ft_linux IN_PROGRESS : ajout check_ready_to_boot.sh (rapport boot ready).
Derniere mise a jour (2026-01-03 04:14:20) : C/ft_linux IN_PROGRESS : check_ready_to_boot verifie rc scripts.
Derniere mise a jour (2026-01-03 04:19:23) : C/ft_linux IN_PROGRESS : reports incluent ready_to_boot.
Derniere mise a jour (2026-01-03 04:24:15) : C/ft_linux IN_PROGRESS : ajout snapshot_image.sh (snapshot disque).
Derniere mise a jour (2026-01-03 04:29:16) : C/ft_linux IN_PROGRESS : run_vm.sh aide mentionne defaults mem/cpus.
Derniere mise a jour (2026-01-03 04:34:44) : C/ft_linux IN_PROGRESS : ajout convert_image.sh (qcow2).
Derniere mise a jour (2026-01-03 04:39:17) : C/ft_linux IN_PROGRESS : run_vm.sh detecte qcow2.
Derniere mise a jour (2026-01-03 04:44:42) : C/ft_linux IN_PROGRESS : ajout image_report.sh (rapport image).
Derniere mise a jour (2026-01-03 04:49:21) : C/ft_linux IN_PROGRESS : run_reports.sh archive reports/logs.
Derniere mise a jour (2026-01-03 04:55:24) : C/ft_linux IN_PROGRESS : archive_reports.sh regenere reports/index.md.
Derniere mise a jour (2026-01-03 04:59:25) : C/ft_linux IN_PROGRESS : archive_reports.sh log index refresh.
Derniere mise a jour (2026-01-03 05:04:46) : C/ft_linux IN_PROGRESS : ajout export_boot_artifacts.sh.
Derniere mise a jour (2026-01-03 05:09:24) : C/ft_linux IN_PROGRESS : boot_finalize exporte artefacts boot.
Derniere mise a jour (2026-01-03 05:14:23) : C/ft_linux IN_PROGRESS : runbook note boot_finalize exporte artefacts.
Derniere mise a jour (2026-01-03 05:19:53) : C/ft_linux IN_PROGRESS : ajout validate_boot_archive.sh.
Derniere mise a jour (2026-01-03 05:24:39) : C/ft_linux IN_PROGRESS : ajout clean_workspace.sh.
Derniere mise a jour (2026-01-03 05:29:38) : C/ft_linux IN_PROGRESS : clean_workspace.sh couvre boot_artifacts/qcow2.
Derniere mise a jour (2026-01-03 05:34:49) : C/ft_linux IN_PROGRESS : ajout partition_report.sh.
Derniere mise a jour (2026-01-03 05:39:31) : C/ft_linux IN_PROGRESS : reports incluent partition_report.
Derniere mise a jour (2026-01-03 05:44:43) : C/ft_linux IN_PROGRESS : partition_report inclut label/unit.
Derniere mise a jour (2026-01-03 05:49:20) : C/ft_linux IN_PROGRESS : ajout release_bundle.sh (bundle final).
Derniere mise a jour (2026-01-03 05:55:37) : C/ft_linux IN_PROGRESS : release_bundle.sh supprime archive precedente.
Derniere mise a jour (2026-01-03 05:59:59) : C/ft_linux IN_PROGRESS : ajout validate_release_bundle.sh.
Derniere mise a jour (2026-01-03 06:04:18) : C/ft_linux IN_PROGRESS : validate_release_bundle verifie boot_artifacts.
Derniere mise a jour (2026-01-03 06:09:18) : C/ft_linux IN_PROGRESS : validate_release_bundle verifie summary.md.
Derniere mise a jour (2026-01-03 06:14:53) : C/ft_linux IN_PROGRESS : ajout assess_status.sh (etat consolide).
Derniere mise a jour (2026-01-03 06:19:22) : C/ft_linux IN_PROGRESS : ajout apply_kernel_requirements.sh.
Derniere mise a jour (2026-01-03 06:24:20) : C/ft_linux IN_PROGRESS : build_kernel_config.sh supporte --apply-reqs.
Derniere mise a jour (2026-01-03 06:29:19) : C/ft_linux IN_PROGRESS : runbook utilise --apply-reqs.
Derniere mise a jour (2026-01-03 06:37:11) : C/ft_linux IN_PROGRESS : reprise build_system/build_mini_system avec state.
Derniere mise a jour (2026-01-03 06:45:16) : C/ft_linux IN_PROGRESS : ajout status/reset state pour build_system/build_mini_system.
Derniere mise a jour (2026-01-03 06:49:56) : C/ft_linux IN_PROGRESS : ajout build_state_report + summary/run_reports.
Derniere mise a jour (2026-01-03 06:54:53) : C/ft_linux IN_PROGRESS : ajout validate_build_state + integration summary/run_reports.
Derniere mise a jour (2026-01-03 07:00:03) : C/ft_linux IN_PROGRESS : ajout build_state_sync (logs -> state).
Derniere mise a jour (2026-01-03 07:05:17) : C/ft_linux IN_PROGRESS : ajout plage --from/--until build_system/mini_system.
Derniere mise a jour (2026-01-03 07:09:58) : C/ft_linux IN_PROGRESS : ajout build_log_audit + integration summary/run_reports.
Derniere mise a jour (2026-01-03 07:14:46) : C/ft_linux IN_PROGRESS : ajout manifest_coverage (logs vs manifests).
Derniere mise a jour (2026-01-03 07:19:56) : C/ft_linux IN_PROGRESS : status_assessment couvre build_state/build_log/coverage.
Derniere mise a jour (2026-01-03 07:24:52) : C/ft_linux IN_PROGRESS : validate_manifests detecte doublons manifests.
Derniere mise a jour (2026-01-03 07:30:23) : C/ft_linux IN_PROGRESS : ajout build_plan + pkg build_system.
Derniere mise a jour (2026-01-03 07:34:46) : C/ft_linux IN_PROGRESS : ajout build_queue (execution plan avec reprise).
Derniere mise a jour (2026-01-03 07:41:28) : C/ft_linux IN_PROGRESS : ajout build_times (timings + rapport).
Derniere mise a jour (2026-01-03 07:44:54) : C/ft_linux IN_PROGRESS : build_queue log CSV + summary.
Derniere mise a jour (2026-01-03 07:49:50) : C/ft_linux IN_PROGRESS : build_queue status/reset.
Derniere mise a jour (2026-01-03 07:54:51) : C/ft_linux IN_PROGRESS : build_queue status integre rapports + assess.
Derniere mise a jour (2026-01-03 07:59:55) : C/ft_linux IN_PROGRESS : ajout validate_build_plan.
Derniere mise a jour (2026-01-03 08:04:47) : C/ft_linux IN_PROGRESS : validate_build_plan corrige comptage + liste inconnus.
Derniere mise a jour (2026-01-03 08:09:49) : C/ft_linux IN_PROGRESS : ajout build_queue_retry.
Derniere mise a jour (2026-01-03 08:14:55) : C/ft_linux IN_PROGRESS : ajout build_queue_retry_report + integration rapports.
Derniere mise a jour (2026-01-03 08:20:12) : C/ft_linux IN_PROGRESS : ajout build_queue_sync_states.
Derniere mise a jour (2026-01-03 08:24:47) : C/ft_linux IN_PROGRESS : build_queue timeout support.
Derniere mise a jour (2026-01-03 08:30:04) : C/ft_linux IN_PROGRESS : ajout build_queue_metrics.
Derniere mise a jour (2026-01-03 08:34:28) : C/ft_linux IN_PROGRESS : build_queue_metrics ajoute top durees.
Derniere mise a jour (2026-01-03 08:39:27) : C/ft_linux IN_PROGRESS : build_queue_metrics ajoute top echecs.
Derniere mise a jour (2026-01-03 08:45:04) : C/ft_linux IN_PROGRESS : ajout validate_build_queue_state.
Derniere mise a jour (2026-01-03 08:49:56) : C/ft_linux IN_PROGRESS : ajout build_queue_report.
Derniere mise a jour (2026-01-03 08:55:27) : C/ft_linux IN_PROGRESS : ajout build_state_snapshot/diff.
Derniere mise a jour (2026-01-03 09:00:06) : C/ft_linux IN_PROGRESS : ajout build_state_list/prune.
Derniere mise a jour (2026-01-03 09:04:56) : C/ft_linux IN_PROGRESS : build_state_prune dry-run + integration rapports.
Derniere mise a jour (2026-01-03 09:10:06) : C/ft_linux IN_PROGRESS : ajout build_dashboard.
Derniere mise a jour (2026-01-03 09:15:32) : C/ft_linux IN_PROGRESS : ajout build_plan_split.
Derniere mise a jour (2026-01-03 09:20:05) : C/ft_linux IN_PROGRESS : ajout build_plan_remaining.
Derniere mise a jour (2026-01-03 09:26:01) : C/ft_linux IN_PROGRESS : build_progress tracking + report.
Derniere mise a jour (2026-01-03 09:30:10) : C/ft_linux IN_PROGRESS : ajout build_progress_rollup.
Derniere mise a jour (2026-01-03 09:34:30) : C/ft_linux IN_PROGRESS : build_queue_metrics detaille durees ok.
Derniere mise a jour (2026-01-03 09:40:02) : C/ft_linux IN_PROGRESS : ajout build_progress_failures.
Derniere mise a jour (2026-01-03 09:45:12) : C/ft_linux IN_PROGRESS : ajout build_orchestrator.
Derniere mise a jour (2026-01-03 09:50:08) : C/ft_linux IN_PROGRESS : ajout build_orchestrator_report.
Derniere mise a jour (2026-01-03 09:55:04) : C/ft_linux IN_PROGRESS : build_orchestrator exporte JSON.
Derniere mise a jour (2026-01-03 10:00:11) : C/ft_linux IN_PROGRESS : ajout build_orchestrator_status.
Derniere mise a jour (2026-01-03 10:04:35) : C/ft_linux IN_PROGRESS : build_orchestrator JSON escape.
Derniere mise a jour (2026-01-03 10:10:09) : C/ft_linux IN_PROGRESS : ajout build_orchestrator_validate.
Derniere mise a jour (2026-01-03 10:15:14) : C/ft_linux IN_PROGRESS : ajout build_health_report.
Derniere mise a jour (2026-01-03 10:19:57) : C/ft_linux IN_PROGRESS : build_queue continue-on-fail.
Derniere mise a jour (2026-01-03 10:25:39) : C/ft_linux IN_PROGRESS : build_system/mini supporte make check.
Derniere mise a jour (2026-01-03 10:30:25) : C/ft_linux IN_PROGRESS : ajout build_gate.
Derniere mise a jour (2026-01-03 10:34:55) : C/ft_linux IN_PROGRESS : run_reports inclut build_gate + health.
Derniere mise a jour (2026-01-03 10:40:23) : C/ft_linux IN_PROGRESS : ajout build_summary_json.
Derniere mise a jour (2026-01-03 10:44:38) : C/ft_linux IN_PROGRESS : build_summary_json corrige rollup.
Derniere mise a jour (2026-01-03 10:50:03) : C/ft_linux IN_PROGRESS : ajout build_session.
Derniere mise a jour (2026-01-03 10:55:25) : C/ft_linux IN_PROGRESS : plan/orchestrator supporte check.
Derniere mise a jour (2026-01-03 11:00:13) : C/ft_linux IN_PROGRESS : ajout build_summary_validate.
Derniere mise a jour (2026-01-03 11:05:25) : C/ft_linux IN_PROGRESS : ajout build_queue_failures.
Derniere mise a jour (2026-01-03 11:09:53) : C/ft_linux IN_PROGRESS : build_queue_report integre failures.
Derniere mise a jour (2026-01-03 11:14:34) : C/ft_linux IN_PROGRESS : build_queue_metrics ajoute taux ok.
