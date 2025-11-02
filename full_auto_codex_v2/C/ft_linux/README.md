# ft_linux

## Synthèse préliminaire
Objectif : construire une distribution Linux minimale et fonctionnelle, utilisée comme base pour les projets kernel ultérieurs. Il faut compiler un noyau >= 4.0 personnalisé (avec login dans la version), configurer partitions (root, /boot, swap), intégrer un bootloader (GRUB/LILO), un gestionnaire de services (SysV ou systemd/elogind), un loader de modules (udev/eudev) et installer la panoplie d’outils de base (liste fournie). L’image doit se connecter au réseau et respecter une hiérarchie FS cohérente.

## Pistes initiales
1. **Plateforme** : VM VirtualBox (64-bit), disque virtuel > 15 Go.
2. **Workflow** : inspiré de Linux From Scratch / Beyond LFS.
   - Toolchain croisée temporaire.
   - Chroot stage1 + stage2 (construction packages).
   - Compilation kernel + initramfs.
3. **Gestion des paquets** : compilation source (scripts bash) ou adoption minimaliste (e.g. `pkgtool`).
4. **Automatisation** : scripts `scripts/` pour orchestrer downloads, build, SHA256.

## Arborescence envisagée
- `docs/` — notes sur partitions, liste packages, ordonnancement build.
- `scripts/` — `build_toolchain.sh`, `build_system.sh`, `create_image.sh`, `run_vm.sh`.
- `configs/` — fichiers `.config` du kernel, grub.cfg, systemd units.
- `checksums/` — hash des tarballs téléchargés, image finale.
- `logs/` — captures compilations, tests.
- `README.md` — instructions globales + TODO.

## Prochaines étapes
1. Définir versions (alignées sur LFS 7.8/8.0 par ex.) et sources officielles.
2. Rédiger plan builds (makefile/shell) + script partitionnement (sfdisk).
3. Automatiser download + vérification SHA256.
4. Compiler toolchain (binutils, gcc, glibc) dans `/tools`.
5. Construire system base + kernel + init.
6. Installer GRUB, config réseau, utilisateurs, tests.
7. Générer checksum final pour dépôt.

> Projet long terme : version contrôlée par scripts (CI locale) et documentation complète (inspirée des livres LFS/BLFS).
