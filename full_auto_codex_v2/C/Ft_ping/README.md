# ft_ping

## Synthèse
Réimplémentation pédagogique de l’outil `ping` : ouverture d’un socket raw ICMP, construction manuelle d’Echo Request, réception via `recvmsg`, calcul de checksum, mesure RTT et statistiques finales (`min/avg/max/mdev`). Le programme gère les options obligatoires du sujet (`-h`, `-v`), l’arrêt par `SIGINT` et prend en charge les FQDN sans résolution inverse lors des réponses.

## Architecture
- `include/ft_ping.h` — constantes, structures (options, statistiques, session) et prototypes partagés.
- `src/main.c` — point d’entrée, vérification des privilèges, dispatch vers la session.
- `src/options.c` — parsing de la ligne de commande (`-h`, `-v`, destination).
- `src/ping.c` — résolution DNS (`getaddrinfo`), création du socket raw, boucle d’envoi/réception, gestion signaux.
- `src/checksum.c` — calcul du checksum ICMP (RFC 792).
- `src/stats.c` — agrégation et affichage des statistiques de fin de session.
- `src/utils.c` — helpers simples (`ft_strlen`, `ft_memcpy`, conversions).
- `scripts/run_tests.sh` — script de fumée sans privilège root.
- `tests_realisation/` — documentation et artefacts de tests.

## Compilation
```sh
make        # construit ft_ping
make re     # clean + build
make clean  # supprime les objets
```

### Dépendances
- Compilateur C POSIX (`cc`).
- Accès aux en-têtes système (`netinet/ip.h`, `netinet/ip_icmp.h`, `sys/socket.h`).
- Liens avec `-lm` (statistiques).

## Utilisation
```sh
sudo ./ft_ping [-hv] destination
```
- `-h` : affiche l’aide.
- `-v` : mode verbeux (affiche les messages ICMP non ECHO/ECHOREPLY).
- `destination` : IPv4 ou FQDN.

Arrêt avec `Ctrl+C` → statistiques imprimées avant sortie.

> Les sockets raw nécessitent les privilèges root. Sans élévation, le binaire affiche un message d’erreur explicite et s’arrête.

## Tests
### Automatisés
- `./scripts/run_tests.sh` — reconstruit le projet puis exécute des checks sans root (messages d’usage, refus sans privilèges). Les sorties sont stockées dans `tests_realisation/tmp/`.

### Manuels (root requis)
1. `sudo ./ft_ping 127.0.0.1`
2. `sudo ./ft_ping -v 8.8.8.8`
3. `sudo ./ft_ping host.example.com`

Les scénarios sont détaillés dans `tests_realisation/commands.md`.

## Limitations & pistes
- Les tests automatisés ne couvrent pas les scénarios nécessitant des privilèges élevés.
- Pas de support IPv6 (à considérer en bonus).
- Le mode verbeux affiche les descriptions ICMP principales mais n’implémente pas l’ensemble des codes possibles.
