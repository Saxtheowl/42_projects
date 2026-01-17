# ft_ping

Statut : DONE

Derniere mise a jour (2026-01-17 03:55:59) : ajout test pattern invalide (options) + tests OK.

Derniere mise a jour (2026-01-17 00:29:53) : passage DONE (tests OK).

## Synthèse
Réimplémentation pédagogique de l’outil `ping` : ouverture d’un socket raw ICMP, construction manuelle d’Echo Request, réception via `recvmsg`, calcul de checksum, mesure RTT et statistiques finales (`min/avg/max/mdev`). Le programme gère les options obligatoires du sujet (`-h`, `-v`), l’arrêt par `SIGINT` et prend en charge les FQDN sans résolution inverse lors des réponses.

## Architecture
- `include/ft_ping.h` — constantes, structures (options, statistiques, session) et prototypes partagés.
- `src/main.c` — point d’entrée, vérification des privilèges, dispatch vers la session.
- `src/options.c` — parsing de la ligne de commande (`-h`, `-v`, `-q`, `-c`, `-t`, `-Q`, `-i`, `-W`, destination).
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
sudo ./ft_ping [-hvqDR] [-c count] [-t ttl] [-Q tos] [-S source] [-i interval] [-W timeout] [-w deadline] [-s size] [-p hexpattern] destination
```
- `-h` : affiche l’aide.
- `-v` : mode verbeux (affiche les messages ICMP non ECHO/ECHOREPLY).
- `-q` : mode silencieux (supprime les lignes par paquet, garde les stats finales).
- `-D` : préfixe chaque sortie par le timestamp epoch (ms).
- `-R` : tente une résolution DNS inverse des réponses ICMP.
- `-c <count>` : arrêter après `count` requêtes.
- `-t <ttl>` : TTL de sortie (1-255).
- `-Q <tos>` : octet TOS/DSCP (0-255) appliqué sur le socket.
- `-S <source>` : adresse IPv4 source à utiliser (bind).
- `-i <interval>` : intervalle entre requêtes en secondes (défaut 1.0).
- `-W <timeout>` : timeout par requête en secondes (défaut 1.0).
- `-w <deadline>` : délai maximal de la session en secondes (arrêt après ce temps).
- `-s <size>` : taille du payload en octets (défaut 56, min sizeof(timeval)).
- `-p <hex>` : motif hexadécimal répété dans le payload après le timestamp RTT.
- `destination` : IPv4 ou FQDN.

Arrêt avec `Ctrl+C` → statistiques imprimées avant sortie.

> Les sockets raw nécessitent les privilèges root. Sans élévation, le binaire affiche un message d’erreur explicite et s’arrête.

## Tests
### Automatisés
- `./scripts/run_tests.sh` — reconstruit le projet puis exécute des checks sans root (messages d’usage, refus sans privilèges). Les sorties sont stockées dans `tests_realisation/tmp/`.

### Manuels (root requis)
1. `sudo ./ft_ping 127.0.0.1`
2. `sudo ./ft_ping -v 8.8.8.8`
3. `sudo ./ft_ping -c 5 -i 0.2 host.example.com`
4. `sudo ./ft_ping -q -c 3 1.1.1.1` (silence pendant les paquets, stats en fin)
5. `sudo ./ft_ping -W 2.5 8.8.8.8` (timeout porté à 2.5 s)
6. `sudo ./ft_ping -w 5 8.8.4.4` (deadline session 5 s)
7. `sudo ./ft_ping -s 120 8.8.8.8` (payload étendu)
8. `sudo ./ft_ping -s 100 -p deadbeef 1.1.1.1` (motif hex custom)

Les scénarios sont détaillés dans `tests_realisation/commands.md`.

## Limitations & pistes
- Les tests automatisés ne couvrent pas les scénarios nécessitant des privilèges élevés.
- Pas de support IPv6 (à considérer en bonus).
- Le mode verbeux affiche les descriptions ICMP principales mais n’implémente pas l’ensemble des codes possibles.
