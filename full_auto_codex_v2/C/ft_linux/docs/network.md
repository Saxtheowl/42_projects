# Réseau minimal

Option simple : DHCP via `dhcpcd`.

1. Installer `dhcpcd` dans le chroot (paquet BLFS).
1.b. Variante : `scripts/install_init_scripts.sh` installe un service `network` (SysV) qui lance `dhcpcd`.
2. Créer le service SysV (si sysvinit) :
```
cat >/etc/sysconfig/ifconfig.eth0 <<'EOF'
ONBOOT=yes
IFACE=eth0
SERVICE=dhcpcd
DHCP_START="-q"
EOF
```
3. Activer dans `/etc/rc.d/rc.inet1` ou équivalent selon votre arbo SysV (à adapter).

Alternative : `NetworkManager` (BLFS) si besoin Wi‑Fi/plus complexe.

Vérifications :
- `ip a` affiche une IPv4 sur `eth0`.
- `ping -c3 1.1.1.1` puis `ping -c3 example.org`.
