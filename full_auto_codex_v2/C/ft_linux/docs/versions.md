# Versions retenues (x86_64)

- Kernel : 6.6.54 (LTS) — https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.54.tar.xz
- Binutils : 2.43.1 — https://ftp.gnu.org/gnu/binutils/binutils-2.43.1.tar.xz
- GCC : 13.2.0 (avec gmp/mpfr/mpc integrés) — https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
- Glibc : 2.40 — https://ftp.gnu.org/gnu/glibc/glibc-2.40.tar.xz
- Linux API Headers : 6.6.54 (extraits du tarball kernel)
- Utilitaires de base (sélection LFS 12.x) :
  - bash 5.2.21, coreutils 9.5, diffutils 3.10, file 5.45, findutils 4.10.0,
  - gawk 5.3.1, grep 3.11, gzip 1.13, kbd 2.6.4, less 661, make 4.4.1,
  - patch 2.7.6, procps-ng 4.0.4, psmisc 23.7, sed 4.9, sysvinit 3.10,
  - tar 1.35, texinfo 7.1, util-linux 2.40.2, eudev 3.2.14.
- Bootloader : GRUB 2.12.

Mirroirs privilégiés : `ftp.gnu.org` (fallback `ftpmirror.gnu.org`), `sourceware.org/pub`, `cdn.kernel.org`, `anduin.linuxfromscratch.org/BLFS/`.

Architecture : x86_64, cible triplet `x86_64-lfs-linux-gnu`.
