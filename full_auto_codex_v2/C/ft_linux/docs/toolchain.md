# Toolchain LFS (rappel)

1) Préparer l'env :
```bash
source scripts/env_lfs.sh
```

2) Télécharger les tarballs (SHA dans `docs/checksums.md`) :
```bash
./scripts/download_sources.sh
```

3) (Optionnel) Générer SHA des tarballs présents :
```bash
./scripts/gen_checksums.sh
```

4) Toolchain (hors chroot) :
```bash
./scripts/build_toolchain.sh binutils
./scripts/build_toolchain.sh gcc
./scripts/build_toolchain.sh linux-headers
./scripts/build_toolchain.sh glibc
```

5) Entrer en chroot :
```bash
./scripts/chroot.sh
```

6) Construire le système de base (ordre `docs/build_order.md`) avec `scripts/build_system.sh` (à compléter paquet par paquet).
