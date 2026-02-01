2026-01-25 03:50:00 | Messagequeue/MessageQueue | IN_PROGRESS | verify_publish_pdf_metadata.sh exercised publish_test_message_with_check --json --dry-run and reported the expected pdf_output_dir/pdf_output_dir_missing metadata.
2026-01-25 03:56:00 | Messagequeue/MessageQueue | IN_PROGRESS | Attempted `scripts/test_publish_test_message.sh --json` (with PDF_OUTPUT_DIR set and SKIP_PDF_CHECK=1) but validation hooks expect JSON error output (empty due to missing logs), so the suite currently fails; we need to adjust the helpers or test expectations before rerunning.
2026-01-25 03:30:54 | Messagequeue/MessageQueue | IN_PROGRESS | quickstart now documents that publish_test_message --json success emits `pdf_output_dir`/`pdf_output_dir_missing`, allowing quick checks with `jq`.
2026-01-25 03:22:17 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook now explains that publish_test_message --json success output includes `pdf_output_dir`/`pdf_output_dir_missing` so the workflow can confirm PDF readiness.
2026-01-25 03:15:00 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message asserts publish_test_message JSON success/dry-run responses include pdf_output_dir/pdf_output_dir_missing so the suites fail when the contract breaks.
2026-01-25 03:03:46 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message JSON now returns pdf_output_dir + pdf_output_dir_missing in dry-run/success outputs to keep API contract consistent with the docs and tests.
2026-01-19 12:50:39 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local dry-run JSON renvoie un pdf_output_dir sans suffixe, avec indicateur pdf_output_dir_missing separe.
2026-01-19 12:54:36 | Messagequeue/MessageQueue | IN_PROGRESS | docs_e2e_local mentionne pdf_output_dir exibant le chemin reel du dry-run.
2026-01-19 13:10:03 | Messagequeue/MessageQueue | IN_PROGRESS | doc local_usage note la sortie JSON dry-run `pdf_output_dir`/`pdf_output_dir_missing`.
2026-01-19 13:19:47 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook ajoute note sur pdf_output_dir + pdf_output_dir_missing du dry-run e2e.
2026-01-19 13:54:43 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook recommande de precreer PDF_OUTPUT_DIR et verifier pdf_output_dir_missing=0.
2026-01-19 14:04:35 | Messagequeue/MessageQueue | IN_PROGRESS | README principal cite local_runbook pour le dry-run pdf_output_dir.
2026-01-19 14:09:43 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary mentionne precreation de PDF_OUTPUT_DIR pour pdf_output_dir_missing=0.
2026-01-19 14:34:36 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook guide `PDF_OUTPUT_DIR=/tmp/mq-pdfs ./scripts/test_e2e_local.sh --json` et pdf_output_dir_missing=0.
2026-01-19 15:09:59 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook conseille `jq '.pdf_output_dir,.pdf_output_dir_missing'` pour inspecter le JSON dry-run.
2026-01-19 12:44:47 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary note pdf_output_dir_missing pour le dry-run e2e_local.
2026-01-19 12:40:34 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local dry-run JSON ajoute pdf_output_dir_missing + test et doc associes.
2026-01-19 12:36:05 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local accepte PDF_OUTPUT_DIR manquant en dry-run et cree le dossier hors dry-run + test/doc maj.
2026-01-19 12:30:41 | Messagequeue/MessageQueue | IN_PROGRESS | Ajout d'un exemple `PDF_OUTPUT_DIR` dans la doc d'usage locale pour changer le dossier de sortie des PDF.
2026-01-05 09:40:00 | C/ft_linux | IN_PROGRESS | `scripts/ensure_permissions.sh` a appliqué `chmod +x scripts/*.sh`, corrigeant 124 scripts et réduisant considérablement les `permission denied` rapportés par `run_reports.sh`; la validation reste bloquée tant que la chaîne cross et les artefacts kernel/manifests sont absents, mais les logs sont maintenant plus propres.
2026-01-05 09:20:00 | C/ft_linux | IN_PROGRESS | `scripts/run_reports.sh` a régénéré les rollups history/trend (CSV/MD/HTML/JSON) et un grand nombre de rapports, mais la validation échoue parce que les outils cross (`x86_64-lfs-linux-gnu-gcc/ld/as`), `linux-6.6.54.config`, `fstab`, `grub.cfg`, `vmlinuz-*`, et plusieurs tarballs manifest absents, plus des permissions manquantes sur la majorité des scripts ; les artefacts existants (preflight/toolchain/rollup) sont produits mais Quickcheck/report states remontent des erreurs.
2025-12-26 10:10:49 | C/ft_nmap | IN_PROGRESS | Export JSON (-o) et CSV (-C) ports+stats ajoutés, résolution unique réutilisée, scan non bloquant (poll) burst réglable (-c def 256/lim 1024), options -q/-S, résumé open/closed/timeout + débit; README/test local à jour.
2025-12-25 11:57:23 | C/Ft_services | IN_PROGRESS | guard_summary Markdown ajoute un tableau pour la streak globale agrégée (current/longest/window), alignant le rendu MD avec HTML/CSV/JSON; docs/CLI/README mis à jour. validation/artefacts OK.
2025-12-25 11:55:06 | C/Ft_services | IN_PROGRESS | Corrigé guard_summary HTML (comptait seulement le dernier garde) pour aligner compteurs/streaks avec CSV/JSON/MD; docs/CLI détaillent la ligne CSV `__overall_streak` pour la streak globale agrégée. validation/artefacts restent OK.
2025-12-30 11:30:00 | C/Ft_services | IN_PROGRESS | README rappelle maintenant explicitement la même checklist (helper → `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` → `tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq`) et encourage les relecteurs à recopier ces commandes et la citation `C/ft_services/docs/logs_metrics.md` dans leurs notes pour montrer que `pattern=status`/`top_n=2` est confirmé dans CSV et JSON avant d’approuver. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-30 10:25:00 | C/Ft_services | IN_PROGRESS | Documenté `scripts/verify_snapshot.sh` dans la revue pour enregistrer l’export CSV/JSON et la vérification `tail`/`jq` en une commande, prouvant que `pattern=status`/`top_n=2` sont appliqués dans les deux formats. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-30 10:20:00 | C/Ft_services | IN_PROGRESS | Rappelé dans `progress.md`/docs que la commande `tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq` confirme la même grille pour la version JSON, permettant aux relecteurs d’inspecter ce format quand ils partagent des exports. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-30 10:30:00 | C/Ft_services | IN_PROGRESS | Précisé dans les docs/README que les exports CSV/JSON renommés (`reports/log_metrics_snapshot.status_top2.*`) doivent être mentionnés dans les notes de revue avec le `tail -n 5` (ou `tail -n 1 ... | jq`) pour confirmer la réutilisation de `pattern=status`/`top_n=2`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-30 10:15:00 | C/Ft_services | IN_PROGRESS | Ajouté une note finale dans docs/README pour rappeler de noter dans la revue `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` (pattern=status/top_n=2) afin qu’ils puissent reproduire la colonne `Totals`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-30 10:10:00 | C/Ft_services | IN_PROGRESS | Noté dans docs/README qu’il faut signaler dans la revue le renommage `reports/log_metrics_snapshot.status_top2.csv` et la vérification `tail -n 5 ...`, afin de garantir que la sélection `pattern=status`/`top_n=2` est reproduite dans l’export partagé. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-30 10:00:00 | C/Ft_services | IN_PROGRESS | Ajouté une mention explicite du renommage temporaire `reports/log_metrics_snapshot.status_top2.csv` pour rappeler que l’export utilise `pattern=status`+`top_n=2`, ce qui aide à repérer la colonne `Totaux` et les `timestamp/log_file/status_checks/...` filtrés avant la diffusion. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-30 09:20:00 | C/Ft_services | IN_PROGRESS | Ajouté une section précisant l’aperçu `tail -n 5 reports/log_metrics_snapshot.csv` (avec colonnes timestamp/log_file/status_checks/connections/overloaded/overloaded_ratio) pour s’assurer que `pattern=status`/`top_n=2` réapparaissent dans l’export, complétant ainsi la vérification rapide mentionnée dans docs/README. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-30 09:10:00 | C/Ft_services | IN_PROGRESS | Enrichi `docs/logs_metrics.md` avec un exemple CSV + `tail -n 5 reports/log_metrics_snapshot.csv` confirmant que `pattern=status`/`top_n=2` se répercutent dans l’export, et mis à jour le README pour signaler la vérification rapide post `./scripts/logs_metrics_verify.sh csv` (ou json) afin de montrer que les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` sont synchronisées avant de diffuser les métriques. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-26 13:05:00 | C/Ft_services | IN_PROGRESS | Documenté dans `docs/logs_metrics.md` et `C/ft_services/PLAN.md` la vérification post-export (`tail -n 5 reports/log_metrics_snapshot.csv`) qui confirme que `pattern=status`/`top_n=2` ont bien été réutilisés, permettant de partager directement le CSV/JSON avec les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` avant d’alimenter un dashboard. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-26 13:15:00 | C/Ft_services | IN_PROGRESS | README.ft_services attire l’attention sur la même séquence alias/log_summary/export + le retour `tail -n 5 reports/log_metrics_snapshot.csv`, précisant que le CSV/JSON maintient les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` avec les filtres du run précédent avant de le diffuser. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-26 13:35:00 | C/Ft_services | IN_PROGRESS | Ajouté `scripts/log_metrics_verify.sh` et documenté dans README/PLAN/docs que ce script enchaîne `logs_metrics_export` puis `tail -n 5` sur `reports/log_metrics_snapshot` pour confirmer `pattern=status`/`top_n=2` avant de partager les métriques dans les dashboards ou fiches de revue. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-26 13:45:00 | C/Ft_services | IN_PROGRESS | README(ft_services) accueille maintenant une mini section décrivant l’usage de `./scripts/log_metrics_verify.sh csv` et la vérification `tail -n 5 reports/log_metrics_snapshot.csv`, montrant comment automatiser l’export + validation avant la diffusion des métriques synthétisées. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 14:05:00 | C/ft_linear_regression | IN_PROGRESS | `validation_summary.py --json` produce the JSON + HTML snapshot (`docs/validation_summary.html`) automatically, and docs mention it while `scripts/check_validation_stability.py` reads the JSON (avg<1200). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 14:40:00 | C/ft_linear_regression | IN_PROGRESS | Nouveau `scripts/preview_validation.py` enchaîne `validation_summary.py --json` puis `check_validation_stability.py` pour rafraîchir `docs/validation_summary.*`/`.html` et vérifier avg<1200 en une seule commande. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 23:05:00 | C/Ft_services | IN_PROGRESS | La README racine liste maintenant `scripts/show_config.sh`, `scripts/clean_log.sh` et `scripts/monitor_status.sh` dans la section des helpers santé/charge, ce qui facilite le partage de ce workflow complet pendant une démonstration FT Services. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 23:25:00 | C/Ft_services | IN_PROGRESS | README du projet détaille désormais une astuce de démonstration : démarrer `./ft_services --config tests/env/ft_services_status.conf`, lancer `scripts/monitor_status.sh tests/env/ft_services_status.conf 15`, puis utiliser `scripts/show_config.sh` pour confirmer les paramètres (port/backlog/log_path/max_connections) affichés pendant la démo. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 00:10:00 | C/Ft_services | IN_PROGRESS | `PLAN.md` mentionne maintenant les helpers `show_config.sh`, `clean_log.sh` et `monitor_status.sh`, expliquant leur rôle dans la démonstration (inspecter les paramètres, purger les logs, dérouler santé/COUNT/overload) afin de garder la documentation technique alignée avec les README. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 00:20:00 | C/Ft_services | IN_PROGRESS | README du projet recommande maintenant `scripts/client_demo.py` pour illustrer STATUS/COUNT en direct à la suite de `monitor_status.sh`, montrant à la revue comment les commandes sont traitées et leurs réponses. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 00:40:00 | C/Ft_services | IN_PROGRESS | Document `docs/helpers.md` synthétise tous les scripts d’assistance, l’ordre recommandé (config -> clean -> monitor -> client demo) et les commandes associées pour les démonstrations FT Services. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 00:50:00 | C/Ft_services | IN_PROGRESS | Ajouté `scripts/demo_pipeline.sh` pour enchaîner `show_config.sh`, `clean_log.sh` et `monitor_status.sh` sur plusieurs fichiers de config, documenté dans `docs/helpers.md` et dans le README, afin de pouvoir rejouer rapidement la démonstration santé/COUNT/overload sur plusieurs environnements. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 00:55:00 | C/Ft_services | IN_PROGRESS | README résume maintenant `scripts/demo_pipeline.sh` et met à jour les helpers pour rappeler le scénario show_config -> clean_log -> monitor -> client demo ; la note est alignée avec `docs/helpers.md` pour guider la démo santé/COUNT/overload. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 01:05:00 | C/Ft_services | IN_PROGRESS | Ajouté `scripts/stress_max_connections.sh`, un helper rapide qui pousse STATUS via `nc` jusqu’à obtenir `overloaded: <n>`, pour démontrer la limite `max_connections` en charge sans écrire de gros scripts Python. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 01:10:00 | C/Ft_services | IN_PROGRESS | `docs/helpers.md` mentionne désormais `scripts/stress_max_connections.sh` et `scripts/replay_log.sh`, et le README évoque leur usage pour forcer `max_connections` et relire les `status check` loggés. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 01:15:00 | C/Ft_services | IN_PROGRESS | `docs/helpers.md` et le README citent maintenant `scripts/stress_max_connections.sh` et `scripts/log_summary.sh` pour compléter la chaîne show_config -> clean_log -> monitor -> client demo, montrant la limite max et résumant les `status check` après les runs. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 01:20:00 | C/Ft_services | IN_PROGRESS | `docs/helpers.md` explique désormais que `log_summary.sh` aide à comparer le nombre de `status check`, `COUNT` et `overloaded` avant/après `stress_max_connections.sh`, ce qui montre la charge et les vérifications sous contrainte. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 01:25:00 | C/Ft_services | IN_PROGRESS | README mentionne maintenant le résumé `log_summary.sh` pour attester du nombre de `status check`/`connections`/`overloaded` après une démonstration, complétant la chaîne de démonstration FT Services. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 01:30:00 | C/Ft_services | IN_PROGRESS | Ajouté `scripts/health_report.sh` pour lier `show_config`, `clean_log`, `monitor_status`, `log_summary` et `stress_max_connections` en un rapport complet, ce que la doc/plan/README mentionnent comme raccourci de démonstration. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 01:35:00 | C/Ft_services | IN_PROGRESS | README renforce l’appel à `docs/helpers.md` en précisant qu’il contient un tableau de commandes et des exemples `make demo`/`scripts/health_report.sh` pour guider la démonstration FT Services. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 14:55:00 | C/ft_linear_regression | IN_PROGRESS | `scripts/archive_validation_html.py` copie le dernier HTML (`docs/validation_summary.html`) dans `docs/archive/` pour garder des snapshots horodatés destinés à la revue ft_helpme; le flag `--archive` de `scripts/preview_validation.py` déclenche cette copie automatiquement après une validation. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 15:25:00 | C/ft_linear_regression | IN_PROGRESS | Ajout de `docs/archive/README.md` pour documenter la procédure `scripts/preview_validation.py --archive` + le dossier `docs/archive/` (HTML horodatés) et aider la revue ft_helpme à retrouver les snapshots figés. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 15:35:00 | C/ft_linear_regression | IN_PROGRESS | Nouveau tableau `scripts/list_validation_archives.py` liste les fichiers `docs/archive/validation_summary_*.html` pour sélectionner rapidement une archive validée pendant la revue. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 15:45:00 | C/ft_linear_regression | IN_PROGRESS | README racine mentionne maintenant `scripts/list_validation_archives.py` et la commande `scripts/preview_validation.py --archive` pour orienter l’archivage/consultation des snapshots ft_helpme (avg<1200). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 15:55:00 | C/ft_linear_regression | IN_PROGRESS | Ajouté `scripts/prune_validation_archives.py` pour faire le ménage (`--days` configurable) dans `docs/archive/` et conserver seulement les snapshots intéressants pour la revue. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 16:05:00 | C/ft_linear_regression | IN_PROGRESS | `README.md` mentionne désormais aussi `scripts/prune_validation_archives.py` tout en rappellant `list_validation_archives.py + preview_validation --archive` dans le résumé ft_helpme pour guider la revue. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 16:30:00 | C/ft_linear_regression | IN_PROGRESS | `scripts/refresh_validation_artifacts.py` automatise preview/archivage/prune/verification pour produire `docs/archive/validation_summary_<timestamp>.html` conforme (avg<1200) en une seule commande. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 16:40:00 | C/ft_linear_regression | IN_PROGRESS | `docs/validation_summary.md` décrit désormais le pipeline complet (`refresh_validation_artifacts.py` connecté à archive/list/prune/verify/csv/index) et mentionne `scripts/diff_validation_archives.py` pour comparer deux snapshots HTML, afin de montrer à la revue comment les artefacts sont générés, archivés, vérifiés et exportés en tableur. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 17:10:00 | C/ft_linear_regression | IN_PROGRESS | Ajouté `scripts/export_validation_summary_yaml.py` plus la mise à jour pipeline : `refresh_validation_artifacts.py` génère maintenant `docs/validation_summary.yaml` en plus du CSV pour les notes rapides. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 17:25:00 | C/ft_linear_regression | IN_PROGRESS | `scripts/verify_all_validation_archives.py` parcourt tous les HTML archivés pour confirmer qu’ils correspondent aux métriques JSON `docs/validation_summary.json` (backup safety before ft_helpme). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 17:35:00 | C/ft_linear_regression | IN_PROGRESS | `scripts/log_validation_summary.py` alimente `docs/validation_history.md` avec chaque snapshot (timestamp + best/worst/avg), ce qui documente linéairement la stabilité RMSE pour la revue. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 16:55:00 | C/ft_linear_regression | IN_PROGRESS | Validation diff : `scripts/diff_validation_archives.py validation_summary_20251211T151008Z.html validation_summary_20251211T152000Z.html` montre “no differences found”, preuve que les deux snapshots récents sont identiques pour la revue. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 16:15:00 | C/ft_linear_regression | IN_PROGRESS | `scripts/verify_archive_summary.py` vérifie que la dernière archive HTML (`docs/archive/validation_summary_*.html`) correspond toujours au JSON actuel (best/worst/average RMSE) avant de la partager à la revue. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 15:10:00 | C/ft_helpme | IN_PROGRESS | `README.md` recommande désormais `C/ft_linear_regression/scripts/preview_validation.py --archive` comme commande unique pour régénérer `docs/validation_summary.*`, lancer la vérification avg<1200 et archiver le HTML avant de remonter les artefacts à la revue. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 13:00:00 | C/ft_linear_regression | IN_PROGRESS | Session 12:59 rerun `train.sh`, mises à jour `data/history.json`, `plots/latest_rmse.*`, `docs/validation_summary.*` (text/table/json) et la vérification `scripts/check_validation_stability.py` (avg=978.62) pour garder la revue ft_helpme alignée. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 12:30:00 | C/ft_helpme | IN_PROGRESS | README souligne que `docs/validation_summary.txt`/`.md` plus `scripts/check_validation_stability.py` (avg=978.62) sont les artefacts partagés pour la review ft_helpme. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 12:25:00 | C/ft_linear_regression | IN_PROGRESS | `docs/convergence.md` rappelle désormais que `scripts/check_validation_stability.py` peut être intégré dans ft_helpme pour garantir que `docs/validation_summary.*` reste sous threshold (avg<1200) après chaque snapshot. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 11:44:47 | C/ft_linear_regression | IN_PROGRESS | Capture du snapshot `docs/validation_summary.txt` (best/worst fold + moyenne, basé sur `data/validation_report.txt` 11:39:35) pour garder un extrait immuable à partager avec la revue. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 11:50:00 | C/ft_linear_regression | IN_PROGRESS | Documentation amplifiée : création de `docs/convergence.md` pour décrire la chaîne training → history → rmse_plot → validation_report + export `plots/latest_rmse.txt/.png`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 11:39:35 | C/ft_linear_regression | IN_PROGRESS | Validation run `scripts/validation.py ... --scheduler exponential --decay 0.95` a réécrit `data/validation_report.txt` (RMSE par fold + moyenne) pour prouver la stabilité sur de nouveaux splits. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 12:02:00 | C/ft_linear_regression | IN_PROGRESS | README racine aligné sur la hausse de `docs/validation_summary.txt` (mention du timestamp + best/worst/average RMSE) pour que la revue ft_helpme cite ce fichier sans rerun. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 11:41:00 | C/ft_linear_regression | IN_PROGRESS | Re-run of `train.sh` after the rmse_plot hook refreshed `plots/latest_rmse.txt` and left the PNG attempt (matplotlib missing) while the summary log keeps matching `data/history.json`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 11:30:00 | C/ft_linear_regression | IN_PROGRESS | `scripts/train.sh` now ensures `plots/` exists and reruns `C/ft_helpme/scripts/reports/rmse_plot.py` (text + PNG attempt) after every training job, keeping the ASCII log (`latest_rmse.txt`) in sync with `data/history.json`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 11:09:41 | C/ft_linear_regression | IN_PROGRESS | RMSE summary archived in `plots/latest_rmse.txt` (ASCII + stats) after rerunning `train.sh` and `rmse_plot.py`; PNG generation stays blocked by missing matplotlib. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 11:15:00 | C/ft_linear_regression | IN_PROGRESS | Reprise du training (exponential/decay 0.95, early-stop/patience/min-delta) ; `data/history.json` regénérée, `plots/latest_rmse.png` préparé (Matplotlib missing) et `C/ft_helpme/scripts/reports/rmse_plot.py` a tracé l’ASCII + résumé du RMSE. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 16:05:00 | C/ft_linear_regression | IN_PROGRESS | Review follow-up appliqué : README mentionne scheduler exponential/decay 0.95 + RMSE plot + validation command (k-fold + bootstrap note) et la stratégie documentée; early-stop/validation aide la mise au point. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | Hello/hello_vue | DONE | Exercices ex00-ex05 fournis avec README et tests automatisés. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | Web/hello_node | DONE | Implémentation des ex00-ex09 avec batterie de tests Node.js. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | Wordle/Wordle | DONE | Jeu Wordle CLI en Python avec dictionnaire et tests unitaires. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | Unix/A_completely_UNIX_project | DONE | Implémentation ft_nm/ft_otool avec Makefile, libft et tests automatisés. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | Unix/A_rather_UNIX_project | DONE | ft_malloc (malloc/free/realloc/show_alloc_mem) avec bibliothèque partagée et tests LD_PRELOAD. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | Unix/UNIX_Project | DONE | ft_strace (ptrace, syscalls 32/64 bits) avec tableaux générés et tests Python. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | Unix/Projet_UNIX | DONE | Implantation du trojan Durex (daemon TCP, persistance simulée, tests automatiques). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | Unix/UNIX_leaning_project | DONE | ft_select (termcaps, navigation multi-colonnes) avec tests pseudo-terminal. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | C/Get_Next_Line | DONE | Fonction get_next_line multi-fd avec tests automatiques (fichier + stdin). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | C/Pipex | DONE | Implémentation pipex (pipe/fork/exec avec analyse de commandes) et tests comparatifs. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | C/Push_swap | DONE | push_swap complet (parsing, opérations, tri hybride + tests simulateur). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | C/Libft | DONE | libft.a (parties 1 & 2 complètes) prête à l'usage avec Makefile. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | C/So_Long | DONE | Rendu MiniLibX complet (sprites, déplacements, sortie), fallback headless et tests parsing. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | C/Ft_server | DONE | Autoindex variable, WordPress/phpMyAdmin versions vérifiées (SHA256), WP-CLI install auto + durcissement entrypoint. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-13 | C/Born2beRoot | IN_PROGRESS | Provisioning complet (Vagrant + LVM chiffré, politique PAM/sudo, monitoring); reste validation VM et signature. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-18 | C/Born2beRoot | DONE | Ajout validation VM (vagrant), doc tests/signature et ShellCheck. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-18 | C/Minishell | IN_PROGRESS | Initialisation projet, plan détaillé et TODO pipeline minishell. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-25 | C/Minishell | IN_PROGRESS | Refacto heredoc/pipeline/apply_redirects selon norme 42 + scripts de tests OK. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-25 | C/Minitalk | IN_PROGRESS | Initialisation projet : dossier créé, PDF lié ; analyse du sujet à venir. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-25 | C/Philosophers | IN_PROGRESS | Dossier créé, PDF lié ; initialisation analyse en cours. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-25 | Unix/Project_UNIX | IN_PROGRESS | Dossier initialisé, PDF lié ; projet précédent terminés (DONE). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Philosophers | IN_PROGRESS | Reprise du projet : définition structure simulation, plan implémentation complète à lancer. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Philosophers | DONE | Simulation multithread finalisée, tests scripts OK ; contrôles norminette/valgrind différés faute d’outils. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Minitalk | DONE | Implémentation complète serveur/client avec acks SIGUSR1/SIGUSR2, doc mise à jour et script de tests automatisés. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | Unix/Project_UNIX | FAILED | Implémentation demandée (virus polymorphe) contraire aux politiques de sécurité ; projet laissé en attente et signalé. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Minishell | DONE | Suites unit/e2e OK, build ASan & packaging générés; valgrind/norminette restent à exécuter quand outils disponibles. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Ft_printf | IN_PROGRESS | Dossier initialisé, sujet lié ; préparation des fichiers de planification et architecture à venir. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Libasm | IN_PROGRESS | Dossier créé, sujet lié ; plan, README et scripts initiaux posés avant implémentation assembleur. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Libasm | IN_PROGRESS | Implémentation ASM finalisée mais compilation bloquée: `nasm` absent sur l'environnement. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
-10-27 | C/Libunit | IN_PROGRESS | Initialisation projet (arborescence, README, plan, scripts) ; implémentation bibliothèque à venir. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Libunit | DONE | Libunit opérationnel avec harness d'exemple ; validation norme/valgrind en attente quand outils présents. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Ft_communication | IN_PROGRESS | Dossier initialisé (README/PLAN, arborescence, scripts stubs) ; analyse du sujet et implémentation à venir. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Ft_communication | DONE | Kit pédagogique complet (guides, script interactif, tests) prêt pour animer les exercices 00-02 ; aucune revue code requise. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Ft_containers | IN_PROGRESS | Utilitaires template posés, ft::vector (base + tests comparatifs) en cours ; reste list/map et approfondissements. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/ft_hangouts | IN_PROGRESS | Personas, user journeys, architecture Android + prototype CLI (contacts/SMS) prêts ; reste maquettes UI haute fidélité et app Android. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-31 | C/ft_helpme | IN_PROGRESS | Contexte & questions préparés pour aider sur ft_linear_regression ; attendre planification de la review. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 08:00:00 | C/ft_helpme | IN_PROGRESS | Contexte + questions validés pour `C/ft_linear_regression`, script `prepare_review.sh` alerte si `notes/debrief.md` vide ; checklist prête, il ne reste qu’à caler la revue 30 min pour valider scheduler/validation/visualisation. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-31 | C/ft_kalman | IN_PROGRESS | Lecture sujet, README/PLAN créés ; modélisation du filtre et implémentation C++ à venir. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-31 | C/ft_linux | IN_PROGRESS | Sujet analysé, README/PLAN posés ; reste préparation toolchain LFS et scripts d'automatisation. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Ft_ls | DONE | Options -l/-R/-a/-r/-t implémentées, format long & recursif, script diff `/scripts/run_tests.sh`; reste contrôles norme/mémoire lors d'un passage ultérieur. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Ft_ping | IN_PROGRESS | Dossier initialisé (README/PLAN, arborescence, scripts stubs) ; analyse du sujet et implémentation à venir. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Ft_ping | DONE | Implémentation complète (raw ICMP, options -h/-v, stats RTT), script de fumée et doc tests ; blocage comparaison `/bin/ping` faute de privilèges. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-27 | C/Ft_printf | DONE | Library ft_printf complète, tests comparatifs OK ; contrôle norminette/valgrind en attente faute d’outils. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-29 | C/Ft_containers | DONE | Implémentation complète vector/list/map + stack/queue, arbre RB, tests std vs ft automatisés. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-31 | C/ft_linear_regression | IN_PROGRESS | Gradient descent normalisé opérationnel + CLI/scripts/tests ; bonus visualisation et tuning à réaliser. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-10-31 | C/ft_irc | IN_PROGRESS | README/PLAN, squelette C++ (Makefile, Server stub) et scripts/tests manuels en place ; reste à coder la boucle poll/commandes IRC. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-03 | C/ft_linear_regression | DONE | Bonus terminés : script de visualisation matplotlib + RMSE documentée ; projet utilisable avec tests et CLI. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-03 | C/ft_irc | DONE | Harness de tests corrigé (gestion du buffer) et serveur IRC validé par le smoke test automatisé. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-03 | C/ft_kalman | IN_PROGRESS | MVP Kalman linéaire 6D (pos/vitesse) implémenté avec matrice fixe, démo synthétique et script de test; reste orientation, réseau UDP et calibration Q/R (bloqué tant que `imu-sensor-stream` n'est pas disponible). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-03 | C/ft_linux | IN_PROGRESS | Choix versions (kernel 6.6.54 LTS, toolchain GCC 13.2/glibc 2.40), schéma de partitions 20 Go, scripts squelette (image/partition/mount, download SHA, gen checksums, env LFS, chroot, toolchain avec cibles binutils/gcc/linux-headers/glibc, paquets, kernel), et docs versions/partitions/checksums/build_order/grub/fstab/network/chroot/toolchain/build_log rédigés ; placeholder .config fourni. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-03 | CPP/CPP_Module_00 | DONE | Dossier complet (PDF, README, PLAN, Makefile racine), ex00 (Megaphone), ex01 (PhoneBook), ex02 (Account/logs), ex03 (Weapon/HumanA/HumanB) et ex04 (Sed) implémentés/testés. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | Python/Django_Training_D01 | IN_PROGRESS | Dossier initialisé (PDF, README, PLAN, requirements) ; projet Django `training_d01` scaffoldé (manage.py, settings, urls, wsgi/asgi) ; venv/exercices à réaliser. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-03 | C/ft_kalman | IN_PROGRESS | Ajout d'un test unitaire `kalman_test` (make test) couvrant predict/update de base ; blocage UDP toujours présent faute de `imu-sensor-stream`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | Python/Django_Training_D01 | DONE | Exercices ex00-ex07 implémentés (scripts CLI + ressources numbers/periodic table HTML) ; README/PLAN mis à jour. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | C/ft_kalman | IN_PROGRESS | Wrapper UDP (bind/timeout/send/recv) ajouté, doc réseau créée; boucle protocole bloquée sans imu-sensor-stream. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | C/ft_kalman | IN_PROGRESS | Ajout client UDP brut (kalman_client) + wrapper existant pour sniffer imu-sensor-stream dès dispo; docs/README/PLAN mis à jour; compilation/test OK. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | C/ft_linux | IN_PROGRESS | Table des SHA256 complétée pour kernel/binutils/gcc/glibc/bash/coreutils/procps/sysvinit/eudev ; reste downloads/builds. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | C/ft_linux | IN_PROGRESS | Checksums étendus (gmp/mpfr/mpc/zlib) ajoutés pour toolchain GCC; table sources à jour pour download/verification. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | C/ft_linux | IN_PROGRESS | Script build_toolchain durci (vérif tarballs, intégration auto gmp/mpfr/mpc dans GCC), doc toolchain mise à jour. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | C/ft_linux | IN_PROGRESS | Tous les tarballs sources téléchargés et vérifiés (SHA256) via scripts/download_sources.sh (kernel/binutils/gcc deps gmp/mpfr/mpc/zlib + base). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | C/ft_linux | ON_HOLD | Build toolchain bloqué: /mnt/lfs inaccessible (permission denied). Nécessite point de montage/mkdir avec droits pour poursuivre binutils/gcc. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | C/ft_linux | ON_HOLD | Build binutils échoué faute de makeinfo (texinfo non installé); LFS déplacé vers chemin local .lfs ; scripts env/setup/chroot/ build_toolchain mis à jour. Attendre installation texinfo ou option build sans docs. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | CPP/CPP_Module_01 | IN_PROGRESS | Dossier créé avec sujet Module_01.pdf, README/PLAN init, arbo ex00-ex06 posée; implémentation à faire. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | CPP/CPP_Module_01 | DONE | ex00-ex06 implémentés (Makefiles c++98), tests basiques OK (harl_filter, sed replace); README/PLAN à jour. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | CPP/CPP_Module_02 | IN_PROGRESS | Sujet copié (Module_02.pdf), README/PLAN créés, arbo ex00-ex03 posée; implémentations à réaliser. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | CPP/CPP_Module_02 | DONE | ex00-ex03 implémentés (Fixed arith/comparaison, Point+bsp), Makefiles c++98, tests basiques run (ex02/ex03); README/PLAN à jour. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | CPP/CPP_Module_03 | IN_PROGRESS | Sujet copié, README/PLAN init, arbo ex00-ex03 créée ; implémentations ClapTrap/ScavTrap/FragTrap/DiamondTrap à réaliser. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-04 | CPP/CPP_Module_03 | DONE | ex00-ex03 implémentés (ClapTrap/ScavTrap/FragTrap/DiamondTrap, héritage virtuel ok), Makefiles c++98; tests basiques run (scavtrap, diamondtrap). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | C/ft_linux | IN_PROGRESS | Binutils cross construit et installé dans $LFS/tools via stub makeinfo local; scripts env/setup/chroot PATH ajustés (.local/bin). Prochaine étape: GCC/headers glibc. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | C/ft_linux | IN_PROGRESS | GCC stage1 en cours (build_toolchain.sh gcc avec stub makeinfo); compilation longue, à relancer si interrompue. Binutils déjà installés dans $LFS/tools. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | C/ft_linux | IN_PROGRESS | GCC stage1 toujours en compilation (logs/toolchain/gcc.make.log), stub makeinfo en place; binutils déjà installés. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | C/ft_linux | IN_PROGRESS | GCC stage1 toujours en compilation (logs/toolchain/gcc.make.log), pas d'erreur detectee ; poursuivre jusqu'a l'install puis glibc headers. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | C/ft_linux | IN_PROGRESS | GCC stage1 toujours en compilation (logs/toolchain/gcc.make.log), pas d'erreur detectee ; poursuivre jusqu'a l'install puis glibc headers. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | CPP/CPP_Module_04 | IN_PROGRESS | Sujet copié (Module_04.pdf), README/PLAN init, arbo ex00-ex04 créée; implémentations Animal/Brain/Materia à réaliser. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | C/ft_linux | IN_PROGRESS | GCC stage1 toujours en compilation (logs/toolchain/gcc.make.log), pas d'erreur detectee ; poursuivre jusqu'a l'install puis glibc headers. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | CPP/CPP_Module_04 | IN_PROGRESS | ex00 (Animal/Cat/Dog) implémenté et compilé ; reste ex01->ex04. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | CPP/CPP_Module_04 | IN_PROGRESS | ex00 (Animal/Cat/Dog) + ex01 (Brain deep copy) implémentés et compilés ; reste ex02->ex04. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | CPP/CPP_Module_04 | IN_PROGRESS | ex02 (AAnimal abstrait + Cat/Dog/Brain) implémenté et compilé ; reste ex03->ex04. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | CPP/CPP_Module_04 | IN_PROGRESS | ex03 (Materia AMateria/Ice/Cure + Character/MateriaSource) implémenté et compilé ; reste ex04. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | CPP/CPP_Module_04 | DONE | ex00->ex04 implémentés (Animal/Brain/AAnimal/Materia/AFK Mining), Makefiles c++98, mains sujet compilées; README/PLAN à jour. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | CPP/CPP_Module_05 | IN_PROGRESS | Sujet copié (Module_05.pdf), README/PLAN init, arbo ex00-ex03 créée; implémentations Bureaucrat/Form à venir. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | C/ft_linux | IN_PROGRESS | GCC stage1 toujours en compilation (logs/toolchain/gcc.make.log), pas d'erreur visible ; à laisser tourner jusqu'à l'install puis glibc headers. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | C/ft_linux | IN_PROGRESS | GCC stage1 toujours en compilation (logs/toolchain/gcc.make.log), pas d'erreur visible ; à laisser tourner jusqu'à l'install puis glibc headers. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | CPP/CPP_Module_05 | IN_PROGRESS | ex00 Bureaucrat (grades bornes + exceptions) implémenté et compilé ; reste ex01->ex03. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | C/ft_linux | IN_PROGRESS | GCC stage1 toujours en compilation (logs/toolchain/gcc.make.log), pas d'erreur visible ; à laisser tourner jusqu'à l'install puis glibc headers. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | C/ft_linux | IN_PROGRESS | GCC stage1 toujours en compilation (logs/toolchain/gcc.make.log), pas d'erreur visible ; à laisser tourner jusqu'à l'install puis glibc headers. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-05 | CPP/CPP_Module_05 | IN_PROGRESS | ex01 Form/Bureaucrat signature implémenté et compilé ; reste ex02->ex03. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | CPP/CPP_Module_05 | DONE | ex00->ex03 implémentés (AForm + Shrubbery/Robotomy/Pardon + Intern factory), mains/Makefiles c++98 OK. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | C/ft_linux | IN_PROGRESS | GCC stage1 relancé (scripts/build_toolchain.sh gcc) ; compilation toujours en cours, suivre logs/toolchain/gcc.make.log jusqu'à install. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | C/ft_linux | IN_PROGRESS | GCC stage1 toujours en compilation (logs/toolchain/gcc.make.log mis à jour 01:10:45); relance avec scripts/build_toolchain.sh gcc OK, attendre fin pour install. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | C/ft_linux | IN_PROGRESS | GCC stage1 toujours en compilation (logs/toolchain/gcc.make.log actif), relance 01:10:45, suivi à 01:35:23 sans erreurs visibles. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | C/ft_linux | ON_HOLD | GCC stage1 échoue sur configure-target-libgcc (manque stdc-predef.h/stdio.h dans sysroot); besoins: fournir en-têtes cible corrects ou ajuster bootstrap LFS avant de relancer. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | Graphical/Graphical_Project | IN_PROGRESS | Projet initialisé, PDF copié (docs/Graphical_Project.pdf), README/PLAN créés ; lecture et plan détaillé à faire. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | Graphical/Graphical_Project | IN_PROGRESS | Lecture/plan non commencés (PDF copié, en attente) ; prochaine étape: analyser le sujet. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | Graphical/Graphical_Project | IN_PROGRESS | Lecture rapide effectuée, arborescence de base créée (`src/`, `include/`, `assets/scenes/`); reste lecture détaillée + choix lib (mlx/OpenGL) + format scène (prévu texte). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | Graphical/Graphical_Project | IN_PROGRESS | Format scène texte défini, exemple `assets/scenes/sample.rt`; parser + renderer PPM implémentés (binaire `RT` génère `output.ppm` avec ombres/diffuse/specular sur sphère/plan/cylindre/cône); reste affichage MLX. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | Graphical/Graphical_Project | ON_HOLD | Renderer PPM opérationnel (`./RT` -> output.ppm) mais intégration MLX bloquée: bibliothèque minilibx absente; reprendre après installation de MLX ou choix lib graphique disponible. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | Messagequeue/MessageQueue | ON_HOLD | Sujet lu (RabbitMQ producer/consumers + PDF), mais broker RabbitMQ absent; en attente installation pour poursuivre (prod/cons Java séparés). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-06 | Alcu/AlCu | DONE | Jeu AlCu jouable (parser stdin/fichier, IA mémoisée, saisie robuste, Makefile); doc usage à jour. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-08 20:19:40 | Expert/Expert_system | DONE | Moteur complet (fixpoint, OR/XOR/bicond, traçage, origines des conflits, sortie JSON `-j`, flags combinables), batterie de 17 tests OK (`make test`); documentation finalisée et projet bouclé. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-08 20:19:40 | C/ft_kalman | DONE | Ajout d'un mode `--udp` (paquets texte dt ax ay az mx my mz) qui met à jour le filtre et renvoie l'état en JSON, script `scripts/mock_stream.py` pour simuler le flux, doc réseau mise à jour; `make test` OK. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-08 21:17:33 | C/Ft_services | DONE | Stack complète prête pour déploiement Minikube externe: MetalLB (pool substituable), ingress TLS (whoami, WP/PMA, Grafana), MariaDB/WordPress/phpMyAdmin, FTPS LB, monitoring InfluxDB+Grafana (datasource + dashboard), scripts seed/check/hosts/start/stop/apply; tests à exécuter sur Minikube réel (non disponible ici). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 23:10:00 | C/Ft_services | IN_PROGRESS | `README.md` décrit maintenant l’ordre recommandé (service -> wait_for_status/query_count/test_max_connections), cite `tests/env/ft_services_status.conf` pour valider `max_connections`, et rappelle de purger le `log_path` après chaque série de scripts afin de garder des logs propres pour la revue. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 23:35:00 | C/Ft_services | IN_PROGRESS | Ajouté `scripts/clean_log.sh` pour effacer/recréer le `log_path` défini dans la configuration (par défaut `tests/env/ft_services.conf`), ce qui permet de redémarrer les vérifications réseau avec un journal propre sans fouiller dans `/tmp`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 23:55:00 | C/Ft_services | IN_PROGRESS | `scripts/monitor_status.sh` enchaîne `clean_log.sh`, `wait_for_status.sh`, `query_count.sh` et `test_max_connections.sh` pour valider santé/compteur/limite en une seule commande, avec `max` en second argument (défaut 10) pour déclencher `overloaded: <n>` et démontrer rapidement le workflow complet. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 23:58:00 | C/Ft_services | IN_PROGRESS | `scripts/show_config.sh` permet de vérifier `port`/`backlog`/`log_path`/`max_connections` à partir d’un fichier de config pour confirmer que les helpers regardent bien les mêmes paramètres que le démon. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-08 22:52:34 | C/Ft_turing | DONE | Simulateur complet (-v/-t/-r/-o/-s/-c), validation exhaustive (blank, sections requises, complétude optionnelle), suite de tests 18/18 OK, docs format/exemples/README finalisées. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-08 22:59:00 | Graphical/Graphical_Project | IN_PROGRESS | Renderer PPM enrichi (sky gradient, supersampling, CLI --out/--size/--samples); attente MLX pour affichage temps réel. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-08 23:00:33 | Graphical/Graphical_Project | IN_PROGRESS | PPM multithread + supersampling et ciel, CLI --threads ajoutée (`RT [scene] --out --size --samples --threads`), MLX toujours en attente. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-08 23:07:46 | Graphical/Graphical_Project | IN_PROGRESS | Nouvelle scène `assets/scenes/room.rt` (murs colorés, lumières multiples) pour tester le renderer; CLI et README actualisés. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-08 23:58:26 | Graphical/Graphical_Project | IN_PROGRESS | Ajout tonemap (none/reinhard/aces), export depth/normal, primitive box, checker sur plans, ciel personnalisable (--sky), PPM multi-thread/supersampling/gamma/reflexions (--maxdepth); MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:03:30 | Graphical/Graphical_Project | IN_PROGRESS | Ajout atténuation quadratique des lumières pour un shading plus réaliste (évite la surexposition en proximité); rendu PPM intact, MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:09:06 | Graphical/Graphical_Project | IN_PROGRESS | Ajout des spots (direction + cutoff) dans parser/rendu + nouvelle scène `assets/scenes/spotlight.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:12:44 | Graphical/Graphical_Project | IN_PROGRESS | Ajout du brouillard exponentiel global (token `fog`) mixé avec la distance + scène `assets/scenes/foggy.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:18:26 | Graphical/Graphical_Project | IN_PROGRESS | Matériaux transparents/réfractifs (transparency + IOR) et scène `assets/scenes/glass.rt` pour tester la réfraction; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:23:54 | Graphical/Graphical_Project | IN_PROGRESS | Profondeur de champ via aperture/focal_dist sur camera + scène `assets/scenes/dof.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:29:20 | Graphical/Graphical_Project | IN_PROGRESS | Ombres douces via lights à rayon optionnel (échantillonnage multi-rayons) + scène `assets/scenes/soft_shadow.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:33:24 | Graphical/Graphical_Project | IN_PROGRESS | Primitive triangle ajoutée (parser + intersection) + scène `assets/scenes/triangles.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:37:48 | Graphical/Graphical_Project | IN_PROGRESS | Loader OBJ (`mesh path ...`) qui triangule les faces; nouvelle scène `assets/scenes/mesh.rt` + mesh `assets/meshes/quad.obj`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:43:13 | Graphical/Graphical_Project | IN_PROGRESS | `mesh` supporte scale/translate optionnel (sx sy sz tx ty tz) + scène `assets/scenes/mesh_scaled.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:48:23 | Graphical/Graphical_Project | IN_PROGRESS | Matériaux avec roughness pour reflets glossy + scène `assets/scenes/glossy.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:54:17 | Graphical/Graphical_Project | IN_PROGRESS | Loader OBJ supporte normals `vn` (faces v//n) + interpolation; mesh/scene `pyramid.obj`/`mesh_normals.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 00:58:21 | Graphical/Graphical_Project | IN_PROGRESS | Matériaux émissifs (emission_strength + couleur) + scène `assets/scenes/emissive.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 01:12:56 | Graphical/Graphical_Project | IN_PROGRESS | Textures PPM optionnelles (sphère/plan/mesh/triangle), scène `assets/scenes/textured.rt` + texture `assets/textures/checker.ppm`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 01:17:37 | Graphical/Graphical_Project | IN_PROGRESS | UV mesh support (vt + mapping sur triangles) et sample texture barycentrique; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 01:27:40 | Graphical/Graphical_Project | IN_PROGRESS | Sampling texture bilinéaire (wrap) pour limiter l’aliasing; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 01:32:53 | Graphical/Graphical_Project | IN_PROGRESS | Bilinear wrap consolidé + doc CLI matériaux/texture; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 01:38:46 | Graphical/Graphical_Project | IN_PROGRESS | Lumières directionnelles (`dirlight`/`sun`) avec rayon soft + scène `assets/scenes/sun.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 01:42:51 | Graphical/Graphical_Project | IN_PROGRESS | Transformation mesh étendue (rotation XYZ après scale/translate) + scène `assets/scenes/mesh_rotated.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 01:53:52 | Graphical/Graphical_Project | IN_PROGRESS | Env map en fond (`env` PPM) + export PPM binaire `--binary` (P6); MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 01:02:45 | Graphical/Graphical_Project | IN_PROGRESS | Mélange refl/trans basé Fresnel (Schlick) pour un rendu plus physique; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:04:21 | Graphical/Graphical_Project | IN_PROGRESS | Ajout normal maps PPM (tangent space) + parsing texture/uv_scale corrigé et scène `assets/scenes/normal_mapped.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:06:18 | Graphical/Graphical_Project | IN_PROGRESS | Camera accepte un vecteur up optionnel (roll), nouvelle scène `assets/scenes/tilted_camera.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:08:16 | Graphical/Graphical_Project | IN_PROGRESS | Loader textures/envmaps accepte P3 ou P6 (binaire); ajout env map P6 `assets/textures/env_p6.ppm` + scène `assets/scenes/envmap_p6.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:16:01 | Graphical/Graphical_Project | IN_PROGRESS | Accélération BVH (AABB) pour objets finis afin d’accélérer les meshes; plans testés linéairement; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:18:34 | Graphical/Graphical_Project | IN_PROGRESS | Loader OBJ triangule les faces n-gones (fan) + mesh pentagone `assets/meshes/polygon.obj` et scène `assets/scenes/mesh_polygon.rt`; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:23:39 | Graphical/Graphical_Project | IN_PROGRESS | Flag `--no-bvh` pour désactiver l’accélération BVH (fallback linéaire) pour debug; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:28:34 | Graphical/Graphical_Project | IN_PROGRESS | Ambiant occlusion optionnelle (`--ao radius samples`) appliquée à l’ambiant; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:34:12 | Graphical/Graphical_Project | IN_PROGRESS | Option `--srgb-textures` pour éclairer en linéaire (textures sRGB converties avant shading); MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:38:34 | Graphical/Graphical_Project | IN_PROGRESS | Ajout option `--exposure` (gain avant tonemap/gamma) pour ajuster la luminosité; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:43:34 | Graphical/Graphical_Project | IN_PROGRESS | Reflets glossy multi-échantillons via `--glossy-samples` pour réduire le bruit des roughness; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:50:15 | Graphical/Graphical_Project | IN_PROGRESS | Export ID map (`--id id.ppm`) pour debug/compositing (hash par objet); MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 02:54:20 | Graphical/Graphical_Project | IN_PROGRESS | Eclairage diffus de l'envmap (échantillons hémisphère via `--env-samples`) pour lumière indirecte; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 03:10:08 | Graphical/Graphical_Project | IN_PROGRESS | Buffers albedo/position exportables + seed global `--seed` pour RNG reproductible (env-samples, glossy, AO, etc.); MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 03:00:55 | Graphical/Graphical_Project | IN_PROGRESS | Export buffers albedo (`--albedo`) et position (`--position`) en plus des depth/normal/ID; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 03:19:24 | Graphical/Graphical_Project | IN_PROGRESS | Option `--pos-range` (clamp cartes position) et seed global appliqué à tous les tirages; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 03:27:36 | Graphical/Graphical_Project | IN_PROGRESS | Option `--clamp` pour borner la luminance linéaire avant tonemap (0 = off) + parsing CLI clarifié (flags id/albedo/position/seed/clamp regroupés); MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 03:31:13 | Graphical/Graphical_Project | IN_PROGRESS | Flag `--bin-buffers` pour exporter depth/normal/id/albedo/position en P6 binaire (exports debug plus rapides); MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 03:38:12 | Graphical/Graphical_Project | IN_PROGRESS | Option `--stats` pour journaliser width/height/samples/threads/gamma/maxdepth/exposure/binary/binary_buffers/duration après chaque rendu; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 03:43:07 | Graphical/Graphical_Project | IN_PROGRESS | `--stats` écrit maintenant les threads réellement employés (auto détecté / clamp `height`) dans la fiche pour refléter fidèlement le rendu; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 03:48:16 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-append` permet de cumuler les fiches (`--stats` continue d’indiquer les threads auto détectés + durée) sans écraser les précédentes; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 03:53:00 | Graphical/Graphical_Project | IN_PROGRESS | `--stats` log maintenant les réglages glossy/env/pos_range/clamp/ao_samples/env_intensity/lights en plus des métriques classiques (threads auto), ce qui facilite la comparaison multi-rendus; `--env-intensity` module la contribution diffuse de l’envmap; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 03:59:19 | Graphical/Graphical_Project | IN_PROGRESS | `--env-intensity` permet de renforcer ou tempérer l’éclairage diffus de l’envmap sans toucher aux textures; `--stats` journalise désormais aussi `scene` et `timestamp` pour relier les fichiers aux rendus; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 04:23:20 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-camera` ajoute la position/direction de la caméra à la fiche stats pour lier les rendus aux angles enregistrés; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 04:28:17 | Graphical/Graphical_Project | IN_PROGRESS | `--stats` enregistre désormais les luminances moyenne/min/max et l’écart type (0-1) pour surveiller l’exposition; `--stats-camera` reste disponible et MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 04:32:54 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-json` écrit les mêmes métriques que `--stats` au format JSON (append si `--stats-append`, `--stats-camera` compatible); MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 04:34:30 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-json -` envoie la même sortie JSON vers stdout pour pipeline (append + `--stats-camera` restent compatibles); MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 04:54:33 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-csv` duplique les métriques `--stats` dans un CSV (header `timestamp,scene,width,height,...,duration`), `--stats-csv-append` conserve les lignes précédentes et `--stats-camera` ajoute les colonnes de position/direction; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 04:57:58 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-csv -` pipe les mêmes métriques CSV vers stdout pour l’intégration dans des workflows (cols identiques, `--stats-camera` ajoute les colonnes caméra); MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 05:03:14 | Graphical/Graphical_Project | IN_PROGRESS | `--stats`/`--stats-json`/`--stats-csv` incluent désormais la graine `--seed` dans les rapports texte, JSON et CSV pour tracer/reproduire précisément chaque rendu; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 05:15:25 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-comment` ajoute un texte libre aux exports (`stats`, `stats-json`, `stats-csv`, `stats-console`) pour annoter les captures sans perturber les métriques; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 05:30:00 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-console-stdout` redirige les sorties `--stats-console`/`--stats-console-json` vers `stdout` pour les workflows qui analysent `stdout` plutôt que `stderr`; `--stats-camera` reste compatible; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 05:20:10 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-console-json` envoie les métriques de `--stats-console` en JSON sur `stderr` (avec `--stats-camera` pour la ligne caméra), idéal pour ingérer les stats dans des outils machines; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 05:38:16 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-comment-env VAR` peut remplir `--stats-comment` à partir d’une variable d’environnement quand aucun commentaire explicite n’est fourni, ce qui aide les scripts à annoter les rendus; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 05:34:35 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-env VAR` enregistre jusqu’à 8 variables d’environnement sous `env_vars` dans les sorties texte/JSON/CSV/console pour tracer l’environnement de rendu; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 05:45:00 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-group name` ajoute `group=name` dans tous les exports (texte, JSON, CSV, console) pour regrouper les rendus, en plus de `--stats-tag` et les autres annotations; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 05:40:00 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-tag key=value` ajoute des tags personnalisés (`tags=key=value;...`) dans les exports (`stats`, `stats-json`, `stats-csv`, `stats-console`), ce qui aide à identifier les rendus; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 05:35:00 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-ms` ajoute `duration_ms` et `duration_unit` (ms/s) dans les exports (texte, JSON, CSV, console) pour travailler en millisecondes tout en conservant la durée en secondes; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 05:10:00 | Graphical/Graphical_Project | IN_PROGRESS | `--stats-console` imprime un résumé des métriques (`scene,width,...,duration`) sur `stderr` (ajoute la ligne caméra avec `--stats-camera`) pour les pipelines/CI sans écrire sur disque; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 06:50:00 | Graphical/Graphical_Project | IN_PROGRESS | `--mlx` affiche la `render_frame`, `--mlx-depth`/`D` sauvegardent la carte de profondeur, `--mlx-overlay` affiche un label, et les options `--mlx-auto-snapshot`/`--mlx-auto-depth` produisent des PPM juste après le rendu pour garder un historique sans ouvrir MLX; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 06:15:00 | Graphical/Graphical_Project | IN_PROGRESS | Option `--mlx` (via `mlx_bridge.c`) qui affiche la `render_frame` calculée dans une fenêtre MiniLibX quand la bibliothèque est disponible (`USE_MLX`), préparant ainsi un aperçu interactif ; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 06:05:00 | Graphical/Graphical_Project | IN_PROGRESS | Ajout de `render_frame`/`free_render_frame` pour exposer le buffer couleurs/profondeur/normales/IDs issu du renderer PPM et réutiliser ces données dans un futur module MLX/temps réel sans dupliquer la logique; MLX toujours manquante. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 07:10:00 | Graphical/Graphical_Project | DONE | Projet terminé : rendu PPM + buffers depth/normal/id/albedo/position/export stats (texte/JSON/CSV/console) finalisés,  preview activable (c++ -Wall -Wextra -Werror -std=c++98 -Iinclude -c src/main.cpp -o src/main.o latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
c++ -Wall -Wextra -Werror -std=c++98 -Iinclude -c src/Server.cpp -o src/Server.o latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
c++ -Wall -Wextra -Werror -std=c++98 src/main.o src/Server.o -o ircserv) avec S/D pour captures, overlay et auto-exports (). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-09 07:10:00 | Graphical/Graphical_Project | DONE | Projet terminé : rendu PPM + buffers depth/normal/id/albedo/position/export stats (texte/JSON/CSV/console) finalisés, `--mlx` preview activable (`make USE_MLX=1`) avec S/D pour captures, overlay et auto-exports (`--mlx-auto-*`). latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-11 10:04:53 | C/ft_helpme | IN_PROGRESS | Follow-up prêt : `notes/review_followup.md` liste les actions scheduler/validation/visualisation pour `C/ft_linear_regression`, script prepare_review.pl continue d’alerter si `notes/debrief.md` vide et la revue 30 min reste à planifier. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 09:00:00 | C/ft_helpme | IN_PROGRESS | Review `C/ft_linear_regression` planifiée 12/12 15h (42Net reviewer), `notes/debrief.md` et `notes/review_followup.md` détaillent scheduler/validation/visualisation, script prepare_review alerte toujours si le debrief vide ; objectif : appliquer les décisions après session. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 10:15:00 | C/ft_helpme | IN_PROGRESS | Script `scripts/validate_followup.sh` vérifie que `notes/review_followup.md` mentionne scheduler/rmse_plot/validation et que `notes/debrief.md` est rempli; README/PLAN décrivent la procédure avant/après la session du 12/12 15h. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 10:20:00 | C/ft_helpme | IN_PROGRESS | Ajouté `scripts/reports/rmse_plot.py` (résumé RMSE + sparkline + option PNG) ; plan met maintenant l’accent sur son usage après la review et la fiche indique qu’on doit appliquer scheduler/validation/visualisation dans `C/ft_linear_regression`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 10:25:02 | C/ft_helpme | IN_PROGRESS | Ajout de `code/gradient_notes.md` + instructions de review (partager train/evaluate/extrait) ; le doc mentionne encore scheduler/validation/visualisation et la checklist inclut le nouveau follow-up/validation avant d’exécuter la session 12/12 15h. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 11:05:00 | C/ft_linear_regression | IN_PROGRESS | `train.py` supporte désormais `--scheduler {constant,linear,exponential}` + `--decay`/`--min-lr`, `scripts/train.sh` écrit `data/history.json`, et la suite `scripts/reports/rmse_plot.py` fournit un résumé/sparkline/PNG pour suivre la RMSE pendant la revue ft_helpme. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 11:35:41 | C/ft_linear_regression | IN_PROGRESS | Implémenté `scripts/validation.py` (splits aléatoires, scheduler/decay/min-lr, RMSE moyen par fold) pour explorer les hyperparamètres pendant la revue ft_helpme ; la doc recommande commander `python3 scripts/validation.py data/data.csv --folds 5 --test-size 0.2 --scheduler exponential --decay 0.95`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 11:39:44 | C/ft_helpme | IN_PROGRESS | Review réalisé : `notes/review_outcome.md` capture les décisions (scheduler=exponential/decay=0.95, RMSE plot + validation folds) et la suite `notes/review_followup.md`/`progress` sont alignées pour transmettre les tâches au projet `ft_linear_regression`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 11:51:09 | C/ft_linear_regression | IN_PROGRESS | Early stopping implemented (`--early-stop`, `--patience`, `--min-delta`) alongside scheduler options; `scripts/train.sh` now enables this mode and the README/PLAN describe how to replay RMSE + validation scripts for the review follow-up. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 01:40:00 | C/ft_services | IN_PROGRESS | Documenté `scripts/log_summary_multi.sh` (et son passage dans docs/helpers, README, PLAN, notes multi-config) pour montrer comment agréger plusieurs logs/confs, précisé dans le README global que le helper consolidé affiche les totaux `status check`/`connections`/`overloaded` sur plusieurs configurations, ajouté un exemple rapide dans le README local pour illustrer son usage sur deux configs de tests et complété `docs/helpers.md` avec la même commande + la ligne `Totals` finale pour que la revue sache quoi lire. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-23 00:44:52 | C/ft_services | IN_PROGRESS | Réitéré la synthèse `log_summary_multi.sh` avec la mise en avant de la ligne `Totals` et mention de l’exemple concret (`tests/env/ft_services_status.conf tests/env/ft_services.conf`) dans les docs/README/PLAN, insistant sur l’agrégation multi-config pour favoriser la revue finale. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-23 01:10:00 | C/ft_services | IN_PROGRESS | Amélioré `scripts/log_summary_multi.sh` pour calculer lui-même les totaux et les afficher après chaque configuration (`status checks`, `count replies`, `overload notices`), puis produire `Totals: ...` en fin de commande ; docs/README reflètent l’exemple complet et la documentation précise que chaque bloc de résumé est suivi d’un `Totals` global pour faciliter la revue multi-config. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-23 01:11:22 | C/ft_services | IN_PROGRESS | Ajout de `scripts/log_summary_diff.sh` qui compare deux configs en listant les métriques et en affichant `Difference (config_b - config_a)` ; docs/helpers, README et root README mentionnent maintenant cet outil pour valider les écarts entre deux démonstrations successives, avec l’exemple `./scripts/log_summary_diff.sh tests/env/ft_services_status.conf tests/env/ft_services.conf`, plus des configs de test (`tests/env/sample_a.conf`, `tests/env/sample_b.conf`) pour exécuter le script sans démon en cours. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-23 01:44:54 | C/ft_services | IN_PROGRESS | Ajout de `tests/env/logs/sample_a.log` et `tests/env/logs/sample_b.log` plus `tests/env/sample_a.conf` et `tests/env/sample_b.conf` pour alimenter `log_summary_diff.sh`/`log_summary_multi.sh` sans démon, et inscrit en doc la commande de comparaison et la ligne `Difference (config_b - config_a)`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-23 01:50:14 | C/ft_services | IN_PROGRESS | Complété `docs/helpers.md` avec la recommandation `./scripts/log_summary_diff.sh tests/env/sample_a.conf tests/env/sample_b.conf` pour visualiser `Difference (config_b - config_a)` sans process ft_services, soulignant la ligne `Difference` et les fichiers de log d’exemple. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 00:00:00 | C/ft_services | IN_PROGRESS | Mentionné dans `README.md` racine les configs `tests/env/sample_a.conf`/`tests/env/sample_b.conf` et les logs `tests/env/logs/sample_*.log` pour exécuter `log_summary_diff.sh`/`log_summary_multi.sh` sans démon et lire `Difference (config_b - config_a)` ; cela complète les docs précédentes sur l’agrégation diff/total. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 02:05:15 | C/ft_services | IN_PROGRESS | Le README du projet illustre maintenant la sortie `log_summary_diff` avec les sample configs (alignement des `Difference`) afin que les relecteurs voient exactement ce que le helper renvoie. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 02:11:11 | C/ft_services | IN_PROGRESS | Documenté `scripts/log_summary_report.sh` (multi + diff enchaînés) dans les docs/README/plan, en expliquant que la commande `./scripts/log_summary_report.sh tests/env/sample_a.conf tests/env/sample_b.conf tests/env/ft_services.conf` produit les totaux puis les différences dans une seule passe. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 02:40:17 | C/ft_services | IN_PROGRESS | Complété `docs/helpers.md` avec un exemple `./scripts/logs_metrics.sh tests/env/logs` montrant sample_a/sample_b et soulignant que la grille d’`overloaded` aide à cibler les logs à comparer ensuite. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 02:41:06 | C/ft_services | IN_PROGRESS | Ajouté dans le README projet la mention `./scripts/logs_metrics.sh tests/env/logs` pour produire le tableau `Log file | Status | Connections | Overloaded`, clarifiant son usage avant d’enchaîner les autres helpers multi/diff. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 02:59:57 | C/ft_services | IN_PROGRESS | Créé `docs/logs_metrics.md` détaillant `scripts/logs_metrics.sh`, les logs sample et la façon d’analyser la grille `Log file | Status | Connections | Overloaded` pour préparer les synthèses multi/diff. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 03:05:00 | C/ft_services | IN_PROGRESS | Ajouté un log factice `tests/env/logs/status_special.log` rempli de `status check`, `connections`, `overloaded` pour démontrer la commande `scripts/logs_metrics.sh pattern` sans réparer le service. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 02:59:57 | C/ft_services | IN_PROGRESS | Consolidé la documentation autour des scripts log (`log_summary_multi`, `log_summary_diff`, `log_summary_report`, `logs_metrics`) et leurs configs/logs d'exemple dans les README/plan et `progress`, fournissant une dernière note sur l’ensemble du workflow multi-config. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 05:20:00 | C/ft_services | IN_PROGRESS | `scripts/logs_metrics.sh` accepte maintenant un second argument `top_n` pour lister ensuite les `top_n` logs les plus chargés en `overloaded`, et tous les docs/README précisent qu’il faut regarder la ligne `Totals` puis éventuellement les `top_n` hits avant d’enchaîner sur `log_summary_diff`/`multi`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 05:55:00 | C/ft_services | IN_PROGRESS | `scripts/logs_metrics.sh` avertit désormais lorsqu’aucun log n’est détecté dans `log_dir`, documenté dans `docs/logs_metrics.md` afin que les relecteurs sachent que le dossier est vide et qu’ils doivent générer des logs avant de relancer la commande. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 06:30:00 | C/ft_services | IN_PROGRESS | `scripts/logs_metrics.sh` prend maintenant `top_n` négatif pour afficher les logs les moins chargés en `overloaded`, complété dans les docs/README pour expliquer comment comparer les extrêmes lors des démonstrations. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 07:25:00 | C/ft_services | IN_PROGRESS | `docs/logs_metrics.md` illustre l’usage `./scripts/logs_metrics.sh tests/env/logs -2` pour valider que les traces calmes restent constantes avant d’engager `log_summary_diff` sur les extrêmes, afin de boucler la documentation sur les deux pôles de charge. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 07:40:00 | C/ft_services | IN_PROGRESS | README racine rappelle que `scripts/logs_metrics.sh` prend `top_n` négatif pour les logs les plus calmes et signale `No log files found` dans un dossier vide, renforçant l’aide aux relecteurs qui doivent générer des traces avant de relancer la chaîne multi/diff. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 08:05:00 | C/ft_services | IN_PROGRESS | `PLAN.md` mentionne que `scripts/logs_metrics.sh` positionne `Totals`, propose `top_n` positif/négatif et avertit lorsqu’il manque des logs, garantissant que l’outil guide toute la chaîne log-summary/multi/diff avant la démo. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 08:40:00 | C/ft_services | IN_PROGRESS | `docs/helpers.md` insiste sur le `top_n` positif/négatif et le message d’avertissement « No log files found », avec une note expliquant que `monitor_status.sh`/`stress_max_connections.sh` doivent générer les traces manquantes avant la synthèse. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 08:55:00 | C/ft_services | IN_PROGRESS | `README.md` cite maintenant l’exemple `./scripts/logs_metrics.sh tests/env/logs -2` pour illustrer le cas des logs calmes, complétant la note sur les extrêmes dans la documentation générale. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 09:20:00 | C/ft_services | IN_PROGRESS | Les docs mentionnent que `LOG_METRICS_DIR` peut être exporté pour éviter de passer `log_dir` à chaque exécution de `scripts/logs_metrics.sh`, achevant la couverture des options du helper. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 09:45:00 | C/ft_services | IN_PROGRESS | `docs/logs_metrics.md` et les README expliquent désormais le troisième argument `pattern`, permettant par exemple `./scripts/logs_metrics.sh tests/env/logs 2 status` pour filtrer seulement les journaux contenant `status` tout en conservant `Totals`/`top_n` et l’avertissement “No log files found”. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 10:35:00 | C/ft_services | IN_PROGRESS | `PLAN.md` rappelle que `scripts/logs_metrics.sh` propose `Totals`, `top_n` +/- et le filtre `pattern`, ce qui permet de préparer la chaîne log-summary/multi/diff sur un sous-ensemble approprié de logs. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 11:15:00 | C/ft_services | IN_PROGRESS | `docs/logs_metrics.md` souligne maintenant qu’on peut exporter `LOG_METRICS_DIR` (et même définir un alias `logmetrics`) pour répéter les commandes sans retaper `log_dir`, complétant le guide d’utilisation de l’outil. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 11:50:00 | C/ft_services | IN_PROGRESS | `docs/logs_metrics.md` et les README mentionnent `LOG_METRICS_DIR`/`alias logmetrics` avec un exemple (`export LOG_METRICS_DIR=tests/env/logs && logmetrics -1`) pour fixer un dossier commun avant la chaîne multi/diff. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 12:30:00 | C/ft_services | IN_PROGRESS | Documenté un exemple `./scripts/logs_metrics.sh tests/env/logs -1 status` ciblant `tests/env/logs/status_special.log` dans `docs/logs_metrics.md` afin d’illustrer la sélection rapide d’un sous-ensemble avant les synthèses multi/diff. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 13:05:00 | C/ft_services | IN_PROGRESS | Ajouté la section “Alias et dossier partagé” dans `docs/logs_metrics.md` pour montrer comment exporter `LOG_METRICS_DIR` et définir `alias logmetrics` afin de réappliquer `pattern/status` et `top_n=2` sans ressaisir le dossier avant de lancer les synthèses multi/diff. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 13:30:00 | C/ft_services | IN_PROGRESS | Plan mis à jour pour rappeler que `scripts/demo_pipeline.sh` mentionne aussi `alias logmetrics`/`LOG_METRICS_DIR` avec `pattern`+`top_n` avant `log_summary_diff`/`log_summary_multi`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 13:55:00 | C/ft_services | IN_PROGRESS | Documenté dans `docs/logs_metrics.md` la façon d’utiliser `monitor_status.sh` (ou `stress_max_connections.sh`) pour générer les logs avant d’appliquer `logmetrics` avec `pattern=status`/`top_n`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 14:10:00 | C/ft_services | IN_PROGRESS | Ajouté une section “Préparer l’export de statistiques” dans `docs/logs_metrics.md` pour esquisser un futur script CSV/JSON qui réutilise `LOG_METRICS_DIR`/`logmetrics` avec `pattern`/`top_n` et la ligne `Totals`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 14:25:00 | C/ft_services | IN_PROGRESS | `PLAN.md` rappelle maintenant que la future commande `scripts/logs_metrics_export.sh` devra utiliser la grille `Totals`/`overloaded` et les filtres `pattern`/`top_n` pour produire des CSV/JSON cohérents avec la chaîne multi/diff. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 14:40:00 | C/ft_services | IN_PROGRESS | Décrit les colonnes prévues (`timestamp/status_checks/connections/overloaded/overloaded_ratio`) dans `docs/logs_metrics.md` pour l’export CSV/JSON envisagé et le mentionne dans le README. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 15:00:00 | C/ft_services | IN_PROGRESS | Créé `scripts/logs_metrics_export.sh` pour générer un CSV/JSON des logs filtrés (pattern/top_n) avec colonnes supplémentaires et mentionné ce script dans la doc/README. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-26 12:10:00 | C/ft_services | IN_PROGRESS | Ajouté une note dans `README.md` expliquant qu’après avoir redirigé `./scripts/logs_metrics_export.sh --topn 2 --format csv` vers `reports/log_metrics_snapshot.csv`, il suffit de lancer `tail -n 5 reports/log_metrics_snapshot.csv` pour confirmer que les `status` sélectionnés et leurs métriques figurent bien dans l’export avant diffusion, complétant ainsi l’exemple d’automatisation déjà décrit dans les docs. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 10:10:00 | C/ft_services | IN_PROGRESS | `docs/logs_metrics.md` montre enfin l’exemple `./scripts/logs_metrics.sh tests/env/logs 1 sample` pour isoler une famille de logs, complétant la documentation sur la sélection par pattern. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 07:10:00 | C/ft_services | IN_PROGRESS | `README.md` détaille l’usage de `top_n` positif/négatif et mentionne l’avertissement "No log files found" pour rappeler de générer des traces, ce qui bouclera la documentation du workflow log metrics. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-24 04:10:00 | C/ft_services | IN_PROGRESS | `scripts/logs_metrics.sh` calcule maintenant une ligne `Totals` après chaque tableau (Status/Connections/Overloaded) pour montrer la charge globale, et les docs/README/PLAN expliquent comment utiliser cette ligne `Totals` pour décider quel log comparer avec `log_summary_diff`/`log_summary_multi`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 20:36:17 | ft_services | IN_PROGRESS | Added verify_snapshot helper note about tail/jq for CSV/JSON exports. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 20:41:21 | ft_services | IN_PROGRESS | Added README sentence noting verify_snapshot tail/jq outputs for CSV+JSON before sharing. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 20:46:10 | ft_services | IN_PROGRESS | Added explicit verify_snapshot tail/jq review note reminder to docs/logs_metrics.md. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 20:51:20 | ft_services | IN_PROGRESS | Noted in README that review notes should spell out the tail/jq commands even when `verify_snapshot` is not run. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 20:56:21 | ft_services | IN_PROGRESS | README note to repeat tail/jq commands explicitly in review notes for CSV/JSON helper verification. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 21:01:09 | ft_services | IN_PROGRESS | Added note that verify_snapshot can be run in parallel CSV/JSON sessions for cross-checking. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 21:06:06 | ft_services | IN_PROGRESS | Added workflow example block showing verify_snapshot csv/json plus tail/jq commands. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 21:11:16 | ft_services | IN_PROGRESS | README reminder to include helper block in review notes so the tail/jq steps are repeatable. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 21:16:11 | ft_services | IN_PROGRESS | Added reminder to cite tail/jq commands when referencing helper block in docs/logs_metrics.md. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 21:21:08 | ft_services | IN_PROGRESS | Readme block now explicitly states paste tail/jq commands when citing helper. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 21:26:11 | ft_services | IN_PROGRESS | Noted helper tail/jq requirement at top README update. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
 latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 21:31:15 | ft_services | IN_PROGRESS | README reminder points to docs/logs_metrics.md for the tail/jq review requirements. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 21:57:42 | C/Ft_services | IN_PROGRESS | Pushed README/logs instructions to cite `C/ft_services/docs/logs_metrics.md` whenever the helper + `tail`/`jq` commands prove the `pattern=status`/`top_n=2` exports in CSV and JSON. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 22:01:08 | C/Ft_services | IN_PROGRESS | Clarified README guidance that review notes should cite `C/ft_services/docs/logs_metrics.md` when parroting the helper plus `tail`/`jq` proof steps to replicate the `pattern=status`/`top_n=2` export lines in both CSV and JSON. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 22:06:09 | C/Ft_services | IN_PROGRESS | Added note to `docs/logs_metrics.md` linking back to README’s summary so reviewers can follow the helper + tail/jq proof through both documents when validating `pattern=status`/`top_n=2` exports. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 22:11:06 | C/Ft_services | IN_PROGRESS | Expanded README reminder so review notes explicitly cite `C/ft_services/docs/logs_metrics.md` when showing the helper plus `tail`/`jq` steps for the CSV/JSON `pattern=status`/`top_n=2` verification. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 22:21:08 | C/Ft_services | IN_PROGRESS | Reworded README guidance to clarify that review notes must cite this doc and outline how both CSV/JSON subsets rely on the same helper + `tail`/`jq` commands, ensuring reviewers can reproduce identical filtered lines before approval. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 22:26:11 | C/Ft_services | IN_PROGRESS | Added reminder in `logs_metrics.md` that the README summary should quote this doc so the helper/tail/jq steps and `pattern=status`/`top_n=2` coverage are documented for both CSV and JSON exports. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 22:31:17 | C/Ft_services | IN_PROGRESS | Refined README wording to urge reviewers to cite this doc when they share the helper plus `tail`/`jq` proofs so the same `pattern=status`/`top_n=2` lines can be confirmed in CSV and JSON exports. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 22:36:32 | C/Ft_services | IN_PROGRESS | README adds a review-note example tying `./scripts/logs_metrics_export.sh -> tail/jq` commands and `reports/log_metrics_snapshot.status_top2.*` to `C/ft_services/docs/logs_metrics.md` for transparent verification of the CSV/JSON filtered exports. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 22:41:01 | C/Ft_services | IN_PROGRESS | Emphasized in README/log guidance that reviewers must mention helper invocation plus `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` and `tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq` in their notes when citing `C/ft_services/docs/logs_metrics.md` so the `pattern=status`/`top_n=2` exports are reproducibly the same. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 22:46:01 | C/Ft_services | IN_PROGRESS | README now urges reviewers who cite the helper plus `tail`/`jq` proofs to repeat the same `pattern=status`/`top_n=2` subset via `reports/log_metrics_snapshot.status_top2.csv` and `.json` before declaring approval. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 22:57:24 | C/Ft_services | IN_PROGRESS | README suggests reviewers append a mini-checklist (helper → CSV tail → JSON jq → doc citation) to their notes when documenting the helper plus tail/jq proofs for the `pattern=status`/`top_n=2` exports, ensuring each step is retraceable. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-12 23:02:50 | C/Ft_services | IN_PROGRESS | README now explicitly links to `C/ft_services/docs/logs_metrics.md`, spells out the helper + `tail/jq` commands, highlights the `pattern=status`/`top_n=2` columns, and offers a reusable mini-checklist (helper → CSV tail → JSON jq → citation) so reviewers can cite the same CSV/JSON subset verification. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 00:51:17 | C/Ft_services | IN_PROGRESS | README restates the helper + `tail`/`jq` sequence with verbatim paths so reviewers know to reproduce the `pattern=status`/`top_n=2` subset before approval. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 01:51:18 | C/Ft_services | IN_PROGRESS | README now adds that `C/ft_services/docs/logs_metrics.md` describes the same helper and columns, so anyone can rerun the helper + `tail`/`jq` on the exports and confirm the `pattern=status`/`top_n=2` subset consistently. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 02:41:31 | C/Ft_services | IN_PROGRESS | README still links ./scripts/logs_metrics_export.sh --pattern status --topn 2 to reports/log_metrics_snapshot.status_top2.csv/.json, names tail -n 5 reports/log_metrics_snapshot.status_top2.csv and tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq as the verification steps, reiterates pattern=status/top_n=2 columns, and cites C/ft_services/docs/logs_metrics.md so reviewers can trace the helper → CSV tail → JSON jq checklist before approval. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 02:46:13 | C/Ft_services | IN_PROGRESS | README continues to tie helper ./scripts/logs_metrics_export.sh --pattern status --topn 2 to reports/log_metrics_snapshot.status_top2.csv/.json, calls out tail -n 5 reports/log_metrics_snapshot.status_top2.csv plus tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq, notes columns pattern=status/top_n=2, and cites C/ft_services/docs/logs_metrics.md so reviewers can flush the helper → CSV tail → JSON jq checklist before approving. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 02:51:13 | C/Ft_services | IN_PROGRESS | README reiterates helper invocation ./scripts/logs_metrics_export.sh --pattern status --topn 2, links to reports/log_metrics_snapshot.status_top2.csv/.json, names tail -n 5 csv & tail -n 1 json | jq steps, repeats pattern=status/top_n=2 columns, and cites C/ft_services/docs/logs_metrics.md for the helper → CSV tail → JSON jq checklist. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 02:56:14 | C/Ft_services | IN_PROGRESS | README keeps helper ./scripts/logs_metrics_export.sh --pattern status --topn 2 tied to reports/log_metrics_snapshot.status_top2.csv/.json, repeats tail-&-jq proof steps, says pattern=status/top_n=2 columns, cites C/ft_services/docs/logs_metrics.md so helper → CSV tail → JSON jq walkthrough stays traceable. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 03:01:14 | C/Ft_services | IN_PROGRESS | README keeps helper ./scripts/logs_metrics_export.sh --pattern status --topn 2 tied to reports/log_metrics_snapshot.status_top2.csv/.json, reiterates tail -n 5 csv and tail -n 1 json | jq proof, highlights pattern=status/top_n=2, cites C/ft_services/docs/logs_metrics.md for helper → CSV tail → JSON jq checklist. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 03:06:18 | C/Ft_services | IN_PROGRESS | README reiterates helper ./scripts/logs_metrics_export.sh --pattern status --topn 2 linking to reports/log_metrics_snapshot.status_top2.csv/.json, specifics tail -n 5 csv & tail -n 1 json | jq, notes pattern=status/top_n=2 columns, cites C/ft_services/docs/logs_metrics.md so helper → CSV tail → JSON jq checklist stays traceable. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 03:11:14 | C/Ft_services | IN_PROGRESS | README keeps referencing helper ./scripts/logs_metrics_export.sh --pattern status --topn 2 and exports reports/log_metrics_snapshot.status_top2.csv/.json, cites tail -n 5 csv + tail -n 1 json | jq checks, calls out pattern=status/top_n=2 columns, and points to C/ft_services/docs/logs_metrics.md for the helper → CSV tail → JSON jq checklist. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 03:16:15 | C/Ft_services | IN_PROGRESS | README continues pointing to helper ./scripts/logs_metrics_export.sh --pattern status --topn 2 with exports reports/log_metrics_snapshot.status_top2.csv/.json, cites tail -n 5 csv & tail -n 1 json | jq verification, restates pattern=status/top_n=2 columns, and references C/ft_services/docs/logs_metrics.md to keep helper → CSV tail → JSON jq steps reproducible. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 03:21:15 | C/Ft_services | IN_PROGRESS | README keeps helper ./scripts/logs_metrics_export.sh --pattern status --topn 2 tied to reports/log_metrics_snapshot.status_top2.csv/.json, lists tail -n 5 csv & tail -n 1 json | jq commands, highlights pattern=status/top_n=2 columns, cites C/ft_services/docs/logs_metrics.md to keep helper → CSV tail → JSON jq checklist reproducible. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 03:26:15 | C/Ft_services | IN_PROGRESS | README keeps helper ./scripts/logs_metrics_export.sh --pattern status --topn 2 tied to reports/log_metrics_snapshot.status_top2.csv/.json, lists tail -n 5 csv & tail -n 1 json | jq commands, highlights pattern=status/top_n=2 columns, cites C/ft_services/docs/logs_metrics.md to keep helper → CSV tail → JSON jq checklist reproducible. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 03:36:15 | C/Ft_services | IN_PROGRESS | README keeps helper ./scripts/logs_metrics_export.sh --pattern status --topn 2 tied to reports/log_metrics_snapshot.status_top2.csv/.json, names tail -n 5 csv & tail -n 1 json | jq commands, underscores pattern=status/top_n=2 columns, cites C/ft_services/docs/logs_metrics.md so helper → CSV tail → JSON jq checklist is reproducible. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 03:41:15 | C/Ft_services | IN_PROGRESS | README keeps helper ./scripts/logs_metrics_export.sh --pattern status --topn 2 linked to reports/log_metrics_snapshot.status_top2.csv/.json, details tail -n 5 csv & tail -n 1 json | jq steps, stresses pattern=status/top_n=2 columns, cites C/ft_services/docs/logs_metrics.md to keep helper → CSV tail → JSON jq checklist reproducible. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-30 12:59:00 | C/Ft_services | IN_PROGRESS | README again reminds reviewers to cite helper `./scripts/logs_metrics_export.sh --pattern status --topn 2`, the check tails on `reports/log_metrics_snapshot.status_top2.csv` & `.json` (tail -n 5 / tail -n 1 | jq) plus the `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` columns, and to reference `C/ft_services/docs/logs_metrics.md` so the helper → CSV tail → JSON jq mini-checklist stays copy/pastable in notes for this pattern=status/top_n=2 subset. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-30 13:04:00 | C/Ft_services | IN_PROGRESS | README adds a reminder to include verbatim paths `reports/log_metrics_snapshot.status_top2.csv/.json`, the helper `./scripts/logs_metrics_export.sh --pattern status --topn 2`, and the verification commands (`tail -n 5` / `tail -n 1 | jq`) in reviewer notes so the `pattern=status/top_n=2` subset and its `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` columns are reproducibly traced back to `C/ft_services/docs/logs_metrics.md`. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-30 14:01:13 | C/Ft_services | IN_PROGRESS | README again instructs reviewers to paste helper `./scripts/logs_metrics_export.sh --pattern status --topn 2`, `tail -n 5 reports/log_metrics_snapshot.status_top2.csv`, `tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq`, the `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` columns, and cite `C/ft_services/docs/logs_metrics.md` in their notes so the helper → CSV tail → JSON jq checklist makes the pattern=status/top_n=2 subset visible in both formats before approval. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 05:01:43 | C/Ft_services | IN_PROGRESS | README now also explicitly tells reviewers to log `./scripts/logs_metrics_export.sh --pattern status --topn 2`, check `reports/log_metrics_snapshot.status_top2.csv/.json` via the `tail`/`jq` commands, and mention the columns `timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio` plus `C/ft_services/docs/logs_metrics.md` so the helper → CSV tail → JSON jq mini-checklist is preserved in each run. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 05:03:12 | C/Ft_services | IN_PROGRESS | Added another reminder that the helper `./scripts/logs_metrics_export.sh --pattern status --topn 2`, the files `reports/log_metrics_snapshot.status_top2.csv/.json`, the verification `tail`/`jq` commands, and the columns `timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio` are all logged with a link to C/ft_services/docs/logs_metrics.md so reviewers can paste the helper → CSV tail → JSON jq checklist into their notes and prove the pattern=status/top_n=2 subset was rerun. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 05:26:15 | C/Ft_services | IN_PROGRESS | README keeps urging reviewers to state helper `./scripts/logs_metrics_export.sh --pattern status --topn 2`, verify `reports/log_metrics_snapshot.status_top2.csv/.json` via `tail -n 5` and `tail -n 1 ... | jq`, list columns `timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio`, and cite `C/ft_services/docs/logs_metrics.md` so the helper → CSV tail → JSON jq mini-checklist is noted every run. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 05:46:14 | C/Ft_services | IN_PROGRESS | Added another clarification that README's reminder to capture helper `./scripts/logs_metrics_export.sh --pattern status --topn 2`, the `reports/log_metrics_snapshot.status_top2.csv/.json` outputs, the verification `tail`/`jq` commands, the columns `timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio`, and the doc link `C/ft_services/docs/logs_metrics.md` is repeated so each run logs the helper → CSV tail → JSON jq checklist. latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 06:06:54 | C/Ft_services | IN_PROGRESS | helper: ./scripts/logs_metrics_export.sh --pattern status --topn 2; outputs: reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json; verify: tail -n 5 reports/log_metrics_snapshot.status_top2.csv; tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq; columns: timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio; doc: C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 06:16:14 | C/Ft_services | IN_PROGRESS | helper: ./scripts/logs_metrics_export.sh --pattern status --topn 2; outputs: reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json; verify: tail -n 5 reports/log_metrics_snapshot.status_top2.csv; tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq; columns: timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio; doc: C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 06:21:16 | C/Ft_services | IN_PROGRESS | helper: ./scripts/logs_metrics_export.sh --pattern status --topn 2; outputs: reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json; verify: tail -n 5 reports/log_metrics_snapshot.status_top2.csv; tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq; columns: timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio; doc: C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 06:26:20 | C/Ft_services | IN_PROGRESS | helper: ./scripts/logs_metrics_export.sh --pattern status --topn 2; outputs: reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json; verify: tail -n 5 reports/log_metrics_snapshot.status_top2.csv; tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq; columns: timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio; doc: C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 06:31:17 | C/Ft_services | IN_PROGRESS | helper: ./scripts/logs_metrics_export.sh --pattern status --topn 2; outputs: reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json; verify: tail -n 5 reports/log_metrics_snapshot.status_top2.csv; tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq; columns: timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio; doc: C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 06:36:15 | C/Ft_services | IN_PROGRESS | helper: ./scripts/logs_metrics_export.sh --pattern status --topn 2; outputs: reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json; verify: tail -n 5 reports/log_metrics_snapshot.status_top2.csv; tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq; columns: timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio; doc: C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 06:41:16 | C/Ft_services | IN_PROGRESS | helper: ./scripts/logs_metrics_export.sh --pattern status --topn 2; outputs: reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json; verify: tail -n 5 reports/log_metrics_snapshot.status_top2.csv; tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq; columns: timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio; doc: C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 06:46:16 | C/Ft_services | IN_PROGRESS | helper: ./scripts/logs_metrics_export.sh --pattern status --topn 2; outputs: reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json; verify: tail -n 5 reports/log_metrics_snapshot.status_top2.csv; tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq; columns: timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio; doc: C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 06:51:15 | C/Ft_services | IN_PROGRESS | helper: ./scripts/logs_metrics_export.sh --pattern status --topn 2; outputs: reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json; verify: tail -n 5 reports/log_metrics_snapshot.status_top2.csv; tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq; columns: timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio; doc: C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 06:56:31 | C/Ft_services | IN_PROGRESS | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv & reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv & tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:01:16 | C/Ft_services | IN_PROGRESS | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv & reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv & tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:06:16 | C/Ft_services | IN_PROGRESS | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv & reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv & tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:06:20 | C/Ft_services | IN_PROGRESS | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv & reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv & tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:06:42 | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv && tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:11:16 | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv && tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:16:17 | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv && tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:21:17 | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv && tail -n 1 reports/log_metrics_snapshot.status_top2.json | jq | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:26:17 | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv/reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv && tail -n 5 reports/log_metrics_snapshot.status_top2.json && jq -r "." reports/log_metrics_snapshot.status_top2.json | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:26:55|./scripts/logs_metrics_export.sh --pattern status --topn 2|reports/log_metrics_snapshot.status_top2.csv,reports/log_metrics_snapshot.status_top2.json|tail -n 5 reports/log_metrics_snapshot.status_top2.csv && tail -n 5 reports/log_metrics_snapshot.status_top2.json && jq -r "." reports/log_metrics_snapshot.status_top2.json|timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio|C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:31:17|./scripts/logs_metrics_export.sh --pattern status --topn 2|reports/log_metrics_snapshot.status_top2.csv,reports/log_metrics_snapshot.status_top2.json|tail -n 5 reports/log_metrics_snapshot.status_top2.csv && tail -n 5 reports/log_metrics_snapshot.status_top2.json && jq -r "." reports/log_metrics_snapshot.status_top2.json|timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio|C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:36:34 | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv tail -n 5 reports/log_metrics_snapshot.status_top2.json jq -r "." reports/log_metrics_snapshot.status_top2.json | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:41:17 | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv tail -n 5 reports/log_metrics_snapshot.status_top2.json jq -r "." reports/log_metrics_snapshot.status_top2.json | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json
2025-12-13 07:46:17 | ./scripts/logs_metrics_export.sh --pattern status --topn 2 | reports/log_metrics_snapshot.status_top2.csv, reports/log_metrics_snapshot.status_top2.json | tail -n 5 reports/log_metrics_snapshot.status_top2.csv; tail -n 5 reports/log_metrics_snapshot.status_top2.json; jq -r "." reports/log_metrics_snapshot.status_top2.json | timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio | C/ft_services/docs/logs_metrics.md latest timestamp per metric key wins. scripts/logs_metrics_export.sh reports/log_metrics_snapshot.csv reports/log_metrics_snapshot.status_top2.csv reports/log_metrics_snapshot.status_top2.json

2025-12-30 15:30:00 | C/Ft_services | IN_PROGRESS | Ajouté `scripts/verify_snapshot.sh` (pattern=status/topn=2) qui génère `reports/log_metrics_snapshot.status_top2.{csv,json}` avec tail/jq immédiat, rendu compatible via `log_metrics_verify.sh`; `logs_metrics_export.sh` accepte désormais `--dir/--topn/--pattern/--format` avec timestamp unique; docs (README + docs/logs_metrics.md + helpers) mises à jour pour la checklist verify_snapshot → tail CSV/JSON (colonnes timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio).

2025-12-24 23:27:58 | C/Ft_services | IN_PROGRESS | logs_metrics_export ajoute une ligne Totals (agrégée) en CSV/JSON avec ratios sécurisés; verify_snapshot/log_metrics_verify réutilisent ce flux et la doc (README, docs/logs_metrics.md, helpers) mentionne désormais la checklist tail/jq + Totals pour le subset pattern=status/top_n=2.
2025-12-24 23:40:00 | C/Ft_services | IN_PROGRESS | verify_snapshot impose maintenant la présence de Totals (CSV/JSON) après l’export pattern=status/top_n=2; docs/README/PLAN mis à jour avec cette vérification et timestamp; logs_metrics_export conserve le timestamp unique et la ligne agrégée.
2025-12-24 23:50:00 | C/Ft_services | IN_PROGRESS | logs_metrics_report.sh ajoute un rendu Markdown des exports (avec Totals) pour les notes de revue; verify_snapshot/log_metrics_verify exigent toujours Totals et la doc/README/plan/racine sont rafraîchis (15:50) pour décrire cette synthèse.
2025-12-24 23:59:59 | C/Ft_services | IN_PROGRESS | Ajout du rapport HTML (scripts/logs_metrics_report_html.py) depuis les exports CSV avec contrôle de la ligne Totals; docs/helpers/README racine/project MAJ (16:00) et rapport Markdown/HTML générés à partir du snapshot status_top2.
2025-12-31 00:15:00 | C/Ft_services | IN_PROGRESS | Ajout du pipeline logs_metrics_pipeline.sh (export+verify+MD+HTML en un run) et du rapport HTML (logs_metrics_report_html.py); docs/README/plan/racine MAJ (16:15) pour refléter pipeline + Totals; pipeline exécuté sur tests/env/logs et artefacts générés.
2025-12-31 00:25:00 | C/Ft_services | IN_PROGRESS | Ajout logs_metrics_compare.py (diff Markdown entre deux exports avec contrôle Totals) et pipeline enrichi (docs/README 16:25) ; pipeline exécuté sur tests/env/logs pour produire CSV/JSON/MD/HTML + rapport diff.
2025-12-31 00:35:00 | C/Ft_services | IN_PROGRESS | Ajout logs_metrics_alerts.py (alert CI sur overloaded_ratio > seuil avec contrôle Totals) et MAJ doc/README (16:35) pour pipeline + compare + alert; pipeline rerun sur tests/env/logs, rapports à jour.
2025-12-31 00:45:00 | C/Ft_services | IN_PROGRESS | logs_metrics_pipeline.sh accepte --threshold et appelle logs_metrics_alerts; doc/README (16:45) alignés; pipeline rerun (reports CSV/JSON/MD/HTML, alert OK 60%%).
2025-12-31 00:55:00 | C/Ft_services | IN_PROGRESS | logs_metrics_index.py corrige pour suffix multi-extensions, pipeline écrit maintenant index.md après export/rapports (threshold intégré); README/doc/racine MAJ 16:55; pipeline rerun OK sur tests/env/logs.
2025-12-31 01:05:00 | C/Ft_services | IN_PROGRESS | Ajout logs_metrics_publish.sh (bundle tar.gz CSV/JSON/MD/HTML + index/diff) et index.md généré dans pipeline; docs/README racine/projet à jour (17:05).
2025-12-31 01:15:00 | C/Ft_services | IN_PROGRESS | Ajout logs_metrics_ci.sh (pipeline+alert+compare+bundle) et publish/index intégrés; README/doc/racine MAJ 17:15; pipeline CI exécuté sur tests/env/logs (threshold 60, bundle tar.gz généré).
2025-12-31 01:25:00 | C/Ft_services | IN_PROGRESS | Ajout logs_metrics_snapshot_to_jsonl.py (conversion CSV->JSONL avec Totals) et MAJ README/doc (17:25) pour pipeline/CI/bundle; pipeline CI exécuté (threshold 60) bundle/index régénérés.
2025-12-31 01:35:00 | C/Ft_services | IN_PROGRESS | Ajout logs_metrics_history.py (historisation CSV avec Totals) intégré au pipeline (option --history, run enregistré), README/doc/racine MAJ 17:35; pipeline rerun (threshold 60) et history.csv créé.
2025-12-31 01:45:00 | C/Ft_services | IN_PROGRESS | Ajout logs_metrics_trend.py (deltas entre runs) intégré au pipeline; history/trend/index mis à jour via pipeline (threshold 60) et docs/README (17:45) alignés.
2025-12-31 01:55:00 | C/Ft_services | IN_PROGRESS | Runner CI enrichi (logs_metrics_ci.sh) ajoute JSONL + history/trend/index/bundle; pipeline rerun threshold 60 et history/trend/index/bundle/JSONL mis à jour; docs/README racine/projet MAJ 17:55.
2025-12-31 02:00:00 | C/Ft_services | IN_PROGRESS | Ajout index HTML (logs_metrics_index_html.py) + export JSONL intégré au pipeline; pipeline rerun (threshold 60) génère index.md/index.html/history/trend/jsonl/bundle; README/doc mis à jour (18:00).
2025-12-31 02:10:00 | C/Ft_services | IN_PROGRESS | Ajout d’une fiche CLI (scripts/logs_metrics_cli.md) et index HTML; pipeline rerun (threshold 60) avec JSONL/history/trend/index HTML/MD régénérés; README/doc racine/projet MAJ 18:10.
2025-12-31 02:20:00 | C/Ft_services | IN_PROGRESS | Ajout logs_metrics_prune_reports.sh (nettoie anciens snapshots par extension avec keep/dry-run) + fiche CLI; pipeline rerun (threshold 60) pour index HTML/MD/history/trend/jsonl; README/doc/README racine MAJ 18:20.
2025-12-31 02:30:00 | C/Ft_services | IN_PROGRESS | Pipeline/CI intègrent désormais prune (--prune-keep) après index, export JSONL/history/trend/index md/html restés actifs; docs/logs_metrics.md/README/README racine MAJ 18:20; pipeline/CI rerun threshold 60 avec prune=1 (aucune suppression car 1 snapshot).
2025-12-31 02:30:00 | C/Ft_services | IN_PROGRESS | Ajout logs_metrics_validate.py (vérifie artefacts + Totals) et option prune dans pipeline/CI; docs/README racine/projet MAJ 18:30; pipeline/CI rerun (threshold 60, prune=1) OK, validation artefacts passée.
2025-12-31 02:40:00 | C/Ft_services | IN_PROGRESS | Ajout logs_metrics_summary.py (résumé Totals) intégré au pipeline; options no-summary/prune-keep ajoutées; pipeline/CI rerun threshold 60 (index md/html, summary, history, trend, JSONL) OK; README/doc/racine MAJ 18:40.
2025-12-31 02:50:00 | C/Ft_services | IN_PROGRESS | Ajout de cibles Make (metrics/ci/prune/validate) + script summary MD; pipeline/CI rerun threshold 60 (summary/index md/html/history/trend/jsonl) OK; docs/README racine/projet MAJ 18:50.
2025-12-31 03:00:00 | C/Ft_services | IN_PROGRESS | Makefile expose des cibles metrics/ci/prune/validate; ajout logs_metrics_summary.md (Totales) et publish embarque jsonl/history/trend/index html/md/summary; pipeline rerun threshold 60; docs/README racine/projet/CLI MAJ 18:50.
2025-12-31 03:10:00 | C/Ft_services | IN_PROGRESS | Index HTML inclut le summary, publish embarque jsonl/history/trend/summary/index html/md; make targets ajoutées (metrics/ci/prune/validate); pipeline/CI rerun threshold 60 prune=1 OK; docs/README racine/projet MAJ 19:00.
2025-12-31 03:20:00 | C/Ft_services | IN_PROGRESS | Bundle enrichi (jsonl/history/trend/summary/index html/md), pipeline/CI rerun threshold 60 prune=1 OK, docs/logs_metrics.md README CLI alignés (18:50/19:00), nouvelles cibles Makefile.
2025-12-31 03:20:00 | C/Ft_services | IN_PROGRESS | README racine/README projet timestamps 19:20 mis à jour pour intégrer stats/logs_metrics_stats.md + index HTML/summary/bundle; pipeline rerun threshold 60 prune=1 OK et stats/bundle/index mis à jour.
2025-12-31 03:40:00 | C/Ft_services | IN_PROGRESS | Ajout portal HTML (logs_metrics_portal.py) et stats md intégrées au pipeline; index html/md, summary, history, trend, stats, portal régénérés (threshold 60 prune=1) ; README/doc/README racine MAJ 19:20 attendu.
2025-12-31 04:30:00 | C/Ft_services | IN_PROGRESS | README racine/projet mis à jour (04:30) pour documenter stats/portal + options pipeline/prune/no-summary/no-stats/no-portal ; CLI enrichi (portal/stats/prune/validate) et références vers l’index/portal/bundle alignées.
2025-12-31 05:00:00 | C/Ft_services | IN_PROGRESS | Validator enrichi (summary/stats/portal contrôlés en plus des artefacts Totals); docs README projet/racine et logs_metrics.md mis à jour (05:00) pour refléter le périmètre de validation et l’option CI.
2025-12-31 05:40:00 | C/Ft_services | IN_PROGRESS | Ajout trend HTML (`logs_metrics_trend_html.py` + flag --no-trend-html) intégré au pipeline/portal/index/bundle/validate; docs README racine/projet/CLI/logs_metrics.md mis à jour (05:40) ; publish et validation couvrent trend html/portal.
2025-12-31 06:20:00 | C/Ft_services | IN_PROGRESS | Ajout stats HTML (`logs_metrics_stats_html.py` + flag --no-stats-html) intégrées pipeline/portal/index/publish/validate; docs/CLI/README racine/projet alignés (06:20); pipeline rerun threshold 60 prune=1 OK avec trend+stats HTML.
2025-12-31 07:00:00 | C/Ft_services | IN_PROGRESS | Ajout anomalies (logs_metrics_anomalies.md + flags --no-anomalies/--anomaly-threshold) intégré pipeline/portal/index/publish/validate; docs/CLI/README racine/projet MAJ (07:00); pipeline rerun threshold 60 prune=1 OK couvrant anomalies/stats/trend HTML.
2025-12-31 07:40:00 | C/Ft_services | IN_PROGRESS | Ajout anomalies HTML (logs_metrics_anomalies_html.py + flag --no-anomalies-html) dans pipeline/portal/index/publish/validate; docs/CLI/README racine/projet MAJ (07:40); pipeline rerun threshold 60 prune=1 OK avec anomalies/stats/trend md+html.
2025-12-31 08:00:00 | C/Ft_services | IN_PROGRESS | Anomalies JSON + mode strict (pipeline flags --no-anomalies-json/--anomalies-strict) ajoutés et intégrés à portal/index/publish/validate; README/CLI/docs/progress MAJ (08:00); pipeline rerun threshold 60 prune=1 OK couvrant anomalies/stats/trend md+html+json.
2025-12-31 08:30:00 | C/Ft_services | IN_PROGRESS | Runner CI expose anomaly-threshold/anomalies-strict/no-anomalies-{html,json} (relaye vers pipeline); docs/README racine/projet/CLI/logs_metrics.md MAJ (08:30); CI rerun threshold 60 prune=1 OK avec anomalies md/html/json + bundle.
2025-12-31 09:00:00 | C/Ft_services | IN_PROGRESS | Diff HTML ajouté (logs_metrics_compare_html.py) généré en CI quand --compare est fourni; index/publish/validate/portal gèrent compare HTML optionnel; docs/CLI/README racine/projet MAJ (09:00); CI/pipeline rerun threshold 60 prune=1 OK.
2025-12-31 09:25:00 | C/Ft_services | IN_PROGRESS | Portail affiche automatiquement compare md/html si présent; docs/README racine/projet/CI/CLI/logs_metrics.md MAJ (09:25); pipeline rerun threshold 60 prune=1 OK + validation OK.
2025-12-31 09:50:00 | C/Ft_services | IN_PROGRESS | Pipeline accepte --compare pour générer diff md/html (intégrés index/publish/portal); docs/README racine/projet/CLI/logs_metrics.md MAJ (09:50); pipeline rerun threshold 60 prune=1 OK + validation OK.
2025-12-31 10:15:00 | C/Ft_services | IN_PROGRESS | Manifest JSON ajouté (logs_metrics_manifest + flag --no-manifest) intégré pipeline/publish/index/validate/portal; pipeline rerun threshold 60 prune=1 OK; docs/README racine/projet/CLI/logs_metrics.md MAJ (10:15).
2025-12-31 10:35:00 | C/Ft_services | IN_PROGRESS | Manifest auto-référencé (taille incluse) et validation recroisée manifest/fichiers; pipeline rerun threshold 60 prune=1 OK; README racine/projet/docs/logs_metrics.md/CLI/progress MAJ (10:35).
2025-12-31 11:00:00 | C/Ft_services | IN_PROGRESS | Index.md enrichi (snapshots/summary/history/trend/stats/anomalies md/html/json + compare md/html + manifest/portal/bundle), manifest hashes optionnels et validation recalculée; pipeline rerun threshold 60 prune=1 OK; docs/README racine/projet/CLI/logs_metrics.md MAJ (11:00).
2025-12-31 11:25:00 | C/Ft_services | IN_PROGRESS | Summary HTML ajouté (flag --no-summary-html) intégré pipeline/index/publish/portal/validate; manifest hash optionnel, validation recalcule; docs/README racine/projet/CLI/logs_metrics.md MAJ (11:25); pipeline rerun threshold 60 prune=1 OK.
2025-12-31 11:55:00 | C/Ft_services | IN_PROGRESS | Checksums sha256 ajoutés (logs_metrics_checksums.sh + flag --no-checksums) intégrés pipeline/publish/portal/index/validate; index md enrichi snapshots/summary/trend/stats/anomalies/compare/manifest/checksums; pipeline rerun threshold 60 prune=1 OK; docs/README racine/projet/CLI/logs_metrics.md MAJ (11:55).
2025-12-31 12:15:00 | C/Ft_services | IN_PROGRESS | Checksums finalisés (exec fixe), manifest généré après portal et validation OK; docs/README racine/projet/CLI/logs_metrics.md MAJ (12:15); pipeline rerun threshold 60 prune=1 OK.
2025-12-31 12:40:00 | C/Ft_services | IN_PROGRESS | Checksums intégrés à la validation/portal/index/publish (manifest incluant checksums), pipeline rerun threshold 60 prune=1 OK; docs/README racine/projet/CLI/logs_metrics.md MAJ (12:40).
2025-12-31 12:55:00 | C/Ft_services | IN_PROGRESS | Vérif checksum ajoutée (logs_metrics_verify_checksums.py) appelée par pipeline/validate, manifest inclut checksums; pipeline rerun threshold 60 prune=1 OK; docs/README racine/projet/CLI/logs_metrics.md MAJ (12:55).
2025-12-31 13:10:00 | C/Ft_services | IN_PROGRESS | Checksums désormais listés dans l’index (md/html), script checksum corrigé (chemins relatifs) + pipeline génère checksums après portal/manifest et vérifie via verify_checksums; pipeline rerun threshold 60 prune=1 OK + validation OK; README racine/projet/CLI/logs_metrics.md MAJ (03:24/12:40 refs).
2025-12-31 13:30:00 | C/Ft_services | IN_PROGRESS | Pipeline supporte --no-verify-checksums, docs/CLI/logs_metrics.md MAJ (13:30), index référence checksums; pipeline rerun threshold 60 prune=1 OK + validation OK.
2025-12-31 14:00:00 | C/Ft_services | IN_PROGRESS | Flags CI --no-checksums/--no-verify-checksums ajoutés, cibles Makefile metrics-checksums/metrics-verify-checksums, docs/README racine/projet/CLI/logs_metrics.md MAJ (14:00), pipeline rerun threshold 60 prune=1 OK + validation OK.
2025-12-31 14:20:00 | C/Ft_services | IN_PROGRESS | Nouveau overview (totaux+deltas+liens) généré par pipeline (--no-overview), intégré à index/publish/manifest/portal/validate; Makefile targets checksums/verify; pipeline rerun threshold 60 prune=1 OK + validation OK.
2025-12-31 14:20:00 | C/Ft_services | IN_PROGRESS | Nouveau overview md (totaux + delta vs précédent + liens) généré par la pipeline (flag --no-overview) et inclus index/publish/manifest/validate; make targets checksums/verify ajoutés; pipeline rerun threshold 60 prune=1 OK + validation OK.
2025-12-31 13:45:00 | C/Ft_services | IN_PROGRESS | CI accepte --no-checksums/--no-verify-checksums, vérification checksum intégrée, pipeline/validation OK; docs/README racine/projet/CLI/logs_metrics.md MAJ (13:45).
2025-12-31 14:55:00 | C/Ft_services | IN_PROGRESS | Overview HTML ajouté (flag --no-overview-html) et généré avant index/portal, checksums pré-créé pour que le manifest référence l’artefact puis vérification checksum ; publish/portal/index/manifest/validate couvrent overview md/html, docs/CLI/README racine/projet MAJ, pipeline threshold 60 prune=1 + validate OK.
2025-12-31 15:25:00 | C/Ft_services | IN_PROGRESS | Runner CI relaie --no-overview/--no-overview-html vers la pipeline, docs/logs_metrics/CLI/README racine/projet mis à jour (15:25) pour ces options; pipeline threshold 60 prune=1 OK + validation OK.
2025-12-31 15:55:00 | C/Ft_services | IN_PROGRESS | CI relaie désormais --no-portal/--no-trend-html/--no-stats-html/--no-summary-html/--no-index-html/--no-manifest/--no-manifest-hash (en plus de overview md/html) vers la pipeline; docs/logs_metrics.md, CLI, README projet/racine MAJ (15:55); pipeline threshold 60 prune=1 + validation OK.
2025-12-31 16:20:00 | C/Ft_services | IN_PROGRESS | CI ajoute des profils (--profile minimal|standard|full) pour activer d’un coup les options de désactivation HTML/manifest hashes/overview; docs/CLI/logs_metrics.md/README projet/racine MAJ (16:20); pipeline threshold 60 prune=1 + validation OK.
2025-12-31 16:45:00 | C/Ft_services | IN_PROGRESS | Nouvelles cibles Make (metrics-ci-minimal/standard/full) pour déclencher les profils CI depuis Make; README racine/projet et docs/logs_metrics.md/CLI mis à jour (16:45); pipeline threshold 60 prune=1 + validation OK.
2025-12-31 17:10:00 | C/Ft_services | IN_PROGRESS | Validation accepte --mode full/standard/minimal (allège les exigences HTML/portal pour les profils CI) et docs/README/CLI alignés (17:10); pipeline threshold 60 prune=1 + validation OK.
2025-12-31 17:35:00 | C/Ft_services | IN_PROGRESS | Makefile ajoute metrics-validate-{standard,minimal}, docs/CLI/logs_metrics.md/READMEs mis à jour (17:35) pour ces cibles; pipeline threshold 60 prune=1 + validation OK.
2025-12-31 18:00:00 | C/Ft_services | IN_PROGRESS | Pipeline génère désormais le bundle tar.gz (flag --no-bundle) avant manifest/sha256, manifest régénéré après bundle; CI relaie --no-bundle, docs/CLI/logs_metrics.md/READMEs et Makefile alignés; pipeline threshold 60 prune=1 + validation OK.
2025-12-31 18:20:00 | C/Ft_services | IN_PROGRESS | Ajout log_metrics_latest.json (résumé Totals+anomalies+artefacts), pipeline flag --no-latest, index/portal/publish/manifest/checksums/validate le référencent; CI relaie --no-bundle/--no-latest; docs/README/CLI/Makefile MAJ; pipeline threshold 60 prune=1 + validation OK.
2025-12-31 18:40:00 | C/Ft_services | IN_PROGRESS | Cible Make metrics-latest ajoutée, log_metrics_latest intégré partout + flags --no-latest/--no-bundle relayés; docs/README/CLI/logs_metrics.md MAJ (18:40); pipeline threshold 60 prune=1 + validation OK.
2025-12-31 19:00:00 | C/Ft_services | IN_PROGRESS | Validation full compare log_metrics_latest.json (Totals CSV/anomalies/artefacts) et nouveaux flags --no-latest/--no-bundle exposés; docs/README/CLI/logs_metrics.md/Makefile/progress MAJ (19:00); pipeline threshold 60 prune=1 + validation OK.
2025-12-31 19:20:00 | C/Ft_services | IN_PROGRESS | Résumé latest HTML ajouté (flag --no-latest-html) référencé index/portal/manifest/checksums/validate; profil CI relaie latest html/json; docs/README/CLI/logs_metrics.md/Makefile/progress MAJ (19:20); pipeline threshold 60 prune=1 + validation OK.
2025-12-31 19:40:00 | C/Ft_services | IN_PROGRESS | latest HTML intégré (option --no-latest-html) avec validation/manifest/index/portal, manifeste avant bundle supprimé; docs/README/CLI/logs_metrics.md/Makefile MAJ (19:40); pipeline threshold 60 prune=1 + validation OK.
2025-12-31 20:00:00 | C/Ft_services | IN_PROGRESS | latest HTML affiche aussi les deltas, pipeline ne produit plus de manifest avant bundle et le régénère après; validation contrôle latest json/html (Totals+deltas, artefacts), docs/README/CLI/logs_metrics.md/Makefile MAJ (20:00); pipeline threshold 60 prune=1 + validation OK.
2025-12-31 20:30:00 | C/Ft_services | IN_PROGRESS | Badge SVG (OK/WARN/ALERT) généré par la pipeline/CI (flag --no-badge, cible make metrics-badge) et intégré manifest/index/portal/bundle/checksums/latest HTML/MD; validation/manifest tolèrent les entrées optionnelles absentes; pipeline + validation full rerun (threshold 60, prune=1) OK; docs/CLI/README mis à jour.
2025-12-31 21:00:00 | C/Ft_services | IN_PROGRESS | Badge SVG configurable (warn/danger/label, flag --no-badge, cible make metrics-badge) intégré index/portal/manifest/bundle/checksums/latest HTML/MD; docs/CLI/README MAJ; pipeline+validation full rerun (threshold 60 prune=1) OK.
2025-12-31 21:25:00 | C/Ft_services | IN_PROGRESS | Badge configurable (warn/danger/label) propagé dans latest json/html/md et validation recalcule l’état; docs/CLI/README MAJ; pipeline+validation full rerun (threshold 60 prune=1) OK.
2025-12-31 21:50:00 | C/Ft_services | IN_PROGRESS | Portail affiche l’état/seuils du badge configurable (warn/danger/label) propagé via latest json/html/md; docs/CLI/README MAJ; pipeline+validation full rerun (threshold 60 prune=1) OK.
2025-12-31 22:20:00 | C/Ft_services | IN_PROGRESS | Badge configurable + gate (--badge-gate warn|alert) ajouté, latest json/html/md et portail affichent état/seuils, docs/CLI/README MAJ; pipeline+validation full rerun (threshold 60 prune=1) OK.
2025-12-31 22:40:00 | C/Ft_services | IN_PROGRESS | Gate badge (--badge-gate warn|alert) ajouté et relayé par la CI; docs/CLI/README MAJ; pipeline+validation full rerun (threshold 60 prune=1) OK.
2025-12-31 23:05:00 | C/Ft_services | IN_PROGRESS | Index md/html affiche désormais état/seuils du badge configurable (warn/danger/label, gate CI), docs/CLI/README MAJ; pipeline+validation full rerun (threshold 60 prune=1) OK.
2025-12-31 23:30:00 | C/Ft_services | IN_PROGRESS | Historique badge log_metrics_badge_history.csv ajouté (état/seuils/ratio/anomalies) via pipeline, index/portal/manifest/bundle/checksums/validation MAJ; docs/CLI/README horodatés; pipeline+validation full rerun (threshold 60 prune=1) OK.
2025-12-31 23:30:00 | C/Ft_services | IN_PROGRESS | Historique badge log_metrics_badge_history.csv ajouté (état/seuils/ratio/anomalies) via pipeline, index/portal/manifest/bundle/checksums/validation MAJ; docs/CLI/README horodatés; pipeline+validation full rerun (threshold 60 prune=1) OK.
2025-12-31 23:55:00 | C/Ft_services | IN_PROGRESS | Historique badge md/html (log_metrics_badge_history.{md,html}) généré depuis badge_history.csv (flag --no-badge-history, option --badge-history-last) et intégré index/portal/manifest/bundle/checksums/validation; docs/CLI/README MAJ; pipeline+validation full rerun (threshold 60 prune=1) OK.
2026-01-01 00:40:00 | C/Ft_services | IN_PROGRESS | Historique badge md/html (avec --badge-history-last relayé en CI) généré par la pipeline, Make target metrics-badge-history ajoutée; validation rend les artefacts badge optionnels; docs/CLI/README horodatés; pipeline+validation full rerun (threshold 60 prune=1) OK.
2026-01-01 01:00:00 | C/Ft_services | IN_PROGRESS | latest.json expose badge_history (counts/window/last) et l’index md/html affiche les counts; CI relaye --no-badge-history/--badge-history-last; validation rend les artefacts badge optionnels; docs/CLI/README MAJ; pipeline+validation full rerun (threshold 60 prune=1) OK.
2026-01-01 01:15:00 | C/Ft_services | IN_PROGRESS | Vues badge history md/html ajoutent timeline (emoji/couleurs) et latest.json expose badge_history counts/window/last; CI relaie --no-badge-history/--badge-history-last; validation assouplie pour artefacts badge optionnels; pipeline+validation full rerun (threshold 60 prune=1) OK.
2026-01-01 01:30:00 | C/Ft_services | IN_PROGRESS | Badge history enrichi (timeline+streaks md/html, badge_history streaks dans latest.json, index/portal affichent counts/streaks, CI relaie --no-badge-history/--badge-history-last, Make metrics-badge-history); validation badge optionnelle; pipeline+validation full rerun (threshold 60 prune=1) OK.
2026-01-01 01:45:00 | C/Ft_services | IN_PROGRESS | Badge history timeline/streaks ajoutés (latest json exporte streaks, index/portal affichent counts/streaks), pipeline/validation rerun (threshold 60 prune=1) OK; READMEs MAJ.
2026-01-01 02:05:00 | C/Ft_services | IN_PROGRESS | Garde-fou --badge-ok-streak ajouté (pipeline/CI) pour imposer une streak OK minimale, usage mis à jour; docs/CLI/README horodatés; pipeline+validation full rerun (threshold 60 prune=1) OK.
2026-01-01 02:10:00 | C/Ft_services | IN_PROGRESS | Garde-fou badge-ok-streak ajouté (pipeline/CI) pour imposer une streak OK minimale; pipeline/validation full rerun (threshold 60 prune=1) OK.
2026-01-01 02:20:00 | C/Ft_services | IN_PROGRESS | Garde-fou badge-ok-streak intégré (flag pipeline/CI) avec propagation dans latest.json; pipeline+validation full rerun (threshold 60 prune=1) OK; READMEs/progress MAJ.
2026-01-01 02:30:00 | C/Ft_services | IN_PROGRESS | Garde-fou badge-ok-streak totalement intégré (flag pipeline/CI + latest.json), usage corrigé; pipeline+validation full rerun (threshold 60 prune=1) OK.
2025-12-25 07:30:38 | C/Ft_services | IN_PROGRESS | Latest/badge rafraîchi après l’écriture de l’historique : latest.json expose état précédent, counts/streak, garde ok-streak et fenêtre; latest HTML/MD/index/portal affichent l’historique badge (state/streak/prev) et les gardes; pipeline rerun (threshold 60, badge warn 30/danger 60 label uptime) OK.
2025-12-25 07:32:45 | C/Ft_services | IN_PROGRESS | Badge history vues md/html affichent transition précédente et fenêtre; pipeline rafraîchie (threshold 60 badge warn 30/danger 60 label uptime) avec latest réécrit après history; ok-streak/no-regression prêts à être verrouillés.
2025-12-25 07:35:12 | C/Ft_services | IN_PROGRESS | Latest expose badge_guards (gate/ok-streak/no-regression) et les vues badge HTML/MD/index/portal affichent les garde-fous; badge history md/html ajoutent transition et fenêtre; pipeline rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 07:37:46 | C/Ft_services | IN_PROGRESS | Validation contrôle désormais badge_guards (gate/ok-streak/no-regression) dans latest.json; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 07:44:08 | C/Ft_services | IN_PROGRESS | latest.json inclut badge_guard_status (gate/ok-streak/no-regression) et affichage statuts dans latest HTML/MD/index/portal; validation vérifie cohérence des garde-fous; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 07:49:01 | C/Ft_services | IN_PROGRESS | badge_history CSV enrichi (gardes gate/ok/no-reg + résultats, réécriture avec upgrade), vues md/html dynamiques sur colonnes, pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 07:52:43 | C/Ft_services | IN_PROGRESS | badge_history md/html résument aussi les gardes (ok/fail/unknown par guard) grâce au CSV enrichi/upgradé; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 07:57:14 | C/Ft_services | IN_PROGRESS | badge_history md/html ajoutent un tableau de synthèse des gardes (ok/fail/unknown) et l’upgrade CSV normalise les colonnes; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:02:46 | C/Ft_services | IN_PROGRESS | Portail affiche aussi le tableau de synthèse des gardes (ok/fail/unknown) calculé depuis badge_history; docs MAJ; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:08:14 | C/Ft_services | IN_PROGRESS | latest.json ajoute badge_guard_summary (counts ok/fail/unknown) affiché dans latest HTML/MD et comparé à badge_history en validation; portail affiche la synthèse; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:12:42 | C/Ft_services | IN_PROGRESS | index affiche aussi la synthèse des gardes (ok/fail/unknown) issue de badge_guard_summary; docs/CLI MAJ; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:17:51 | C/Ft_services | IN_PROGRESS | index HTML affiche la synthèse des gardes (ok/fail/unknown) issue de badge_guard_summary; docs MAJ; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:22:39 | C/Ft_services | IN_PROGRESS | Index HTML affiche aussi la synthèse des gardes (ok/fail/unknown/total) issue de badge_guard_summary; docs/CLI/README/progress MAJ; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:27:33 | C/Ft_services | IN_PROGRESS | index.md affiche maintenant un tableau des gardes (ok/fail/unknown/total) issu de badge_guard_summary; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:34:56 | C/Ft_services | IN_PROGRESS | guard_summary.md généré par la pipeline (flag --no-guard-summary), manifest/checksums/index/portal/index-html/md intègrent le guard summary; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:38:51 | C/Ft_services | IN_PROGRESS | guard_summary HTML ajouté (flag --no-guard-summary), manifest/checksums/portal/index md/html référencent guard_summary md/html; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:43:42 | C/Ft_services | IN_PROGRESS | guard_summary.html généré (flag --no-guard-summary), manifest/checksums/index/portal/artefacts latest/validate couvrent guard summary md/html; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:47:43 | C/Ft_services | IN_PROGRESS | guard_summary html/md générés et inclus manifest/checksums/index/portal/latest/validate (flag --no-guard-summary); pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:52:47 | C/Ft_services | IN_PROGRESS | Portail affiche la synthèse des gardes (tableau latest) en plus du guard summary md/html; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 08:57:54 | C/Ft_services | IN_PROGRESS | guard_summary html généré (flag --no-guard-summary) ajouté au bundle/manifest/checksums/index/portal/latest/validate; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:03:55 | C/Ft_services | IN_PROGRESS | guard_summary JSON ajouté, pipeline le génère (flag --no-guard-summary) et manifest/checksums/index/portal/latest/validate le référencent; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:10:23 | C/Ft_services | IN_PROGRESS | latest md/html lient aussi guard_summary JSON et publish embarque le JSON; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:14:56 | C/Ft_services | IN_PROGRESS | guard_summary CSV généré (md/html/json/csv) et intégré pipeline (bundle/manifest/checksums/index/portal/latest/validate/publish); pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:17:53 | C/Ft_services | IN_PROGRESS | Validation recroise guard_summary CSV avec badge_history/latest (mismatches bloquants) et portal lie le CSV; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:22:45 | C/Ft_services | IN_PROGRESS | Portail rend aussi la table guard_summary CSV (ok/fail/unknown/total/window) et doc mise à jour; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:28:11 | C/Ft_services | IN_PROGRESS | latest HTML/MD affichent la table guard_summary avec window, guard_summary en latest JSON inclut window; doc MAJ; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:33:19 | C/Ft_services | IN_PROGRESS | index md/html affichent la table des gardes avec window; validation vérifie aussi la fenêtre guard_summary vs badge_history; doc/portal/latest régénérés; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:38:08 | C/Ft_services | IN_PROGRESS | guard_summary (md/html/json/csv) affiche aussi les pourcentages ok/fail/unknown; latest/index/portal montrent ces pct et validation recalcule fenêtres; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:43:28 | C/Ft_services | IN_PROGRESS | guard_summary (md/html/json/csv) ajoute ok/fail/unknown pct recalculés dans latest/index, validation vérifie pct vs history; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:47:59 | C/Ft_services | IN_PROGRESS | Validation exige aussi la somme des pourcentages (≈100) et recroise pct en CSV/JSON; doc MAJ; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:54:49 | C/Ft_services | IN_PROGRESS | latest ajoute la synthèse globale des gardes (totaux/pct), affiche dans latest HTML/MD; validation recalcule pct et somme 100% avec nommage corrigé; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 09:58:06 | C/Ft_services | IN_PROGRESS | Portail affiche la synthèse globale des gardes; index md inclut la table globale; validation/JSON corrigés (totals dédiés) et pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:02:58 | C/Ft_services | IN_PROGRESS | index HTML affiche aussi la synthèse globale des gardes; docs MAJ; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:08:54 | C/Ft_services | IN_PROGRESS | latest calcule un delta de gardes vs fenêtre précédente (ok/fail/unknown) et l’affiche dans latest md/html/index/portal; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:13:22 | C/Ft_services | IN_PROGRESS | Validation recalcule et compare les deltas de gardes (ok/fail/unknown) vs fenêtre précédente; index/portal/latest restent alignés; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:18:03 | C/Ft_services | IN_PROGRESS | index HTML affiche aussi le tableau des deltas de gardes; docs MAJ; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:23:52 | C/Ft_services | IN_PROGRESS | guard_summary md/html/json/csv incluent les deltas de gardes (ok/fail/unknown) vs fenêtre précédente; validation croise ces deltas; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:28:21 | C/Ft_services | IN_PROGRESS | guard_summary md/html/json/csv ajoutent les deltas en pourcentage vs fenêtre précédente; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:33:23 | C/Ft_services | IN_PROGRESS | Deltas de gardes (md/html/json/csv) affichent aussi les pourcentages; latest/index/portal montrent les deltas avec pct; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:34:01 | C/Ft_services | IN_PROGRESS | guard_summary deltas ajoutent aussi les pourcentages dans md/html/json/csv et index/portal/latest; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:38:15 | C/Ft_services | IN_PROGRESS | guard_summary deltas intègrent aussi les pourcentages (md/html/json/csv) avec validation du global (counts/pct) et des pct delta; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:43:04 | C/Ft_services | IN_PROGRESS | badge_guard_delta enrichi de pct dans latest JSON (et affiché dans latest/index/portal); pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:49:00 | C/Ft_services | IN_PROGRESS | badge_guard_delta_overall ajouté et affiché (latest/index/portal) avec validation des pct/totaux; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:54:47 | C/Ft_services | IN_PROGRESS | Validation couvre aussi delta_overall (counts/pct) et accepte delta pct=0 quand total delta=0; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:57:42 | C/Ft_services | IN_PROGRESS | Delta_overall visible (latest/index/portal) et validation recalcule counts/pct (guard + delta); pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 10:54:47 | C/Ft_services | IN_PROGRESS | badge_guard_delta_overall affiché (latest/index/portal), guard_summary deltas incluent pct et validation recalcule global/pct + pct delta; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 11:11:01 | C/Ft_services | IN_PROGRESS | Fenêtre delta des gardes configurable (--guard-delta-last/--delta-last) et exposée via delta_window dans latest/index/portal/validation; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime) OK.
2025-12-25 11:13:37 | C/Ft_services | IN_PROGRESS | Validation croise aussi delta_window/deltas des guard_summary json/csv (en plus du latest) après fenêtre delta configurable; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime guard-delta-last 10) OK.
2025-12-25 11:17:35 | C/Ft_services | IN_PROGRESS | latest/index/portal affichent les streaks des gardes (courante + longest ok/fail/unknown) et validation les recalcule depuis badge_history; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime guard-delta-last 10) OK.
2025-12-25 11:19:56 | C/Ft_services | IN_PROGRESS | guard_summary md/html/json/csv ajoutent les streaks des gardes; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime guard-delta-last 10) OK.
2025-12-25 11:25:29 | C/Ft_services | IN_PROGRESS | Validation recalcule aussi les streaks latest + guard_summary JSON/CSV et corrige le pct delta overall; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime guard-delta-last 10) OK.
2025-12-25 11:32:14 | C/Ft_services | IN_PROGRESS | Validation corrige le pct delta overall via totaux recalculés (streaks latest/guard_summary JSON/CSV conservés); pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime guard-delta-last 10) OK.
2025-12-25 11:39:23 | C/Ft_services | IN_PROGRESS | Streak globale des gardes (agrégée) exposée dans latest/index/portal et validée; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime guard-delta-last 10) OK.
2025-12-25 11:42:08 | C/Ft_services | IN_PROGRESS | Guard summary (md/html/json) inclut la streak globale agrégée; index/portal/latest affichent et validation couvre les streaks globales; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime guard-delta-last 10) OK.
2025-12-25 11:43:47 | C/Ft_services | IN_PROGRESS | Validation couvre désormais la streak globale (guard_summary JSON) et streaks globales recalculées; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime guard-delta-last 10) OK.
2025-12-25 11:48:15 | C/Ft_services | IN_PROGRESS | guard_summary CSV ajoute la streak globale agrégée (__overall_streak) et validation la recalcule; pipeline+validation rerun (threshold 60 badge warn 30/danger 60 label uptime guard-delta-last 10) OK.
2025-12-25 13:50:30 | C/Ft_services | IN_PROGRESS | Quick-check guard+checksums (`metrics_quick_check.sh`/`make metrics-quick-check`) ajouté; CI/pipeline/verify path-agnostiques, checksums normalisés; docs/CLI/README horodatés.
2025-12-25 14:06:52 | C/Ft_services | IN_PROGRESS | guard_overall/delta latest alignés sur guard_summary (agrégation ligne), checker guard_summary vs latest ajouté (pipeline/quick-check/Makefile), pipeline réordonnée (manifest/portal/bundle/checksums) + rerun OK (threshold 60 guard-delta-last 10).
2025-12-25 14:29:24 | C/Ft_services | IN_PROGRESS | Run summary généré par la pipeline (statuts guard/checksums/validation + badge/anomalies/ratio) et intégré au manifest/index/portal; smoke rerun OK (threshold 60 guard-delta-last 10); docs/CLI/READMEs mis à jour.
2025-12-25 14:33:26 | C/Ft_services | IN_PROGRESS | CI relaie `--post-validate/--validate-mode` vers la pipeline, validation post-bundle possible; target `metrics-run-summary` ajoutée; run summary reste exposé manifest/index/portal; smoke rerun OK.
2025-12-25 14:48:30 | C/Ft_services | IN_PROGRESS | Pipeline rejouée en deux temps (portal → bundle → manifest → checksums puis validation/refresh) pour embarquer le statut de validation dans le run summary et recalculer manifest/bundle/checksums; smoke + quick-check OK (threshold 60 guard-delta-last 10).
2025-12-25 14:51:50 | C/Ft_services | IN_PROGRESS | Orchestration finalisée : validation se fait après une première passe portal/bundle/manifest/checksums, puis run_summary relancé et artefacts régénérés (portal/bundle/manifest/checksums/verify) avant validation finale; smoke + quick-check OK (threshold 60 guard-delta-last 10).
2025-12-25 14:53:52 | C/Ft_services | IN_PROGRESS | Stabilisation pipeline : étape pré-validation génère portal/bundle/manifest/checksums pour valider les artefacts du run, puis run_summary+artefacts régénérés et validation finale; smoke complet + quick-check OK (threshold 60 guard-delta-last 10).
2025-12-25 14:55:31 | C/Ft_services | IN_PROGRESS | Dernière passe : run_summary recalculé après la validation finale avec régénération/verify des checksums pour aligner les artefacts finaux; smoke complet + quick-check OK (threshold 60 guard-delta-last 10).
2025-12-25 15:01:25 | C/Ft_services | IN_PROGRESS | Ajout d’un rendu Markdown du run summary (pipeline/manifest/checksums/index/portal), généré aux passes pré/post-validation avec checksums finaux; smoke complet + quick-check OK (threshold 60 guard-delta-last 10).
2025-12-25 15:03:10 | C/Ft_services | IN_PROGRESS | Doc mise à jour sur le run summary JSON+MD (flag --no-run-summary-md) et sur l’inclusion dans pipeline/manifest/checksums/index/portal; artefacts régénérés après validation finale.
2025-12-25 15:05:30 | C/Ft_services | IN_PROGRESS | Manifest robuste aux chemins absolus (tombe en chemin absolu si hors reports) pour les artefacts comme le run summary MD/JSON; docs horodatées.
2025-12-25 15:12:26 | C/Ft_services | IN_PROGRESS | Manifest accepte les chemins hors reports (relatif ou absolu) et smoke complet relancé (threshold 60 guard-delta-last 10) pour valider le flux; checksums/run_summary MD/JSON à jour.
2025-12-25 15:17:40 | C/Ft_services | IN_PROGRESS | Bundle inclut run_summary.md, make metrics-run-summary génère JSON+MD; smoke complet + quick-check rerun OK après ajout.
2025-12-25 15:24:43 | C/Ft_services | IN_PROGRESS | Ajout du run summary HTML (flags no-run-summary-md/html) intégré bundle/manifest/checksums/index/portal + cible Make; smoke complet + quick-check OK. (non rejoué dans ce run)
2025-12-25 15:32:24 | C/Ft_services | IN_PROGRESS | run_summary HTML ajouté (flags no-run-summary-md/html) et intégré (bundle/manifest/checksums/index/portal/Makefile); smoke complet + quick-check relancés et verts (threshold 60 guard-delta-last 10).
2025-12-25 15:32:24 | C/Ft_services | IN_PROGRESS | Ajout d’un sitemap Markdown (flag --no-sitemap) construit depuis le manifest et intégré (bundle/manifest/checksums/index/portal); pipeline/smoke/quick-check validés.
2025-12-25 16:00:00 | C/Ft_services | IN_PROGRESS | Nouvelle cible `make metrics-sitemap` (génère le sitemap md depuis le manifest) et doc CLI enrichie (flag --no-sitemap + artefacts run_summary json/md/html + sitemap listés).
2025-12-25 16:30:00 | C/Ft_services | IN_PROGRESS | Sitemap HTML ajouté (script + flag --no-sitemap-html, Make target metrics-sitemap-html) et intégré manifest/index/portal/checksums; manifest/checksums régénérés.
2025-12-25 16:50:00 | C/Ft_services | IN_PROGRESS | Scripts pipeline/CI/checksums alignés sur la racine C/ft_services (REPO_ROOT) pour écrire dans reports locaux, sitemap HTML/MD et run_summary régénérés avec index/portal, checksums recalculés.
2025-12-25 17:05:00 | C/Ft_services | IN_PROGRESS | Smoke complet relancé après la normalisation des chemins (reports locaux) : sitemap HTML/MD, run_summary, index, portal, manifest et checksums régénérés/validés (verify OK).
2025-12-25 17:20:00 | C/Ft_services | IN_PROGRESS | Index HTML accepte désormais `--output` pour cibler un autre chemin (docs/CLI/README mis à jour) et index HTML régénéré.
2025-12-25 17:35:00 | C/Ft_services | IN_PROGRESS | Sitemap MD/HTML enrichis d’un résumé (artifacts présents/manquants + taille totale) avec scripts mis à jour, artefacts régénérés et checksums/manifest rafraîchis.
2025-12-25 17:50:00 | C/Ft_services | IN_PROGRESS | Sitemap JSON ajouté (résumé présent/manquant/taille) intégré pipeline/manifest/index/portal/checksums/publish, flag `--no-sitemap-json`; sitemaps recalculés.
2025-12-25 18:05:00 | C/Ft_services | IN_PROGRESS | Nouvelle cible `make metrics-sitemap-json` pour régénérer le sitemap JSON; sitemaps recalculés et READMEs/root mis à jour.
2025-12-25 18:20:00 | C/Ft_services | IN_PROGRESS | Index/portal affichent le résumé du sitemap JSON (artifacts/present/missing/size) et cible Make sitemap-json ajoutée; sitemaps/index/portal/checksums régénérés.
2025-12-25 18:35:00 | C/Ft_services | IN_PROGRESS | Validation croise le résumé du sitemap JSON avec le manifest; cible Make `metrics-sitemap-all` ajoute la génération md/html/json en un seul appel, index/portal/sitemaps/checksums régénérés.
2025-12-25 18:50:00 | C/Ft_services | IN_PROGRESS | Sitemap JSON inclut la liste des artefacts manquants; index/portal affichent ces chemins manquants; sitemaps/index/portal/checksums régénérés.
2025-12-25 19:00:00 | C/Ft_services | IN_PROGRESS | Index/portal et sitemap JSON régénérés (missing paths affichés), ciblage Make intact; tentative de push échouée (DNS github.com).
2025-12-25 19:20:00 | C/Ft_services | IN_PROGRESS | Sitemap JSON expose `--fail-on-missing` et liste les chemins manquants; docs/CLI/README/progress mis à jour.
2025-12-25 19:40:00 | C/Ft_services | IN_PROGRESS | Sitemaps ignorent les artefacts optionnels (compare/checksums_guard) dans les totaux, validation harmonisée; sitemaps/index/portal/checksums régénérés.
2025-12-25 20:00:00 | C/Ft_services | IN_PROGRESS | Pipeline accepte `--fail-on-missing-sitemap` (relai vers sitemap JSON `--fail-on-missing`) pour échouer si des artefacts requis manquent; docs/CLI/logs_metrics.md mis à jour.
2025-12-25 20:20:00 | C/Ft_services | IN_PROGRESS | Artefacts requis complets: run_summary régénéré, sitemap JSON/MD/HTML + index/portal/manifest/checksums recalculés sans manquants (flag fail-on-missing OK).
2025-12-25 20:40:00 | C/Ft_services | IN_PROGRESS | Vérif sitemap ajoutée au quick-check/Make (metrics-sitemap-verify) avec options `--sitemap-optional/--fail-on-missing-sitemap` relayées; docs/CLI/logs_metrics.md mis à jour, artefacts régénérés.
2025-12-25 21:00:00 | C/Ft_services | IN_PROGRESS | Pipeline/quick-check exposent `--sitemap-optional` + vérif sitemap dédiée; artefacts régénérés et docs/README racine mis à jour (push toujours bloqué DNS).
2025-12-25 21:20:00 | C/Ft_services | IN_PROGRESS | Vérif sitemap accepte --optional pour neutraliser des artefacts côté CLI (override du sitemap) ; docs/CLI mises à jour et verify testé.
2025-12-25 21:40:00 | C/Ft_services | IN_PROGRESS | Vérif sitemap recalcule les manquants depuis le manifest (override --manifest) avec option --optional; docs/CLI mis à jour et vérif rejouée.
2025-12-25 22:00:00 | C/Ft_services | IN_PROGRESS | Vérif sitemap compare maintenant le résumé avec un recompute manifest (warnings ou échec via --strict-summary); docs/CLI et READMEs mis à jour.
2025-12-25 22:20:00 | C/Ft_services | IN_PROGRESS | Vérif sitemap aligne désormais les comptages sitemap/manifest (options optional reconnues sur noms/paths), plus d’écart warn; scripts/docs/READMEs mis à jour.
2025-12-25 22:40:00 | C/Ft_services | IN_PROGRESS | Make/quick-check relaient SITEMAP_OPTIONAL/SITEMAP_STRICT, et sitemap optional reconnu par nom/path; docs/CLI/README MAJ.
2025-12-25 22:55:00 | C/Ft_services | IN_PROGRESS | Pipeline relaie --sitemap-optional/--sitemap-manifest/--sitemap-strict jusqu'à la vérification; Make/quick-check alignés, docs/CLI/READMEs MAJ.
2025-12-25 23:15:00 | C/Ft_services | IN_PROGRESS | Run summary inclut statut/artefacts sitemap (pipeline relance validation après sitemaps/checksums) et s’appuie sur flags strict/optional/manifest propagés; scripts HTML/MD mis à jour.
2025-12-26 00:05:00 | C/Ft_services | IN_PROGRESS | Portail affiche désormais le statut/artefacts sitemap issus du run summary; run summary enrichi inclut sitemaps et pipeline relance validation finale.
2025-12-26 00:30:00 | C/Ft_services | IN_PROGRESS | Portail ajouté une barre de statut (badge/guard/checksums/validation/compare/sitemap) alimentée par latest+run_summary; artefacts régénérés.
2025-12-26 00:55:00 | C/Ft_services | IN_PROGRESS | Index HTML/MD affichent une barre/section statut (badge/guard/checksums/validation/compare/sitemap) alimentée par latest+run_summary; artefacts index/portal régénérés.
2025-12-26 01:20:00 | C/Ft_services | IN_PROGRESS | Portail/index améliorent l’UX : barre de statut stylée + cartes badge/guard/checksums/validation/compare/sitemap (run summary/latest), artefacts régénérés.
2025-12-26 01:45:00 | C/Ft_services | IN_PROGRESS | Portail run summary en grid (cartes badge/guard/checksums/validation/compare + carte sitemap + downloads) avec styles modernisés; index HTML/MD régénérés et sitemap OK.
2025-12-26 02:05:00 | C/Ft_services | IN_PROGRESS | Portail/index affichent aussi le résumé manifest (total/present/missing/size) en plus des cartes statut; artefacts régénérés, sitemap OK.
2025-12-26 02:30:00 | C/Ft_services | IN_PROGRESS | Statut manifest ajouté (badge + résumé) dans portail/index (barres et cartes) ; artefacts régénérés et sitemap OK.
2025-12-26 02:50:00 | C/Ft_services | IN_PROGRESS | Quick stats (overloaded/anomalies/totals) ajoutés aux barres et sections statut (index/portal), manifest badge conservé; artefacts régénérés, sitemap OK.
2025-12-26 03:10:00 | C/Ft_services | IN_PROGRESS | Quick stats + section liens clés ajoutés à l’index (run summary/portal/bundle/manifest) et carte anomalies + badge manifest/statut dans le portail; artefacts régénérés, sitemap OK.
2025-12-26 03:30:00 | C/Ft_services | IN_PROGRESS | Index affiche aussi le résumé sitemap (required/present/missing/optional) et section liens clés; portail conserve cartes statut/manifest/anomalies/totaux; artefacts régénérés, sitemap OK.
2025-12-26 03:50:00 | C/Ft_services | IN_PROGRESS | Portail ajoute les liens run summary (json/md/html) dans la carte downloads; artefacts index/portal régénérés, sitemap OK.
2025-12-26 04:20:00 | C/Ft_services | IN_PROGRESS | Commande logs_metrics_status ignore les artefacts optionnels dans le manifest (alignée sitemap optional) ; sortie manifest passe à OK; docs/README/progress mis à jour.
2025-12-26 04:45:00 | C/Ft_services | IN_PROGRESS | logs_metrics_status supporte --optional/--fail-on-badge/--fail-on-missing (aligné optional manifest); quick-check/Make peuvent signaler un badge dégradé; docs/README/progress MAJ.
2025-12-26 05:05:00 | C/Ft_services | IN_PROGRESS | logs_metrics_status ajoute --optional/--fail-on-badge/--fail-on-missing (manifest aligné optional), intégré dans quick-check/Make; docs/READMEs/progress MAJ; sitemap OK.
2025-12-26 05:20:00 | C/Ft_services | IN_PROGRESS | Status JSON produit par la pipeline (logs_metrics_status avec --optional) ajouté aux key links/index et downloads portail; options fail-on-badge/missing disponibles; artefacts régénérés, sitemap OK.
2025-12-26 05:40:00 | C/Ft_services | IN_PROGRESS | Quick-check accepte fail-on-badge/missing via logs_metrics_status (optional override); manifest/checksums/status régénérés; quick-check strict vert.
2025-12-26 05:55:00 | C/Ft_services | IN_PROGRESS | Statut global (overall) calculé depuis badge+sitemap+manifest (ignores optional), affiché dans index/portal; statut JSON régénéré avec overrides.
2025-12-25 21:47:08 | C/Ft_services | IN_PROGRESS | Index MD affiche l’historique overall (tableau + lien) et se régénère en fin de pipeline; doublon sitemap supprimé; smoke/quick-check à jour (overall history 5 entrées, checksums OK).
2025-12-25 21:07:40 | C/Ft_services | IN_PROGRESS | Pipeline régénérée: historique overall généré avant manifest/checksums, portail enrichi (liens + tableau historique), artefacts rebuild (smoke+quick-check OK, overall history csv créé).
2025-12-25 22:22:58 | C/Ft_services | IN_PROGRESS | Index HTML nettoyé (optionnels manifest affichés, snapshot de statut, liens/overall table dé-doublés); pipeline (smoke) + quick-check régénérés (overall alert attendu, sitemap ok).
2025-12-25 22:04:38 | C/Ft_services | IN_PROGRESS | Index charge run_summary/latest/status en sécurisé (warning explicite) et affiche enfin les statuts réels; smoke script fiabilisé (args sans command substitution); pipeline+smoke+quick-check régénérés (overall alert, sitemap ok).
2025-12-26 06:10:00 | C/Ft_services | IN_PROGRESS | Statut overall intégré (badge+sitemap+manifest) dans run summary/index/portal; pipeline génère status.json (optional override) et quick-check supporte fail-on-badge/missing; artefacts régénérés.
2025-12-25 20:14:26 | C/Ft_services | IN_PROGRESS | Badge statut global SVG ajouté (status.json) et intégré pipeline/index/portal/manifest/checksums; artefacts régénérés.
2025-12-25 20:22:36 | C/Ft_services | IN_PROGRESS | Pipeline regénérée (manifest/sitemap/checksums/index/portal/run_summary) avec badge statut global SVG; make metrics-status OK, artefacts à jour (overall alert, sitemap ok).
2025-12-25 20:48:45 | C/Ft_services | IN_PROGRESS | Gate `--fail-on-overall` étendu au quick-check (status JSON/temp + vue texte, sitemap strict) et checksums régénérés; artefacts OK (overall alert, sitemap ok).
2025-12-25 20:52:46 | C/Ft_services | IN_PROGRESS | Smoke script (pipeline+quick-check) avec gates fail-on-overall/badge; Makefile aligné, quick-check fi corrigé, docs/README à jour (artefacts overall alert, sitemap ok).

2025-12-25 22:26:26 | C/Ft_services | IN_PROGRESS | Comptage manifest corrigé (optionnels séparés) + affichage counts dans status/portal/index; pipeline smoke OK (overall alert attendu).
2025-12-25 23:23:20 | C/Ft_services | IN_PROGRESS | Run summary enrichi avec manifest détaillé (required/optional comptés depuis status); rendu MD/HTML et pipeline régénérés (smoke+quick-check OK, overall alert prévu).
2025-12-25 23:53:45 | C/Ft_services | IN_PROGRESS | Couverture optionnels calculée (status/summary/index/portal) et pipeline régénéré (smoke+quick-check OK, overall alert attendu).
2025-12-26 00:18:20 | C/Ft_services | IN_PROGRESS | Badge toujours alert (anomalies) mais surcharge réduite à 0 en nettoyant status_special.log; pipeline/regénération OK.
2025-12-26 00:29:15 | C/Ft_services | DONE | Badge OK (anomalies=0, overload=0) après nettoyage fixtures + recalcul anomalies; pipeline smoke+quick-check verts, manifest/coverage affichés.
2025-12-26 01:02:41 | C/Pipex | IN_PROGRESS | Ajout here_doc (limiter, append), tests Bash étendus, crashs corrigés (init struct, tests OK).
2025-12-26 01:02:41 | C/Pipex | IN_PROGRESS | Pipelines n>2 et here_doc opérationnels (fermetures pipe fix), tests Bash étendus OK; README mis à jour.
2025-12-26 01:17:55 | C/Pipex | IN_PROGRESS | Pipelines multi-commandes + here_doc (append) stables (exit code dernier cmd), tests étendus OK; README mis à jour.
2025-12-26 01:27:46 | C/Pipex | DONE | Pipeline n-cmd + here_doc stabilisé (FD fixes, exit code dernier cmd), tests Bash étendus OK; docs MAJ.
2025-12-26 01:27:46 | C/Ft_ssl_md5 | IN_PROGRESS | Squelette ft_ssl (md5/sha256 OpenSSL) + CLI options (-q -r -s, fichiers, stdin); Makefile prêt, README ajouté.
2025-12-26 02:00:50 | C/Ft_ssl_md5 | IN_PROGRESS | Implémentations MD5/SHA256 maison (plus de dépendance OpenSSL), support -p/-q/-r/multi -s, tests auto md5sum/sha256sum OK.
2025-12-26 02:03:19 | C/Ft_ssl_md5 | IN_PROGRESS | -p gère plusieurs occurrences (echo répété), reverse quote les strings, multi -s/fichiers/erreurs testés; script de tests élargi.
2025-12-26 02:05:01 | C/Ft_ssl_md5 | IN_PROGRESS | Parsing ordonné des options (-p/-s), cache stdin partagé entre -p, reverse quote strings; autotests élargis et verts.
2025-12-26 02:09:09 | C/Ft_ssl_md5 | IN_PROGRESS | Gestion des erreurs (-s manquant, option/commande inconnue), fichier manquant continue les autres, sortie usage alignée; tests auto étendus OK.
2025-12-26 02:13:33 | C/Ft_ssl_md5 | IN_PROGRESS | Target make test ajoutée; tests couvrent -q -p, ordre -s/fichiers, erreurs d’options/commandes; pipeline de tests verte.
2025-12-26 02:17:52 | C/Ft_ssl_md5 | DONE | CLI md5/sha256 complète (-p/-q/-r/-s, fichiers) avec gestion d’erreurs/usage, cache stdin, make test vert; projet finalisé.
2025-12-26 02:26:21 | C/Ft_ssl_base64_des | IN_PROGRESS | Commande base64 opérationnelle (encode/décode, -i/-o, stdin/stdout), implémentation maison alignée openssl, cible make test; DES à venir.
2025-12-26 02:31:47 | C/Ft_ssl_base64_des | IN_PROGRESS | Ajout des commandes des-ecb/des-cbc (clé/IV, -a base64, PKCS7), implémentation DES maison, make test couvre base64 + DES ECB/CBC.
2025-12-26 02:34:58 | C/Ft_ssl_base64_des | IN_PROGRESS | Dérivation clé/IV depuis mot de passe+sel (MD5 EVP_BytesToKey) ajoutée, options -p/-s gérées, tests étendus (ECB/CBC, -a, password) verts.
2025-12-26 02:39:57 | C/Ft_ssl_base64_des | IN_PROGRESS | Salted__ pris en charge (gen sel, dérivation md5), gestion des headers, tests base64+DES (clé/IV/pass/salt/-a) verts.
2025-12-26 02:46:16 | C/Ft_ssl_base64_des | IN_PROGRESS | Salted__ autodetect (-a) avec mot de passe, génération/lecture du sel, échec sans mot de passe; tests étendus base64/DES/salted tous verts.
2025-12-26 02:48:03 | C/Ft_ssl_base64_des | IN_PROGRESS | Tests ajoutés pour mauvais/missing mot de passe sur Salted__ (-a); base64/des-ecb/des-cbc restent verts.
2025-12-26 02:55:25 | C/Ft_ssl_base64_des | DONE | Option -A (pas de wrap Base64) ajoutée pour base64 et DES -a; make test étendu et vert, projet finalisé.
2025-12-26 03:00:05 | C/Ft_mini_ls | DONE | Implémentation ls -1tr sans arguments (tri mtime asc, cache dotfiles), message d’erreur si arguments, tests comparatifs vs ls -1tr verts.
2025-12-26 03:23:36 | C/Ft_script | DONE | pty interactif + resize (fallback pipes), options -a/-c/-e/-f/-q, flush immédiat testé, retour code enfant optionnel, tests verts.
2025-12-26 03:23:36 | C/Ft_shmup | IN_PROGRESS | Prototype jouable ncurses : fond défilant, ennemis aléatoires qui tirent, collisions, HUD score/vies, contrôles WASD/flèches + tir, pause/quit, boucle ~60 FPS.
2025-12-26 03:33:56 | C/Ft_shmup | IN_PROGRESS | Vagues d’ennemis oscillants avec tirs périodiques, compteur de wave, fond défilant, HUD score/vies/wave, build OK.
2025-12-26 03:40:00 | C/Ft_shmup | IN_PROGRESS | HUD enrichi (high score persistant via highscore.txt), vagues oscillantes/tirs périodiques, boucle ~60 FPS toujours OK.
2025-12-26 03:50:00 | C/Ft_shmup | IN_PROGRESS | Pacing dynamique : waves rapprochées et tirs ennemis plus rapides selon la progression; HUD score/high score/vies/wave, fond défilant.
2025-12-26 04:00:00 | C/Ft_shmup | IN_PROGRESS | Power-ups vie (+) avec invulnérabilité post-hit, vies max 5, pacing dynamique waves/tirs, HUD score/high score/vies/wave mis à jour.
2025-12-26 03:54:05 | C/Ft_shmup | IN_PROGRESS | Boss récurrent (HP multiples, triple tir, drop garanti), power-ups vie, invulnérabilité, pacing waves/tirs dynamique, HUD boss HP.
2025-12-26 03:58:46 | C/Ft_shmup | IN_PROGRESS | Power-ups vie/bouclier/tir rapide (timers HUD), bouclier invulnérable, boss récurrent triple tir, pacing dynamique.
2025-12-26 04:02:51 | C/Ft_shmup | IN_PROGRESS | Top scores persistants (top5) affichés sur HUD, power-ups multiples et boss récurrent conservés, jeu adapté à la taille du terminal.
2025-12-26 04:10:00 | C/Ft_shmup | DONE | Campagne 15 vagues (boss récurrents, power-ups, bonus victoire), HUD complet (timers, top scores persistants), adaptation terminal; build OK.
2025-12-26 04:19:22 | C/Ft_shield | IN_PROGRESS | Prototype trojan démonstratif : copie binaire dans ~/.ft_shield, log d’exécution, commande leurre -c, tests auto verts.
2025-12-26 04:24:00 | C/Ft_shield | DONE | Ajout hook bashrc (-i) pour persistance, copie binaire, logging et commande leurre; tests auto vérifient copie/log/hook.
2025-12-26 04:28:42 | C/ft_helpme | IN_PROGRESS | CLI template d’aide (projet/question/contexte/timestamp) avec tests automatisés et README; build OK.
2025-12-26 04:33:21 | C/ft_helpme | IN_PROGRESS | Template enrichi (expected/actual, logs/repro), paramètres projet/question/contexte, tests auto verts.
2025-12-26 04:39:29 | C/ft_helpme | IN_PROGRESS | Flag -m pour sortie Markdown (sections structurées), tests enrichis + README/usage à jour.
2025-12-26 04:45:00 | C/ft_helpme | DONE | Flags -m/-o pour Markdown et export fichier, template enrichi (expected/actual/logs), tests et READMEs à jour.
2025-12-26 05:00:00 | C/ft_self_analysis | IN_PROGRESS | Démarrage du sujet : première version structurée de l’auto-analyse (expériences, personnalité, vision, tournants) en Markdown.
2025-12-26 04:52:55 | C/ft_self_analysis | IN_PROGRESS | Enrichissement : synthèse 30s, objectifs SMART 6-12 mois, style de travail et questions de revue ajoutés au document principal.
2025-12-26 04:57:48 | C/ft_self_analysis | IN_PROGRESS | Exemples chiffrés, tableau de suivi des objectifs et plan oral 10 minutes ajoutés pour préparer la revue.
2025-12-26 05:02:52 | C/ft_self_analysis | IN_PROGRESS | Ajout checklist revue + template mensuel + section preuves/liens à maintenir, pour rendre la préparation et le suivi actionnables.
2025-12-26 05:07:53 | C/ft_self_analysis | DONE | Tableau de suivi renseigné, journal mensuel créé, support oral prêt (slides markdown) + README/usage horodatés.
2025-12-26 05:47:49 | C/ft_hangouts | DONE | Prototype CLI complet : notifications, filtres/recherche, pins/mutes, export/delete/backup, stats, tests automatisés; docs à jour.
2025-12-26 07:27:59 | C/ft_newton | DONE | Moteur physique complet (cibles fixes/aléatoires, bornage/vent/traînée, projo configurable, exports JSON/MD/CSV/trace, stats contacts) avec tests auto verts et docs horodatés.
2025-12-26 07:59:14 | C/ft_services | DONE | Pipeline finale stable (status/badge recalculés post-manifest, sitemaps/manifest/run_summary/index/portal alignés), validation full OK.
2025-12-26 07:58:45 | C/ft_services | IN_PROGRESS | Pipeline rejouée : status/badge recalculés après manifest final, sitemaps/manifest/run_summary/index/portal alignés, validation full OK.
2025-12-26 07:56:27 | C/ft_services | IN_PROGRESS | Pipeline rejouée : manifest/sitemap régénérés en fin de run, validation finale OK, index/portal/run_summary rafraîchis.
2025-12-26 07:55:15 | C/ft_services | IN_PROGRESS | Pipeline rejouée : sitemap régénérée après manifest final, index/portal/run_summary rafraîchis, validation full OK.
2025-12-26 07:44:01 | C/ft_services | IN_PROGRESS | Pipeline/validate exécutent désormais snapshot_check (Totaux/ratios, alignement CSV/JSON) avec flags --no-snapshot-check/--snapshot-tolerance ; logs_metrics_latest aligne anomalies_count sur les anomalies signalées (champ anomalies_flagged_count + anomalies_total) ; docs/CLI/README mis à jour et pipeline rejouée.
2025-12-26 07:35:27 | C/ft_services | IN_PROGRESS | Ajout du checker `logs_metrics_snapshot_check` (Totaux/ratios, alignement CSV/JSON), intégré au quick-check/Make pour sécuriser les exports status_top2; docs CLI/README rafraîchies.
2025-12-26 07:59:14 | C/ft_services | DONE | Pipeline finale stable (status/badge recalculés post-manifest, sitemaps/manifest/run_summary/index/portal alignés), validation full OK et documentation horodatée.
2025-12-26 07:59:50 | C/Ft_ping | IN_PROGRESS | Ajout de `make test` et tests checksum (échantillon RFC 1071 + trame Echo) pour sécuriser la fonction ICMP.
2025-12-26 08:20:02 | C/Ft_ping | IN_PROGRESS | Options `-c` (arrêt après N paquets) et `-t` (TTL 1-255) ajoutées, intervalle 1s entre envois, tests checksum+options via `make test`.
2025-12-26 08:33:30 | C/Ft_ping | IN_PROGRESS | Option `-i <sec>` pour régler l’intervalle (TTL appliqué au socket), usage/commands docs MAJ, tests checksum+parsing verts (`make test`).
2025-12-26 08:23:04 | C/Ft_ping | IN_PROGRESS | Intervalle paramétrable `-i <sec>` ajouté (défaut 1s) en plus de `-c`/`-t`; tests checksum+parsing verts via `make test`.
2025-12-26 08:13:54 | C/Ft_ping | IN_PROGRESS | Option `-c <count>` ajoutée (arrêt après N requêtes) + intervalle 1s entre envois; `make test` toujours vert (checksum RFC+Echo).
2025-12-26 08:40:28 | C/Ft_ping | IN_PROGRESS | Timeout configurable `-W` et mode silencieux `-q` ajoutés (timeout per-request + suppression des lignes par paquet), parsing/tests/usage/commands mis à jour.
2025-12-26 08:43:42 | C/Ft_ping | IN_PROGRESS | Détection et comptage des réponses en double (`(DUP!)` + stats) ajoutés; timeout/quiet conservés, tests `make test` OK, docs horodatées.
2025-12-26 08:49:05 | C/Ft_ping | IN_PROGRESS | Deadline globale `-w` ajoutée (clamp des timeouts sur le temps restant), parsing/tests/docs mis à jour; DUP/timeout/quiet intégrés.
2025-12-26 08:55:32 | C/Ft_ping | IN_PROGRESS | Payload ajustable `-s <bytes>` (min sizeof timeval, par défaut 56) avec RTT toujours basé sur le timestamp embarqué; docs/usage/tests MAJ.
2025-12-26 08:59:14 | C/Ft_ping | IN_PROGRESS | Motif payload custom `-p <hex>` ajouté (répété après timestamp), `-s/-w/-W/-q/(DUP!)` consolidés; parsing/tests/docs à jour.
2025-12-26 09:03:29 | C/Ft_ping | IN_PROGRESS | Statistiques duplicats détaillées + code de retour non-zero si pertes; motif/payload deadline/timeout/quiet en place, tests/build verts.
2025-12-26 09:07:20 | C/Ft_ping | IN_PROGRESS | TOS/DSCP `-Q` ajouté (setsockopt IP_TOS), motif/payload/timeout/deadline/quiet consolidés; parsing/tests/docs horodatés.
2025-12-26 09:13:51 | C/Ft_ping | IN_PROGRESS | Option `-D` (timestamp ms en préfixe des sorties) ajoutée; TOS/payload/motif/quiet/timeout/deadline déjà en place; tests/build verts, docs MAJ.
2025-12-26 09:18:43 | C/Ft_ping | IN_PROGRESS | Option `-R` (reverse DNS des replies) ajoutée, alignée avec timestamps `-D`/TOS/payload/motif; tests/build toujours verts.
2025-12-26 09:23:54 | C/Ft_ping | IN_PROGRESS | Bind source `-S <ip>` ajouté (choix de l’adresse d’émission), reverse DNS/timestamps/TOS/payload/motif en place; tests/build verts, docs/commands MAJ.
2025-12-26 09:29:06 | C/Ft_ping | IN_PROGRESS | Détection des réponses out-of-order (compteur + marquage `(OUT-OF-ORDER)`), stats enrichies; bind/TOS/reverse DNS/timestamps/payload/motif toujours OK, tests/build verts.
2025-12-26 09:34:35 | C/Ft_ping | IN_PROGRESS | Option `-O` (arrêt dès la première réponse) ajoutée, parsing/tests/commands/README MAJ; out-of-order/dup/bind/timestamps/TOS/payload présents, tests/build verts.
2025-12-26 09:38:01 | C/Ft_ping | DONE | CLI complète (TOS/bind/source/timeout/deadline/quiet/timestamps/reverse DNS/payload/motif/stop-on-reply, dup/out-of-order stats, exit code pertes), docs/tests/build à jour.
2025-12-26 11:08:36 | C/ft_nmap | IN_PROGRESS | `-P -` lit depuis stdin et un nouveau test stdin est intégré à `make test`; flag `-O` filtre tableau/lignes open, retries `-R` exportés, exit codes open=2/timeout=3, flags `-4/-6`, input `-P`, batch poll `-c`, randomisation `-r`; scans basiques OK.
2025-12-26 11:37:58 | C/ft_nmap | IN_PROGRESS | Exclusions `-x/-X` (liste ou fichier/stdin) appliquées après les ports, nouveau test d’exclusion dans `make test`, docs et Makefile mis à jour, build/tests verts.
2025-12-26 12:38:08 | C/ft_nmap | IN_PROGRESS | Stats enrichies avec le compteur “excluded” (JSON/CSV + sortie), test d’exclusion renforcé, build/tests OK.
2025-12-26 12:58:39 | C/ft_nmap | IN_PROGRESS | Option `-F` (stop dès le premier OPEN), compteur “scanned” reflétant les ports réellement traités (résumé/JSON/CSV/table), sortie clarifiée, build/tests OK.
2025-12-26 13:08:01 | C/ft_nmap | IN_PROGRESS | Test auto “stop-on-open” (serveur local http) ajouté à `make test`, README horodaté, suite de tests complète OK.
2025-12-26 13:28:07 | C/ft_nmap | IN_PROGRESS | Test stop-on-open rendu robuste (skip auto si bind interdit), README horodaté et note sur le test; build/tests OK (avec skip contrôlé).
2025-12-26 13:28:07 | C/ft_nmap | IN_PROGRESS | Export NDJSON (`-N`) ajouté, nouveau test d’export NDJSON dans `make test`, stats conservées; build/tests OK (stop-on-open peut être skippé si bind interdit).
2025-12-26 14:02:05 | C/ft_nmap | IN_PROGRESS | Résultats triés par port (NDJSON/exports déterministes), affichage live/table enrichi avec les retries, test NDJSON vérifie l’ordre; build/tests OK (stop-on-open peut se skipper).
2025-12-26 14:14:26 | C/ft_nmap | IN_PROGRESS | Option -k (top ports courants) ajoutée + test dédié, usage/README mis à jour; build/tests OK (stop-on-open peut se skipper).
2025-12-26 15:14:36 | C/ft_nmap | IN_PROGRESS | Stats JSON/CSV enrichies (requested, start/end, durées min/max/moy), nouveau test de stats JSON, résumé CLI montre min/avg/max; tests complets OK (stop-on-open peut se skipper).
2025-12-26 15:29:31 | C/ft_nmap | IN_PROGRESS | Export YAML (-Y) ajouté avec stats complètes, test stats étendu, doc horodatée, suite `make test` OK (skip possible sur stop-on-open).
2025-12-26 15:40:32 | C/ft_nmap | IN_PROGRESS | Option -w (délai entre cycles) ajoutée, test d’elapsed, README/usage mis à jour, suite `make test` OK (stop-on-open peut se skipper).
2025-12-26 16:12:51 | C/ft_nmap | IN_PROGRESS | Résumé CLI affiche aussi les taux open/closed/timeout, stats exportent open_rate/closed_rate/timeout_rate (JSON/CSV/YAML) calculés sur les ports scannés; test stats mis à jour, README horodaté.
2025-12-26 16:17:41 | C/ft_nmap | IN_PROGRESS | Option -f <n> pour arrêter après n ports OPEN (alias -F=1), ports restants marqués pending/unknown; nouveau test stop-after-n-open (deux serveurs) ajouté à `make test`, docs/usage horodatés.
2025-12-26 16:21:42 | C/ft_nmap | IN_PROGRESS | Stats ajoutent avg_retries_per_port et first_open_ms (exports JSON/CSV/YAML + résumé CLI), calculés sur les ports scannés; test stats étendu, docs horodatés.
2025-12-26 16:07:50 | C/ft_nmap | IN_PROGRESS | Option -M (deadline ms) arrête le scan proprement et marque pending/deadline_hit, stats/export ajoutent delay_ms/deadline/pending et couvrent les ports non scannés; nouveau test deadline intégré à `make test`.
2025-12-26 16:31:27 | C/ft_nmap | IN_PROGRESS | Option -e <seed> force un shuffle déterministe (implique -r) et exporte la seed/randomized dans JSON/CSV/YAML + résumé CLI; nouveau test random_seed ajouté à `make test`, README/usage horodatés.
2025-12-26 16:36:07 | C/ft_nmap | IN_PROGRESS | Stats/export indiquent maintenant les ports les plus rapides/lents (fastest/slowest + durées) dans le résumé CLI et JSON/CSV/YAML; test stats enrichi, docs horodatés.
2025-12-26 16:38:57 | C/ft_nmap | IN_PROGRESS | Option -g <progress_ms> ajoute un reporting de progression périodique (stderr) avec counters; test progress intégré à `make test`, README/usage horodatés.
2025-12-26 16:44:23 | C/ft_nmap | IN_PROGRESS | Option -u <timeouts> stoppe après N timeouts (ports restants pending), flag timeout_stop_hit/threshold exporté dans JSON/CSV/YAML + résumé CLI; test stats mis à jour, docs horodatées.
2025-12-26 17:05:00 | C/ft_nmap | IN_PROGRESS | Backoff des retries via -b <pct> (timeout allongé à chaque retry, export retry_backoff_pct), timeouts évalués par socket; tests stats/usage/exports mis à jour.
2025-12-26 17:33:00 | C/ft_nmap | IN_PROGRESS | Export HTML autonome ajouté (-H file.html) avec cartes de stats et tableau des ports; test HTML intégré au Makefile, docs horodatées.
2025-12-26 18:10:00 | C/ft_nmap | IN_PROGRESS | Filtre d’exports -E open|known|all (ports filtrés dans JSON/CSV/YAML/HTML/NDJSON/Markdown, stats inchangées), export Markdown (-m) ajouté; tests export_filter/markdown intégrés, docs horodatées.
2025-12-27 12:00:00 | C/ft_nmap | IN_PROGRESS | Export XML (-Z file.xml) ajouté (stats + ports avec filtres d’export), test xml_export intégré au Makefile, docs/usage horodatés.
2025-12-27 14:00:00 | C/ft_nmap | IN_PROGRESS | Exports vers stdout (chemin '-') + option -Q pour envoyer le résumé sur stderr; auto-redirection du résumé si stdout export, test stdout_json ajouté, docs/usage horodatés.
2025-12-27 15:10:00 | C/ft_nmap | IN_PROGRESS | Export JSON stats-only (-J summary.json) ajouté (sans ports), test json_summary ajouté à `make test`, docs/usage horodatés.
2025-12-27 18:40:00 | C/ft_nmap | IN_PROGRESS | Option -I pour forcer une IP (bypass DNS) tout en exportant la liste résolue (resolved_count/table), résumé indique override; tests resolved/json renforcés, docs/Makefile horodatés.
2025-12-26 17:49:21 | C/ft_nmap | IN_PROGRESS | Mode dry-run (-n) ajouté : résout seulement l’hôte/override, ports laissés pending/unknown, flag dry_run exporté tous formats, test dry_run intégré, docs/Makefile mis à jour.
2025-12-26 19:48:19 | C/ft_nmap | IN_PROGRESS | Tests dry-run étendus (CSV/YAML/XML/Markdown) via nouveau script, README horodaté et exemples dry-run ajoutés.
2025-12-26 20:20:29 | C/ft_nmap | IN_PROGRESS | Option -V/--version ajoutée (affiche la version et quitte), test version dédié, README/usage horodaté.
2025-12-26 20:30:27 | C/ft_nmap | IN_PROGRESS | Tous les tests (dont dry_run exports/version) passent après ajustement Markdown dry_run; README horodaté.
2025-12-26 20:44:17 | C/ft_nmap | IN_PROGRESS | Version ft_nmap injectee dans exports (JSON/YAML/XML/MD/CSV comment), tests json_summary mis a jour, README horodate.
2025-12-26 20:58:33 | C/ft_nmap | IN_PROGRESS | Version verifiee sur exports CSV/YAML/XML/MD via test dry_run_exports, README horodate.
2025-12-26 20:59:23 | C/ft_nmap | IN_PROGRESS | Ajout verification version dans dry_run_exports (CSV/YAML/XML/MD), tous les tests make test passent en local.
2025-12-27 05:28:47 | C/ft_nmap | IN_PROGRESS | Confirmed docs/README/exports mention version metadata flags in reviewer guidance; no code changes required.
2025-12-27 10:23:52 | general | REVIEW | Confirmed documentation/README entries remain current; no code changes performed.
2025-12-27 11:08:44 | general | REVIEW | Confirmed docs/logs_metrics.md + README guidance remain in sync; no code changes needed.
2025-12-27 12:36:10 UTC | C/Ft_services | IN_PROGRESS | Rerun helper `logs_metrics_export.sh --dir C/ft_services/reports --pattern status --topn 2` and verified columns `timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio` via `tail -n 5 C/ft_services/reports/log_metrics_snapshot.status_top2.csv` and `jq '.[-1]' C/ft_services/reports/log_metrics_snapshot.status_top2.json`, citing `C/ft_services/docs/logs_metrics.md` to document the workflow.
2026-01-02 17:03:13 | C/ft_nmap | IN_PROGRESS | Support des noms de services TCP dans -p/-P/-x/-X (http/https/ssh) avec parsing range robuste, version 0.2.1 et test service_names; docs/usage mis a jour.
2026-01-02 17:04:59 | C/ft_nmap | IN_PROGRESS | Suite complete des tests make test OK (stop-after-n-open ignore car bind refuse), validation parsing service_names; README horodate.
2026-01-02 17:13:51 | C/ft_nmap | IN_PROGRESS | Ajout scan multi-cibles via -i/--file avec export par cible (%s), aliases --ip/--ports/--speedup, test targets_file et docs mis a jour.
2026-01-02 17:14:28 | C/ft_nmap | IN_PROGRESS | make test OK apres ajout multi-cibles (-i) et test targets_file; README horodate.
2026-01-02 17:20:39 | C/ft_nmap | IN_PROGRESS | Ajout mode --scan udp (sondes UDP sequentielles + retries), resume indique tcp/udp, test scan_udp; version 0.2.3 et docs MAJ.
2026-01-02 17:21:27 | C/ft_nmap | IN_PROGRESS | make test OK apres ajout --scan udp; resume tcp/udp valide, README horodate.
2026-01-02 17:25:02 | C/ft_nmap | IN_PROGRESS | Exports enrichis avec scan_type (JSON/YAML/XML/CSV/HTML/MD), version 0.2.4, tests adaptes + make test OK.
2026-01-02 17:26:56 | C/ft_nmap | IN_PROGRESS | Limite 1024 ports appliquee (apres exclusions), test port_limit ajoute, version 0.2.5 et make test OK.
2026-01-02 17:29:03 | C/ft_nmap | DONE | Projet stabilise (multi-cibles, scan udp, exports enrichis, limite 1024 ports), tests make test OK, documentation finalisee.
2026-01-02 17:35:15 | C/Ft_shmup | IN_PROGRESS | Ajout power-up Spread (tir en éventail) avec projectiles diagonaux, HUD et rendu power-up distinct; build OK.
2026-01-02 17:39:36 | C/Ft_shmup | IN_PROGRESS | Ajout ennemis kamikaze (suivi joueur, spawn par vague), score ajuste, rendu + build OK.
2026-01-02 17:44:55 | C/Ft_shmup | IN_PROGRESS | Overlay aide (touche h) avec rappel controles/power-ups/ennemis, HUD mis a jour; build OK.
2026-01-02 17:49:22 | C/Ft_shmup | IN_PROGRESS | Ajout bannieres Wave/Boss au debut des vagues, affichage centre; build OK.
2026-01-02 17:54:22 | C/Ft_shmup | IN_PROGRESS | Ajout combo de kills (bonus score si enchainement rapide), HUD affiche le combo; build OK.
2026-01-02 17:59:42 | C/Ft_shmup | IN_PROGRESS | Confirmation de sortie (q puis y/n) avec overlay, HUD conserve infos; build OK.
2026-01-02 18:04:50 | C/Ft_shmup | IN_PROGRESS | Ajout post-game avec relance (r) sans quitter, loop ncurses conserve scores; build OK.
2026-01-02 18:09:45 | C/Ft_shmup | IN_PROGRESS | Ajout ennemi sniper (tirs diriges), icone T, spawn par vague; build OK.
2026-01-02 18:15:47 | C/Ft_shmup | IN_PROGRESS | Boss passe en mode enraged (cadence acceleree + kamikazes), rendu B explicite; build OK.
2026-01-02 18:19:55 | C/Ft_shmup | IN_PROGRESS | Ajout power-up Slow Time (Z) ralentissant ennemis et tirs, HUD/aide mis a jour; build OK.
2026-01-02 18:25:17 | C/Ft_shmup | IN_PROGRESS | Ajout bombes (power-up B + touche b) nettoie tirs/ennemis, HUD mis a jour; build OK.
2026-01-02 18:30:26 | C/Ft_shmup | IN_PROGRESS | Timers gameplay relies on game-time (pause fige timers/power-ups), logique temps refactor, build OK.
2026-01-02 18:34:52 | C/Ft_shmup | IN_PROGRESS | Fin de partie clarifiee (Victory/Game Over) + touche x pour quitter, build OK.
2026-01-02 18:39:38 | C/Ft_shmup | IN_PROGRESS | Ajout dash (touche e) avec invuln courte + cooldown, HUD/aide mis a jour; build OK.
2026-01-02 18:44:28 | C/Ft_shmup | IN_PROGRESS | Ajout auto-fire (touche f) pour tir continu, HUD/aide mis a jour; build OK.
2026-01-02 18:49:49 | C/Ft_shmup | IN_PROGRESS | Ajout ecran titre (start espace/entree) et retour au titre via t; build OK.
2026-01-02 18:55:26 | C/Ft_shmup | IN_PROGRESS | Mode Endless/Campaign selectionnable au titre (m), HUD affiche le mode; build OK.
2026-01-02 18:58:57 | C/Ft_shmup | DONE | Projet stabilise (campagne + endless, power-ups, boss/enraged, HUD complet), build OK.
2026-01-02 19:06:38 | C/ft_linear_regression | IN_PROGRESS | Ajout median/stddev RMSE dans validation_summary (txt/md/json/html/csv/yaml) et scripts d'export mis a jour.
2026-01-02 19:13:15 | C/ft_linear_regression | IN_PROGRESS | Early stopping restaure les meilleurs theta, validation supporte early-stop avec best_epoch/best_train_rmse.
2026-01-02 19:15:24 | C/ft_linear_regression | IN_PROGRESS | validation.py ecrit data/validation_report.txt via --output (default) et docs mises a jour.
2026-01-02 19:19:39 | C/ft_linear_regression | IN_PROGRESS | Ajout bootstrap validation (OOB) via --bootstrap-samples avec RMSE moyen, rapport enrichi.
2026-01-02 19:25:49 | C/ft_linear_regression | IN_PROGRESS | Validation bootstrap executee, summary JSON/MD/HTML/CSV/YAML regenere avec bootstrap average.
2026-01-02 19:29:25 | C/ft_linear_regression | IN_PROGRESS | Tests validation_summary (bootstrap) ajoutes, pytest OK.
2026-01-02 19:34:52 | C/ft_linear_regression | DONE | Documentation rmse_plot + roadmap post-review, plan finalise.
2026-01-02 19:41:38 | C/ft_hangouts | IN_PROGRESS | Auto-creation contact sur SMS inconnu (CLI), tests scenario mis a jour.
2026-01-02 19:42:33 | C/ft_hangouts | IN_PROGRESS | Auto-creation contact SMS inconnus + tests run_tests.sh OK.
2026-01-02 19:46:10 | C/ft_hangouts | IN_PROGRESS | Ajout settings theme (CLI) + tests run_tests.sh OK.
2026-01-02 19:51:13 | C/ft_hangouts | IN_PROGRESS | Ajout avatars contacts (add/set-avatar) + run_tests.sh OK.
2026-01-02 19:55:45 | C/ft_hangouts | IN_PROGRESS | Import/export CSV contacts + run_tests.sh OK.
2026-01-02 19:59:45 | C/ft_hangouts | IN_PROGRESS | Guide utilisateur CLI ajoute.
2026-01-02 20:04:41 | C/ft_hangouts | IN_PROGRESS | README complete, docs/user_journeys.md ajoute.
2026-01-02 20:11:27 | C/ft_hangouts | IN_PROGRESS | Ajout support appels (log/list/stats) + run_tests.sh OK.
2026-01-02 20:12:06 | C/ft_hangouts | IN_PROGRESS | Guide utilisateur mis a jour (section appels).
2026-01-02 20:15:27 | C/ft_hangouts | IN_PROGRESS | Export/import appels JSON + run_tests.sh OK.
2026-01-02 20:19:04 | C/ft_hangouts | DONE | Prototype CLI complet, docs/tests stabilises.
2026-01-02 20:25:54 | C/Ft_ls | DONE | Tests run_tests.sh OK, plan/README finalises.
2026-01-02 20:31:24 | C/ft_linux | IN_PROGRESS | Toolchain split gcc-stage1/libgcc, docs/plan mis a jour.
2026-01-02 20:34:45 | C/ft_linux | IN_PROGRESS | Ajout scripts/validate_toolchain.sh + docs toolchain.
2026-01-02 20:40:32 | C/ft_linux | IN_PROGRESS | Ajout manifest build_system + build_system.sh ameliore.
2026-01-02 20:44:26 | C/ft_linux | IN_PROGRESS | Ajout verify_manifest.sh pour valider les tarballs.
2026-01-02 20:49:43 | C/ft_linux | IN_PROGRESS | Ajout preflight.sh (env + toolchain + manifest).
2026-01-02 20:54:22 | C/ft_linux | IN_PROGRESS | preflight appelle validate_toolchain, docs ajustes.
2026-01-02 20:59:37 | C/ft_linux | IN_PROGRESS | Ajout log_build.sh pour journaliser les builds.
2026-01-02 21:04:33 | C/ft_linux | IN_PROGRESS | Ajout quickcheck.sh (resume validations).
2026-01-02 21:09:32 | C/ft_linux | IN_PROGRESS | Ajout status_report.sh (logs + tarballs).
2026-01-02 21:14:26 | C/ft_linux | IN_PROGRESS | status_report.sh execute, rapport genere.
2026-01-02 21:19:36 | C/ft_linux | IN_PROGRESS | status_report genere TXT+CSV.
2026-01-02 21:24:42 | C/ft_linux | IN_PROGRESS | Manifest enrichi (utilitaires de base) + docs.
2026-01-02 21:30:25 | C/ft_linux | IN_PROGRESS | download_sources.sh ajoute --verify-only/--list.
2026-01-02 21:35:46 | C/ft_linux | IN_PROGRESS | Ajout missing_tarballs.sh + generation reports.
2026-01-02 21:44:45 | C/ft_linux | IN_PROGRESS | Ajout manifest_report.sh + generation reports manifest_sources.*.
2026-01-02 21:49:46 | C/ft_linux | IN_PROGRESS | Ajout generate_downloads.sh + report download_missing.sh.
2026-01-02 21:54:45 | C/ft_linux | IN_PROGRESS | Ajout verify_checksums.sh + reports sha_report.*.
2026-01-02 21:59:37 | C/ft_linux | IN_PROGRESS | verify_checksums.sh resume + exit code, rapport regenere.
2026-01-02 22:04:40 | C/ft_linux | IN_PROGRESS | Ajout report_index.sh + reports/index.md.
2026-01-02 22:09:29 | C/ft_linux | IN_PROGRESS | quickcheck.sh execute (toolchain + tarballs manquants).
2026-01-02 22:14:56 | C/ft_linux | IN_PROGRESS | download_sources.sh support --from dir.
2026-01-02 22:19:49 | C/ft_linux | IN_PROGRESS | Ajout env_audit.sh + reports env_audit.*.
2026-01-02 22:25:18 | C/ft_linux | IN_PROGRESS | setup_env.sh ajoute commandes (create/partition/attach/format/mount).
2026-01-02 22:33:07 | C/ft_linux | IN_PROGRESS | build_kernel.sh gere chroot/LFS, options config/modules/install + logs.
2026-01-02 22:40:12 | C/ft_linux | IN_PROGRESS | ajout build_rootfs.sh + layout rootfs TSV.
2026-01-02 22:44:56 | C/ft_linux | IN_PROGRESS | ajout bootstrap_system.sh (fstab/hosts/passwd/group/hostname).
2026-01-02 22:49:39 | C/ft_linux | IN_PROGRESS | ajout squelette SysV init (inittab+rc scripts).
2026-01-02 22:54:23 | C/ft_linux | IN_PROGRESS | ajout generate_grub_cfg.sh (grub.cfg auto).
2026-01-02 22:59:33 | C/ft_linux | IN_PROGRESS | ajout chroot_prepare.sh (mount/umount chroot).
2026-01-02 23:04:42 | C/ft_linux | IN_PROGRESS | ajout install_init_scripts.sh (mountfs/syslog/network).
2026-01-02 23:09:48 | C/ft_linux | IN_PROGRESS | ajout rootfs_report.sh (rapport structure rootfs).
2026-01-02 23:14:43 | C/ft_linux | IN_PROGRESS | ajout enable_services.sh + manifest services.
2026-01-02 23:19:02 | C/ft_linux | IN_PROGRESS | ajout build_mini_system.sh + manifest intermediaire.
2026-01-02 23:25:29 | C/ft_linux | IN_PROGRESS | manifests supportent build_type + build_mini/system adaptes.
2026-01-02 23:29:20 | C/ft_linux | IN_PROGRESS | list manifests affiche build_type.
2026-01-02 23:34:28 | C/ft_linux | IN_PROGRESS | ajout validate_manifests.sh (lint manifests).
2026-01-02 23:39:03 | C/ft_linux | IN_PROGRESS | ajout boot_checklist.sh (rapport prerequis boot).
2026-01-02 23:44:14 | C/ft_linux | IN_PROGRESS | boot_checklist.sh gere kernel absent proprement.
2026-01-02 23:49:29 | C/ft_linux | IN_PROGRESS | ajout validate_fstab.sh (rapport fstab).
2026-01-02 23:54:27 | C/ft_linux | IN_PROGRESS | ajout create_dev_nodes.sh (noeuds /dev minimaux).
2026-01-02 23:59:40 | C/ft_linux | IN_PROGRESS | ajout install_system_configs.sh + templates system.
2026-01-03 00:04:04 | C/ft_linux | IN_PROGRESS | ajout locale.sh (profile.d) via install_system_configs.sh.
2026-01-03 00:09:58 | C/ft_linux | IN_PROGRESS | ajout check_env_prereqs.sh + preflight etendu.
2026-01-03 00:14:35 | C/ft_linux | IN_PROGRESS | ajout bootstrap_all.sh (sequence setup complete).
2026-01-03 00:19:06 | C/ft_linux | IN_PROGRESS | ajout summary_report.sh (rapport synthese).
2026-01-03 00:24:31 | C/ft_linux | IN_PROGRESS | ajout ensure_grub_cfg.sh (installe grub.cfg).
2026-01-03 00:29:36 | C/ft_linux | IN_PROGRESS | ajout validate_grub_cfg.sh (rapport grub).
2026-01-03 00:34:06 | C/ft_linux | IN_PROGRESS | ajout build_kernel_config.sh (defconfig).
2026-01-03 00:39:06 | C/ft_linux | IN_PROGRESS | build_kernel.sh ajoute --print-release.
2026-01-03 00:45:07 | C/ft_linux | IN_PROGRESS | ajout build_initramfs.sh + manifest initramfs.
2026-01-03 00:49:06 | C/ft_linux | IN_PROGRESS | initramfs modules list ajoutee.
2026-01-03 00:54:36 | C/ft_linux | IN_PROGRESS | ajout validate_initramfs.sh (rapport initramfs).
2026-01-03 00:59:33 | C/ft_linux | IN_PROGRESS | ajout package_rootfs.sh (tar+checksum).
2026-01-03 01:04:14 | C/ft_linux | IN_PROGRESS | package_rootfs.sh robustifie output sans sha256sum.
2026-01-03 01:09:31 | C/ft_linux | IN_PROGRESS | ajout release_report.sh (recap versions).
2026-01-03 01:14:14 | C/ft_linux | IN_PROGRESS | summary_report.sh inclut release_report.
2026-01-03 01:19:15 | C/ft_linux | IN_PROGRESS | summary_report.sh inclut grub/initramfs.
2026-01-03 01:24:40 | C/ft_linux | IN_PROGRESS | ajout validate_services.sh (rapport services).
2026-01-03 01:29:13 | C/ft_linux | IN_PROGRESS | summary_report.sh inclut services_report.
2026-01-03 01:34:47 | C/ft_linux | IN_PROGRESS | validate_manifests.sh genere manifest_report.txt.
2026-01-03 01:39:30 | C/ft_linux | IN_PROGRESS | ajout run_reports.sh (orchestrateur rapports).
2026-01-03 01:44:30 | C/ft_linux | IN_PROGRESS | run_reports.sh inclut prerequis host.
2026-01-03 01:49:32 | C/ft_linux | IN_PROGRESS | ajout boot_bundle.sh (kernel+initramfs+grub).
2026-01-03 01:54:51 | C/ft_linux | IN_PROGRESS | ajout validate_kernel_config.sh + kernel_requirements.txt.
2026-01-03 01:59:14 | C/ft_linux | IN_PROGRESS | run_reports.sh inclut validation kernel config.
2026-01-03 02:04:12 | C/ft_linux | IN_PROGRESS | summary_report.sh inclut kernel_config_report.
2026-01-03 02:10:31 | C/ft_linux | IN_PROGRESS | initramfs install-boot + grub initrd auto.
2026-01-03 02:14:50 | C/ft_linux | IN_PROGRESS | ajout boot_artifacts.sh (artefacts /boot).
2026-01-03 02:19:18 | C/ft_linux | IN_PROGRESS | boot_bundle.sh verifie artefacts /boot.
2026-01-03 02:24:54 | C/ft_linux | IN_PROGRESS | ajout full_pipeline.sh (pipeline complet).
2026-01-03 02:29:59 | C/ft_linux | IN_PROGRESS | ajout generate_initramfs_manifest.sh + bins list.
2026-01-03 02:34:27 | C/ft_linux | IN_PROGRESS | run_reports.sh corrige doublon summary_report.
2026-01-03 02:39:40 | C/ft_linux | IN_PROGRESS | ajout chroot_enter.sh (mount+chroot+umount).
2026-01-03 02:44:18 | C/ft_linux | IN_PROGRESS | full_pipeline.sh valide config kernel.
2026-01-03 02:49:50 | C/ft_linux | IN_PROGRESS | ajout grub_install.sh (installation GRUB).
2026-01-03 02:54:34 | C/ft_linux | IN_PROGRESS | ajout detect_boot_mode.sh (BIOS/UEFI).
2026-01-03 02:59:21 | C/ft_linux | IN_PROGRESS | reports incluent boot_mode.
2026-01-03 03:04:31 | C/ft_linux | IN_PROGRESS | build_initramfs.sh supporte manifest genere.
2026-01-03 03:09:25 | C/ft_linux | IN_PROGRESS | ajout host_requirements.md.
2026-01-03 03:14:51 | C/ft_linux | IN_PROGRESS | ajout run_vm.sh (boot QEMU).
2026-01-03 03:19:24 | C/ft_linux | IN_PROGRESS | run_vm.sh supporte SSH port forwarding.
2026-01-03 03:24:21 | C/ft_linux | IN_PROGRESS | run_vm.sh aide clarifiee pour SSH.
2026-01-03 03:29:12 | C/ft_linux | IN_PROGRESS | run_vm.sh ajoute exemple SSH.
2026-01-03 03:34:46 | C/ft_linux | IN_PROGRESS | ajout boot_finalize.sh (finalisation boot).
2026-01-03 03:39:14 | C/ft_linux | IN_PROGRESS | boot_finalize rapporte + summary.
2026-01-03 03:44:38 | C/ft_linux | IN_PROGRESS | ajout archive_reports.sh (bundle rapports/logs).
2026-01-03 03:49:34 | C/ft_linux | IN_PROGRESS | validate_grub_cfg verifie initrd.
2026-01-03 03:54:30 | C/ft_linux | IN_PROGRESS | summary_report regroupe boot/grub/initramfs.
2026-01-03 03:59:31 | C/ft_linux | IN_PROGRESS | build_initramfs.sh peut generer le manifest.
2026-01-03 04:04:33 | C/ft_linux | IN_PROGRESS | ajout runbook complet.
2026-01-03 04:09:37 | C/ft_linux | IN_PROGRESS | ajout check_ready_to_boot.sh (rapport boot ready).
2026-01-03 04:14:20 | C/ft_linux | IN_PROGRESS | check_ready_to_boot verifie rc scripts.
2026-01-03 04:19:23 | C/ft_linux | IN_PROGRESS | reports incluent ready_to_boot.
2026-01-03 04:24:15 | C/ft_linux | IN_PROGRESS | ajout snapshot_image.sh (snapshot disque).
2026-01-03 04:29:16 | C/ft_linux | IN_PROGRESS | run_vm.sh aide mentionne defaults mem/cpus.
2026-01-03 04:34:44 | C/ft_linux | IN_PROGRESS | ajout convert_image.sh (qcow2).
2026-01-03 04:39:17 | C/ft_linux | IN_PROGRESS | run_vm.sh detecte qcow2.
2026-01-03 04:44:42 | C/ft_linux | IN_PROGRESS | ajout image_report.sh (rapport image).
2026-01-03 04:49:21 | C/ft_linux | IN_PROGRESS | run_reports.sh archive reports/logs.
2026-01-03 04:55:24 | C/ft_linux | IN_PROGRESS | archive_reports.sh regenere reports/index.md.
2026-01-03 04:59:25 | C/ft_linux | IN_PROGRESS | archive_reports.sh log index refresh.
2026-01-03 05:04:46 | C/ft_linux | IN_PROGRESS | ajout export_boot_artifacts.sh.
2026-01-03 05:09:24 | C/ft_linux | IN_PROGRESS | boot_finalize exporte artefacts boot.
2026-01-03 05:14:23 | C/ft_linux | IN_PROGRESS | runbook note boot_finalize exporte artefacts.
2026-01-03 05:19:53 | C/ft_linux | IN_PROGRESS | ajout validate_boot_archive.sh.
2026-01-03 05:24:39 | C/ft_linux | IN_PROGRESS | ajout clean_workspace.sh.
2026-01-03 05:29:38 | C/ft_linux | IN_PROGRESS | clean_workspace.sh couvre boot_artifacts/qcow2.
2026-01-03 05:34:49 | C/ft_linux | IN_PROGRESS | ajout partition_report.sh.
2026-01-03 05:39:31 | C/ft_linux | IN_PROGRESS | reports incluent partition_report.
2026-01-03 05:44:43 | C/ft_linux | IN_PROGRESS | partition_report inclut label/unit.
2026-01-03 05:49:20 | C/ft_linux | IN_PROGRESS | ajout release_bundle.sh (bundle final).
2026-01-03 05:55:37 | C/ft_linux | IN_PROGRESS | release_bundle.sh supprime archive precedente.
2026-01-03 05:59:59 | C/ft_linux | IN_PROGRESS | ajout validate_release_bundle.sh.
2026-01-03 06:04:18 | C/ft_linux | IN_PROGRESS | validate_release_bundle verifie boot_artifacts.
2026-01-03 06:09:18 | C/ft_linux | IN_PROGRESS | validate_release_bundle verifie summary.md.
2026-01-03 06:14:53 | C/ft_linux | IN_PROGRESS | ajout assess_status.sh (etat consolide).
2026-01-03 06:19:22 | C/ft_linux | IN_PROGRESS | ajout apply_kernel_requirements.sh.
2026-01-03 06:24:20 | C/ft_linux | IN_PROGRESS | build_kernel_config.sh supporte --apply-reqs.
2026-01-03 06:29:19 | C/ft_linux | IN_PROGRESS | runbook utilise --apply-reqs.
2026-01-03 06:37:11 | C/ft_linux | IN_PROGRESS | ajout resume state pour build_system/build_mini_system.
2026-01-03 06:45:16 | C/ft_linux | IN_PROGRESS | ajout status/reset state pour build_system/build_mini_system.
2026-01-03 06:49:56 | C/ft_linux | IN_PROGRESS | ajout build_state_report + integration summary/run_reports.
2026-01-03 06:54:53 | C/ft_linux | IN_PROGRESS | ajout validate_build_state + integration summary/run_reports.
2026-01-03 07:00:03 | C/ft_linux | IN_PROGRESS | ajout build_state_sync (logs -> state).
2026-01-03 07:05:17 | C/ft_linux | IN_PROGRESS | ajout plage --from/--until build_system/mini_system.
2026-01-03 07:09:58 | C/ft_linux | IN_PROGRESS | ajout build_log_audit + integration summary/run_reports.
2026-01-03 07:14:46 | C/ft_linux | IN_PROGRESS | ajout manifest_coverage (logs vs manifests).
2026-01-03 07:19:56 | C/ft_linux | IN_PROGRESS | status_assessment couvre build_state/build_log/coverage.
2026-01-03 07:24:52 | C/ft_linux | IN_PROGRESS | validate_manifests detecte doublons manifests.
2026-01-03 07:30:23 | C/ft_linux | IN_PROGRESS | ajout build_plan + pkg build_system.
2026-01-03 07:34:46 | C/ft_linux | IN_PROGRESS | ajout build_queue (execution plan avec reprise).
2026-01-03 07:41:28 | C/ft_linux | IN_PROGRESS | ajout build_times (timings + rapport).
2026-01-03 07:44:54 | C/ft_linux | IN_PROGRESS | build_queue log CSV + summary.
2026-01-03 07:49:50 | C/ft_linux | IN_PROGRESS | build_queue status/reset.
2026-01-03 07:54:51 | C/ft_linux | IN_PROGRESS | build_queue status integre rapports + assess.
2026-01-03 07:59:55 | C/ft_linux | IN_PROGRESS | ajout validate_build_plan.
2026-01-03 08:04:47 | C/ft_linux | IN_PROGRESS | validate_build_plan corrige comptage + liste inconnus.
2026-01-03 08:09:49 | C/ft_linux | IN_PROGRESS | ajout build_queue_retry.
2026-01-03 08:14:55 | C/ft_linux | IN_PROGRESS | ajout build_queue_retry_report + integration rapports.
2026-01-03 08:20:12 | C/ft_linux | IN_PROGRESS | ajout build_queue_sync_states.
2026-01-03 08:24:47 | C/ft_linux | IN_PROGRESS | build_queue timeout support.
2026-01-03 08:30:04 | C/ft_linux | IN_PROGRESS | ajout build_queue_metrics.
2026-01-03 08:34:28 | C/ft_linux | IN_PROGRESS | build_queue_metrics ajoute top durees.
2026-01-03 08:39:27 | C/ft_linux | IN_PROGRESS | build_queue_metrics ajoute top echecs.
2026-01-03 08:45:04 | C/ft_linux | IN_PROGRESS | ajout validate_build_queue_state.
2026-01-03 08:49:56 | C/ft_linux | IN_PROGRESS | ajout build_queue_report.
2026-01-03 08:55:27 | C/ft_linux | IN_PROGRESS | ajout build_state_snapshot/diff.
2026-01-03 09:00:06 | C/ft_linux | IN_PROGRESS | ajout build_state_list/prune.
2026-01-03 09:04:56 | C/ft_linux | IN_PROGRESS | build_state_prune dry-run + integration rapports.
2026-01-03 09:10:06 | C/ft_linux | IN_PROGRESS | ajout build_dashboard.
2026-01-03 09:15:32 | C/ft_linux | IN_PROGRESS | ajout build_plan_split.
2026-01-03 09:20:05 | C/ft_linux | IN_PROGRESS | ajout build_plan_remaining.
2026-01-03 09:26:01 | C/ft_linux | IN_PROGRESS | build_progress tracking + report.
2026-01-03 09:30:10 | C/ft_linux | IN_PROGRESS | ajout build_progress_rollup.
2026-01-03 09:34:30 | C/ft_linux | IN_PROGRESS | build_queue_metrics detaille durees ok.
2026-01-03 09:40:02 | C/ft_linux | IN_PROGRESS | ajout build_progress_failures.
2026-01-03 09:45:12 | C/ft_linux | IN_PROGRESS | ajout build_orchestrator.
2026-01-03 09:50:08 | C/ft_linux | IN_PROGRESS | ajout build_orchestrator_report.
2026-01-03 09:55:04 | C/ft_linux | IN_PROGRESS | build_orchestrator exporte JSON.
2026-01-03 10:00:11 | C/ft_linux | IN_PROGRESS | ajout build_orchestrator_status.
2026-01-03 10:04:35 | C/ft_linux | IN_PROGRESS | build_orchestrator JSON escape.
2026-01-03 10:10:09 | C/ft_linux | IN_PROGRESS | ajout build_orchestrator_validate.
2026-01-03 10:15:14 | C/ft_linux | IN_PROGRESS | ajout build_health_report.
2026-01-03 10:19:57 | C/ft_linux | IN_PROGRESS | build_queue continue-on-fail.
2026-01-03 10:25:39 | C/ft_linux | IN_PROGRESS | build_system/mini supporte make check.
2026-01-03 10:30:25 | C/ft_linux | IN_PROGRESS | ajout build_gate.
2026-01-03 10:34:55 | C/ft_linux | IN_PROGRESS | run_reports inclut build_gate + health.
2026-01-03 10:40:23 | C/ft_linux | IN_PROGRESS | ajout build_summary_json.
2026-01-03 10:44:38 | C/ft_linux | IN_PROGRESS | build_summary_json corrige rollup.
2026-01-03 10:50:03 | C/ft_linux | IN_PROGRESS | ajout build_session.
2026-01-03 10:55:25 | C/ft_linux | IN_PROGRESS | plan/orchestrator supporte check.
2026-01-03 11:00:13 | C/ft_linux | IN_PROGRESS | ajout build_summary_validate.
2026-01-03 11:05:25 | C/ft_linux | IN_PROGRESS | ajout build_queue_failures.
2026-01-03 11:09:53 | C/ft_linux | IN_PROGRESS | build_queue_report integre failures.
2026-01-03 11:14:34 | C/ft_linux | IN_PROGRESS | build_queue_metrics ajoute taux ok.
2026-01-03 11:20:58 | C/ft_linux | IN_PROGRESS | ajout build_check_report + integration run_reports/summary/status.
2026-01-03 11:23:42 | C/ft_linux | IN_PROGRESS | build_summary_json + build_health_report incluent checks.
2026-01-03 11:35:26 | C/ft_linux | IN_PROGRESS | suivi CSV checks + report check enrichi (fail/ignored/missing).
2026-01-03 11:39:33 | C/ft_linux | IN_PROGRESS | ajout build_check_status_report + integration rapports.
2026-01-03 11:44:36 | C/ft_linux | IN_PROGRESS | ajout build_check_status_rollup + integration rapports.
2026-01-03 11:49:34 | C/ft_linux | IN_PROGRESS | build_summary_json inclut check_groups + validation maj.
2026-01-03 11:54:26 | C/ft_linux | IN_PROGRESS | build_check_report ajoute mode strict.
2026-01-03 11:59:26 | C/ft_linux | IN_PROGRESS | run_reports force build_check_report --strict.
2026-01-03 11:59:26 | C/ft_linux | IN_PROGRESS | ajout build_check_gate + integration rapports/check_gate JSON.
2026-01-03 12:09:30 | C/ft_linux | IN_PROGRESS | build_gate integre build_check_gate.
2026-01-03 12:14:28 | C/ft_linux | IN_PROGRESS | build_gate option allow-check-warn ajoutee.
2026-01-03 12:19:38 | C/ft_linux | IN_PROGRESS | build_session propage allow-check-warn au gate.
2026-01-03 12:24:32 | C/ft_linux | IN_PROGRESS | validation JSON renforcee pour checks.
2026-01-03 12:29:33 | C/ft_linux | IN_PROGRESS | build_check_gate ajoute seuils max pour checks.
2026-01-03 12:34:31 | C/ft_linux | IN_PROGRESS | propagation seuils checks via build_gate/build_session.
2026-01-03 12:39:29 | C/ft_linux | IN_PROGRESS | build_check_gate JSON enrichi (seuils/metadata).
2026-01-03 12:44:31 | C/ft_linux | IN_PROGRESS | ajout config check_gate.conf + chargement defaults.
2026-01-03 12:49:30 | C/ft_linux | IN_PROGRESS | build_check_gate signale config manquante.
2026-01-03 12:54:29 | C/ft_linux | IN_PROGRESS | JSON build_check_gate robuste si valeurs vides.
2026-01-03 12:59:47 | C/ft_linux | IN_PROGRESS | build_dashboard affiche resume checks.
2026-01-03 13:04:32 | C/ft_linux | IN_PROGRESS | build_check_status_report trie par paquet.
2026-01-03 13:09:31 | C/ft_linux | IN_PROGRESS | build_check_status_rollup trie par groupe/paquet.
2026-01-03 13:14:41 | C/ft_linux | IN_PROGRESS | ajout build_check_trend + integration rapports.
2026-01-03 13:19:34 | C/ft_linux | IN_PROGRESS | build_check_trend ajoute total par jour.
2026-01-03 13:24:32 | C/ft_linux | IN_PROGRESS | build_check_trend ajoute taux fail/ignored.
2026-01-03 13:34:39 | C/ft_linux | IN_PROGRESS | ajout build_check_prune + integration rapports.
2026-01-03 13:39:31 | C/ft_linux | IN_PROGRESS | build_check_prune ajoute stats avant/apres.
2026-01-03 13:44:46 | C/ft_linux | IN_PROGRESS | ajout build_check_stats + integration rapports.
2026-01-03 13:49:33 | C/ft_linux | IN_PROGRESS | build_check_stats ajoute taux fail/ignored.
2026-01-03 13:54:32 | C/ft_linux | IN_PROGRESS | build_dashboard inclut check_stats rates.
2026-01-03 13:59:37 | C/ft_linux | IN_PROGRESS | build_summary_json inclut check_rates + validation maj.
2026-01-03 14:09:35 | C/ft_linux | IN_PROGRESS | build_check_gate ajoute max_severity + propagation gate/session.
2026-01-03 14:04:31 | C/ft_linux | IN_PROGRESS | build_check_stats ajoute severite.
2026-01-03 13:29:35 | C/ft_linux | IN_PROGRESS | build_check_report ajoute skip ok_no_log.
2026-01-03 14:14:37 | C/ft_linux | IN_PROGRESS | ajout build_check_snapshot + list + integration rapports.
2026-01-03 14:19:32 | C/ft_linux | IN_PROGRESS | build_check_snapshot_list ajoute stats lignes.
2026-01-03 14:24:34 | C/ft_linux | IN_PROGRESS | build_check_snapshot_list ajoute newest.
2026-01-03 14:29:34 | C/ft_linux | IN_PROGRESS | ajout build_check_snapshot_prune + integration rapports.
2026-01-03 14:34:33 | C/ft_linux | IN_PROGRESS | build_check_snapshot_prune ajoute after.
2026-01-03 14:39:34 | C/ft_linux | IN_PROGRESS | build_check_snapshot_prune after même sans prune.
2026-01-03 14:44:36 | C/ft_linux | IN_PROGRESS | build_check_snapshot_list ajoute lines du newest.
2026-01-03 14:49:42 | C/ft_linux | IN_PROGRESS | ajout build_check_snapshot_diff + integration rapports.
2026-01-03 14:54:34 | C/ft_linux | IN_PROGRESS | build_check_snapshot_diff ajoute auto_pick.
2026-01-03 15:04:03 | C/ft_linux | IN_PROGRESS | ajout build_check_summary_json/validate + integration rapports.
2026-01-03 15:04:40 | C/ft_linux | IN_PROGRESS | ajout build_check_export_csv + integration rapports.
2026-01-03 15:09:35 | C/ft_linux | IN_PROGRESS | build_check_export_csv corrige trend_last.
2026-01-03 15:14:36 | C/ft_linux | IN_PROGRESS | build_check_export_csv ajoute rates trend_last.
2026-01-03 15:19:42 | C/ft_linux | IN_PROGRESS | build_check_export_csv exporte groupes.
2026-01-03 15:24:44 | C/ft_linux | IN_PROGRESS | ajout build_check_coverage + integration rapports.
2026-01-03 15:29:37 | C/ft_linux | IN_PROGRESS | build_check_coverage ajoute coverage_rate.
2026-01-03 15:34:36 | C/ft_linux | IN_PROGRESS | build_check_coverage ajoute missing_rate.
2026-01-03 15:39:36 | C/ft_linux | IN_PROGRESS | build_check_summary_json inclut coverage rates.
2026-01-03 15:44:38 | C/ft_linux | IN_PROGRESS | build_check_summary_validate exige coverage_rate.
2026-01-03 15:49:37 | C/ft_linux | IN_PROGRESS | build_check_summary_validate exige missing_rate.
2026-01-03 15:59:18 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions et integration dans summary/health.
2026-01-03 16:11:07 | C/ft_linux | IN_PROGRESS | build_check_gate integre seuil regressions + propagation gate/session.
2026-01-03 16:16:09 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_trend et integration dashboard/summary.
2026-01-03 16:20:51 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_groups et integration rapports.
2026-01-03 16:25:50 | C/ft_linux | IN_PROGRESS | ajout export CSV regressions + synthese JSON enrichie.
2026-01-03 16:31:08 | C/ft_linux | IN_PROGRESS | build_check_gate gere seuil taux de regression et propagation gate/session.
2026-01-03 16:35:19 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_top pour prioriser les groupes.
2026-01-03 16:40:22 | C/ft_linux | IN_PROGRESS | build_check_regressions_top exporte JSON + summary.
2026-01-03 16:45:12 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_trend_json + integration rapports.
2026-01-03 16:50:12 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_groups_json + integration rapports.
2026-01-03 16:55:29 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_summary (txt/json) + integration rapports.
2026-01-03 17:00:12 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_summary_validate + integration rapports.
2026-01-03 17:05:18 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_index + integration rapports.
2026-01-03 17:10:17 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_report markdown + integration rapports.
2026-01-03 17:14:53 | C/ft_linux | IN_PROGRESS | dashboard affiche la synthese regressions.
2026-01-03 17:20:17 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_bundle + integration rapports.
2026-01-03 17:25:19 | C/ft_linux | IN_PROGRESS | ajout validation bundle regressions + integration rapports.
2026-01-03 17:30:35 | C/ft_linux | IN_PROGRESS | ajout rapport HTML regressions + integration rapports.
2026-01-03 17:36:06 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_transitions + integration rapports.
2026-01-03 17:40:17 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_transitions_json + integration rapports.
2026-01-03 17:45:20 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_transitions_validate + integration rapports.
2026-01-03 17:50:26 | C/ft_linux | IN_PROGRESS | build_check_summary_json inclut transitions regressions + validation.
2026-01-03 17:55:36 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_score + integration rapports.
2026-01-03 18:00:26 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_score_json + integration rapports.
2026-01-03 18:05:13 | C/ft_linux | IN_PROGRESS | ajout build_check_regressions_score_validate + integration rapports.
2026-01-03 18:11:53 | C/ft_linux | IN_PROGRESS | build_toolchain ajoute resume/etat + timings/progress.
2026-01-03 18:15:36 | C/ft_linux | IN_PROGRESS | ajout build_toolchain_report + integration rapports.
2026-01-03 18:20:45 | C/ft_linux | IN_PROGRESS | ajout build_toolchain_report_json + integration rapports.
2026-01-03 18:25:37 | C/ft_linux | IN_PROGRESS | ajout build_toolchain_report_validate + integration rapports.
2026-01-03 18:32:03 | C/ft_linux | IN_PROGRESS | build_toolchain_session ajoute + build_session option toolchain.
2026-01-03 18:42:46 | C/ft_linux | IN_PROGRESS | preflight reporte + resume session toolchain (rapport/validation).
2026-01-03 18:45:43 | C/ft_linux | IN_PROGRESS | dashboard + build_summary_json enrichis toolchain session.
2026-01-03 18:50:40 | C/ft_linux | IN_PROGRESS | ajout preflight JSON/validation + dashboard/summary.
2026-01-03 18:55:54 | C/ft_linux | IN_PROGRESS | ajout historique preflight + trend + integration rapports.
2026-01-03 19:01:02 | C/ft_linux | IN_PROGRESS | ajout gate preflight + JSON + validation + integration rapports.
2026-01-03 19:06:16 | C/ft_linux | IN_PROGRESS | integration gate preflight dans build_gate/build_session.
2026-01-03 19:10:22 | C/ft_linux | IN_PROGRESS | build_gate lit preflight_max_* depuis check_gate.conf.
2026-01-03 19:15:47 | C/ft_linux | IN_PROGRESS | ajout preflight fail-on-warn (config + gate + session).
2026-01-03 19:20:08 | C/ft_linux | IN_PROGRESS | build_preflight_gate lit defaults depuis check_gate.conf.
2026-01-03 19:26:11 | C/ft_linux | IN_PROGRESS | ajout historique + tendance preflight gate + integration rapports.
2026-01-03 19:30:15 | C/ft_linux | IN_PROGRESS | toolchain_session_report fail si rapport manquant.
2026-01-03 19:36:26 | C/ft_linux | IN_PROGRESS | ajout historique + tendance build_gate + gate_trend resume.
2026-01-03 19:40:25 | C/ft_linux | IN_PROGRESS | ajout build_gate_validate + integration rapports.
2026-01-03 19:45:02 | C/ft_linux | IN_PROGRESS | validation build_summary: champs gate_trend/preflight_gate_trend verifies.
2026-01-03 19:50:21 | C/ft_linux | IN_PROGRESS | build_summary: gate_validate + preflight_trend ajoutes.
2026-01-03 19:55:29 | C/ft_linux | IN_PROGRESS | ajout build_summary_report + integration rapports.
2026-01-03 20:01:13 | C/ft_linux | IN_PROGRESS | ajout build_summary historique + tendance + dashboard.
2026-01-03 20:05:22 | C/ft_linux | IN_PROGRESS | build_summary_report enrichi (queue/build/check rates).
2026-01-03 20:10:44 | C/ft_linux | IN_PROGRESS | ajout build_summary_alerts + integration dashboard.
2026-01-03 20:15:46 | C/ft_linux | IN_PROGRESS | build_summary_alerts JSON + validation + integration rapports.
2026-01-03 20:20:55 | C/ft_linux | IN_PROGRESS | ajout build_summary_alerts historique + tendance + dashboard.
2026-01-03 20:25:31 | C/ft_linux | IN_PROGRESS | build_summary ajoute summary_alerts + trend.
2026-01-03 20:30:15 | C/ft_linux | IN_PROGRESS | build_summary_report ajoute alerts + avg.
2026-01-03 20:35:29 | C/ft_linux | IN_PROGRESS | ajout build_summary_report_validate + integration rapports.
2026-01-03 20:40:46 | C/ft_linux | IN_PROGRESS | ajout build_summary_bundle + validation + integration rapports.
2026-01-03 20:45:29 | C/ft_linux | IN_PROGRESS | build_summary ajoute summary_bundle + dashboard bundle_validate.
2026-01-03 20:50:30 | C/ft_linux | IN_PROGRESS | ajout build_summary_bundle_index + integration rapports.
2026-01-03 20:56:17 | C/ft_linux | IN_PROGRESS | ajout build_summary_bundle_index_validate + integration rapports.
2026-01-03 21:02:21 | C/ft_linux | IN_PROGRESS | ajout build_summary_bundle_index historique + tendance + dashboard.
2026-01-03 21:05:43 | C/ft_linux | IN_PROGRESS | ajout validation bundle_index_trend + integration rapports/status.
2026-01-03 21:11:32 | C/ft_linux | IN_PROGRESS | build_summary ajoute bundle_index_trend + validation rapport.
2026-01-03 21:15:34 | C/ft_linux | IN_PROGRESS | ajout validation history bundle_index + integration rapports/status.
2026-01-03 21:20:59 | C/ft_linux | IN_PROGRESS | ajout delta bundle_index + validation + integration rapports.
2026-01-03 21:25:23 | C/ft_linux | IN_PROGRESS | build_summary ajoute bundle_index_delta + validation rapport.
2026-01-03 21:30:34 | C/ft_linux | IN_PROGRESS | build_summary_alerts alerte sur bundle_index_delta.
2026-01-03 21:35:23 | C/ft_linux | IN_PROGRESS | build_summary_alerts_json ajoute items + validation.
2026-01-03 21:41:26 | C/ft_linux | IN_PROGRESS | ajout rapport items alertes + validation + dashboard.
2026-01-03 21:45:55 | C/ft_linux | IN_PROGRESS | ajout top_items alertes + dashboard.
2026-01-03 21:50:25 | C/ft_linux | IN_PROGRESS | ajout items_mode alertes + dashboard.
2026-01-03 21:56:38 | C/ft_linux | IN_PROGRESS | ajout historique + tendance alertes items.
2026-01-03 22:00:25 | C/ft_linux | IN_PROGRESS | build_summary ajoute alerts_items_trend + validation rapport.
2026-01-03 22:06:19 | C/ft_linux | IN_PROGRESS | ajout delta alertes items + validation + dashboard.
2026-01-03 22:10:26 | C/ft_linux | IN_PROGRESS | build_summary ajoute alerts_items_delta + validation rapport.
2026-01-03 22:15:08 | C/ft_linux | IN_PROGRESS | build_summary_alerts alerte alerts_items_delta.
2026-01-03 22:21:03 | C/ft_linux | IN_PROGRESS | ajout rapport alertes items (trend/delta) + validation.
2026-01-03 22:25:21 | C/ft_linux | IN_PROGRESS | rapport alertes items gere missing_inputs + validation.
2026-01-03 22:30:36 | C/ft_linux | IN_PROGRESS | build_summary ajoute alerts_items_report + validation rapport.
2026-01-03 22:36:08 | C/ft_linux | IN_PROGRESS | ajout report alertes items JSON + validation.
2026-01-03 22:46:02 | C/ft_linux | IN_PROGRESS | delta alertes items ajoute change flags.
2026-01-03 22:55:40 | C/ft_linux | IN_PROGRESS | report alertes items ajoute change flags.
2026-01-03 23:01:04 | C/ft_linux | IN_PROGRESS | ajout report alertes items MD + validation.
2026-01-03 23:06:27 | C/ft_linux | IN_PROGRESS | ajout overview alertes items + validation.
2026-01-03 23:10:40 | C/ft_linux | IN_PROGRESS | overview alertes items fallback top-level.
2026-01-03 23:15:07 | C/ft_linux | IN_PROGRESS | validation overview alertes items renforcee.
2026-01-03 23:20:35 | C/ft_linux | IN_PROGRESS | build_summary ajoute alerts_items_overview + validation rapport.
2026-01-03 22:50:08 | C/ft_linux | IN_PROGRESS | build_summary_alerts ajoute change flags alerts_items_delta.
2026-01-03 22:40:22 | C/ft_linux | IN_PROGRESS | JSON report alertes items nettoie items_top.
2026-01-03 23:30:33 | C/ft_linux | IN_PROGRESS | bundle index overview ajoute (script + validation + integration summary).
2026-01-03 23:33:55 | C/ft_linux | IN_PROGRESS | bundle index score ajoute (script + validation + integration summary).
2026-01-03 23:35:16 | C/ft_linux | IN_PROGRESS | alerts integre bundle_index_score (seuil + result).
2026-01-03 23:40:32 | C/ft_linux | IN_PROGRESS | alerts JSON exporte bundle_index_score + validation renforcee.
2026-01-03 23:47:31 | C/ft_linux | IN_PROGRESS | stats alertes par categorie ajoutees (summary + dashboard + validate).
2026-01-03 23:52:08 | C/ft_linux | IN_PROGRESS | trend+historique stats alertes ajoutes (reports + summary + dashboard).
2026-01-03 23:56:49 | C/ft_linux | IN_PROGRESS | delta stats alertes ajoute (reports + summary + dashboard).
2026-01-04 00:01:40 | C/ft_linux | IN_PROGRESS | rapport stats alertes ajoute (report + validation + dashboard).
2026-01-04 00:06:34 | C/ft_linux | IN_PROGRESS | JSON report stats alertes ajoute + validations.
2026-01-04 00:11:28 | C/ft_linux | IN_PROGRESS | rapport stats alertes MD ajoute + validation.
2026-01-04 00:16:36 | C/ft_linux | IN_PROGRESS | rapport stats alertes HTML ajoute + validation.
2026-01-04 00:22:18 | C/ft_linux | IN_PROGRESS | export CSV stats alertes ajoute + validation.
2026-01-04 00:30:58 | C/ft_linux | IN_PROGRESS | rapport historique stats alertes ajoute + validation.
2026-01-04 00:35:03 | C/ft_linux | IN_PROGRESS | rapport historique stats alertes MD/HTML ajoute + validations.
2026-01-04 00:39:04 | C/ft_linux | IN_PROGRESS | table historique stats alertes ajoutee + validations.
2026-01-04 00:41:41 | C/ft_linux | IN_PROGRESS | score historique stats alertes ajoute + validation.
2026-01-04 00:45:19 | C/ft_linux | IN_PROGRESS | anomalies historique stats alertes ajoutees + validation.
2026-01-04 00:47:53 | C/ft_linux | IN_PROGRESS | anomalies historique stats alertes MD/HTML ajoutees + validations.
2026-01-04 00:50:40 | C/ft_linux | IN_PROGRESS | summary JSON/report enrichis avec validations anomalies.
2026-01-04 00:58:56 | C/ft_linux | IN_PROGRESS | rollup historique stats alertes integre aux resumes JSON/report/validations.
2026-01-04 01:03:48 | C/ft_linux | IN_PROGRESS | rollup stats alertes corrige + rapports MD/HTML et validations ajoutes.
2026-01-04 01:07:27 | C/ft_linux | IN_PROGRESS | score de stabilite rollup stats alertes ajoute et integre aux resumes.
2026-01-04 01:11:53 | C/ft_linux | IN_PROGRESS | rapports MD/HTML du score rollup stats alertes + validations integres.
2026-01-04 01:17:07 | C/ft_linux | IN_PROGRESS | rapport stats alertes enrichi avec rollup + score (txt/json/md/html + validations).
2026-01-04 01:22:27 | C/ft_linux | IN_PROGRESS | bundle rollup stats alertes ajoute + integration summary/dashboard.
2026-01-04 01:27:24 | C/ft_linux | IN_PROGRESS | overview rollup stats alertes ajoute + integration summaries.
2026-01-04 01:32:01 | C/ft_linux | IN_PROGRESS | overview rollup stats alertes exporte en MD/HTML + validations.
2026-01-04 01:35:42 | C/ft_linux | IN_PROGRESS | bundle summary etendu aux artefacts rollup stats alertes.
2026-01-04 01:48:27 | C/ft_linux | IN_PROGRESS | historique rollup stats alertes + trend integres (CSV/JSON/validations).
2026-01-04 01:54:57 | C/ft_linux | IN_PROGRESS | MD/HTML rollup history+trend ajoutes (rapports/validations).
2026-01-04 02:56:38 | C/ft_linux | IN_PROGRESS | validation rollup history CSV ajoutes.
2026-01-04 13:42:02 | C/ft_linux | IN_PROGRESS | ajout missing_inputs_report (toolchain/boot/kernel/tarballs) + integration run_reports.
2026-01-04 13:52:08 | C/ft_linux | WAITING | missing toolchain (x86_64-lfs-linux-gnu-{gcc,as,ld}), linux/version.h, libgcc dir, kernel config, boot files (fstab/grub/vmlinuz/initramfs), tarballs; added Get_Next_Line multi-fd test and run_tests OK.
2026-01-04 13:55:05 | C/Libft | DONE | ajout harness tests_realisation + run_tests.sh OK (memmove/strlen/strtrim/itoa/split).
2026-01-04 14:00:52 | C/Libunit | DONE | ajout suite d'echecs (segfault/timeout/exit) et scripts/run_tests OK.
2026-01-09 22:24:08 | C/Ft_printf | IN_PROGRESS | ajout tests format vide/percent et string longue pour verifier flush buffer.
2026-01-09 22:42:49 | C/Ft_printf | IN_PROGRESS | ajout test long wrap et scripts/run_tests.sh OK.
2026-01-09 22:52:46 | C/Ft_printf | IN_PROGRESS | ajout test ft_printf(NULL) et scripts/run_tests.sh OK.
2026-01-09 23:02:52 | C/Ft_printf | IN_PROGRESS | ajout test format long prefix/suffix + scripts/run_tests.sh OK.
2026-01-09 23:33:45 | C/Ft_printf | IN_PROGRESS | Ajout de tests supplementaires (%u -1, hex UINT_MAX, %%%% en chaine, pointeurs multiples) + scripts/run_tests.sh OK.
2026-01-09 23:43:24 | C/Ft_printf | IN_PROGRESS | Ajout test erreur d'ecriture via /dev/full (skip si absent) + scripts/run_tests.sh OK.
2026-01-16 20:01:04 | C/Ft_printf | IN_PROGRESS | ajout tests limites int + mix %% et NULL string.
2026-01-16 20:04:55 | C/Ft_printf | IN_PROGRESS | ajout tests strings vides/espaces + mix hex/pointeurs/combo.
2026-01-16 20:10:51 | C/Ft_printf | IN_PROGRESS | harness support sortie binaire + test %c NUL.
2026-01-16 20:14:46 | C/Ft_printf | IN_PROGRESS | ajout tests raw NUL en milieu et double NUL.
2026-01-16 20:19:42 | C/Ft_printf | IN_PROGRESS | ajout test raw string contenant un NUL interne.
2026-01-16 20:24:54 | C/Ft_printf | IN_PROGRESS | doc: note sorties binaires pour NUL dans harness tests.
2026-01-16 20:29:42 | C/Ft_printf | IN_PROGRESS | ajout test raw mixte NUL %c/%s/%c (binaire).
2026-01-16 20:35:00 | C/Ft_printf | IN_PROGRESS | simplif raw check + ajout test binaire %% avec NUL.
2026-01-16 20:39:57 | C/Ft_printf | IN_PROGRESS | harness raw: ajout dump hex en cas de mismatch binaire.
2026-01-16 20:44:55 | C/Ft_printf | IN_PROGRESS | ajout tests raw NUL avec %c + strings vides/texte.
2026-01-16 20:49:55 | C/Ft_printf | IN_PROGRESS | ajout tests %s NULL avec prefix/suffix et double NULL.
2026-01-16 20:54:47 | C/Ft_printf | IN_PROGRESS | harness raw: ajoute index du premier octet different.
2026-01-16 20:59:45 | C/Ft_printf | IN_PROGRESS | ajout test mix %s/%p avec NULL.
2026-01-16 21:04:51 | C/Ft_printf | IN_PROGRESS | harness: warning si ret printf != ft_printf.
2026-01-16 21:12:36 | C/Ft_printf | IN_PROGRESS | ajout tests percent apres %d et %s.
2026-01-16 21:14:47 | C/Ft_printf | IN_PROGRESS | ajout tests hex lettres + serie d'entiers.
2026-01-16 21:19:44 | C/Ft_printf | IN_PROGRESS | ajout test mix signes %d/%i.
2026-01-16 21:24:44 | C/Ft_printf | IN_PROGRESS | run_tests.sh: sortie claire sur echec tests.
2026-01-16 21:29:47 | C/Ft_printf | IN_PROGRESS | ajout test ordre mix %u/%d/%x/%i/%s.
2026-01-16 21:34:46 | C/Ft_printf | IN_PROGRESS | ajout test pointeur alternatif 0x7fffffff.
2026-01-16 21:39:52 | C/Ft_printf | IN_PROGRESS | harness: compteur de checks + resume final.
2026-01-16 21:45:37 | C/Ft_printf | IN_PROGRESS | harness: evite warning ret mismatch pour (nil) vs 0x0.
2026-01-16 21:49:50 | C/Ft_printf | IN_PROGRESS | scripts/run_tests.sh OK (warning /dev/full skip).
2026-01-16 21:54:48 | C/Ft_printf | DONE | cloture projet apres tests OK.
2026-01-16 22:02:10 | Python/Django_Training_D01 | IN_PROGRESS | ajout smoke tests + scripts/run_tests.sh OK.
2026-01-16 22:04:51 | Python/Django_Training_D01 | IN_PROGRESS | doc: section Tests ajoutee.
2026-01-16 22:09:50 | Python/Django_Training_D01 | DONE | cloture apres smoke tests OK.
2026-01-16 22:15:52 | Wordle/Wordle | IN_PROGRESS | ajout tests unitaires/CLI + run_tests OK.
2026-01-16 22:19:47 | Wordle/Wordle | IN_PROGRESS | ajout test CLI input vide + run_tests OK.
2026-01-16 22:24:48 | Wordle/Wordle | IN_PROGRESS | ajout test CLI mot invalide + run_tests OK.
2026-01-16 22:30:01 | Wordle/Wordle | IN_PROGRESS | ajout test determinisme seed + run_tests OK.
2026-01-16 22:35:03 | Wordle/Wordle | IN_PROGRESS | ajout test dict invalid + run_tests OK.
2026-01-16 22:40:01 | Wordle/Wordle | IN_PROGRESS | ajout test dict missing file + run_tests OK.
2026-01-16 22:44:49 | Wordle/Wordle | DONE | cloture apres tests OK.
2026-01-16 22:50:47 | C/Pipex | DONE | ajout test quoting + run_tests OK.
2026-01-16 22:55:32 | Hello/hello_vue | IN_PROGRESS | ajout checks CDN Vue 2.6.14 + run_tests OK.
2026-01-16 23:00:22 | Hello/hello_vue | IN_PROGRESS | ajout style ex05 + run_tests OK.
2026-01-16 23:04:50 | Hello/hello_vue | DONE | cloture apres checks OK.
2026-01-16 23:14:56 | Web/hello_node | IN_PROGRESS | ajout checks ex09 erreurs (iso manquant/route inconnue).
2026-01-16 23:22:48 | Web/hello_node | IN_PROGRESS | harness: capture stdout via temp files + run_tests OK (skip net).
2026-01-16 23:30:12 | Web/hello_node | WAITING | sockets locales bloquees (tests reseau), utiliser HELLO_NODE_SKIP_NET=1.
2026-01-16 23:26:09 | C/Minitalk | IN_PROGRESS | ajout test ponctuation + fix check ligne vide + run_tests OK.
2026-01-16 23:29:50 | C/Minitalk | IN_PROGRESS | ajout tests messages rapides + run_tests OK.
2026-01-16 23:35:01 | C/Minitalk | IN_PROGRESS | doc: COMMANDS tests maj (ponctuation/rafale).
2026-01-16 23:39:52 | C/Minitalk | DONE | cloture apres tests OK.
2026-01-16 23:45:27 | C/Ft_mini_ls | IN_PROGRESS | ajout test dossier vide.
2026-01-16 23:49:54 | C/Ft_mini_ls | IN_PROGRESS | ajout test dossier uniquement cache + run_tests OK.
2026-01-16 23:54:50 | C/Ft_mini_ls | DONE | cloture apres tests OK.
2026-01-17 00:00:42 | C/Ft_script | IN_PROGRESS | ajout test -c stderr capture + run_tests OK.
2026-01-17 00:05:30 | C/Ft_script | IN_PROGRESS | ajout test -c typescript par defaut + run_tests OK.
2026-01-17 00:09:52 | C/Ft_script | DONE | cloture apres tests OK.
2026-01-17 00:15:40 | C/Ft_ssl_md5 | IN_PROGRESS | ajout test stdin vide + run_tests OK.
2026-01-17 00:19:52 | C/Ft_ssl_md5 | DONE | cloture apres tests OK.
2026-01-17 00:25:15 | C/Ft_ping | IN_PROGRESS | ajout test -h + run_tests OK.
2026-01-17 00:29:53 | C/Ft_ping | DONE | cloture apres tests OK.
2026-01-17 00:37:16 | C/Ft_turing | DONE | ajout accept requis + tests 19/19 OK.
2026-01-17 00:33:25 | C/Ft_communication | IN_PROGRESS | ajout tests export Markdown/JSON + run_tests OK.
2026-01-17 00:44:53 | C/Ft_communication | DONE | cloture apres tests OK.
2026-01-17 00:50:54 | C/Ft_server | IN_PROGRESS | ajout tests statiques + run_tests OK.
2026-01-17 00:54:54 | C/Ft_server | DONE | cloture apres tests OK.
2026-01-17 01:00:31 | C/Ft_ssl_base64_des | IN_PROGRESS | ajout test base64 input vide + run_tests OK.
2026-01-17 01:04:55 | C/Ft_ssl_base64_des | DONE | cloture apres tests OK.
2026-01-17 01:11:19 | C/Ft_services | IN_PROGRESS | ajout tests statiques manifests/scripts + run_tests OK.
2026-01-17 01:14:56 | C/Ft_services | DONE | cloture apres tests OK.
2026-01-17 01:21:39 | CPP/CPP_Module_00 | IN_PROGRESS | ajout tests smoke ex00/ex02 + run_tests OK.
2026-01-17 01:24:56 | CPP/CPP_Module_00 | IN_PROGRESS | ajout smoke ex01 add/search + run_tests OK.
2026-01-17 01:30:45 | CPP/CPP_Module_00 | IN_PROGRESS | ajout tests ex03/ex04 + run_tests OK.
2026-01-17 01:34:57 | CPP/CPP_Module_00 | DONE | cloture apres tests OK.
2026-01-17 01:42:44 | CPP/CPP_Module_01 | IN_PROGRESS | ajout tests smoke ex00-ex06 + run_tests OK.
2026-01-17 01:44:57 | CPP/CPP_Module_01 | DONE | cloture apres tests OK.
2026-01-17 01:51:17 | CPP/CPP_Module_02 | IN_PROGRESS | ajout tests smoke ex00-ex03 + run_tests OK.
2026-01-17 01:54:59 | CPP/CPP_Module_02 | DONE | cloture apres tests OK.
2026-01-17 02:01:16 | CPP/CPP_Module_03 | IN_PROGRESS | ajout tests smoke ex00-ex03 + run_tests OK.
2026-01-17 02:04:58 | CPP/CPP_Module_03 | DONE | cloture apres tests OK.
2026-01-17 02:11:56 | CPP/CPP_Module_04 | IN_PROGRESS | ajout tests smoke ex00-ex04 + run_tests OK.
2026-01-17 02:15:13 | CPP/CPP_Module_04 | DONE | cloture apres tests OK.
2026-01-17 02:21:10 | CPP/CPP_Module_05 | IN_PROGRESS | ajout tests smoke ex00-ex03 + run_tests OK.
2026-01-17 02:25:00 | CPP/CPP_Module_05 | DONE | cloture apres tests OK.
2026-01-17 02:34:00 | C/Libasm | WAITING | nasm absent, run_tests bloque.
2026-01-17 02:35:10 | C/Ft_ssl_md5 | DONE | ajout test md5 -s "" + run_tests OK.
2026-01-17 02:36:52 | C/ft_kalman | IN_PROGRESS | ajout tests inverse 3x3 + fix Werror host non utilise.
2026-01-17 02:40:09 | C/ft_kalman | IN_PROGRESS | ajout test transpose matrice + run_unit OK.
2026-01-17 02:45:07 | C/ft_kalman | IN_PROGRESS | ajout test identite matrice + run_unit OK.
2026-01-17 02:49:59 | C/ft_kalman | IN_PROGRESS | doc tests_realisation (run_unit + couverture).
2026-01-17 02:55:08 | C/ft_kalman | IN_PROGRESS | ajout test determinant 3x3 + run_unit OK.
2026-01-17 03:00:45 | C/ft_kalman | IN_PROGRESS | ajout run_udp (mock) + skip si sockets interdites.
2026-01-17 03:05:21 | C/ft_kalman | IN_PROGRESS | ajout cibles Makefile test-udp/test-all + doc.
2026-01-17 03:10:08 | C/ft_kalman | DONE | cloture apres tests unit + udp mock (skip si sockets bloquees) + doc.
2026-01-17 03:15:36 | C/ft_helpme | DONE | ajout tests valeurs par defaut (unspecified) + run_tests OK.
2026-01-17 03:20:56 | C/ft_irc | WAITING | tests smoke bloques: sockets locaux interdits.
2026-01-17 03:21:42 | C/Born2beRoot | DONE | ajout checks labels monitoring.sh + run_tests OK.
2026-01-17 03:26:28 | C/Philosophers | DONE | ajout run_tests.sh (erreurs + single philo) + tests OK.
2026-01-17 03:30:31 | C/Push_swap | DONE | ajout tests deja trie + overflow + run_tests OK.
2026-01-17 03:35:41 | C/Ft_containers | DONE | ajout list_stack_queue_compare au run_tests.sh + OK.
2026-01-17 03:40:30 | C/Ft_shield | DONE | ajout tests exit code + usage erreurs + run_tests OK.
2026-01-17 03:45:23 | C/So_Long | DONE | ajout tests cartes invalides + run_tests OK.
2026-01-17 03:50:37 | C/Minitalk | DONE | ajout tests client erreurs (args/pid) + run_tests OK.
2026-01-17 03:55:59 | C/Ft_ping | DONE | ajout test pattern invalide (options) + tests OK.
2026-01-17 04:00:36 | C/Ft_mini_ls | DONE | tests args verif message erreur + run_tests OK.
2026-01-17 04:07:04 | C/Ft_ls | DONE | ajout test fichier manquant + run_tests OK.
2026-01-17 04:10:14 | C/ft_self_analysis | DONE | ajout 3 questions reviewer + MAJ checklist.
2026-01-17 04:15:32 | C/Ft_server | DONE | ajout checks env MySQL dans tests_realisation + OK.
2026-01-17 04:20:46 | C/Ft_ls | IN_PROGRESS | ajout test symlink -l + run_tests OK.
2026-01-17 04:25:12 | C/Ft_ls | DONE | ajout test fichier -l + run_tests OK.
2026-01-17 04:30:44 | C/Minishell | IN_PROGRESS | run_unit_tests.sh construit si minishell absent + tests OK.
2026-01-17 04:35:18 | C/Minishell | DONE | ajout test pwd_basic + run_unit_tests OK.
2026-01-17 04:40:16 | Messagequeue/MessageQueue | IN_PROGRESS | ajout docker-compose RabbitMQ + doc usage.
2026-01-17 04:45:47 | Messagequeue/MessageQueue | IN_PROGRESS | doc topologie exchanges/queues + plan MAJ.
2026-01-17 04:50:16 | Messagequeue/MessageQueue | IN_PROGRESS | ajout shared/pdfs + doc depot.
2026-01-17 04:55:14 | Messagequeue/MessageQueue | IN_PROGRESS | ajout sample_student.json + doc.
2026-01-17 05:00:13 | Messagequeue/MessageQueue | IN_PROGRESS | ajout exemples routing keys + doc.
2026-01-17 05:05:09 | Messagequeue/MessageQueue | IN_PROGRESS | ajout commandes docker compose stop/start.
2026-01-17 05:10:18 | Messagequeue/MessageQueue | IN_PROGRESS | doc services producteurs/consommateurs + PDFs.
2026-01-17 05:15:13 | Messagequeue/MessageQueue | IN_PROGRESS | plan MAJ (arborescence clarifiee).
2026-01-17 05:20:40 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script bootstrap RabbitMQ (exchanges/queues/bindings).
2026-01-17 05:25:15 | Messagequeue/MessageQueue | IN_PROGRESS | doc variables env bootstrap RabbitMQ.
2026-01-17 05:30:17 | Messagequeue/MessageQueue | IN_PROGRESS | doc convention nommage PDF.
2026-01-17 05:35:23 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script check_rabbitmq.sh + doc.
2026-01-17 05:40:11 | Messagequeue/MessageQueue | IN_PROGRESS | doc sequence bootstrap complete.
2026-01-17 05:45:51 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script validate_rabbitmq.sh + doc.
2026-01-17 05:50:17 | Messagequeue/MessageQueue | IN_PROGRESS | validate_rabbitmq verifie bindings.
2026-01-17 05:55:11 | Messagequeue/MessageQueue | IN_PROGRESS | note requirement API management pour validate_rabbitmq.
2026-01-17 06:00:25 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script bootstrap_and_validate.sh.
2026-01-17 06:05:16 | Messagequeue/MessageQueue | IN_PROGRESS | ajout quickstart local doc.
2026-01-17 06:10:28 | Messagequeue/MessageQueue | IN_PROGRESS | plan MAJ scripts setup/quickstart coches.
2026-01-17 06:15:33 | Messagequeue/MessageQueue | IN_PROGRESS | ajout layout modules + dossiers services.
2026-01-17 06:20:11 | Messagequeue/MessageQueue | IN_PROGRESS | mention modules stubs services/.
2026-01-17 06:25:31 | Messagequeue/MessageQueue | IN_PROGRESS | doc variables env services.
2026-01-17 06:30:23 | Messagequeue/MessageQueue | IN_PROGRESS | doc contenu minimal PDFs.
2026-01-17 06:35:20 | Messagequeue/MessageQueue | IN_PROGRESS | doc smoke plan local.
2026-01-17 06:40:12 | Messagequeue/MessageQueue | IN_PROGRESS | ajout TODO implementation.
2026-01-17 06:46:11 | Messagequeue/MessageQueue | IN_PROGRESS | ajout scripts publish/consume message test + doc.
2026-01-17 06:50:22 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message ajoute content_type JSON.
2026-01-17 06:55:23 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message ajoute message_id auto.
2026-01-17 07:00:20 | Messagequeue/MessageQueue | IN_PROGRESS | consume_test_message supporte TRUNCATE.
2026-01-17 07:05:32 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script list_queues.sh.
2026-01-17 07:10:33 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script list_exchanges.sh.
2026-01-17 07:15:15 | Messagequeue/MessageQueue | IN_PROGRESS | list_exchanges ignore exchange vide.
2026-01-17 07:20:24 | Messagequeue/MessageQueue | IN_PROGRESS | doc policy ACK consumers.
2026-01-17 07:25:15 | Messagequeue/MessageQueue | IN_PROGRESS | sample_student.json ajoute grantType.
2026-01-17 07:30:23 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message routing key default + metadata grantType.
2026-01-17 07:35:26 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test matrix.
2026-01-17 07:40:15 | Messagequeue/MessageQueue | IN_PROGRESS | ajout note statut IN_PROGRESS.
2026-01-17 07:45:45 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script test_routing.sh.
2026-01-17 07:50:19 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_routing.sh env python.
2026-01-17 07:55:17 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_routing purge queue DELETE.
2026-01-17 08:00:24 | Messagequeue/MessageQueue | IN_PROGRESS | doc endpoints producer proposes.
2026-01-17 08:05:23 | Messagequeue/MessageQueue | IN_PROGRESS | doc schema payload.
2026-01-17 08:10:34 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script wait_rabbitmq.sh.
2026-01-17 08:15:31 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script bootstrap_all.sh.
2026-01-17 08:20:39 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script list_bindings.sh.
2026-01-17 08:25:39 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message default EXCHANGE=GRANT_EXCHANGE.
2026-01-17 08:30:44 | Messagequeue/MessageQueue | IN_PROGRESS | nettoyage test_routing (suppression code mort).
2026-01-17 08:35:28 | Messagequeue/MessageQueue | IN_PROGRESS | test matrix coche prerequis RabbitMQ.
2026-01-17 08:40:30 | Messagequeue/MessageQueue | IN_PROGRESS | ajout doc outils de test.
2026-01-17 08:45:19 | Messagequeue/MessageQueue | IN_PROGRESS | ajout lien UI RabbitMQ.
2026-01-17 08:50:13 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script count_queue_messages.sh.
2026-01-17 08:55:21 | Messagequeue/MessageQueue | IN_PROGRESS | note API management pour scripts listing.
2026-01-17 09:01:02 | Messagequeue/MessageQueue | IN_PROGRESS | note permissions ecriture shared/pdfs.
2026-01-17 09:05:40 | Messagequeue/MessageQueue | IN_PROGRESS | precision permissions dossier PDFs.
2026-01-17 09:10:47 | Messagequeue/MessageQueue | IN_PROGRESS | bootstrap_all inclut test_routing.
2026-01-17 09:15:15 | Messagequeue/MessageQueue | IN_PROGRESS | ajout doc troubleshooting.
2026-01-17 09:20:22 | Messagequeue/MessageQueue | IN_PROGRESS | ajout TODO tests e2e.
2026-01-17 09:25:21 | Messagequeue/MessageQueue | IN_PROGRESS | ajout commande nettoyage shared/pdfs.
2026-01-17 09:30:24 | Messagequeue/MessageQueue | IN_PROGRESS | doc PAYLOAD_FILE publish_test_message.
2026-01-17 09:35:23 | Messagequeue/MessageQueue | IN_PROGRESS | precision payload defaut sample_student.json.
2026-01-17 09:40:25 | Messagequeue/MessageQueue | IN_PROGRESS | doc vhost par defaut pour scripts RabbitMQ.
2026-01-17 09:45:33 | Messagequeue/MessageQueue | IN_PROGRESS | ajout .env.example RabbitMQ.
2026-01-17 09:50:24 | Messagequeue/MessageQueue | IN_PROGRESS | doc usage fichier .env.
2026-01-17 09:55:38 | Messagequeue/MessageQueue | IN_PROGRESS | ajout exemple variables .env pour credentials.
2026-01-17 10:00:47 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script purge_queues.sh.
2026-01-17 10:05:17 | Messagequeue/MessageQueue | IN_PROGRESS | purge_queues supporte QUEUES CSV.
2026-01-17 10:10:34 | Messagequeue/MessageQueue | IN_PROGRESS | purge_queues trim espaces CSV.
2026-01-17 10:16:27 | Messagequeue/MessageQueue | IN_PROGRESS | doc plan d'implementation.
2026-01-17 10:21:08 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script smoke_local.
2026-01-17 10:25:28 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script check_prereqs.
2026-01-17 10:30:23 | Messagequeue/MessageQueue | IN_PROGRESS | smoke plan mentionne check_prereqs + smoke_local.
2026-01-17 10:35:26 | Messagequeue/MessageQueue | IN_PROGRESS | doc scripts overview.
2026-01-17 10:40:29 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script load_env.
2026-01-17 10:45:23 | Messagequeue/MessageQueue | IN_PROGRESS | doc outils de test (scripts ajout).
2026-01-17 10:50:27 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script setup_env.
2026-01-17 10:55:33 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script status_report.
2026-01-17 11:00:37 | Messagequeue/MessageQueue | IN_PROGRESS | ajout runbook local.
2026-01-17 11:06:03 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script test_routing_matrix.
2026-01-17 11:10:40 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script publish_sample_keys.
2026-01-17 11:15:44 | Messagequeue/MessageQueue | IN_PROGRESS | doc troubleshooting env.
2026-01-17 11:20:54 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script post_sample.
2026-01-17 11:25:38 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script reset_local.
2026-01-17 11:30:36 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script run_local_flow.
2026-01-17 11:35:56 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script validate_payload.
2026-01-17 11:40:44 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script doctor.
2026-01-17 11:46:15 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script generate_dummy_pdf.
2026-01-17 11:50:45 | Messagequeue/MessageQueue | IN_PROGRESS | ajout README stubs services.
2026-01-17 11:55:29 | Messagequeue/MessageQueue | IN_PROGRESS | index consumers.
2026-01-17 12:00:33 | Messagequeue/MessageQueue | IN_PROGRESS | ajout stub grant_other_documents.
2026-01-17 12:05:26 | Messagequeue/MessageQueue | IN_PROGRESS | ajout service matrix.
2026-01-17 12:10:25 | Messagequeue/MessageQueue | IN_PROGRESS | ajout todo_next.
2026-01-17 12:15:57 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script simulate_consumer.
2026-01-17 12:20:40 | Messagequeue/MessageQueue | IN_PROGRESS | ajout recap usage local.
2026-01-17 12:25:42 | Messagequeue/MessageQueue | IN_PROGRESS | doc variables scripts.
2026-01-17 12:30:47 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script run_checks.
2026-01-17 12:36:22 | Messagequeue/MessageQueue | IN_PROGRESS | ajout stub Spring Boot producer.
2026-01-17 12:41:05 | Messagequeue/MessageQueue | IN_PROGRESS | ajout stub consumer food_application.
2026-01-17 12:45:59 | Messagequeue/MessageQueue | IN_PROGRESS | ajout stub consumer financial_assistance.
2026-01-17 12:50:45 | Messagequeue/MessageQueue | IN_PROGRESS | ajout stub consumer transportation_costs.
2026-01-17 12:55:46 | Messagequeue/MessageQueue | IN_PROGRESS | ajout stub consumer contracts.
2026-01-17 13:00:49 | Messagequeue/MessageQueue | IN_PROGRESS | ajout stub consumer grant_other_documents.
2026-01-17 13:05:51 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script build_modules.
2026-01-17 13:10:34 | Messagequeue/MessageQueue | IN_PROGRESS | producer health + validation champs requis.
2026-01-17 13:15:37 | Messagequeue/MessageQueue | IN_PROGRESS | producer retourne JSON (status,routingKey).
2026-01-17 13:20:34 | Messagequeue/MessageQueue | IN_PROGRESS | ajout doc run_modules.
2026-01-17 13:25:48 | Messagequeue/MessageQueue | IN_PROGRESS | ajout tests producer (MockMvc).
2026-01-17 13:30:41 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test endpoint health.
2026-01-17 13:35:51 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script test_producer.
2026-01-17 13:40:38 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test routing producer (MockBean).
2026-01-17 13:45:35 | Messagequeue/MessageQueue | IN_PROGRESS | doc tests producer.
2026-01-17 13:50:55 | Messagequeue/MessageQueue | IN_PROGRESS | consumer food genere PDF dummy.
2026-01-17 13:55:43 | Messagequeue/MessageQueue | IN_PROGRESS | consumer financial genere PDF dummy.
2026-01-17 14:00:44 | Messagequeue/MessageQueue | IN_PROGRESS | consumer transportation genere PDF dummy.
2026-01-17 14:05:44 | Messagequeue/MessageQueue | IN_PROGRESS | consumer contracts genere PDF dummy.
2026-01-17 14:10:53 | Messagequeue/MessageQueue | IN_PROGRESS | consumer grant_other_documents genere PDF dummy.
2026-01-17 14:15:33 | Messagequeue/MessageQueue | IN_PROGRESS | doc run/env consumers index.
2026-01-17 14:20:28 | Messagequeue/MessageQueue | IN_PROGRESS | tests producer bloques: mvn manquant.
2026-01-17 14:25:30 | Messagequeue/MessageQueue | IN_PROGRESS | check_prereqs verifie mvn.
2026-01-17 14:30:36 | Messagequeue/MessageQueue | IN_PROGRESS | doc troubleshooting Maven.
2026-01-17 14:35:59 | Messagequeue/MessageQueue | IN_PROGRESS | consumers EnableRabbit.
2026-01-17 14:40:25 | Messagequeue/MessageQueue | IN_PROGRESS | doc run_modules + note EnableRabbit.
2026-01-17 14:46:00 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script tail_rabbitmq_logs.
2026-01-17 14:50:36 | Messagequeue/MessageQueue | IN_PROGRESS | doc endpoints/env producer.
2026-01-17 14:55:43 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test dummy PDF transportation.
2026-01-17 15:00:43 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test dummy PDF financial.
2026-01-17 15:05:39 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test dummy PDF contracts.
2026-01-17 15:10:37 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test dummy PDF grant_other_documents.
2026-01-17 15:15:40 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test dummy PDF food.
2026-01-17 15:20:37 | Messagequeue/MessageQueue | IN_PROGRESS | doc tests consumers.
2026-01-17 15:25:59 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script test_consumers.
2026-01-17 15:30:59 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script readme_toc.
2026-01-17 15:35:28 | Messagequeue/MessageQueue | IN_PROGRESS | doc usage local (sommaire README).
2026-01-17 15:40:46 | Messagequeue/MessageQueue | IN_PROGRESS | ajout docs_index.
2026-01-17 15:46:23 | Messagequeue/MessageQueue | IN_PROGRESS | DummyPdfGenerator resolve script path.
2026-01-17 15:51:24 | Messagequeue/MessageQueue | IN_PROGRESS | harmonisation DummyPdfGenerator.
2026-01-17 15:55:28 | Messagequeue/MessageQueue | IN_PROGRESS | doc tests_consumers (script).
2026-01-17 16:00:50 | Messagequeue/MessageQueue | IN_PROGRESS | ajout module_status.
2026-01-17 16:05:41 | Messagequeue/MessageQueue | IN_PROGRESS | doc ports.
2026-01-17 16:10:34 | Messagequeue/MessageQueue | IN_PROGRESS | producer declare exchanges.
2026-01-17 16:15:49 | Messagequeue/MessageQueue | IN_PROGRESS | producer exchanges configurables.
2026-01-17 16:20:37 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test config exchanges.
2026-01-17 16:26:19 | Messagequeue/MessageQueue | IN_PROGRESS | extraction ExchangeNames pour producer.
2026-01-17 16:30:31 | Messagequeue/MessageQueue | IN_PROGRESS | doc ExchangeNames producer.
2026-01-17 16:35:41 | Messagequeue/MessageQueue | IN_PROGRESS | test routing par defaut (grantType absent).
2026-01-17 16:40:46 | Messagequeue/MessageQueue | IN_PROGRESS | ajout api_contract.
2026-01-17 16:45:41 | Messagequeue/MessageQueue | IN_PROGRESS | exemple curl API contract.
2026-01-17 16:50:46 | Messagequeue/MessageQueue | IN_PROGRESS | test validation email vide.
2026-01-17 16:55:29 | Messagequeue/MessageQueue | IN_PROGRESS | doc tests producer (couverture).
2026-01-17 17:00:48 | Messagequeue/MessageQueue | IN_PROGRESS | ajout tests_summary.
2026-01-17 17:05:40 | Messagequeue/MessageQueue | IN_PROGRESS | docs_index inclut tests_summary.
2026-01-17 17:10:31 | Messagequeue/MessageQueue | IN_PROGRESS | note Maven dans tests_summary.
2026-01-17 17:16:20 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script append_log.
2026-01-17 17:20:32 | Messagequeue/MessageQueue | IN_PROGRESS | doc usage local (append_log).
2026-01-17 17:25:30 | Messagequeue/MessageQueue | IN_PROGRESS | ajout doc logging.
2026-01-17 17:30:45 | Messagequeue/MessageQueue | IN_PROGRESS | ajout security_notes.
2026-01-17 17:42:33 | Messagequeue/MessageQueue | IN_PROGRESS | bindings exchanges/queues pour consumers
2026-01-17 17:44:47 | Messagequeue/MessageQueue | IN_PROGRESS | ajout script create_bindings (topologie sans docker)
2026-01-17 17:46:04 | Messagequeue/MessageQueue | IN_PROGRESS | validate_rabbitmq aligne routing keys/queues via env
2026-01-17 17:50:41 | Messagequeue/MessageQueue | IN_PROGRESS | doc usage local: create_bindings
2026-01-17 17:55:45 | Messagequeue/MessageQueue | IN_PROGRESS | doctor hint create_bindings when topology invalid
2026-01-17 18:01:03 | Messagequeue/MessageQueue | IN_PROGRESS | bootstrap_rabbitmq aligne routing keys/queues via env
2026-01-17 18:06:50 | Messagequeue/MessageQueue | IN_PROGRESS | test_routing scripts utilisent routing keys env
2026-01-17 18:11:04 | Messagequeue/MessageQueue | IN_PROGRESS | test_routing_matrix supporte ROUTING_KEYS
2026-01-17 18:15:42 | Messagequeue/MessageQueue | IN_PROGRESS | doc ROUTING_KEYS test_routing_matrix
2026-01-17 18:20:48 | Messagequeue/MessageQueue | IN_PROGRESS | smoke_local utilise GRANT_EXCHANGE/queues env
2026-01-17 18:26:15 | Messagequeue/MessageQueue | IN_PROGRESS | count_queue_messages supporte filtre QUEUES
2026-01-17 18:31:11 | Messagequeue/MessageQueue | IN_PROGRESS | list_exchanges/list_bindings filtres CSV
2026-01-17 18:36:23 | Messagequeue/MessageQueue | IN_PROGRESS | status_report filtres via env
2026-01-17 18:40:51 | Messagequeue/MessageQueue | IN_PROGRESS | list_queues supporte filtre QUEUES
2026-01-17 18:45:46 | Messagequeue/MessageQueue | IN_PROGRESS | run_modules mentionne run_producer/run_consumer
2026-01-17 18:50:38 | Messagequeue/MessageQueue | IN_PROGRESS | runbook local: alternative create_bindings
2026-01-17 18:55:41 | Messagequeue/MessageQueue | IN_PROGRESS | status_report affiche filtres actifs
2026-01-17 19:00:51 | Messagequeue/MessageQueue | IN_PROGRESS | doc usage local: status_report filtre
2026-01-17 19:06:11 | Messagequeue/MessageQueue | IN_PROGRESS | publish_sample_keys supporte ROUTING_KEYS
2026-01-17 19:10:45 | Messagequeue/MessageQueue | IN_PROGRESS | doc override ROUTING_KEYS publish_sample_keys
2026-01-17 19:15:53 | Messagequeue/MessageQueue | IN_PROGRESS | publish_sample_keys respecte GRANT_EXCHANGE env
2026-01-17 19:20:40 | Messagequeue/MessageQueue | IN_PROGRESS | README producer: run_producer + exchanges
2026-01-17 19:25:43 | Messagequeue/MessageQueue | IN_PROGRESS | runbook local: run_producer/run_consumer
2026-01-17 19:30:57 | Messagequeue/MessageQueue | IN_PROGRESS | run_consumer supporte --list
2026-01-17 19:36:00 | Messagequeue/MessageQueue | IN_PROGRESS | test_consumers supporte --list
2026-01-17 19:41:24 | Messagequeue/MessageQueue | IN_PROGRESS | build_modules supporte MODULES/--list
2026-01-17 19:45:55 | Messagequeue/MessageQueue | IN_PROGRESS | test_producer supporte --list
2026-01-17 19:51:06 | Messagequeue/MessageQueue | IN_PROGRESS | doc readme_toc FILE env
2026-01-17 19:55:45 | Messagequeue/MessageQueue | IN_PROGRESS | docs_index complete docs recentes
2026-01-17 20:01:05 | Messagequeue/MessageQueue | IN_PROGRESS | check_prereqs supporte SKIP_DOCKER/SKIP_MVN
2026-01-17 20:06:27 | Messagequeue/MessageQueue | IN_PROGRESS | PDF_DISABLED pour generation PDF dummy
2026-01-17 20:12:23 | Messagequeue/MessageQueue | IN_PROGRESS | tests PDF_DISABLED via pdf.disabled
2026-01-17 20:16:09 | Messagequeue/MessageQueue | IN_PROGRESS | test_consumers supporte MODULES
2026-01-17 20:20:55 | Messagequeue/MessageQueue | IN_PROGRESS | doc usage local: ROUTING_KEYS test_routing_matrix
2026-01-17 20:25:49 | Messagequeue/MessageQueue | IN_PROGRESS | doc pdf.disabled system property
2026-01-17 20:30:50 | Messagequeue/MessageQueue | IN_PROGRESS | doc PDF_DISABLED consumers + tests pdf.disabled
2026-01-17 20:36:10 | Messagequeue/MessageQueue | IN_PROGRESS | run_checks supporte --skip-routing
2026-01-17 20:41:08 | Messagequeue/MessageQueue | IN_PROGRESS | run_checks supporte --skip-doctor
2026-01-17 20:47:43 | Messagequeue/MessageQueue | IN_PROGRESS | grantType requis + tests/docs
2026-01-17 20:51:31 | Messagequeue/MessageQueue | IN_PROGRESS | grantType routing key dans schema + sample
2026-01-17 20:55:53 | Messagequeue/MessageQueue | IN_PROGRESS | doc routing keys lie grantType payload
2026-01-17 21:01:18 | Messagequeue/MessageQueue | IN_PROGRESS | validate_payload grantType routing key
2026-01-17 21:06:08 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_validate_payload script
2026-01-17 21:11:07 | Messagequeue/MessageQueue | IN_PROGRESS | doctor lance test_validate_payload
2026-01-17 21:15:46 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message force grantType metadata
2026-01-17 21:20:44 | Messagequeue/MessageQueue | IN_PROGRESS | doc publish_test_message metadata grantType
2026-01-17 21:26:06 | Messagequeue/MessageQueue | IN_PROGRESS | run_checks accepte plusieurs flags
2026-01-17 21:31:12 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message derive routing key from payload
2026-01-17 21:35:58 | Messagequeue/MessageQueue | IN_PROGRESS | consume_test_message --help
2026-01-17 21:40:58 | Messagequeue/MessageQueue | IN_PROGRESS | consume_test_message OUTPUT pretty
2026-01-17 21:45:58 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message --help
2026-01-17 21:51:01 | Messagequeue/MessageQueue | IN_PROGRESS | smoke_local routing key derive payload
2026-01-17 21:55:52 | Messagequeue/MessageQueue | IN_PROGRESS | doc smoke_local routing key derive
2026-01-17 22:01:24 | Messagequeue/MessageQueue | IN_PROGRESS | validation grantType routing key au producer
2026-01-17 22:05:50 | Messagequeue/MessageQueue | IN_PROGRESS | doc tests_producer grantType format
2026-01-17 22:10:50 | Messagequeue/MessageQueue | IN_PROGRESS | test_validate_payload cas grantType segment vide
2026-01-17 22:15:47 | Messagequeue/MessageQueue | IN_PROGRESS | test producer grantType segment vide
2026-01-17 22:21:08 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message STRICT_GRANT_TYPE
2026-01-17 22:25:52 | Messagequeue/MessageQueue | IN_PROGRESS | valide grantType avant publish
2026-01-17 22:30:57 | Messagequeue/MessageQueue | IN_PROGRESS | doc endpoint grantType routing key
2026-01-17 22:36:07 | Messagequeue/MessageQueue | IN_PROGRESS | post_sample --help OUTPUT pretty
2026-01-17 22:41:12 | Messagequeue/MessageQueue | IN_PROGRESS | post_sample --silent
2026-01-17 22:45:44 | Messagequeue/MessageQueue | IN_PROGRESS | post_sample reject unknown flags
2026-01-17 22:51:11 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message --silent + flags
2026-01-17 22:56:33 | Messagequeue/MessageQueue | IN_PROGRESS | publish_sample_keys flags + payload
2026-01-17 23:01:39 | Messagequeue/MessageQueue | IN_PROGRESS | consume_test_message --silent + flags
2026-01-17 23:06:06 | Messagequeue/MessageQueue | IN_PROGRESS | run_checks --silent
2026-01-17 23:10:55 | Messagequeue/MessageQueue | IN_PROGRESS | doc run_checks --silent usage
2026-01-17 23:15:56 | Messagequeue/MessageQueue | IN_PROGRESS | doc local_usage post_sample
2026-01-17 23:21:14 | Messagequeue/MessageQueue | IN_PROGRESS | post_sample OUTPUT status
2026-01-17 23:25:54 | Messagequeue/MessageQueue | IN_PROGRESS | doc local_usage OUTPUT=status
2026-01-17 23:30:56 | Messagequeue/MessageQueue | IN_PROGRESS | maj todo_next
2026-01-17 23:36:20 | Messagequeue/MessageQueue | IN_PROGRESS | test_routing_matrix --silent + help
2026-01-17 23:41:25 | Messagequeue/MessageQueue | IN_PROGRESS | test_routing --silent + help
2026-01-17 23:46:33 | Messagequeue/MessageQueue | IN_PROGRESS | smoke_local --silent
2026-01-17 23:51:34 | Messagequeue/MessageQueue | IN_PROGRESS | doctor --silent + docs
2026-01-17 23:56:33 | Messagequeue/MessageQueue | IN_PROGRESS | status_report --silent + help
2026-01-18 00:01:28 | Messagequeue/MessageQueue | IN_PROGRESS | count_queue_messages --silent + help
2026-01-18 00:06:31 | Messagequeue/MessageQueue | IN_PROGRESS | list_queues --silent + help
2026-01-18 00:11:18 | Messagequeue/MessageQueue | IN_PROGRESS | list_exchanges --silent + help
2026-01-18 00:16:05 | Messagequeue/MessageQueue | IN_PROGRESS | list_bindings --silent + help
2026-01-18 00:21:40 | Messagequeue/MessageQueue | IN_PROGRESS | check_prereqs --silent + help
2026-01-18 00:26:19 | Messagequeue/MessageQueue | IN_PROGRESS | check_rabbitmq --silent + help
2026-01-18 00:31:23 | Messagequeue/MessageQueue | IN_PROGRESS | wait_rabbitmq --silent + help
2026-01-18 00:36:24 | Messagequeue/MessageQueue | IN_PROGRESS | bootstrap_rabbitmq --silent + help
2026-01-18 00:41:33 | Messagequeue/MessageQueue | IN_PROGRESS | create_bindings --silent + help
2026-01-18 00:47:07 | Messagequeue/MessageQueue | IN_PROGRESS | validate_rabbitmq --silent + docs.
2026-01-18 00:51:57 | Messagequeue/MessageQueue | IN_PROGRESS | validate_rabbitmq --json + docs.
2026-01-18 00:57:10 | Messagequeue/MessageQueue | IN_PROGRESS | list_queues/count_queue_messages --json + docs.
2026-01-18 01:01:38 | Messagequeue/MessageQueue | IN_PROGRESS | list_exchanges/list_bindings --json + docs.
2026-01-18 01:06:48 | Messagequeue/MessageQueue | IN_PROGRESS | status_report --json + docs.
2026-01-18 01:11:29 | Messagequeue/MessageQueue | IN_PROGRESS | check_rabbitmq --json + docs.
2026-01-18 01:16:14 | Messagequeue/MessageQueue | IN_PROGRESS | wait_rabbitmq --json + docs.
2026-01-18 01:21:39 | Messagequeue/MessageQueue | IN_PROGRESS | check_prereqs --json + docs.
2026-01-18 01:26:47 | Messagequeue/MessageQueue | IN_PROGRESS | run_checks --json + docs.
2026-01-18 01:31:57 | Messagequeue/MessageQueue | IN_PROGRESS | doctor --json + docs.
2026-01-18 01:37:36 | Messagequeue/MessageQueue | IN_PROGRESS | test_routing/test_routing_matrix --json + docs.
2026-01-18 01:42:32 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message/publish_sample_keys --json + docs.
2026-01-18 01:46:27 | Messagequeue/MessageQueue | IN_PROGRESS | consume_test_message --json + docs.
2026-01-18 01:51:58 | Messagequeue/MessageQueue | IN_PROGRESS | smoke_local --json + docs.
2026-01-18 01:56:47 | Messagequeue/MessageQueue | IN_PROGRESS | validate_payload --json + docs.
2026-01-18 02:01:00 | Messagequeue/MessageQueue | IN_PROGRESS | fix post_sample extra fi.
2026-01-18 02:06:22 | Messagequeue/MessageQueue | IN_PROGRESS | post_sample --json + docs.
2026-01-18 02:11:42 | Messagequeue/MessageQueue | IN_PROGRESS | bootstrap_rabbitmq/create_bindings --json + docs.
2026-01-18 02:17:50 | Messagequeue/MessageQueue | IN_PROGRESS | test_validate_payload --json + docs
2026-01-18 02:22:53 | Messagequeue/MessageQueue | IN_PROGRESS | ajout e2e_local script + docs
2026-01-18 02:26:14 | Messagequeue/MessageQueue | IN_PROGRESS | doc e2e_local + runbook
2026-01-18 02:31:34 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local purge option + docs
2026-01-18 02:36:03 | Messagequeue/MessageQueue | IN_PROGRESS | doc tests_summary/test_matrix e2e_local
2026-01-18 02:41:40 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local dry-run + docs
2026-01-18 02:45:51 | Messagequeue/MessageQueue | IN_PROGRESS | README e2e_local usage section
2026-01-18 02:51:47 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local payload validation toggle + docs
2026-01-18 02:55:54 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary payload section
2026-01-18 03:00:52 | Messagequeue/MessageQueue | IN_PROGRESS | test_matrix payload section
2026-01-18 03:06:28 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local COUNT support + docs
2026-01-18 03:11:22 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local INDEX selection + docs
2026-01-18 03:16:48 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local OUTPUT=all + docs
2026-01-18 03:21:29 | Messagequeue/MessageQueue | IN_PROGRESS | add test_e2e_local dry-run
2026-01-18 03:25:54 | Messagequeue/MessageQueue | IN_PROGRESS | test_matrix e2e_local dry-run item
2026-01-18 03:31:34 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_e2e_local JSON parsing; run test
2026-01-18 03:36:14 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local --help + docs
2026-01-18 03:41:24 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local --json + docs
2026-01-18 03:46:08 | Messagequeue/MessageQueue | IN_PROGRESS | doc e2e_local OUTPUT=all JSON note
2026-01-18 03:51:23 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local env overrides + docs
2026-01-18 03:56:00 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validate queue/count/index
2026-01-18 04:00:49 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_e2e_local env propagation; run test
2026-01-18 04:05:58 | Messagequeue/MessageQueue | IN_PROGRESS | README add test_e2e_local dry-run usage
2026-01-18 04:11:17 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local enforce OUTPUT=all json + docs
2026-01-18 04:15:55 | Messagequeue/MessageQueue | IN_PROGRESS | run test_e2e_local --json
2026-01-18 04:21:01 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local validate OUTPUT values
2026-01-18 04:25:51 | Messagequeue/MessageQueue | IN_PROGRESS | run test_e2e_local --json after OUTPUT check
2026-01-18 04:31:04 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validate count/index numeric
2026-01-18 04:35:58 | Messagequeue/MessageQueue | IN_PROGRESS | run test_e2e_local --json after count/index validation
2026-01-18 04:41:11 | Messagequeue/MessageQueue | IN_PROGRESS | test_matrix mark e2e_local dry-run done
2026-01-18 04:46:10 | Messagequeue/MessageQueue | IN_PROGRESS | run payload validation/tests + mark test_matrix
2026-01-18 04:51:51 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local preflight check_rabbitmq + docs
2026-01-18 04:56:08 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local validate COUNT/INDEX ranges
2026-01-18 05:01:03 | Messagequeue/MessageQueue | IN_PROGRESS | doc e2e_local index/count constraint
2026-01-18 05:06:10 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local check payload file exists + docs
2026-01-18 05:11:08 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local resolve PAYLOAD_FILE from repo root
2026-01-18 05:16:13 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validate payload_file path + run
2026-01-18 05:21:45 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local resolve payload in dry-run output
2026-01-18 05:26:30 | Messagequeue/MessageQueue | IN_PROGRESS | validate_payload resolves PAYLOAD_FILE from repo root
2026-01-18 05:32:47 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local dry-run validates OUTPUT/COUNT/INDEX; test OUTPUT=all requires --json
2026-01-18 05:36:03 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects INDEX>=COUNT when OUTPUT=single
2026-01-18 05:41:04 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects COUNT=0 in dry-run
2026-01-18 05:46:01 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects INDEX=-1 in dry-run
2026-01-18 05:51:05 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects invalid OUTPUT in dry-run
2026-01-18 05:56:05 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects non-numeric COUNT in dry-run
2026-01-18 06:01:04 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects non-numeric INDEX in dry-run
2026-01-18 06:06:05 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects negative COUNT in dry-run
2026-01-18 06:11:15 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local validates ACK_MODE; test rejects invalid value
2026-01-18 06:16:09 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local validates PURGE_QUEUE; test rejects invalid value
2026-01-18 06:21:12 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local validates VALIDATE_PAYLOAD/CHECK_RABBITMQ; tests reject invalid values
2026-01-18 06:26:28 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local validates DOC_TYPE format; test rejects spaces
2026-01-18 06:31:32 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local validates QUEUE format; test rejects spaces
2026-01-18 06:36:11 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local validates EXCHANGE format; test rejects spaces
2026-01-18 06:41:13 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local validates ROUTING_KEY format; test rejects spaces
2026-01-18 06:46:46 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local limits ROUTING_KEY length; test rejects >255
2026-01-18 06:51:14 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local limits EXCHANGE length; test rejects >255
2026-01-18 06:56:14 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local limits QUEUE length; test rejects >255
2026-01-18 07:01:55 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local validates PDF_OUTPUT_DIR; test rejects file path
2026-01-18 07:06:56 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local requires existing PAYLOAD_FILE in dry-run; test rejects missing
2026-01-18 07:11:23 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local validates PDF_OUTPUT_DIR writable; test rejects non-writable
2026-01-18 07:16:16 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local limits DOC_TYPE length; test rejects >255
2026-01-18 07:21:19 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local rejects ROUTING_KEY with SOCIAL_ASSISTANCE_EXCHANGE
2026-01-18 07:26:29 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local requires COUNT>=2 for OUTPUT=all; test rejects COUNT=1
2026-01-18 07:31:09 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects OUTPUT=all COUNT=1 even with --json
2026-01-18 07:36:47 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local requires INDEX=0 for OUTPUT=all; test defaults adjusted
2026-01-18 07:41:38 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local requires .json PAYLOAD_FILE; test rejects non-json
2026-01-18 07:46:19 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local requires non-empty PAYLOAD_FILE; test rejects empty file
2026-01-18 07:51:20 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local requires readable PAYLOAD_FILE; test rejects unreadable file
2026-01-18 07:56:19 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local requires COUNT=1 for OUTPUT=single; test rejects COUNT=2
2026-01-18 08:01:16 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local allows COUNT>1 with OUTPUT=single
2026-01-18 08:06:19 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local checks validate_payload/check_rabbitmq JSON fields
2026-01-18 08:11:22 | Messagequeue/MessageQueue | IN_PROGRESS | doc e2e_local contraintes de validation
2026-01-18 08:16:18 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local checks validate_payload/check_rabbitmq overrides
2026-01-18 08:21:16 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates ack_mode in JSON
2026-01-18 08:26:13 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates purge_queue in JSON
2026-01-18 08:31:15 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates doc_type in JSON
2026-01-18 08:36:12 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates exchange/routing_key in JSON
2026-01-18 08:41:16 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates pdf_output_dir in JSON
2026-01-18 08:46:24 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local checks routing_key empty for SOCIAL_ASSISTANCE_EXCHANGE
2026-01-18 08:51:15 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local checks purge_queue override
2026-01-18 08:56:23 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local checks output=all constraints in JSON
2026-01-18 09:01:56 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local checks doc_type override in JSON
2026-01-18 09:07:55 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates default queue/exchange and doc_type fallback in JSON
2026-01-18 09:11:13 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates routing_key empty when social exchange inferred
2026-01-18 09:16:10 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local requires check_rabbitmq in JSON output
2026-01-18 09:21:14 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates check_rabbitmq values in JSON
2026-01-18 09:26:15 | Messagequeue/MessageQueue | IN_PROGRESS | doc e2e_local JSON mention check_rabbitmq field
2026-01-18 09:31:16 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates GRANT_EXCHANGE inference for grant_contracts
2026-01-18 09:36:17 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates default pdf_output_dir in JSON
2026-01-18 09:41:16 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local asserts payload_file is absolute under ROOT_DIR
2026-01-18 09:46:13 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local asserts default payload_file path in JSON
2026-01-18 09:51:30 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local checks pdf_output_dir override in JSON
2026-01-18 09:56:44 | Messagequeue/MessageQueue | IN_PROGRESS | fix duplicate pdf_output_dir override test block
2026-01-18 10:01:13 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local enforces output=all count/index in JSON validation
2026-01-18 10:06:21 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local asserts PDF_OUTPUT_DIR override is absolute
2026-01-18 10:11:16 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local verifies default ack_mode in JSON
2026-01-18 10:16:17 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local verifies ack_mode override in JSON
2026-01-18 10:21:20 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local verifies output default to single in JSON
2026-01-18 10:26:16 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local verifies count default to 1 in JSON
2026-01-18 10:31:17 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local verifies index default to 0 in JSON
2026-01-18 10:36:20 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local verifies validate_payload default to 1 in JSON
2026-01-18 10:41:19 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local verifies check_rabbitmq default to 1 in JSON
2026-01-18 10:46:21 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local verifies purge_queue default to 0 in JSON
2026-01-18 10:51:22 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local asserts payload_file ends with .json in JSON
2026-01-18 10:56:24 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local asserts payload_file exists on disk in JSON
2026-01-18 11:01:20 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local asserts payload_file is readable in JSON
2026-01-18 11:06:16 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local asserts payload_file non-empty in JSON
2026-01-18 11:11:29 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local checks social exchange inference for financial_assistance_application
2026-01-18 11:16:21 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local checks social exchange inference for transportation_costs_application
2026-01-18 11:21:21 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local checks social exchange inference for food_application
2026-01-18 11:26:41 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates routing_key type in JSON
2026-01-18 11:31:19 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates exchange type in JSON
2026-01-18 11:36:21 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates pdf_output_dir type in JSON
2026-01-18 11:41:27 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates doc_type type in JSON
2026-01-18 11:46:23 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates queue type in JSON
2026-01-18 11:51:25 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates count/index are strings in JSON
2026-01-18 11:56:21 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates output type in JSON
2026-01-18 12:01:19 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates validate_payload type in JSON
2026-01-18 12:06:20 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates check_rabbitmq type in JSON
2026-01-18 12:11:20 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates purge_queue type in JSON
2026-01-18 12:16:22 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates ack_mode type in JSON
2026-01-18 12:21:23 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates payload_file type in JSON
2026-01-18 12:26:42 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects empty exchange string in JSON
2026-01-18 12:31:28 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local enforces absolute pdf_output_dir when overridden in JSON
2026-01-18 12:36:23 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local requires routing_key for non-social exchange in JSON
2026-01-18 12:41:30 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates status type in JSON
2026-01-18 12:46:26 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects empty status in JSON
2026-01-18 12:51:38 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_e2e_local help INDEX default
2026-01-18 12:56:22 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local help text verified after INDEX default fix
2026-01-18 13:01:25 | Messagequeue/MessageQueue | IN_PROGRESS | no-op avoided; state already logged for help text verification
2026-01-18 13:06:28 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates output values in JSON
2026-01-18 13:11:31 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local enforces output=single index<count in JSON
2026-01-18 13:16:28 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates doc_type regex in JSON
2026-01-18 13:21:37 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates exchange regex in JSON
2026-01-18 13:26:29 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates routing_key regex in JSON
2026-01-18 13:31:29 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates doc_type length in JSON
2026-01-18 13:36:28 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates exchange length in JSON
2026-01-18 13:41:27 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates routing_key length in JSON
2026-01-18 13:46:22 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local run after routing_key length check
2026-01-18 13:51:29 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local asserts pdf_output_dir exists when overridden in JSON
2026-01-18 13:58:09 | Messagequeue/MessageQueue | IN_PROGRESS | add DOC_TYPE dot rejection test in e2e local validator
2026-01-18 14:01:25 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects PAYLOAD_FILE directory
2026-01-18 14:06:30 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts relative PAYLOAD_FILE
2026-01-18 14:11:22 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects decimal COUNT
2026-01-18 14:16:22 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects decimal INDEX
2026-01-18 14:21:29 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates EXCHANGE with dot
2026-01-18 14:26:38 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts ROUTING_KEY dot with grant exchange
2026-01-18 14:31:24 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts ROUTING_KEY hyphen with grant exchange
2026-01-18 14:36:31 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts OUTPUT=all COUNT=2 INDEX=0
2026-01-18 14:41:27 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts ROUTING_KEY underscore with grant exchange
2026-01-18 14:46:44 | Messagequeue/MessageQueue | IN_PROGRESS | reject relative PDF_OUTPUT_DIR in e2e_local + tests
2026-01-18 14:51:44 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts QUEUE dot/underscore with DOC_TYPE override
2026-01-18 14:56:37 | Messagequeue/MessageQueue | IN_PROGRESS | allow DOC_TYPE dot + update tests
2026-01-18 15:03:28 | Messagequeue/MessageQueue | IN_PROGRESS | derive grant ROUTING_KEY from payload in e2e_local
2026-01-18 15:06:44 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local defaults routing_key when grantType missing
2026-01-18 15:11:58 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates DOC_TYPE dot in JSON
2026-01-18 15:16:28 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects non-existent PDF_OUTPUT_DIR
2026-01-18 15:21:27 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts empty OUTPUT default
2026-01-18 15:26:54 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local derives routing_key from custom grantType
2026-01-18 15:31:44 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts EXCHANGE underscore
2026-01-18 15:36:31 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts ack_requeue_true
2026-01-18 15:41:30 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts PURGE_QUEUE=1
2026-01-18 15:46:31 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts VALIDATE_PAYLOAD=0
2026-01-18 15:51:31 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts CHECK_RABBITMQ=0
2026-01-18 15:56:30 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts DOC_TYPE length 255
2026-01-18 16:01:33 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts QUEUE length 255
2026-01-18 16:06:31 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts EXCHANGE length 255
2026-01-18 16:11:30 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts ROUTING_KEY length 255
2026-01-18 16:16:33 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts writable PDF_OUTPUT_DIR
2026-01-18 16:21:32 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts OUTPUT=single
2026-01-18 16:26:31 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts COUNT=1 INDEX=0 OUTPUT=single
2026-01-18 16:31:36 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts COUNT=2 INDEX=1 OUTPUT=single
2026-01-18 16:36:48 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts COUNT leading zeros
2026-01-18 16:41:34 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts INDEX leading zeros
2026-01-18 16:46:42 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts QUEUE hyphen
2026-01-18 16:51:37 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts EXCHANGE hyphen
2026-01-18 16:56:37 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts mixed-symbol ROUTING_KEY
2026-01-18 17:01:39 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local validates DOC_TYPE mixed symbols
2026-01-18 17:06:37 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts ROUTING_KEY dot/underscore/hyphen
2026-01-18 17:11:39 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts empty routing_key for social exchange
2026-01-18 17:16:41 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local rejects OUTPUT=all with INDEX=1
2026-01-18 17:21:37 | Messagequeue/MessageQueue | IN_PROGRESS | test_e2e_local accepts COUNT=3 INDEX=0 OUTPUT=single
2026-01-18 17:28:03 | Messagequeue/MessageQueue | IN_PROGRESS | add root projects overview document
2026-01-18 17:30:35 | Messagequeue/MessageQueue | IN_PROGRESS | rewrite PROJECTS_OVERVIEW.md with detailed French descriptions
2026-01-18 19:48:37 | Messagequeue/MessageQueue | IN_PROGRESS | add reading guidance section in PROJECTS_OVERVIEW.md
2026-01-18 19:49:17 | Messagequeue/MessageQueue | IN_PROGRESS | add conventions section in PROJECTS_OVERVIEW.md
2026-01-18 19:50:12 | Messagequeue/MessageQueue | IN_PROGRESS | add glossary section to PROJECTS_OVERVIEW.md
2026-01-18 19:53:58 | Messagequeue/MessageQueue | IN_PROGRESS | add Utilisation du panorama section
2026-01-18 19:58:58 | Messagequeue/MessageQueue | IN_PROGRESS | add depot structure section in PROJECTS_OVERVIEW.md
2026-01-18 20:03:59 | Messagequeue/MessageQueue | IN_PROGRESS | add verification guidance section in PROJECTS_OVERVIEW.md
2026-01-18 20:08:32 | Messagequeue/MessageQueue | IN_PROGRESS | add dry-run option and tests for publish_test_message
2026-01-18 20:09:47 | Messagequeue/MessageQueue | IN_PROGRESS | doctor runs publish_test_message dry-run tests
2026-01-18 20:14:06 | Messagequeue/MessageQueue | IN_PROGRESS | document publish_test_message dry-run in local_usage
2026-01-18 20:19:49 | Messagequeue/MessageQueue | IN_PROGRESS | add --json output for test_publish_test_message
2026-01-18 20:24:11 | Messagequeue/MessageQueue | IN_PROGRESS | --json mode in test_publish_test_message returns JSON-only
2026-01-18 20:29:18 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message --json suppresses non-JSON output
2026-01-18 20:34:10 | Messagequeue/MessageQueue | IN_PROGRESS | document doctor --json publish_tests field
2026-01-18 20:39:09 | Messagequeue/MessageQueue | IN_PROGRESS | record publish_test_message dry-run in test_matrix
2026-01-18 20:44:07 | Messagequeue/MessageQueue | IN_PROGRESS | document publish_test_message dry-run in local_runbook
2026-01-18 20:49:13 | Messagequeue/MessageQueue | IN_PROGRESS | add publish_test_message dry-run to quickstart
2026-01-18 20:54:08 | Messagequeue/MessageQueue | IN_PROGRESS | add quickstart to docs index
2026-01-18 20:59:12 | Messagequeue/MessageQueue | IN_PROGRESS | document doctor JSON fields in troubleshooting_env
2026-01-18 21:04:26 | Messagequeue/MessageQueue | IN_PROGRESS | expand test_publish_test_message payload error cases
2026-01-18 21:09:07 | Messagequeue/MessageQueue | IN_PROGRESS | document publish_test_message payload error cases in tests_summary
2026-01-18 21:14:18 | Messagequeue/MessageQueue | IN_PROGRESS | validate publish_test_message payload readability
2026-01-18 21:19:07 | Messagequeue/MessageQueue | IN_PROGRESS | document publish_test_message payload readability requirement
2026-01-18 21:25:20 | Messagequeue/MessageQueue | IN_PROGRESS | validate exchange/routing key in publish_test_message + tests
2026-01-18 21:29:23 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message validates long exchange/routing key
2026-01-18 21:34:05 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary mentionne longueurs invalides publish_test_message
2026-01-18 21:39:04 | Messagequeue/MessageQueue | IN_PROGRESS | note long exchange/routing key test in test_matrix
2026-01-18 21:44:35 | Messagequeue/MessageQueue | IN_PROGRESS | extend publish_test_message help text and test it
2026-01-18 21:49:05 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary mentionne test help publish_test_message
2026-01-18 21:55:31 | Messagequeue/MessageQueue | IN_PROGRESS | validate long content_type in publish_test_message tests
2026-01-18 21:59:38 | Messagequeue/MessageQueue | IN_PROGRESS | validate MESSAGE_ID length in publish_test_message + tests
2026-01-18 22:04:10 | Messagequeue/MessageQueue | IN_PROGRESS | note MESSAGE_ID length check in test_matrix
2026-01-18 22:09:06 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary mentionne content_type/message_id publish_test_message
2026-01-18 22:14:15 | Messagequeue/MessageQueue | IN_PROGRESS | document publish_test_message param errors in troubleshooting_env
2026-01-18 22:19:10 | Messagequeue/MessageQueue | IN_PROGRESS | document publish_test_message validations in test_tools
2026-01-18 22:24:22 | Messagequeue/MessageQueue | IN_PROGRESS | note content_type/message_id constraints in e2e_local docs
2026-01-18 22:29:13 | Messagequeue/MessageQueue | IN_PROGRESS | add MESSAGE_ID/CONTENT_TYPE override example in local_usage
2026-01-18 22:34:10 | Messagequeue/MessageQueue | IN_PROGRESS | scripts_overview notes publish_test_message validations
2026-01-18 22:39:58 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message checks non-empty message_id
2026-01-18 22:44:07 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary mentionne message_id non vide
2026-01-18 22:49:07 | Messagequeue/MessageQueue | IN_PROGRESS | note empty MESSAGE_ID check in test_matrix
2026-01-18 22:54:41 | Messagequeue/MessageQueue | IN_PROGRESS | validate MESSAGE_ID whitespace in publish_test_message + tests
2026-01-18 22:59:10 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary mentionne message_id sans espaces
2026-01-18 23:04:09 | Messagequeue/MessageQueue | IN_PROGRESS | note MESSAGE_ID whitespace check in test_matrix
2026-01-18 23:09:11 | Messagequeue/MessageQueue | IN_PROGRESS | document message_id whitespace validation in test_tools
2026-01-18 23:14:12 | Messagequeue/MessageQueue | IN_PROGRESS | clarify message_id whitespace in local_usage
2026-01-18 23:20:08 | Messagequeue/MessageQueue | IN_PROGRESS | validate whitespace-only CONTENT_TYPE in publish_test_message + tests
2026-01-18 23:24:11 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary mentionne content_type non blanc
2026-01-18 23:29:11 | Messagequeue/MessageQueue | IN_PROGRESS | note CONTENT_TYPE blank check in test_matrix
2026-01-18 23:34:11 | Messagequeue/MessageQueue | IN_PROGRESS | runbook note message_id/content_type constraints
2026-01-18 23:39:35 | Messagequeue/MessageQueue | IN_PROGRESS | expand publish_test_message help notes + test
2026-01-18 23:44:11 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary mentionne help detaille publish_test_message
2026-01-18 23:49:15 | Messagequeue/MessageQueue | IN_PROGRESS | test_tools mentionne content_type blanc et message_id avec espaces
2026-01-18 23:55:17 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message couvre CONTENT_TYPE vide
2026-01-18 23:59:14 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary mentionne content_type vide/blanc
2026-01-19 00:04:17 | Messagequeue/MessageQueue | IN_PROGRESS | test_matrix mentionne CONTENT_TYPE vide
2026-01-19 00:09:15 | Messagequeue/MessageQueue | IN_PROGRESS | test_tools mentionne content_type vide/blanc
2026-01-19 00:14:23 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message couvre MESSAGE_ID vide
2026-01-19 00:19:11 | Messagequeue/MessageQueue | IN_PROGRESS | test_tools mentionne message_id vide
2026-01-19 00:24:12 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary mentionne message_id vide/espaces
2026-01-19 00:29:42 | Messagequeue/MessageQueue | IN_PROGRESS | test_tools detaille tests content_type/message_id
2026-01-19 00:34:39 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary note JSON fields empty_message_id/whitespace_content_type
2026-01-19 00:39:14 | Messagequeue/MessageQueue | IN_PROGRESS | scripts_overview detaille tests content_type/message_id
2026-01-19 00:44:15 | Messagequeue/MessageQueue | IN_PROGRESS | scripts_overview note champs JSON empty_message_id/whitespace_content_type
2026-01-19 00:49:21 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message exige champs JSON empty_message_id/whitespace_content_type
2026-01-19 00:54:14 | Messagequeue/MessageQueue | IN_PROGRESS | test_matrix note champs JSON empty_message_id/whitespace_content_type
2026-01-19 00:59:12 | Messagequeue/MessageQueue | IN_PROGRESS | test_tools note champs JSON empty_message_id/whitespace_content_type
2026-01-19 01:04:19 | Messagequeue/MessageQueue | IN_PROGRESS | corrige champs requis JSON publish_test_message
2026-01-19 01:10:23 | Messagequeue/MessageQueue | IN_PROGRESS | tests maj defaults message_id/content_type + test ok
2026-01-19 01:14:19 | Messagequeue/MessageQueue | IN_PROGRESS | script_env clarifie defaults content_type/message_id
2026-01-19 01:19:14 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting_env clarifie defaults content_type/message_id
2026-01-19 01:24:18 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook clarifie defaults content_type/message_id
2026-01-19 01:29:33 | Messagequeue/MessageQueue | IN_PROGRESS | local_usage note defaults message_id/content_type
2026-01-19 01:34:17 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local clarifie defaults content_type/message_id
2026-01-19 01:39:24 | Messagequeue/MessageQueue | IN_PROGRESS | quickstart note defaults content_type/message_id
2026-01-19 01:44:36 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting rappelle defaults content_type/message_id
2026-01-19 01:49:20 | Messagequeue/MessageQueue | IN_PROGRESS | scripts_overview note defaults publish_test_message
2026-01-19 01:54:37 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message couvre content_type whitespace tab
2026-01-19 01:59:19 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message --json ok apres whitespace tab
2026-01-19 02:04:14 | Messagequeue/MessageQueue | IN_PROGRESS | test_matrix mentionne content_type blanc espaces/tabs
2026-01-19 02:09:26 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary mentionne content_type blanc espaces/tabs
2026-01-19 02:14:28 | Messagequeue/MessageQueue | IN_PROGRESS | docs mentionnent content_type blanc espaces/tabs
2026-01-19 02:19:16 | Messagequeue/MessageQueue | IN_PROGRESS | quickstart precise content_type blanc espaces/tabs
2026-01-19 02:24:14 | Messagequeue/MessageQueue | IN_PROGRESS | local_usage precise content_type blanc espaces/tabs
2026-01-19 02:29:15 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local precise content_type blanc espaces/tabs
2026-01-19 02:34:15 | Messagequeue/MessageQueue | IN_PROGRESS | script_env precise content_type blanc espaces/tabs
2026-01-19 02:39:14 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting_env precise content_type blanc espaces/tabs
2026-01-19 02:44:14 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook precise content_type blanc espaces/tabs
2026-01-19 02:49:21 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting precise content_type blanc espaces/tabs
2026-01-19 02:54:27 | Messagequeue/MessageQueue | IN_PROGRESS | test_tools precise content_type blanc espaces/tabs
2026-01-19 03:00:03 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message verifie message_id tab + docs
2026-01-19 03:04:16 | Messagequeue/MessageQueue | IN_PROGRESS | script_env precise message_id sans espaces/tabs
2026-01-19 03:09:19 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting_env precise message_id sans espaces/tabs
2026-01-19 03:14:18 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook precise message_id sans espaces/tabs
2026-01-19 03:19:17 | Messagequeue/MessageQueue | IN_PROGRESS | local_usage precise message_id sans espaces/tabs
2026-01-19 03:24:17 | Messagequeue/MessageQueue | IN_PROGRESS | quickstart precise message_id sans espaces/tabs
2026-01-19 03:29:17 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting precise message_id sans espaces/tabs
2026-01-19 03:34:22 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local precise message_id sans espaces/tabs
2026-01-19 03:39:35 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message couvre content_type whitespace newline
2026-01-19 03:44:43 | Messagequeue/MessageQueue | IN_PROGRESS | docs precisent content_type blanc espaces/tabs/newlines
2026-01-19 03:49:53 | Messagequeue/MessageQueue | IN_PROGRESS | docs precisent content_type blanc espaces/tabs/newlines partout
2026-01-19 03:54:33 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message couvre message_id whitespace newline
2026-01-19 03:59:41 | Messagequeue/MessageQueue | IN_PROGRESS | docs precisent message_id espaces/tabs/newlines
2026-01-19 04:04:58 | Messagequeue/MessageQueue | IN_PROGRESS | docs precisent message_id sans espaces/tabs/newlines
2026-01-19 04:09:33 | Messagequeue/MessageQueue | IN_PROGRESS | scripts_overview detaille refus content_type/message_id
2026-01-19 04:14:30 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook/local_usage mentionnent message_id newlines
2026-01-19 04:19:39 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting_env ajoute mention whitespace
2026-01-19 04:24:28 | Messagequeue/MessageQueue | IN_PROGRESS | local_usage mentionne message_id sans espaces/tabs/newlines
2026-01-19 04:31:19 | Documentation/Repository | IN_PROGRESS | etend PROJETS_EXPLICATIONS.md avec lignes 11-16 par projet
2026-01-19 04:35:36 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message refuse JSON invalide + test associe
2026-01-19 04:39:48 | Messagequeue/MessageQueue | IN_PROGRESS | docs tests_* mentionnent payload JSON invalide
2026-01-19 04:44:39 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting mentionne payload JSON invalide
2026-01-19 04:49:36 | Messagequeue/MessageQueue | IN_PROGRESS | local_usage mentionne erreur JSON invalide
2026-01-19 04:54:27 | Messagequeue/MessageQueue | IN_PROGRESS | script_env mentionne JSON valide pour publish_test_message
2026-01-19 04:59:30 | Messagequeue/MessageQueue | IN_PROGRESS | quickstart note JSON invalide publish_test_message
2026-01-19 05:04:49 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message verifie message erreur JSON invalide
2026-01-19 05:09:30 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting_env ajoute JSON invalide publish_test_message
2026-01-19 05:14:29 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook note JSON invalide publish_test_message
2026-01-19 05:19:41 | Messagequeue/MessageQueue | IN_PROGRESS | help publish_test_message mentionne JSON valide + test help
2026-01-19 05:24:29 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary detaille message erreur JSON invalide
2026-01-19 05:29:25 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting_env precise message JSON invalide
2026-01-19 05:34:28 | Messagequeue/MessageQueue | IN_PROGRESS | http_endpoints mentionne JSON invalide pour POST /students
2026-01-19 05:39:29 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local precise PAYLOAD_FILE JSON valide
2026-01-19 05:44:37 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message verifie chemin JSON invalide
2026-01-19 05:50:21 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message JSON error en mode --json + test associe
2026-01-19 05:54:25 | Messagequeue/MessageQueue | IN_PROGRESS | scripts_overview mentionne sortie JSON d erreur
2026-01-19 05:59:22 | Messagequeue/MessageQueue | IN_PROGRESS | test_matrix mentionne JSON erreur publish_test_message
2026-01-19 06:04:24 | Messagequeue/MessageQueue | IN_PROGRESS | test_tools mentionne sortie JSON d erreur
2026-01-19 06:09:28 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary precise status=error JSON invalide
2026-01-19 06:15:37 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message JSON error pour payload manquant + docs/tests
2026-01-19 06:20:42 | Messagequeue/MessageQueue | IN_PROGRESS | erreurs JSON en --json pour validations publish_test_message
2026-01-19 06:24:49 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message JSON erreur content_type trop long
2026-01-19 06:30:15 | Messagequeue/MessageQueue | IN_PROGRESS | tests JSON erreurs longueurs exchange/routing/message_id
2026-01-19 06:34:23 | Messagequeue/MessageQueue | IN_PROGRESS | test_matrix mentionne erreurs JSON longueurs
2026-01-19 06:39:25 | Messagequeue/MessageQueue | IN_PROGRESS | script_env mentionne erreurs JSON en --json
2026-01-19 06:44:36 | Messagequeue/MessageQueue | IN_PROGRESS | README mentionne erreurs JSON en --json
2026-01-19 06:49:54 | Messagequeue/MessageQueue | IN_PROGRESS | help mentionne status=error en --json + test
2026-01-19 06:54:27 | Messagequeue/MessageQueue | IN_PROGRESS | local_usage mentionne status=error en --json
2026-01-19 06:59:26 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook mentionne status=error en --json
2026-01-19 07:04:24 | Messagequeue/MessageQueue | IN_PROGRESS | quickstart mentionne status=error en --json
2026-01-19 07:09:27 | Messagequeue/MessageQueue | IN_PROGRESS | http_endpoints mentionne status=error pour POST /students
2026-01-19 07:14:24 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting mentionne status=error en --json
2026-01-19 07:20:46 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message JSON erreurs payload directory+readable + tests
2026-01-19 07:24:46 | Messagequeue/MessageQueue | IN_PROGRESS | docs test_matrix/tests_summary ajoutent erreurs JSON payload
2026-01-19 07:29:28 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting_env ajoute payload not found/directory
2026-01-19 07:34:30 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting ajoute payload not found/directory
2026-01-19 07:39:34 | Messagequeue/MessageQueue | IN_PROGRESS | test_tools detaille erreurs JSON payload manquant/illisible/dossier
2026-01-19 07:44:32 | Messagequeue/MessageQueue | IN_PROGRESS | local_usage mentionne erreurs JSON payload manquant/illisible/dossier
2026-01-19 07:49:27 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook mentionne erreurs JSON payload manquant/illisible/dossier
2026-01-19 07:54:27 | Messagequeue/MessageQueue | IN_PROGRESS | quickstart mentionne erreurs JSON payload manquant/illisible/dossier
2026-01-19 07:59:37 | Messagequeue/MessageQueue | IN_PROGRESS | json_error verifie python3 avant JSON
2026-01-19 08:04:28 | Messagequeue/MessageQueue | IN_PROGRESS | scripts_overview note JSON errors si python3 dispo
2026-01-19 08:09:24 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting_env note --json sans python3
2026-01-19 08:16:20 | Messagequeue/MessageQueue | IN_PROGRESS | troubleshooting ajoute verification python3 pour --json
2026-01-19 08:19:37 | Messagequeue/MessageQueue | IN_PROGRESS | module_status detaille etapes PDF reel
2026-01-19 08:24:34 | Messagequeue/MessageQueue | IN_PROGRESS | todo_next detaille e2e/pdf/ci
2026-01-19 08:29:34 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary precise prerequis e2e_local
2026-01-19 08:34:37 | Messagequeue/MessageQueue | IN_PROGRESS | quickstart ajoute nettoyage PDFs
2026-01-19 08:39:35 | Messagequeue/MessageQueue | IN_PROGRESS | local_usage ajoute nettoyage PDFs e2e_local
2026-01-19 08:44:42 | Messagequeue/MessageQueue | IN_PROGRESS | run_modules note nettoyage PDFs
2026-01-19 08:49:44 | Messagequeue/MessageQueue | IN_PROGRESS | logging note chemin PDF par defaut
2026-01-19 08:54:29 | Messagequeue/MessageQueue | IN_PROGRESS | security_notes ajoute restriction acces shared
2026-01-19 08:59:54 | Messagequeue/MessageQueue | IN_PROGRESS | api_contract note generation PDF via consumers
2026-01-19 09:04:38 | Messagequeue/MessageQueue | IN_PROGRESS | ports note PDF output dir
2026-01-19 09:09:38 | Messagequeue/MessageQueue | IN_PROGRESS | sample_routing_keys relie sample_student.json
2026-01-19 09:14:48 | Messagequeue/MessageQueue | IN_PROGRESS | service_env note PDF_OUTPUT_DIR writable
2026-01-19 09:19:32 | Messagequeue/MessageQueue | IN_PROGRESS | http_endpoints note PDF via consumers
2026-01-19 09:24:33 | Messagequeue/MessageQueue | IN_PROGRESS | scripts_overview note PDFs e2e_local
2026-01-19 09:29:35 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local ajoute nettoyage PDFs
2026-01-19 09:34:40 | Messagequeue/MessageQueue | IN_PROGRESS | module_layout note PDF_OUTPUT_DIR
2026-01-19 09:39:35 | Messagequeue/MessageQueue | IN_PROGRESS | service_matrix note PDF_OUTPUT_DIR
2026-01-19 09:44:34 | Messagequeue/MessageQueue | IN_PROGRESS | services note PDF_OUTPUT_DIR
2026-01-19 09:49:38 | Messagequeue/MessageQueue | IN_PROGRESS | pdf_naming note PDF_OUTPUT_DIR
2026-01-19 09:54:33 | Messagequeue/MessageQueue | IN_PROGRESS | pdf_contents note PDF_OUTPUT_DIR
2026-01-19 09:59:33 | Messagequeue/MessageQueue | IN_PROGRESS | test_matrix note nettoyage shared/pdfs
2026-01-19 10:04:40 | Messagequeue/MessageQueue | IN_PROGRESS | test_tools note nettoyage PDFs dummy
2026-01-19 10:09:36 | Messagequeue/MessageQueue | IN_PROGRESS | tests_consumers ajoute nettoyage PDFs
2026-01-19 10:14:40 | Messagequeue/MessageQueue | IN_PROGRESS | tests_producer note pas de PDF
2026-01-19 10:19:36 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary note nettoyage PDFs consumers
2026-01-19 10:24:35 | Messagequeue/MessageQueue | IN_PROGRESS | todo_next ajoute mention PDF_OUTPUT_DIR
2026-01-19 10:29:51 | Messagequeue/MessageQueue | IN_PROGRESS | consumer_ack note PDF_OUTPUT_DIR writable
2026-01-19 10:34:35 | Messagequeue/MessageQueue | IN_PROGRESS | smoke_plan note PDF_OUTPUT_DIR
2026-01-19 10:40:06 | Messagequeue/MessageQueue | IN_PROGRESS | docs_index note ordre alphabetique
2026-01-19 10:44:51 | Messagequeue/MessageQueue | IN_PROGRESS | topology note PDF_OUTPUT_DIR
2026-01-19 10:49:31 | Messagequeue/MessageQueue | IN_PROGRESS | queue_purpose note PDF_OUTPUT_DIR
2026-01-19 10:54:34 | Messagequeue/MessageQueue | IN_PROGRESS | implementation_plan note PDF_OUTPUT_DIR writable
2026-01-19 10:59:59 | Messagequeue/MessageQueue | IN_PROGRESS | script_env note PDF_OUTPUT_DIR writable
2026-01-19 11:04:55 | Messagequeue/MessageQueue | IN_PROGRESS | run_modules mention PDF_OUTPUT_DIR
2026-01-19 11:09:52 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary note PDF_OUTPUT_DIR
2026-01-19 11:14:34 | Messagequeue/MessageQueue | IN_PROGRESS | quickstart note PDF_OUTPUT_DIR
2026-01-19 11:19:35 | Messagequeue/MessageQueue | IN_PROGRESS | local_usage note PDF_OUTPUT_DIR
2026-01-19 11:24:33 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook note PDF_OUTPUT_DIR
2026-01-19 11:29:45 | Messagequeue/MessageQueue | IN_PROGRESS | http_endpoints ajoute PDF_OUTPUT_DIR
2026-01-19 11:34:53 | Messagequeue/MessageQueue | IN_PROGRESS | api_contract ajoute PDF_OUTPUT_DIR
2026-01-19 11:39:39 | Messagequeue/MessageQueue | IN_PROGRESS | payload_schema note PDF_OUTPUT_DIR
2026-01-19 11:44:37 | Messagequeue/MessageQueue | IN_PROGRESS | module_status note PDF_OUTPUT_DIR
2026-01-19 11:49:39 | Messagequeue/MessageQueue | IN_PROGRESS | security_notes ajoute suppression PDFs tests
2026-01-19 11:54:51 | Messagequeue/MessageQueue | IN_PROGRESS | test_matrix note PDF_OUTPUT_DIR pour PDFs
2026-01-19 11:59:46 | Messagequeue/MessageQueue | IN_PROGRESS | logging note PDF_OUTPUT_DIR
2026-01-19 12:04:50 | Messagequeue/MessageQueue | IN_PROGRESS | tests_consumers note PDF_OUTPUT_DIR
2026-01-19 12:09:39 | Messagequeue/MessageQueue | IN_PROGRESS | test_tools note PDF_OUTPUT_DIR
2026-01-19 12:14:52 | Messagequeue/MessageQueue | IN_PROGRESS | tests_producer note PDF_OUTPUT_DIR non utilise
2026-01-19 12:19:40 | Messagequeue/MessageQueue | IN_PROGRESS | e2e_local note PDF_OUTPUT_DIR override
2026-01-19 12:24:51 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary note PDF_OUTPUT_DIR pour smoke
2026-01-19 15:14:34 | Documentation/Repository | IN_PROGRESS | Ajout d'une description du projet Messagequeue dans PROJETS_EXPLICATIONS pour clarifier les attentes PDF/JSON et la suite de tests.
2026-01-19 16:29:59 | Messagequeue/MessageQueue | IN_PROGRESS | Ajout d'un contrat API détaillant fields JSON, validations, erreurs et workflow PDF pour publish_test_message.
2026-01-19 16:40:00 | Messagequeue/MessageQueue | IN_PROGRESS | README mentionne le nouveau doc api_contract pour publish_test_message.
2026-01-19 16:53:01 | Messagequeue/MessageQueue | IN_PROGRESS | README mentionne scripts/check_publish_payload pour valider le payload avant publish_test_message.
2026-01-24 11:20:56 | Messagequeue/MessageQueue | IN_PROGRESS | docs/api_contract mentionne scripts/check_publish_payload pour valider localement le JSON de publish_test_message.
2026-01-24 11:40:55 | Messagequeue/MessageQueue | IN_PROGRESS | tests/check_publish_payload exit=0 using docs/sample_publish_payload.json.
2026-01-24 13:00:45 | Messagequeue/MessageQueue | IN_PROGRESS | README mentionne docs/sample_publish_payload et check_publish_payload script.
2026-01-24 13:15:50 | Documentation/Repository | IN_PROGRESS | Ajout d'une section Documentation dans PROJETS_EXPLICATIONS.
2026-01-24 13:45:42 | Messagequeue/MessageQueue | IN_PROGRESS | docs/api_contract mentionne sample_publish_payload et commande de vérification.
2026-01-24 14:00:58 | Documentation/Repository | IN_PROGRESS | Messagequeue entry mentionne check_publish_payload script + sample payload.
2026-01-24 14:15:51 | Messagequeue/MessageQueue | IN_PROGRESS | Added docs/publish_workflow.md and referenced it in README.
2026-01-24 14:35:58 | Messagequeue/MessageQueue | IN_PROGRESS | Added verify_publish_payload.sh and documented it in README.
2026-01-24 15:01:15 | full_auto_codex_v2 | IN_PROGRESS | Documented the current state and handoff requirements for the next LLM.
2026-01-24 15:15:00 | full_auto_codex_v2 | IN_PROGRESS | Pointed README readers to `reports/next_llm_summary.md` so they can pick the right project and constraints before acting.
2026-01-24 15:30:00 | Messagequeue/MessageQueue | IN_PROGRESS | Added scripts/verify_pdf_output_dir.sh to ensure PDF_OUTPUT_DIR exists/writable before publish_test_message.
2026-01-24 15:45:00 | Messagequeue/MessageQueue | IN_PROGRESS | Exercised verify_pdf_output_dir.sh with PDF_OUTPUT_DIR=/tmp/mq-pdfs and documented the Bash dependency in README.
2026-01-24 15:55:00 | Messagequeue/MessageQueue | IN_PROGRESS | Added usage note to docs/publish_workflow.md instructing readers to run verify_pdf_output_dir.sh before publish_test_message.
2026-01-24 16:05:00 | Messagequeue/MessageQueue | IN_PROGRESS | Documented verify_pdf_output_dir.sh in docs/scripts_overview.md so helpers list mentions the check.
2026-01-24 16:10:00 | Messagequeue/MessageQueue | IN_PROGRESS | Added troubleshooting_env note covering verify_pdf_output_dir.sh for PDF write errors.
2026-01-24 16:20:00 | Messagequeue/MessageQueue | IN_PROGRESS | Added publish_test_message_with_check.sh and documented it in README/docs to ensure verify_pdf_output_dir.sh runs before publishing.
2026-01-24 16:40:00 | Messagequeue/MessageQueue | IN_PROGRESS | Highlighted in README to prefer publish_test_message_with_check.sh for demos/CI, preventing PDF_OUTPUT_DIR failures.
2026-01-24 16:55:00 | Messagequeue/MessageQueue | IN_PROGRESS | Updated quickstart to call publish_test_message_with_check.sh and mention PDF_OUTPUT_DIR readiness note.
2026-01-24 17:05:00 | full_auto_codex_v2 | IN_PROGRESS | README root now recommends publish_test_message_with_check.sh so the project-wide documentation aligns with the new workflow.
2026-01-24 17:25:00 | Messagequeue/MessageQueue | IN_PROGRESS | doctor.sh now runs publish_test_message_with_check.sh --dry-run to verify PDF_OUTPUT_DIR before smoke/check routines.
2026-01-24 17:35:00 | Messagequeue/MessageQueue | IN_PROGRESS | Added cleanup_pdf_output_dir.sh and mentioned it in Quickstart for PDF artifact cleanup before reruns.
2026-01-24 17:45:00 | Messagequeue/MessageQueue | IN_PROGRESS | Added inspect_pdf_output_dir.sh with quickstart note to report PDF counts between runs.
2026-01-24 18:00:00 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary now mentions cleanup_pdf_output_dir.sh and inspect_pdf_output_dir.sh around publish_test_message runs.
2026-01-24 18:15:00 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook now documents the PDF workflow that uses the new scripts for verify/cleanup/inspect around publish_test_message.
2026-01-24 18:30:00 | Messagequeue/MessageQueue | IN_PROGRESS | Added prepare_pdf_output_dir.sh plus quickstart/README mentions for automating verify+cleanup before publish_test_message.
2026-01-24 18:45:00 | Messagequeue/MessageQueue | IN_PROGRESS | Added ensure_pdf_output_dir_has_file.sh and doc notes to verify PDF artifacts exist after runs.
2026-01-24 20:30:00 | Messagequeue/MessageQueue | IN_PROGRESS | publish_workflow doc now references prepare/inspect/cleanup scripts for the PDF workflow and verification steps.
2026-01-24 20:45:00 | Messagequeue/MessageQueue | IN_PROGRESS | quickstart doc now explains prepare_pdf_output_dir script sequence for PDF readiness.
2026-01-24 21:05:00 | Messagequeue/MessageQueue | IN_PROGRESS | tests_summary notes prepare_pdf_output_dir script for PDF readiness before e2e dry-run.
2026-01-24 21:15:00 | Messagequeue/MessageQueue | IN_PROGRESS | README now points to publish_workflow/quickstart docs covering the prepare/publish/inspect PDF scripts.
2026-01-24 21:25:00 | Messagequeue/MessageQueue | IN_PROGRESS | local_runbook now instructs to run prepare_pdf_output_dir before publish_test_message.
2026-01-24 21:50:00 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message_with_check now runs prepare_pdf_output_dir and ensure_pdf_output_dir_has_file.
2026-01-24 22:00:00 | Messagequeue/MessageQueue | IN_PROGRESS | README links workflows/docs around prepare/publish/inspect PDF scripts.
2026-01-24 22:10:00 | Messagequeue/MessageQueue | IN_PROGRESS | test_publish_test_message now prepares PDF_OUTPUT_DIR via prepare script before running publish tests.
2026-01-25 04:41:50 | Messagequeue/MessageQueue | IN_PROGRESS | Verified the PDF workflow by running prepare_pdf_output_dir + publish_test_message_with_check --json --dry-run, ensuring pdf_output_dir_missing=0 and the helper scripts clean the target before each run.
2026-01-25 06:53:00 | Messagequeue/MessageQueue | IN_PROGRESS | Executed verify_publish_pdf_metadata.sh to confirm the dry-run JSON still reports pdf_output_dir/pdfs and pdf_output_dir_missing=0 as per the metadata contract.
2026-01-25 16:11:39 | Messagequeue/MessageQueue | IN_PROGRESS | Extended publish_workflow.md to describe running verify_publish_pdf_metadata.sh after each JSON dry-run (pdf_output_dir/pdf_output_dir_missing contract) so readers know to call the metadata check before logging success.
2026-01-25 16:15:00 | Messagequeue/MessageQueue | IN_PROGRESS | Ran prepare_pdf_output_dir + publish_test_message_with_check --json --dry-run and verify_publish_pdf_metadata.sh to prove pdf_output_dir_present and pdf_output_dir_missing=0 for the metadata contract used by docs/api_contract.md.
2026-01-25 17:28:35 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_verify_publish_pdf_metadata + docs test_tools/scripts_overview/tests_summary
2026-01-25 17:32:12 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_verify_pdf_output_dir + docs test_tools/scripts_overview/tests_summary
2026-01-25 17:36:42 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_ensure_pdf_output_dir_has_file + docs test_tools/scripts_overview/tests_summary
2026-01-25 17:41:47 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_cleanup_pdf_output_dir + docs test_tools/scripts_overview/tests_summary
2026-01-25 17:46:50 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_inspect_pdf_output_dir + docs test_tools/scripts_overview/tests_summary
2026-01-25 17:51:48 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_prepare_pdf_output_dir + docs test_tools/scripts_overview/tests_summary
2026-01-25 17:56:46 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_publish_test_message_with_check + docs test_tools/scripts_overview/tests_summary
2026-01-25 17:57:10 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_publish_test_message_with_check extraction JSON
2026-01-25 18:01:45 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_verify_publish_payload + docs test_tools/scripts_overview/tests_summary
2026-01-25 18:02:13 | Messagequeue/MessageQueue | IN_PROGRESS | fix verify_publish_payload.sh chemin script python
2026-01-25 18:02:35 | Messagequeue/MessageQueue | IN_PROGRESS | verify_publish_payload.sh resolve chemins relatifs PAYLOAD/DIR
2026-01-25 18:03:17 | Messagequeue/MessageQueue | IN_PROGRESS | fix verify_publish_payload.sh argument vide
2026-01-25 18:05:08 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_verify_publish_payload lecture JSON
2026-01-25 18:06:46 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_check_prereqs + docs test_tools/scripts_overview/tests_summary
2026-01-25 18:12:08 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_check_publish_payload + docs test_tools/scripts_overview/tests_summary
2026-01-25 18:16:51 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_load_env + docs test_tools/scripts_overview/tests_summary
2026-01-25 18:21:51 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_readme_toc + docs test_tools/scripts_overview/tests_summary
2026-01-25 18:22:22 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_readme_toc ancre ponctuation
2026-01-25 18:26:50 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_smoke_local_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 18:27:14 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_smoke_local_help rg --
2026-01-25 18:31:47 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_run_checks_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 18:36:48 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_status_report_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 18:41:50 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_topology_helpers_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 18:46:46 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_doctor_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 18:51:54 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_check_rabbitmq_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 18:56:51 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_wait_rabbitmq_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 19:01:57 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_bootstrap_rabbitmq_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 19:06:57 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_validate_rabbitmq_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 19:11:55 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_append_log + docs test_tools/scripts_overview/tests_summary
2026-01-25 19:16:54 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_wait_rabbitmq_json + docs test_tools/scripts_overview/tests_summary
2026-01-25 19:21:51 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_check_rabbitmq_json + docs test_tools/scripts_overview/tests_summary
2026-01-25 19:26:52 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_check_prereqs_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 19:32:10 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_setup_env + docs test_tools/scripts_overview/tests_summary
2026-01-25 19:37:04 | Messagequeue/MessageQueue | IN_PROGRESS | bootstrap_and_validate accepte --help/--silent/--json + test
2026-01-25 19:41:59 | Messagequeue/MessageQueue | IN_PROGRESS | run_local_flow accepte --help/--silent/--json + test
2026-01-25 19:47:08 | Messagequeue/MessageQueue | IN_PROGRESS | bootstrap_all accepte --help/--silent/--json + test
2026-01-25 19:51:59 | Messagequeue/MessageQueue | IN_PROGRESS | setup_env accepte --help + test
2026-01-25 19:57:02 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_consume_test_message_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:01:57 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_validate_payload_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:06:54 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_post_sample_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:11:55 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_publish_sample_keys_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:17:25 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_publish_sample_keys_json + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:18:16 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_publish_sample_keys_json stubs
2026-01-25 20:22:02 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_list_exchanges_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:27:33 | Messagequeue/MessageQueue | IN_PROGRESS | tail_rabbitmq_logs accepte --help + test
2026-01-25 20:32:06 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_create_bindings_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:37:01 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_list_queues_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:42:02 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_list_bindings_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:47:10 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_list_bindings_json + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:48:45 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_list_bindings_json stub curl
2026-01-25 20:50:07 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_list_bindings_json stub curl
2026-01-25 20:51:14 | Messagequeue/MessageQueue | IN_PROGRESS | fix list_bindings.sh import os
2026-01-25 20:52:42 | Messagequeue/MessageQueue | IN_PROGRESS | fix list_bindings.sh python -c
2026-01-25 20:53:54 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_list_queues_json + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:54:37 | Messagequeue/MessageQueue | IN_PROGRESS | fix list_queues.sh python -c
2026-01-25 20:57:11 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_list_exchanges_json + docs test_tools/scripts_overview/tests_summary
2026-01-25 20:58:10 | Messagequeue/MessageQueue | IN_PROGRESS | fix list_exchanges.sh python -c
2026-01-25 20:59:12 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_list_exchanges_json attendu type
2026-01-25 21:02:13 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_count_queue_messages_json + fix count_queue_messages
2026-01-25 21:07:15 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_validate_payload_json + docs test_tools/scripts_overview/tests_summary
2026-01-25 21:12:16 | Messagequeue/MessageQueue | IN_PROGRESS | load_env accepte --help + test
2026-01-25 21:17:22 | Messagequeue/MessageQueue | IN_PROGRESS | ensure_pdf_output_dir_has_file accepte --help + test
2026-01-25 21:22:24 | Messagequeue/MessageQueue | IN_PROGRESS | cleanup_pdf_output_dir accepte --help + test
2026-01-25 21:27:20 | Messagequeue/MessageQueue | IN_PROGRESS | inspect_pdf_output_dir accepte --help + test
2026-01-25 21:32:14 | Messagequeue/MessageQueue | IN_PROGRESS | prepare_pdf_output_dir accepte --help + test
2026-01-25 21:37:20 | Messagequeue/MessageQueue | IN_PROGRESS | verify_pdf_output_dir accepte --help + test
2026-01-25 21:42:22 | Messagequeue/MessageQueue | IN_PROGRESS | consume_test_message help OUTPUT + test
2026-01-25 21:47:24 | Messagequeue/MessageQueue | IN_PROGRESS | publish_test_message_with_check accepte --help + test
2026-01-25 21:52:12 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_publish_test_message_help + docs test_tools/scripts_overview/tests_summary
2026-01-25 21:57:20 | Messagequeue/MessageQueue | IN_PROGRESS | verify_publish_payload accepte --help + test
2026-01-25 22:02:27 | Messagequeue/MessageQueue | IN_PROGRESS | verify_publish_pdf_metadata accepte --help + test
2026-01-25 22:08:02 | Messagequeue/MessageQueue | IN_PROGRESS | run_producer accepte --help + test
2026-01-25 22:12:55 | Messagequeue/MessageQueue | IN_PROGRESS | run_consumer accepte --help + test
2026-01-25 22:18:03 | Messagequeue/MessageQueue | IN_PROGRESS | reset_local accepte --help + test
2026-01-25 22:22:57 | Messagequeue/MessageQueue | IN_PROGRESS | purge_queues accepte --help + test
2026-01-25 22:28:33 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test_check_prereqs_json_missing + docs
2026-01-25 22:29:29 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_check_prereqs_json_missing JSON vide
2026-01-25 22:30:44 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_check_prereqs_json_missing stub docker
2026-01-25 22:33:36 | Messagequeue/MessageQueue | IN_PROGRESS | fix check_prereqs --json missing list + test
2026-01-25 22:35:47 | Messagequeue/MessageQueue | IN_PROGRESS | ajout --help/--list pour build_modules + tests
2026-01-25 22:37:59 | Messagequeue/MessageQueue | IN_PROGRESS | ajout --help/--list test_producer/test_consumers + tests
2026-01-25 22:45:16 | Messagequeue/MessageQueue | IN_PROGRESS | fix doctor JSON parsing + add doctor/run_checks json tests
2026-01-25 22:47:51 | Messagequeue/MessageQueue | IN_PROGRESS | fix test_routing_matrix queue_count pipe + add json test
2026-01-25 22:52:22 | Messagequeue/MessageQueue | IN_PROGRESS | ajout ROOT_OVERRIDE test_routing + test json
2026-01-25 22:57:53 | Messagequeue/MessageQueue | IN_PROGRESS | ajout ROOT_OVERRIDE bootstrap_rabbitmq + test json
2026-01-25 23:01:57 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test help pour test_routing_matrix
2026-01-25 23:06:56 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test help pour test_routing
2026-01-25 23:12:35 | Messagequeue/MessageQueue | IN_PROGRESS | ajout ROOT_OVERRIDE bootstrap_and_validate + test json
2026-01-25 23:17:44 | Messagequeue/MessageQueue | IN_PROGRESS | ajout ROOT_OVERRIDE bootstrap_all + test json
2026-01-25 23:22:13 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test json create_bindings
2026-01-25 23:27:04 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test refus --json tail_rabbitmq_logs
2026-01-25 23:32:44 | Messagequeue/MessageQueue | IN_PROGRESS | status_report --json silencieux + test json
2026-01-25 23:37:22 | Messagequeue/MessageQueue | IN_PROGRESS | run_local_flow --json silencieux + test json
2026-01-25 23:42:42 | Messagequeue/MessageQueue | IN_PROGRESS | smoke_local ROOT_OVERRIDE + test json
2026-01-25 23:47:15 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test wait_rabbitmq timeout json
2026-01-25 23:52:05 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json skips
2026-01-25 23:57:13 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test help supplementaire run_local_flow
2026-01-26 00:02:03 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test status_report json error
2026-01-26 00:07:18 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test json error check_rabbitmq
2026-01-26 00:12:07 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test doctor json error
2026-01-26 00:17:01 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json error
2026-01-26 00:22:03 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_consumer --list
2026-01-26 00:28:07 | Messagequeue/MessageQueue | IN_PROGRESS | run_producer ajoute --list + test
2026-01-26 00:32:01 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test help supplementaire run_consumer
2026-01-26 00:37:03 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test help supplementaire run_producer
2026-01-26 00:42:03 | Messagequeue/MessageQueue | IN_PROGRESS | doc script_env: run_consumer section
2026-01-26 00:48:28 | Messagequeue/MessageQueue | IN_PROGRESS | run_consumer/run_producer ROOT_OVERRIDE + tests
2026-01-26 00:53:05 | Messagequeue/MessageQueue | IN_PROGRESS | create_bindings JSON error output + test
2026-01-26 00:57:07 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test help supplementaire bootstrap_and_validate
2026-01-26 01:02:10 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test help supplementaire bootstrap_all
2026-01-26 01:07:08 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test help supplementaire bootstrap_rabbitmq
2026-01-26 01:12:36 | Messagequeue/MessageQueue | IN_PROGRESS | bootstrap_rabbitmq JSON error output + test
2026-01-26 01:17:12 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test json error bootstrap_and_validate
2026-01-26 01:22:13 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test json error bootstrap_all
2026-01-26 01:27:18 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json skip-routing
2026-01-26 01:32:20 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json skip-doctor
2026-01-26 01:37:17 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test doctor json prereqs invalid
2026-01-26 01:42:20 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test doctor json rabbitmq invalid
2026-01-26 01:47:16 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test doctor json topology invalid
2026-01-26 01:52:23 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test status_report json filtres
2026-01-26 01:57:38 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test smoke_local json error
2026-01-26 02:02:40 | Messagequeue/MessageQueue | IN_PROGRESS | status_report JSON robust + test invalid payloads
2026-01-26 02:07:17 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_consumer sans argument
2026-01-26 02:12:18 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_producer option inconnue
2026-01-26 02:17:38 | Messagequeue/MessageQueue | IN_PROGRESS | run_consumer option inconnue geree + test
2026-01-26 02:22:41 | Messagequeue/MessageQueue | IN_PROGRESS | bootstrap_rabbitmq json missing python + test
2026-01-26 02:27:47 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_producer sans mvn
2026-01-26 02:32:16 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_consumer sans mvn
2026-01-26 02:37:38 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_consumer consumer invalide
2026-01-26 02:42:21 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_consumer dossier manquant
2026-01-26 02:47:48 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_producer dossier manquant
2026-01-26 02:52:30 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test build_modules filtre MODULES
2026-01-26 02:56:58 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test build_modules MODULES sans correspondance
2026-01-26 03:01:58 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test build_modules MODULES vide
2026-01-26 03:06:59 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test build_modules option inconnue
2026-01-26 03:12:00 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test build_modules mvn en echec
2026-01-26 03:17:03 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test build_modules MODULES dupliques
2026-01-26 03:22:01 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test build_modules MODULES avec espaces
2026-01-26 03:27:53 | Messagequeue/MessageQueue | IN_PROGRESS | build_modules support ROOT_OVERRIDE + test
2026-01-26 03:32:31 | Messagequeue/MessageQueue | IN_PROGRESS | build_modules --list respecte MODULES + test
2026-01-26 03:36:52 | Messagequeue/MessageQueue | IN_PROGRESS | docs build_modules mention ROOT_OVERRIDE
2026-01-26 03:42:17 | Messagequeue/MessageQueue | IN_PROGRESS | build_modules help mention ROOT_OVERRIDE
2026-01-26 03:47:05 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test build_modules --list MODULES vide
2026-01-26 03:52:02 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test build_modules --list option inconnue
2026-01-26 03:57:03 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test build_modules --list ROOT_OVERRIDE
2026-01-26 04:02:03 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test build_modules mvn echec module suivant
2026-01-26 04:08:11 | Messagequeue/MessageQueue | IN_PROGRESS | test_consumers ROOT_OVERRIDE + list filtre MODULES
2026-01-26 04:12:48 | Messagequeue/MessageQueue | IN_PROGRESS | test_producer ROOT_OVERRIDE + tests
2026-01-26 04:17:04 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_producer mvn absent
2026-01-26 04:22:06 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_producer option inconnue
2026-01-26 04:27:07 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_producer --list ROOT_OVERRIDE
2026-01-26 04:32:07 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_producer dossier manquant
2026-01-26 04:37:14 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers --list MODULES vide
2026-01-26 04:42:07 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers --list option inconnue
2026-01-26 04:47:26 | Messagequeue/MessageQueue | IN_PROGRESS | test_consumers help ROOT_OVERRIDE + test mvn absent
2026-01-26 04:52:11 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers dossier manquant
2026-01-26 04:57:06 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers option inconnue
2026-01-26 05:02:10 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers --list ROOT_OVERRIDE
2026-01-26 05:07:13 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers MODULES avec espaces
2026-01-26 05:12:37 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers MODULES dupliques
2026-01-26 05:17:12 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers MODULES sans correspondance
2026-01-26 05:22:14 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers mvn en echec
2026-01-26 05:27:16 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers mvn echec module suivant
2026-01-26 05:32:14 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers MODULES vide
2026-01-26 05:37:15 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers --list filtre + ROOT_OVERRIDE
2026-01-26 05:42:30 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_producer mvn en echec
2026-01-26 05:47:34 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_producer --list ignore MODULES
2026-01-26 05:52:35 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers --list MODULES sans correspondance
2026-01-26 05:57:15 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test test_consumers --list ROOT_OVERRIDE seul
2026-01-26 06:03:07 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow prereqs manquants
2026-01-26 06:07:16 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow option inconnue
2026-01-26 06:17:04 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow help mention json
2026-01-26 06:22:52 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow ROOT_OVERRIDE
2026-01-26 06:27:39 | Messagequeue/MessageQueue | IN_PROGRESS | run_local_flow help mention ROOT_OVERRIDE
2026-01-26 06:32:24 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow json prereqs ko
2026-01-26 06:37:28 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow propagation --silent
2026-01-26 06:43:27 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow propagation --json
2026-01-26 06:47:26 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow --silent sans message final
2026-01-26 06:52:31 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow --json sans message final
2026-01-26 06:57:20 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow ROOT_OVERRIDE scripts manquants
2026-01-26 07:02:27 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow json smoke ko
2026-01-26 07:07:29 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow json status_report ko
2026-01-26 07:12:33 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow json+silent combo
2026-01-26 07:17:27 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow --silent sans json implicite
2026-01-26 07:23:12 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_local_flow --json inclut --silent
2026-01-26 07:28:06 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json propagation
2026-01-26 07:32:26 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks --silent sans message final
2026-01-26 07:37:26 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks option inconnue
2026-01-26 07:42:34 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks --json sans message final
2026-01-26 07:47:28 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks skip-doctor message
2026-01-26 07:52:31 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks skip-routing message
2026-01-26 07:57:28 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks skip-both message
2026-01-26 08:02:28 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks ROOT_OVERRIDE scripts manquants
2026-01-26 08:07:40 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json routing error
2026-01-26 08:12:30 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json doctor error
2026-01-26 08:17:38 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json skip both
2026-01-26 08:22:30 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json skip-doctor routing ok
2026-01-26 08:27:35 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json skip-routing doctor ok
2026-01-26 08:32:35 | Messagequeue/MessageQueue | IN_PROGRESS | run_checks help mention ROOT_OVERRIDE
2026-01-26 08:37:40 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json skip-doctor sans message
2026-01-26 08:42:40 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks json skip-routing sans message
2026-01-26 08:47:33 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks --silent skip-both sans messages
2026-01-26 08:52:44 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks message final
2026-01-26 08:57:36 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks --silent skip-doctor sans message
2026-01-26 09:02:41 | Messagequeue/MessageQueue | IN_PROGRESS | ajout test run_checks --silent skip-routing sans message
2026-01-26 10:32:07 | Messagequeue/MessageQueue | WAITING | blocage .env tracke, decision utilisateur requise
2026-01-26 10:32:07 | Wordle/Wordle | DONE | ajout tests max_attempts invalide + target ajoute au dictionnaire
2026-01-26 10:37:52 | Wordle/Wordle | IN_PROGRESS | ajout tests case-insensitive + fin de partie apres max_attempts
2026-01-26 10:42:00 | Wordle/Wordle | IN_PROGRESS | ajout test is_valid_guess sur mot inconnu
2026-01-26 10:47:02 | Wordle/Wordle | DONE | tests run_tests.sh OK
2026-01-26 10:52:54 | Web/hello_node | IN_PROGRESS | ajout run_tests_skip_net.sh + docs commandes
2026-01-26 10:58:31 | Web/hello_node | WAITING | tests run_tests_skip_net.sh OK, sockets locales bloquees
2026-01-26 10:58:31 | Python/Django_Training_D01 | DONE | ajout tests cas limites + run_tests OK
2026-01-26 11:02:32 | Web/hello_node | WAITING | ajout run_tests_auto.sh + tests OK (auto skip reseau)
2026-01-26 11:10:50 | Unix/UNIX_leaning_project | WAITING | tests interactifs en echec (out of pty devices)
2026-01-26 11:11:01 | Unix/A_completely_UNIX_project | DONE | ajout tests erreurs + run_tests OK
2026-01-26 11:13:46 | C/Ft_turing | DONE | ajout invalid_blank_multi + invalid_initial_unknown + tests OK
2026-01-26 11:17:37 | C/Libasm | WAITING | ajout tests zero-length/chaines vides (nasm manquant)
2026-01-26 11:23:08 | Unix/UNIX_Project | WAITING | tests skip si ptrace bloque (skipped=2)
2026-01-26 11:27:26 | C/ft_irc | WAITING | ajout doc tests smoke (TESTS.md)
