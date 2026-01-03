# Ordonnancement LFS (système de base)

Inspiré de LFS 12.x, à adapter selon versions retenues. Chaque build se fait en chroot avec toolchain prête.

Ce document indique l'ordre LFS. Le script `scripts/build_system.sh` peut aussi lire
le manifest `configs/build_system_manifest.tsv` pour enchaîner des paquets ciblés.
`scripts/build_system.sh --resume` relit `work/build_system.state` pour reprendre un build interrompu (override via `--state`/`--manifest`).
`scripts/build_system.sh --status` affiche les paquets restants; `--reset-state` purge l'etat.
`scripts/build_system.sh --from <pkg> --until <pkg>` limite la plage de build.
`scripts/build_system.sh --check` execute `make check` (log `logs/system/*.check.log`), `--check-allow-fail` ignore les tests en echec.
Utilisez `scripts/verify_manifest.sh` pour valider que les tarballs existent avant l'execution.
Le script `scripts/preflight.sh` combine un check environnement/toolchain + manifest avant le build.
Le script `scripts/status_report.sh` produit un recapitulatif des logs et de l'etat des tarballs (TXT + CSV).
Le manifest inclut coreutils/bash/procps-ng + utilitaires (diffutils, findutils, grep, gzip, make, patch, tar, texinfo, util-linux) pour un chainage minimal.
Le script `scripts/missing_tarballs.sh` liste les archives manquantes a partir de `docs/checksums.md`.
Le script `scripts/manifest_report.sh` genere `reports/manifest_sources.txt/.csv` pour les paquets du manifest.
Le script `scripts/build_state_report.sh` genere `reports/build_state.txt/.csv` (etat manifests vs state).
Le script `scripts/validate_build_state.sh` genere `reports/build_state_validation.txt/.csv` (doublons/entrees inconnues).
Le script `scripts/build_state_sync.sh` genere `reports/build_state_sync.txt/.csv` (synchronisation logs -> state, option `--apply`).
Le script `scripts/build_log_audit.sh` genere `reports/build_log_audit.txt/.csv` (etat logs vs state).
Le script `scripts/manifest_coverage.sh` genere `reports/manifest_coverage.txt/.csv` (couverture manifests vs logs).
Le script `scripts/validate_manifests.sh` detecte aussi les doublons intra/entre manifests.
Le script `scripts/build_plan.sh` genere `reports/build_plan.sh/.txt` (liste de commandes a executer).
`scripts/build_plan.sh --with-check` ajoute `--check` aux commandes, `--check-allow-fail` ignore les tests en echec.
Le script `scripts/build_queue.sh` execute un plan de build avec reprise (`reports/build_queue.txt`).
`scripts/build_queue.sh` genere aussi `reports/build_queue.csv` et `reports/build_queue_summary.txt`.
`scripts/build_queue.sh --status` genere `reports/build_queue_status.txt`.
`scripts/run_reports.sh` genere `reports/build_queue_status.txt` automatiquement.
Le script `scripts/validate_build_plan.sh` genere `reports/build_plan_validation.txt/.csv` (validation du plan).
Le script `scripts/build_queue_retry.sh` relance la derniere commande en echec (`reports/build_queue_retry.txt`).
Le script `scripts/build_queue_retry_report.sh` genere `reports/build_queue_retry_report.txt` (etat du retry).
Le script `scripts/build_queue_sync_states.sh` synchronise build_queue.state -> states packages (`reports/build_queue_sync.txt/.csv`).
`scripts/build_queue.sh --timeout <sec>` arrete une commande trop longue (status timeout dans CSV).
`scripts/build_queue.sh --continue-on-fail` continue apres erreur (result warn dans summary).
Le script `scripts/build_queue_metrics.sh` genere `reports/build_queue_metrics.txt` (stats build_queue.csv).
Le script `scripts/validate_build_queue_state.sh` valide build_queue.state vs plan (`reports/build_queue_state_validation.txt/.csv`).
Le script `scripts/build_queue_failures.sh` genere `reports/build_queue_failures.txt` (echecs/timeout).
Le script `scripts/build_queue_report.sh` inclut maintenant `build_queue_failures`.
Le script `scripts/build_queue_report.sh` agrege les rapports build_queue (`reports/build_queue_report.txt`).
Le script `scripts/build_state_snapshot.sh` snapshot les states (`reports/build_state_snapshot.txt`, `reports/state_snapshots/`).
Le script `scripts/build_state_diff.sh` compare deux snapshots (`reports/build_state_diff.txt`).
Le script `scripts/build_state_list.sh` liste les snapshots (`reports/build_state_snapshots.txt`).
Le script `scripts/build_state_prune.sh` purge les anciens snapshots (`reports/build_state_prune.txt`, `--dry-run` supporte).
Le script `scripts/build_dashboard.sh` genere un tableau de bord (`reports/build_dashboard.txt`).
Le script `scripts/build_plan_split.sh` decoupe le plan (`reports/build_plan_splits.txt`, `reports/build_plan_splits/`).
Le script `scripts/build_plan_remaining.sh` liste les commandes restantes (`reports/build_plan_remaining.txt`).
Le script `scripts/build_orchestrator.sh` orchestre plan/split/queue/sync/reports (`reports/build_orchestrator.txt` + JSON).
Options `--plan-check` / `--plan-check-allow-fail` pour propager les tests au plan.
Le script `scripts/build_orchestrator_report.sh` genere `reports/build_orchestrator_report.txt`.
Le script `scripts/build_orchestrator_status.sh` genere `reports/build_orchestrator_status.txt`.
Le script `scripts/build_orchestrator_validate.sh` genere `reports/build_orchestrator_validation.txt`.
Le script `scripts/build_session.sh` enchaine gate + orchestrator + reports (`reports/build_session.txt/.json`).
Option `--allow-check-warn` pour relacher le gate checks depuis build_session.
Options `--check-max-*` pour propager les seuils vers build_gate/build_check_gate.
Le script `scripts/build_health_report.sh` genere `reports/build_health_report.txt` (synthese sante).
Le script `scripts/build_gate.sh` genere `reports/build_gate.txt`/`build_gate.json` (gate pre-build).
`scripts/run_reports.sh` inclut aussi `build_gate.sh` et `build_health_report.sh`.
Le script `scripts/build_summary_json.sh` genere `reports/build_summary.json`.
Le script `scripts/build_summary_validate.sh` genere `reports/build_summary_validate.txt`.
Le script `scripts/build_progress_report.sh` genere `reports/build_progress.txt` (resume du build).
Le script `scripts/build_progress_rollup.sh` genere `reports/build_progress_rollup.txt` (synthese par groupe).
Le script `scripts/build_progress_failures.sh` genere `reports/build_progress_failures.txt` (derniers echec par paquet).
Le script `scripts/build_times_report.sh` genere `reports/build_times.txt` (temps de build).
Le script `scripts/build_check_report.sh` genere `reports/build_check_report.txt` (tests make check, `--strict` marque fail_ignored).
Les scripts build ecrivent `reports/build_check_status.csv` quand `--check` est actif (resultats par paquet).
Le script `scripts/build_check_status_report.sh` genere `reports/build_check_status_report.txt` (dernier statut par paquet).
Le script `scripts/build_check_status_rollup.sh` genere `reports/build_check_status_rollup.txt` (resume par groupe).
Le script `scripts/build_check_trend.sh` genere `reports/build_check_trend.txt` (historique par jour).
Le script `scripts/build_check_prune.sh` genere `reports/build_check_prune.txt` (purge CSV, `--apply`).
Le script `scripts/build_check_stats.sh` genere `reports/build_check_stats.txt` (stats par groupe).
Le script `scripts/build_check_summary_json.sh` genere `reports/build_check_summary.json`.
Le script `scripts/build_check_summary_validate.sh` genere `reports/build_check_summary_validate.txt`.
Le script `scripts/build_check_export_csv.sh` genere `reports/build_check_export.csv`.
Le script `scripts/build_check_coverage.sh` genere `reports/build_check_coverage.txt` (couverture checks vs manifest).
Le script `scripts/build_check_snapshot.sh` genere un snapshot CSV (`reports/build_check_snapshot.txt`).
Le script `scripts/build_check_snapshot_list.sh` liste les snapshots (`reports/build_check_snapshot_list.txt`).
Le script `scripts/build_check_snapshot_prune.sh` purge les anciens snapshots (`reports/build_check_snapshot_prune.txt`).
Le script `scripts/build_check_snapshot_diff.sh` compare deux snapshots (`reports/build_check_snapshot_diff.txt`).
Le script `scripts/build_check_gate.sh` genere `reports/build_check_gate.txt`/`.json` (gate checks, seuils `--max-*` dont severite).
Le fichier `configs/check_gate.conf` fournit des seuils par defaut pour build_check_gate.
Le script `scripts/build_gate.sh` integre maintenant build_check_gate (niveau global, `--allow-check-warn`).
Le script `scripts/generate_downloads.sh` genere `reports/download_missing.sh` pour telecharger les archives manquantes.
Le script `scripts/verify_checksums.sh` genere `reports/sha_report.txt/.csv` pour verifier les SHA locales.
Le script `scripts/env_audit.sh` genere `reports/env_audit.txt/.csv` pour lister les outils disponibles.

