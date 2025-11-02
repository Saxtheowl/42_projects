# ft_irc

## Synthèse
Développer un serveur IRC conforme au protocole (sans interconnexion serveur à serveur) en C++98. 

## Contraintes clés
- C++98 (`-std=c++98`), Makefile avec règles standard, pas de librairies externes.
- Pas de fork ; I/O non bloquantes + un seul mécanisme de multiplexage (`poll`, `select`, `kqueue`).
- Gérer PASS/NICK/USER, join de channels, PRIVMSG, opérateurs de base.
- Support IPv4/IPv6, reconstructions de messages traitant les paquets partiels.

## Architecture envisagée
- `include/` — headers (`Server.hpp`, `Client.hpp`, `Channel.hpp`, ...).
- `src/` — implémentations (boucle serveur, command handlers, utils).
- `scripts/` — tests manuels (`nc_basic.sh`, tutoriel irssi/weechat).
- `tests_realisation/` — scénarios de validation et instructions.

## Build & exécution
```bash
make
./ircserv 6667 secret
```

## Tests manuels
- `./scripts/nc_basic.sh 6667 secret` — handshake PASS/NICK/USER + JOIN & PRIVMSG via netcat.
- Consultez `tests_realisation/COMMANDS.md` pour d’autres scénarios (irssi).

## TODO
- Implémenter boucle `poll` et la gestion des clients/channels.
- Module de parsing IRC (RFC1459) + réponses numérotées.
- Ajout tests automatisés (Python) multi-clients.
