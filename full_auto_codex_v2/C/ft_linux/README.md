# ft_linux

Statut : IN_PROGRESS

Derniere mise a jour : 2026-01-03 15:49:37

## Validation toolchain
Le script `scripts/validate_toolchain.sh` verifie la presence des outils cross (`$LFS/tools/bin`), des headers et de `libgcc`. Il permet de confirmer rapidement que l'ordre de build est coherent avant le chroot.

## Sources
`scripts/download_sources.sh` accepte `--verify-only` pour verifier les tarballs sans telecharger, `--list` pour afficher les URLs, et `--from <dir>` pour copier depuis un depot local.
Le script `scripts/missing_tarballs.sh` genere `reports/missing_tarballs.txt` et `reports/missing_tarballs.csv` avec les archives manquantes.
Le script `scripts/manifest_report.sh` genere `reports/manifest_sources.txt` et `reports/manifest_sources.csv` pour partager les URLs/sha du manifest.
Le script `scripts/generate_downloads.sh` genere `reports/download_missing.sh` (liste de curl) pour telecharger les archives manquantes.
Le script `scripts/verify_checksums.sh` genere `reports/sha_report.txt` et `reports/sha_report.csv` pour verifier les SHA locales.
Le script `scripts/report_index.sh` genere `reports/index.md` pour centraliser les rapports.
`scripts/quickcheck.sh` a ete execute : toolchain incomplète (cross gcc/ld/as manquants) et 9 tarballs manquants dans `sources/`.
Le script `scripts/env_audit.sh` genere `reports/env_audit.txt` et `reports/env_audit.csv` (outils disponibles).

## Build system (manifest)
Le script `scripts/build_system.sh` lit `configs/build_system_manifest.tsv` pour enchaîner des paquets de base dans l'ordre defini (coreutils, bash, procps-ng, diffutils, findutils, grep, gzip, make, patch, tar, texinfo, util-linux).
Utilisez `scripts/build_system.sh list` pour voir la liste et `--dry-run` pour afficher les commandes sans construire.
Option `--resume` disponible (state par defaut `work/build_system.state`, override via `--state`).
Options `--status` et `--reset-state` pour inspecter/vider l'etat de build.
Options `--from <pkg>` et `--until <pkg>` pour executer une plage du manifest.
Options `--check` et `--check-allow-fail` pour executer/ignorer les tests `make check`.
Le script `scripts/verify_manifest.sh` valide la presence des tarballs requis avant execution.
Le script `scripts/preflight.sh` combine environnement, validation toolchain et manifest pour un check complet.
Le script `scripts/setup_env.sh` dispose maintenant d'actions (create/partition/attach/format/mount/umount/detach/fstab) pour piloter l'image disque.
Le script `scripts/quickcheck.sh` enchaîne validate_toolchain + verify_manifest + list manifest.
Le script `scripts/status_report.sh` genere `reports/build_status.txt` et `reports/build_status.csv` avec un resume des logs et des tarballs.
Le dernier rapport genere se trouve dans `reports/build_status.txt` et `reports/build_status.csv`.
Le script `scripts/build_state_report.sh` genere `reports/build_state.txt` et `reports/build_state.csv` (etat de reprise manifests).
Le script `scripts/validate_build_state.sh` genere `reports/build_state_validation.txt` et `reports/build_state_validation.csv` (doublons/entrees inconnues).
Le script `scripts/build_state_sync.sh` genere `reports/build_state_sync.txt` et `reports/build_state_sync.csv` (scan logs, option `--apply`).
Le script `scripts/build_log_audit.sh` genere `reports/build_log_audit.txt` et `reports/build_log_audit.csv` (coherence logs/state).
Le script `scripts/manifest_coverage.sh` genere `reports/manifest_coverage.txt` et `reports/manifest_coverage.csv` (couverture manifests/logs).

## Journal de build
Utilisez `scripts/log_build.sh` pour ajouter des notes horodatées dans `docs/build_log.md` (sections toolchain/system/kernel/bootloader/network/image).

