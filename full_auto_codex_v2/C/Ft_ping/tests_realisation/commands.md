# Scénarios manuels ft_ping

- Build: `make` (ou `make re`)
- Tests unitaires (checksum + options): `make test`
- Smoke rootless: `scripts/run_tests.sh` (vérifie usage + erreur de privilège)

### Exemples d'exécution (root requis)
- Ping simple: `sudo ./ft_ping 127.0.0.1`
- Verbose + TTL custom: `sudo ./ft_ping -v -t 42 8.8.8.8`
- Nombre limité + intervalle court: `sudo ./ft_ping -c 5 -i 0.2 localhost`
- TTL réduit: `sudo ./ft_ping -t 2 example.com`
- Timeout allongé: `sudo ./ft_ping -W 2.5 1.1.1.1`
- Deadline globale: `sudo ./ft_ping -w 5 1.1.1.1`
- Mode silencieux (stats uniquement): `sudo ./ft_ping -q -c 3 8.8.8.8`
- Payload étendu: `sudo ./ft_ping -s 120 8.8.8.8`
- Motif hex custom: `sudo ./ft_ping -s 100 -p deadbeef 1.1.1.1`
- TOS/DSCP forcé (0xB8 = AF41): `sudo ./ft_ping -Q 184 8.8.8.8`
- Timestamp en sortie: `sudo ./ft_ping -D 8.8.8.8`
- Résolution inverse: `sudo ./ft_ping -R 8.8.8.8`
- Source spécifique: `sudo ./ft_ping -S 192.168.0.10 8.8.8.8`
- Détection out-of-order: observer les lignes `(OUT-OF-ORDER)` si les séquences arrivent en désordre.
- Stop after first reply: `sudo ./ft_ping -O 8.8.8.8`
- Vérifier un host: `sudo ./ft_ping example.com`

### Comparaison manuelle vs ping système (root)
- `sudo ./ft_ping -c 4 127.0.0.1`
- `/bin/ping -c 4 127.0.0.1`
  - Vérifier que le nombre de paquets et les stats min/avg/max sont cohérents (mdev peut varier légèrement).
