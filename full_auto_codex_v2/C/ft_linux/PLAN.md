# Plan de mise en œuvre ft_linux

## Étape 1 – Analyse
- [x] Lire `Sujet_ft_linux.pdf` et noter contraintes (kernel >= 4.0, 3 partitions, udev, bootloader, packages list).
- [x] Choisir les versions des paquets et mirroirs de téléchargement fiables (cf. `docs/versions.md`).
- [x] Décider architecture (x86_64), hyperviseur cible (VM), disque 20 Go (cf. `docs/partitions.md`).

## Étape 2 – Préparation
- [x] Documenter plan partitions (`docs/partitions.md`), hostname, login.
- [x] Élaborer scripts squelette :
  - `scripts/setup_env.sh` (création image et rappel partitionnement).
  - `scripts/build_toolchain.sh` (binutils/gcc cross).
  - `scripts/build_system.sh` (paquets système sélectionnés).
  - `scripts/download_sources.sh` (download + SHA).
  - `scripts/gen_checksums.sh` (SHA256 des tarballs présents).
  - `scripts/env_lfs.sh` (export variables LFS).
- [x] Générer fichier SHA256 pour tarballs (`docs/checksums.md`) + script `scripts/download_sources.sh` (avec vérif SHA).

## Étape 3 – Toolchain
- [x] Installer binutils temporaire dans `/tools` (`scripts/build_toolchain.sh binutils`) — makeinfo contourné via stub local.
- [ ] Installer gcc/glibc temporaires dans `/tools` (`scripts/build_toolchain.sh gcc-stage1` puis `libgcc` après headers/glibc).
- [ ] Installer linux headers + glibc headers dans `$LFS/usr/include` (targets ajoutés dans `scripts/build_toolchain.sh`).
- [ ] Configurer variables d’environnement (LFS, PATH).
- [ ] Valider toolchain (tests binutils/gcc).

## Étape 4 – Système de base
- [ ] Compiler packages list (order LFS) avec logs (cf. `docs/build_order.md`).
- [ ] Configurer sysvinit/systemd + udev/eudev.
- [ ] Mettre en place hiérarchie FHS (/etc, /var, /usr, ...).

## Étape 5 – Kernel & Bootloader
- [ ] Télécharger sources kernel >= 4.0, config `.config` (nom version avec login) — script `scripts/build_kernel.sh` prêt.
- [ ] Compiler kernel + modules, installer dans `/boot/vmlinuz-<version>-<login>`.
- [ ] Installer GRUB (ou LILO) et générer `grub.cfg` (cf. `docs/grub.md` + `configs/grub.cfg.example`).

## Étape 6 – Finalisation
- [ ] Config réseau (dhcpcd ou NetworkManager minimal).
- [ ] Créer utilisateurs, mot de passe root, scripts rc.
- [ ] `/etc/fstab` (cf. `docs/fstab.md` / `configs/fstab.example`) + UUID.
- [ ] Tests : boot VM, réseau, module loader, service manager.
- [ ] Générer checksum image (shasum disk.vdi) + documenter.
- [ ] Documenter la configuration réseau (cf. `docs/network.md`) et valider DHCP.

## Étape 7 – Documentation & Bonus
- [x] `docs/build_log.md` (commande & temps build) — squelette à compléter lors d'un run réel.
- [ ] Instructions README (comment reproduire).
- [ ] Bonus éventuels (X server, WM, packaging).