0. Initialiser la hiérarchie LFS (scripts/build_rootfs.sh + configs/rootfs_layout.tsv).
0.b. Bootstrap fichiers /etc (scripts/bootstrap_system.sh, fstab/hosts/passwd/group/hostname).
0.c. Squelette SysV init (scripts/install_sysvinit_skeleton.sh + configs/inittab.example).
0.d. Scripts init de base (scripts/install_init_scripts.sh: mountfs/syslog/network).
0.e. Verifier la structure rootfs (scripts/rootfs_report.sh).
0.f. Activer les services SysV (scripts/enable_services.sh + configs/services_manifest.tsv).
0.f.b. Verifier les services SysV (scripts/validate_services.sh).
0.g. Valider les manifests (scripts/validate_manifests.sh) avant build.
0.g.b. Le rapport `reports/manifest_report.txt` est genere par validate_manifests.sh.
0.h. Check boot prerequis (scripts/boot_checklist.sh).
0.i. Verifier fstab (scripts/validate_fstab.sh).
0.j. Creer noeuds /dev minimaux (scripts/create_dev_nodes.sh).
0.k. Installer configs systeme (/etc/nsswitch.conf, sysctl.conf) via scripts/install_system_configs.sh.
0.k.b. Raccourci : `scripts/bootstrap_all.sh` enchaine rootfs + /etc + sysv + services (+ devnodes si root).
0.k.c. Synthese rapports : `scripts/summary_report.sh` (rootfs/fstab/boot/prereqs).
0.k.d. Installer grub.cfg : `scripts/ensure_grub_cfg.sh`.
0.k.e. Valider grub.cfg : `scripts/validate_grub_cfg.sh`.
0.k.f. Rapporter le partitionnement : `scripts/partition_report.sh`.
1. man-pages
1.b. Paquets intermediaires via `scripts/build_mini_system.sh list` + `configs/mini_system_manifest.tsv` (colonne build_type).
     Resume possible avec `scripts/build_mini_system.sh --resume` (state `work/mini_system.state`).
     `scripts/build_mini_system.sh --status` liste les paquets restants; `--reset-state` purge l'etat.
     `scripts/build_mini_system.sh --from <pkg> --until <pkg>` limite la plage de build.
     `scripts/build_mini_system.sh --check` execute `make check`, `--check-allow-fail` ignore les tests en echec.
