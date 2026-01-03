# Runbook ft_linux

Objectif : sequence complete depuis l'image disque jusqu'au boot QEMU.

## 1) Preflight + bootstrap
```
scripts/preflight.sh
scripts/bootstrap_all.sh
```

## 2) Toolchain (cross)
```
scripts/build_toolchain.sh all
```

## 3) Paquets systeme
```
scripts/build_mini_system.sh all
scripts/build_system.sh all
```

## 4) Kernel + initramfs
```
scripts/build_kernel_config.sh --apply-reqs
scripts/validate_kernel_config.sh
scripts/build_kernel.sh --config configs/linux-6.6.54.config
scripts/build_initramfs.sh --generate --install-boot
```

## 5) GRUB + boot
```
scripts/ensure_grub_cfg.sh
scripts/grub_install.sh --device /dev/loop0 --target i386-pc
scripts/boot_finalize.sh --device /dev/loop0 --target i386-pc
```

## 6) Rapports + packaging
```
scripts/run_reports.sh
scripts/check_ready_to_boot.sh
scripts/package_rootfs.sh
scripts/archive_reports.sh
```

## 7) Boot QEMU
```
scripts/run_vm.sh --img work/disk.raw --mem 2048 --cpus 2
```

## 8) Snapshot image
```
scripts/snapshot_image.sh
```

## 9) Convert QCOW2
```
scripts/convert_image.sh
```

## 10) Export boot artifacts
```
scripts/export_boot_artifacts.sh
```

## 11) Clean workspace
```
scripts/clean_workspace.sh --dry-run
```

## 12) Release bundle
```
scripts/release_bundle.sh
```

## 13) Validate release bundle
```
scripts/validate_release_bundle.sh
```

Note : `boot_finalize.sh` exporte deja les artefacts boot.

Notes :
- Adaptez `--device` (ex: /dev/sda) et `--target` (x86_64-efi si UEFI).
- Si besoin, utilisez `scripts/detect_boot_mode.sh` pour choisir la cible GRUB.
