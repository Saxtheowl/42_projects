# Schéma de partitions (VDI 20 Go)

- `/dev/sda1` — 512 MiB — EFI/boot (type EF00) ou ext2 si BIOS, monté sur `/boot`.
- `/dev/sda2` — 2 GiB — swap.
- `/dev/sda3` — ~17.5 GiB — root (`/`, ext4).

Hostname : `ftlinux`.
Utilisateur : `ftuser` (sudo optional), root activé.

Notes : alignement 1 MiB, table GPT par défaut (fallback MBR si BIOS uniquement).
