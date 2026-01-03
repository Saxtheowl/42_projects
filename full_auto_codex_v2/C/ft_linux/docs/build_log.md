# Journal de build (à remplir lors d'une exécution réelle)

> Astuce: utilisez `scripts/log_build.sh <section> <note>` pour ajouter une ligne horodatée.

## Toolchain
- Date :
- binutils :
- gcc (cross) :
- linux headers :
- glibc headers :
- glibc finale :

## Système de base (ordre LFS)
- Paquets clés (coreutils, bash, procps, util-linux, eudev, sysvinit, kmod…) :
- Temps total :
- Logs : `logs/system/…`

## Kernel
- Version/config :
- Commande : `scripts/build_kernel.sh`
- Résultat : `/boot/vmlinuz-…`

## Bootloader
- Type (BIOS/EFI) :
- grub-install :
- grub.cfg :

## Réseau
- dhcpcd/NetworkManager :
- Tests ping/DNS :

## Image finale
- Taille :
- Checksum (sha256) :
- Notes :
