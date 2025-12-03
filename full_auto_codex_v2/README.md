# ft_irc

## Synthèse
`ircserv` est une implémentation C++98 d'un serveur IRC monoproc/multiplexé conforme au sujet 42. Le binaire gère l'authentification PASS/NICK/USER, le routage des commandes de base (JOIN/PART/PRIVMSG/NOTICE/PING/QUIT) et la modération de canaux (MODE, TOPIC, INVITE, KICK) en appliquant les modes `i/t/k/l/o`. Toute l'I/O est non bloquante et orchestrée via un unique `poll(2)` comme requis.

## Architecture
- **Boucle d'événements** : un seul thread pilote `poll` sur le socket d'écoute et tous les clients. Chaque client possède des buffers d'entrée/sortie, l'état d'inscription et la liste des canaux rejoints.
- **Canaux** : structure `Channel` stockant membres, opérateurs et modes (`inviteOnly`, `topicProtected`, `key`, `userLimit`). Les diffusions utilisent des préfixes IRC standards (`nick!user@host`).
- **Parser IRC** : découpe ligne par ligne (`\r\n`), prise en charge du paramètre final préfixé par `:` (texte libre) et table de dispatch par commande.
- **Modes opérateurs** : vérifications centralisées (`requireRegistration`, `channel.isOperator`) et mise à jour atomique des modes avec diffusion d'un `MODE` synthétique à tous les membres.

## Compilation & exécution
```bash
make            # produit ./ircserv
./ircserv 6667 superpass
```
Le serveur écoute sur toutes les interfaces IPv4/IPv6 disponibles. Utilisez ensuite un client IRC (netcat, irssi, weechat…) en fournissant le mot de passe `PASS`.

## Procédure de tests
Les tests manuels peuvent se faire via `nc` :
```bash
nc localhost 6667
PASS superpass
NICK alice
USER alice 0 * :Alice
JOIN #test
PRIVMSG #test :hello world
```
Vous devriez voir les diffusions `JOIN`, `353/366` et les messages privés. Une exécution simultanée de deux clients permet de vérifier les modes `MODE +i/+t/+k/+l/+o`, `TOPIC`, `INVITE` et `KICK`.
