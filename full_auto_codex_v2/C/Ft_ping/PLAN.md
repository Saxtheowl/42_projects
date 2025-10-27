# Plan de mise en œuvre ft_ping

## Étape 1 – Analyse
- [x] Lire `Sujet_ft_ping.pdf` : options supportées (obligatoires `-v` et `-h`, paramètre IPv4/FQDN), format de sortie, contraintes.
- [x] Inventorier les fonctions autorisées (`socket`, `sendto`, `recvmsg`, `gettimeofday`, `alarm`, `signal`, etc.) et les droits requis (raw socket ⇒ root).
- [x] Identifier les scénarios de tests (pings vers localhost, FQDN, gestion d'erreurs, comparaison option `-v`).

## Étape 2 – Infrastructure
- [x] Makefile (`ft_ping`, règles usuelles, build dans `build/`).
- [x] `include/ft_ping.h` : structures (options, stats, session), macros ICMP.
- [x] Squelettes `src/` : `main.c`, `options.c`, `ping.c`, `checksum.c`, `stats.c`, `utils.c`.

## Étape 3 – Parsing / setup
- [x] Parsing arguments (hostname/IP, options). Résolution DNS (`getaddrinfo`).
- [x] Création socket raw (`SOCK_RAW`, `IPPROTO_ICMP`), réglage TTL et timeout.
- [x] Gestion des privilèges (message explicite si non root).

## Étape 4 – Envoi / réception
- [x] Construire Echo Request (id/process, seq, timestamp), checksum.
- [x] Boucle d’envoi périodique (intervalle ~1s via boucle d’attente).
- [x] Réception Echo Reply : filtre id/seq, calcul RTT, gestion timeouts et verbosité.

## Étape 5 – Statistiques & affichage
- [x] Maintenir stats (min/avg/max/mdev, packets sent/received, loss).
- [x] Gestion `SIGINT` pour afficher les statistiques finales.
- [x] Formatage inspiré de `ping` (banner, lignes de réponse, résumé).

## Étape 6 – Tests & validation
- [ ] Comparaison automatique à `/bin/ping` (bloqué : nécessite privilèges root → documenté).
- [x] `scripts/run_tests.sh` (fumée rootless : usage + contrôle privilèges).
- [x] Documentation des scénarios manuels (`tests_realisation/commands.md`).

## Étape 7 – Finition
- [ ] Norme 42 (`norminette`) et valgrind (à planifier quand outils disponibles).
- [x] Documenter dans `README.md` (usage, options, limitations tests).