2. iana-etc
3. glibc (final)
4. zlib
5. bzip2
6. xz
7. zstd
8. file
9. readline
10. m4
11. bc
12. flex
13. tcl, expect, dejagnu (pour tests gcc)
14. binutils (final)
15. gmp, mpfr, mpc
16. attr, acl, libcap
17. shadow
18. gcc (final)
19. pkg-config-lite
20. ncurses
21. coreutils
22. diffutils
23. gawk
24. findutils
25. grep
26. gzip
27. make
28. patch
29. tar
30. texinfo
31. vim
32. procps-ng
33. util-linux
34. eudev
35. kmod
36. sysvinit
37. e2fsprogs
38. less, iproute2, dhcpcd (réseau)
39. bash (si rebuild), cleanup /tmp, strip, logs.

Avant kernel : `scripts/build_kernel_config.sh` pour generer un .config de base (`--apply-reqs` possible).
Verifier config kernel : `scripts/validate_kernel_config.sh` + `configs/kernel_requirements.txt`.
Appliquer config kernel : `scripts/apply_kernel_requirements.sh`.
Ensuite : kernel 6.6.54 + initramfs + GRUB.
Initramfs : `scripts/build_initramfs.sh` avec `configs/initramfs_manifest.tsv` + `configs/initramfs_modules.txt` (`--install-boot` pour /boot, `--use-generated` si manifest genere, `--generate` pour le creer).
Generer manifest initramfs : `scripts/generate_initramfs_manifest.sh` + `configs/initramfs_bins.txt`.
Verifier initramfs : `scripts/validate_initramfs.sh`.
Raccourci boot : `scripts/boot_bundle.sh` (kernel + initramfs + grub).
Installer artefacts /boot : `scripts/boot_artifacts.sh` (kernel/initramfs/grub).
Installer GRUB sur le disque : `scripts/grub_install.sh` (root requis).
Detecter BIOS/UEFI : `scripts/detect_boot_mode.sh` (rapport dans reports/boot_mode.txt).
Demarrer la VM : `scripts/run_vm.sh` (qemu, BIOS/UEFI).
Finaliser le boot : `scripts/boot_finalize.sh` (grub.cfg + install + checks).
Packaging rootfs : `scripts/package_rootfs.sh` (tar.gz + checksum).
Rapport release : `scripts/release_report.sh`.
Rapports complets : `scripts/run_reports.sh` (genere tous les rapports).
Archiver rapports/logs : `scripts/archive_reports.sh` (bundle + checksum).
Pipeline complet : `scripts/full_pipeline.sh` (preflight -> build -> boot -> reports).
