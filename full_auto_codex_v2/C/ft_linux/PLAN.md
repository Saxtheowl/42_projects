# Plan de mise en œuvre ft_linux

## Étape 1 – Analyse
- [x] Lire `Sujet_ft_linux.pdf` et noter contraintes (kernel >= 4.0, 3 partitions, udev, bootloader, packages list).
- [ ] Choisir les versions des paquets et mirroirs de téléchargement fiables.
- [ ] Décider architecture (x86_64 vs i686), hyperviseur (VirtualBox) et taille disque.

## Étape 2 – Préparation
- [ ] Documenter plan partitions (`docs/partitions.md`), hostname, login.
- [ ] Élaborer scripts :
  - `scripts/setup_env.sh` (création VDI, montage loop).
  - `scripts/build_toolchain.sh` (toolchain cross LFS).
  - `scripts/build_system.sh` (packages LFS).
- [ ] Générer fichier SHA256 pour tarballs.

## Étape 3 – Toolchain
- [ ] Installer binutils/gcc/glibc temporaires dans `/tools`.
- [ ] Configurer variables d’environnement (LFS, PATH).
- [ ] Valider toolchain (tests binutils/gcc).

## Étape 4 – Système de base
- [ ] Compiler packages list (order LFS) avec logs.
- [ ] Configurer sysvinit/systemd + udev/eudev.
- [ ] Mettre en place hiérarchie FHS (/etc, /var, /usr, ...).

## Étape 5 – Kernel & Bootloader
- [ ] Télécharger sources kernel >= 4.0, config `.config` (nom version avec login).
- [ ] Compiler kernel + modules, installer dans `/boot/vmlinuz-<version>-<login>`.
- [ ] Installer GRUB (ou LILO) et générer `grub.cfg`.

## Étape 6 – Finalisation
- [ ] Config réseau (dhcpcd ou NetworkManager minimal).
- [ ] Créer utilisateurs, mot de passe root, scripts rc.
- [ ] Tests : boot VM, réseau, module loader, service manager.
- [ ] Générer checksum image (shasum disk.vdi) + documenter.

## Étape 7 – Documentation & Bonus
- [ ] `docs/build_log.md` (commande & temps build).
- [ ] Instructions README (comment reproduire).
- [ ] Bonus éventuels (X server, WM, packaging).