## Synthèse préliminaire
Objectif : construire une distribution Linux minimale et fonctionnelle, utilisée comme base pour les projets kernel ultérieurs. Il faut compiler un noyau >= 4.0 personnalisé (avec login dans la version), configurer partitions (root, /boot, swap), intégrer un bootloader (GRUB/LILO), un gestionnaire de services (SysV ou systemd/elogind), un loader de modules (udev/eudev) et installer la panoplie d’outils de base (liste fournie). L’image doit se connecter au réseau et respecter une hiérarchie FS cohérente.

## Décisions actuelles
- Architecture : x86_64, disque 20 Go GPT (boot/EFI 512 MiB, swap 2 GiB, root ext4).
- Versions : cf. `docs/versions.md` (kernel 6.6.54 LTS, binutils 2.43.1, gcc 13.2.0, glibc 2.40, sysvinit 3.10, eudev 3.2.14, etc.).
- Hyperviseur cible : VM (VirtualBox/virt-manager).

## Arborescence et scripts
- `docs/versions.md` : tableau des paquets retenus + URLs.
- `docs/partitions.md` : schéma GPT 20 Go.
- `scripts/setup_env.sh` : crée l’image RAW, rappelle le partitionnement (sfdisk), la création des FS et les points de montage.
- `scripts/build_toolchain.sh` : squelette binutils/gcc cross (logs dans `logs/toolchain`).
- `scripts/build_system.sh` : squelette build paquets de base (coreutils, bash, procps).
- `scripts/download_sources.sh` : télécharge les tarballs et vérifie les SHA issus de `docs/checksums.md`.
- `scripts/gen_checksums.sh` : calcule les SHA256 des tarballs déjà présents dans `sources/` (pour alimenter `docs/checksums.md`).
- `scripts/build_kernel.sh` : build kernel 6.6.54 en chroot ou vers `$LFS` (options `--config`, `--no-modules`, `--no-install`, logs dans `logs/kernel`).
- `scripts/build_rootfs.sh` : initialise l'arborescence LFS selon `configs/rootfs_layout.tsv` (dirs/symlinks/modes).
- `scripts/bootstrap_system.sh` : installe des fichiers /etc minimaux (fstab, hosts, passwd/group, hostname) et permissions.
- `scripts/install_sysvinit_skeleton.sh` : installe un squelette SysV init (`/etc/inittab`, `rcS`, `rc`, `rc.local`).
- `scripts/generate_grub_cfg.sh` : genere un `grub.cfg` basique a partir du kernel installe et du UUID root (ajoute initrd si present).
- `scripts/chroot_prepare.sh` : prepare /dev,/proc,/sys,/run pour le chroot (mount/umount/status).
- `scripts/chroot_enter.sh` : monte, entre en chroot, puis demon-te automatiquement.
- `scripts/install_init_scripts.sh` : installe des scripts init (mountfs/syslog/network) et liens runlevel.
- `scripts/rootfs_report.sh` : verifie la presence des dossiers/symlinks essentiels et genere un rapport.
- `scripts/enable_services.sh` : active/desactive les services SysV via `configs/services_manifest.tsv`.
- `scripts/build_mini_system.sh` : enchaine paquets intermediaires via `configs/mini_system_manifest.tsv`.
- `scripts/build_system.sh --resume` et `scripts/build_mini_system.sh --resume` reprennent un build interromptu (state dans `work/`).
- `scripts/build_system.sh --status/--reset-state` et `scripts/build_mini_system.sh --status/--reset-state` pilotent l'etat de reprise.
- `scripts/build_system.sh --from/--until` et `scripts/build_mini_system.sh --from/--until` executent une plage du manifest.
- `scripts/build_system.sh pkg <name>` permet d'executer un paquet specifique du manifest.
- Les manifests `configs/build_system_manifest.tsv` et `configs/mini_system_manifest.tsv` supportent un champ `build_type` (`autotools` ou `makeonly`).
- `scripts/build_system.sh list` et `scripts/build_mini_system.sh list` affichent le build_type.
- `scripts/validate_manifests.sh` controle les manifests (champs + build_type) et avertit sur les tarballs manquants.
- `scripts/boot_checklist.sh` verifie fstab/kernel/grub/inittab et produit un rapport boot.
- `scripts/boot_checklist.sh` gere l'absence de kernel avec un message explicite.
- `scripts/validate_fstab.sh` controle les entrees fstab et genere un rapport.
- `scripts/create_dev_nodes.sh` cree les noeuds /dev minimaux (null/zero/console/tty) dans $LFS.
- `scripts/install_system_configs.sh` installe `nsswitch.conf`, `sysctl.conf` et `profile.d/locale.sh` depuis `configs/system/`.
- `scripts/check_env_prereqs.sh` ajoute un rapport des prerequis host (gcc/make/bison/flex...).
- `scripts/host_requirements.md` liste les prerequis host verifiés.
- `scripts/bootstrap_all.sh` enchaine rootfs + /etc + sysv + services + devnodes (si root).
- `scripts/summary_report.sh` agrege les rapports rootfs/fstab/boot/prereqs en `reports/summary.md`.
- `scripts/ensure_grub_cfg.sh` installe le grub.cfg genere sous `$LFS/boot/grub/grub.cfg`.
- `scripts/validate_grub_cfg.sh` verifie la coherence grub.cfg (kernel + root UUID + initrd) et genere un rapport.
- `scripts/build_kernel_config.sh` genere un .config kernel de base (defconfig) dans `configs/` (option `--apply-reqs`).
- `scripts/build_kernel.sh` supporte `--print-release` pour afficher la version kernel.
- `scripts/build_initramfs.sh` genere un initramfs a partir de `configs/initramfs_manifest.tsv` et charge `configs/initramfs_modules.txt` (options `--install-boot`, `--use-generated`, `--generate`).
- `scripts/generate_initramfs_manifest.sh` genere un manifest initramfs depuis `configs/initramfs_bins.txt`.
- `scripts/validate_initramfs.sh` controle la presence des fichiers initramfs et genere un rapport.
- `scripts/package_rootfs.sh` cree une archive rootfs et un checksum.
- `scripts/package_rootfs.sh` affiche le succes meme si sha256sum est absent.
- `scripts/release_report.sh` genere un recap versions (docs/versions.md + manifests).
- `scripts/summary_report.sh` inclut maintenant le rapport release.
- `scripts/summary_report.sh` inclut les rapports grub/initramfs/boot.
- `scripts/validate_services.sh` controle les liens SysV actifs et genere un rapport.
- `scripts/summary_report.sh` inclut maintenant le rapport services.
- `scripts/build_state_report.sh` genere un recap des manifests vs states (`reports/build_state.txt/.csv`).
- `scripts/validate_build_state.sh` controle les doublons/entrees inconnues des states (`reports/build_state_validation.txt/.csv`).
- `scripts/build_state_sync.sh` propose de synchroniser les states depuis les logs (`reports/build_state_sync.txt/.csv`).
- `scripts/build_log_audit.sh` controle la coherence entre logs et state (`reports/build_log_audit.txt/.csv`).
- `scripts/manifest_coverage.sh` mesure la couverture manifests/logs (`reports/manifest_coverage.txt/.csv`).
- `scripts/assess_status.sh` inclut build_state/build_log/manifest_coverage.
- `scripts/validate_manifests.sh` detecte les doublons intra/entre manifests.
- `scripts/build_plan.sh` genere un plan de build (`reports/build_plan.sh/.txt`).
- `scripts/validate_build_plan.sh` verifie le plan (`reports/build_plan_validation.txt/.csv`).
- `scripts/build_queue.sh` execute un plan de build avec reprise (`reports/build_queue.txt/.csv` + `reports/build_queue_summary.txt`).
- `scripts/build_queue.sh --status` genere `reports/build_queue_status.txt`.
- `scripts/run_reports.sh` genere aussi `reports/build_queue_status.txt`.
- `scripts/build_queue_retry.sh` relance la derniere commande en echec (`reports/build_queue_retry.txt`).
- `scripts/build_queue_retry_report.sh` genere un etat de retry (`reports/build_queue_retry_report.txt`).
- `scripts/build_queue_sync_states.sh` synchronise build_queue.state vers les states packages (`reports/build_queue_sync.txt/.csv`).
- `scripts/build_queue.sh --timeout <sec>` arrete une commande trop longue (status timeout).
- `scripts/build_queue.sh --continue-on-fail` continue apres erreur (summary en warn).
- `scripts/build_queue_metrics.sh` genere des stats sur `reports/build_queue.csv` (`reports/build_queue_metrics.txt`).
- `scripts/validate_build_queue_state.sh` valide build_queue.state contre le plan (`reports/build_queue_state_validation.txt/.csv`).
- `scripts/build_queue_failures.sh` liste les echecs/timeout (`reports/build_queue_failures.txt`).
- `scripts/build_queue_report.sh` agrege les rapports build_queue (`reports/build_queue_report.txt`).
- `scripts/build_queue_report.sh` inclut maintenant `build_queue_failures`.
- `scripts/build_state_snapshot.sh` snapshot les states (`reports/build_state_snapshot.txt`, `reports/state_snapshots/`).
- `scripts/build_state_diff.sh` compare des snapshots (`reports/build_state_diff.txt`).
- `scripts/build_state_list.sh` liste les snapshots (`reports/build_state_snapshots.txt`).
- `scripts/build_state_prune.sh` purge les anciens snapshots (`reports/build_state_prune.txt`, `--dry-run` supporte).
- `scripts/build_dashboard.sh` genere un tableau de bord (`reports/build_dashboard.txt`, checks + stats inclus).
- `scripts/build_plan_split.sh` decoupe le plan (`reports/build_plan_splits.txt`, `reports/build_plan_splits/`).
- `scripts/build_plan_remaining.sh` liste les commandes restantes (`reports/build_plan_remaining.txt`).
- `scripts/build_plan.sh --with-check` ajoute `--check` aux commandes, `--check-allow-fail` ignore les tests en echec.
- `scripts/build_orchestrator.sh` orchestre plan/split/queue/sync/reports (`reports/build_orchestrator.txt` + JSON).
- Options `--plan-check` / `--plan-check-allow-fail` pour propager les tests au plan.
- `scripts/build_orchestrator_report.sh` genere `reports/build_orchestrator_report.txt`.
- `scripts/build_orchestrator_status.sh` genere `reports/build_orchestrator_status.txt`.
- `scripts/build_orchestrator_validate.sh` genere `reports/build_orchestrator_validation.txt`.
- `scripts/build_health_report.sh` genere `reports/build_health_report.txt` (synthese sante).
- `scripts/build_gate.sh` genere `reports/build_gate.txt`/`reports/build_gate.json` (gate pre-build).
- `scripts/run_reports.sh` lance aussi `build_gate.sh` et `build_health_report.sh`.
- `scripts/build_summary_json.sh` genere `reports/build_summary.json` (checks + rates + groupes).
- `scripts/build_summary_validate.sh` renforce la validation (`check_groups` + `check_gate`).
- `scripts/build_session.sh` enchaine gate + orchestrator + reports (`reports/build_session.txt/.json`).
- `scripts/build_session.sh` accepte `--allow-check-warn`/`--check-max-*` dont severite.
- `scripts/build_progress_report.sh` genere `reports/build_progress.txt` (resume du build).
- `scripts/build_progress_rollup.sh` genere `reports/build_progress_rollup.txt` (synthese par groupe).
- `scripts/build_progress_failures.sh` genere `reports/build_progress_failures.txt` (derniers echecs).
- `scripts/build_times_report.sh` genere un rapport des temps de build (`reports/build_times.txt`).
- `scripts/build_check_report.sh` genere un rapport des tests `make check` (`reports/build_check_report.txt`, options `--strict`, `--skip-ok-no-log`).
- `reports/build_check_status.csv` trace l'etat des checks par paquet (`--check` actif).
- `scripts/build_check_status_report.sh` genere un rapport des checks par paquet (trié, `reports/build_check_status_report.txt`).
- `scripts/build_check_status_rollup.sh` genere un resume des checks par groupe (trié, `reports/build_check_status_rollup.txt`).
- `scripts/build_check_trend.sh` genere un historique checks par jour avec taux/total (`reports/build_check_trend.txt`).
- `scripts/build_check_prune.sh` permet de purger `build_check_status.csv` (avant/apres dans `reports/build_check_prune.txt`).
- `scripts/build_check_stats.sh` genere un resume checks par groupe avec taux/severite (`reports/build_check_stats.txt`).
- `scripts/build_check_summary_json.sh` genere une synthese JSON checks (inclut coverage rates).
- `scripts/build_check_summary_validate.sh` valide la synthese checks (coverage/missing rates obligatoires).
- `scripts/build_check_export_csv.sh` exporte une synthese CSV checks (trend_last + groups).
- `scripts/build_check_coverage.sh` reporte la couverture checks vs manifest (`reports/build_check_coverage.txt`, coverage/missing rates).
- `scripts/build_check_snapshot.sh` fait un snapshot du CSV (`reports/build_check_snapshot.txt`).
- `scripts/build_check_snapshot_list.sh` liste les snapshots (lignes totales + dernier+lines, `reports/build_check_snapshot_list.txt`).
- `scripts/build_check_snapshot_prune.sh` purge les anciens snapshots (before/after, `reports/build_check_snapshot_prune.txt`).
- `scripts/build_check_snapshot_diff.sh` compare deux snapshots (auto-pick, `reports/build_check_snapshot_diff.txt`).
- `scripts/build_check_gate.sh` genere `reports/build_check_gate.txt`/`reports/build_check_gate.json` (JSON robuste + seuils `--max-*` dont severite).
- `configs/check_gate.conf` definit les seuils par defaut du gate checks (warning si absent).
- `scripts/build_gate.sh` integre les checks via `build_check_gate` (`--allow-check-warn`, `--check-max-*` dont severite).
- `scripts/validate_manifests.sh` genere `reports/manifest_report.txt` (lint manifests).
- `scripts/run_reports.sh` enchaine tous les rapports et regenere `reports/summary.md` (corrige doublon).
- `scripts/run_reports.sh` lance aussi `build_check_report.sh --strict`.
- `scripts/run_reports.sh` inclut maintenant le rapport de prerequis host.
- `scripts/boot_bundle.sh` enchaine kernel + initramfs + grub (raccourci boot).
- `scripts/boot_artifacts.sh` installe/verifie les artefacts /boot (kernel/initramfs/grub), utilise dans `boot_bundle.sh`.
- `scripts/grub_install.sh` installe GRUB sur le disque cible (root requis).
- `scripts/detect_boot_mode.sh` detecte BIOS/UEFI et recommande la cible grub.
- `scripts/run_vm.sh` lance la VM via QEMU (BIOS/UEFI, RAW ou QCOW2, kernel/initrd optionnels, SSH port forwarding).
- `scripts/snapshot_image.sh` cree un snapshot de l'image disque et un checksum.
- `scripts/convert_image.sh` convertit l'image RAW en QCOW2 avec checksum.
- `scripts/export_boot_artifacts.sh` packe kernel/initramfs/grub.cfg et checksum.
- `scripts/validate_boot_archive.sh` verifie le contenu du bundle boot.
- `scripts/clean_workspace.sh` nettoie les artefacts `work/` (initramfs, bundles, qcow2).
- `scripts/release_bundle.sh` regroupe rapports/logs/artefacts/images dans un bundle final.
- `scripts/validate_release_bundle.sh` verifie le contenu du bundle final (reports/logs/boot_artifacts/summary).
- `scripts/assess_status.sh` genere un etat consolide (ready_to_boot/grub/initramfs/etc).
- `scripts/release_bundle.sh` supprime l'archive precedente avant recreation.
- `scripts/boot_finalize.sh` exporte maintenant les artefacts boot.
- `scripts/partition_report.sh` genere un rapport du partitionnement (label/unit + sfdisk + image).
- `scripts/run_reports.sh` inclut maintenant le rapport de partitionnement.
- `docs/runbook.md` fournit un run complet de bout en bout.
- `scripts/check_ready_to_boot.sh` verifie les prerequis de boot et genere un rapport.
- `scripts/run_reports.sh` inclut ready_to_boot + summary l'affiche.
- `scripts/image_report.sh` genere un rapport sur l'image disque (taille/format).
- `scripts/boot_finalize.sh` enchaine grub.cfg + installation GRUB + checks boot.
- `scripts/boot_finalize.sh` genere `reports/boot_finalize.txt`, integre au summary.
- `scripts/archive_reports.sh` archive reports/logs et genere un checksum (regenere `reports/index.md`).
- `scripts/run_reports.sh` archive maintenant reports/logs automatiquement.
- `scripts/run_reports.sh` inclut detect_boot_mode + summary reporte le mode boot.
- `scripts/full_pipeline.sh` enchaine preflight, bootstrap, builds, boot et rapports.
- `scripts/full_pipeline.sh` lance aussi la validation de config kernel.
- `scripts/validate_kernel_config.sh` verifie les options kernel requises via `configs/kernel_requirements.txt`.
- `scripts/apply_kernel_requirements.sh` applique les options requises dans le .config.
- `scripts/run_reports.sh` inclut maintenant la validation kernel config.
- `scripts/summary_report.sh` inclut maintenant le rapport kernel config.
- `scripts/env_lfs.sh` : exports LFS/LFS_TGT/PATH/locale à sourcer avant build.
- `scripts/chroot.sh` : monte les bind nécessaires et entre en chroot LFS.
- `configs/` : à compléter (.config kernel `linux-6.6.config.todo`, grub.cfg exemple `configs/grub.cfg.example`, `fstab.example`).
- `configs/partitions.sfdisk` : partitionnement GPT 20 Go (boot/swap/root).
- `docs/build_order.md` : ordre de compilation des paquets LFS (base system).
- `docs/grub.md` : procédure d’installation GRUB (BIOS/EFI) avec le fichier d’exemple.
- `docs/fstab.md` : modèle /etc/fstab (UUID à privilégier).
- `docs/network.md` : notes réseau (DHCP via dhcpcd, alternative NetworkManager).
- `docs/chroot.md` : instructions pour entrer en chroot (bind mounts + chroot).
 - `docs/build_log.md` : journal de build à compléter lors d'un run réel.
 - `docs/toolchain.md` : rappel commandes pour binutils/gcc/linux-headers/glibc + chroot.
  - `configs/linux-6.6.config.todo` : placeholder .config à générer/adapter.
