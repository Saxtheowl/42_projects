# ft_linux

Statut : IN_PROGRESS

Derniere mise a jour : 2026-01-02 20:31:24

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
- `scripts/build_kernel.sh` : squelette de compilation du kernel 6.6.54 (attend un `.config` fourni).
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
