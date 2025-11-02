# Tests ft_irc

## Pré-requis
- Compiler le serveur :
  ```bash
  make
  ```
- Avoir `python3` et `nc` dans le `PATH` (pour les scripts automatiques/manuels).

## Automatisation
- `python3 tests_realisation/run_smoke.py`  
  Lance `ircserv` sur un port éphémère, enregistre deux clients simulés et vérifie :
  - handshake PASS/NICK/USER (`001` reçu),
  - diffusion `PRIVMSG` d'un canal,
  - changement de topic (`TOPIC`),
  - application d'un mode opérateur (`MODE +i`),
  - expulsion via `KICK`.
  Le script stoppe le serveur et ferme les sockets proprement en fin de parcours.

## Tests manuels rapides
- Lancer le serveur puis exécuter :
  ```bash
  ./ircserv 6667 secret &
  ./scripts/nc_basic.sh 6667 secret
  ```
  pour vérifier la création de channel et la diffusion par `netcat`.
- Avec un client IRC (irssi/weechat) :
  1. `PASS secret`, `NICK alice`, `USER alice 0 * :Alice`.
  2. `JOIN #test`, envoyer un message et observer la diffusion,
  3. Depuis un second client, valider `MODE #test +i`, `TOPIC #test :demo`, `KICK #test alice`.

## Nettoyage
```bash
pkill ircserv || true
make fclean
```