- `docs/checksums.md` : SHA256 des sources (kernel/binutils/gcc/glibc/bash/coreutils/procps/sysvinit/eudev + deps gmp/mpfr/mpc/zlib).
- `checksums/` : à compléter (SHA256 tarballs téléchargés + image finale).
- `logs/` : répertoires pour les builds.

## Prochaines étapes
1. LFS pointe désormais par défaut sur `$ROOT/.lfs` (scripts env/setup/chroot) pour éviter `/mnt/lfs` root-only.
2. `makeinfo` contourné via stub (`.local/bin/makeinfo`) et PATH mis à jour ; binutils cross installé dans `$LFS/tools` (warnings gprofng ignorés).
3. GCC stage1 en échec (`scripts/build_toolchain.sh gcc` 2025-12-06 03:36:38) : configure-target-libgcc ne trouve pas `stdc-predef.h`/`stdio.h` dans le sysroot; besoin de fournir des en-têtes cibles (ou stubs propres) avant de relancer.
4. Sources téléchargées et vérifiées (`scripts/download_sources.sh` OK, SHA256 alignés). Suivant : automatiser les mkfs/mount dans `setup_env.sh` (utiliser `configs/partitions.sfdisk`).
5. Poursuivre toolchain : finaliser GCC + linux headers + glibc headers.
5. Enchaîner les paquets LFS dans `build_system.sh` (ordre complet + tests).
6. Compiler le kernel 6.6.54, préparer initramfs, installer GRUB.
7. Documenter un run complet (build + boot VM) dans `docs/build_log.md`.

> Projet long terme : version contrôlée par scripts (CI locale) et documentation complète (inspirée des livres LFS/BLFS).
