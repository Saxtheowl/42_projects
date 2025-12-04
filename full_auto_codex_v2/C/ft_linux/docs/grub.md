# GRUB installation (chroot)

Suppositions : `/boot` monté, kernel installé sous `/boot/vmlinuz-6.6.54-ftlinux`, table GPT (sda).

1. Installer GRUB (BIOS) :
```bash
grub-install --target=i386-pc /dev/sda
```
Pour EFI :
```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
```

2. Copier/adapter `configs/grub.cfg.example` :
```bash
cp /sources/grub.cfg.example /boot/grub/grub.cfg   # ou générer via grub-mkconfig
```
Assurez-vous que `root=/dev/sda3` correspond bien à la partition racine et que l’initrd correspond à votre initramfs (`/boot/initrd.img-6.6.54-ftlinux` si généré).

3. Vérifier que `/etc/fstab` contienne les bonnes entrées (UUID recommandés).
