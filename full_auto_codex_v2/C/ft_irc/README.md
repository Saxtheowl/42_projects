# ft_irc

Statut : WAITING (tests smoke bloques: sockets locaux interdits)

Derniere mise a jour (2026-01-17 03:20:56) : ajout skip test smoke si sockets interdites, blocage env.

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
Les tests de fumée automatisés nécessitent `python3` et `nc` :
- `tests_realisation/run_smoke.py` lance le serveur sur un port éphémère, crée deux clients simulés, vérifie l'accueil, la diffusion `PRIVMSG`, `TOPIC`, `MODE` et un `KICK`.
- `scripts/nc_basic.sh <port> <password>` permet un test manuel rapide comparant la diffusion à la sortie standard.

Commande recommandée pour la campagne de fumée :
```bash
make
python3 tests_realisation/run_smoke.py
```

## Rôle du PDF
Le fichier `Sujet_ft_irc.pdf` (copié depuis `organized_subjects/C/`) détaille les exigences officielles du projet, notamment l'usage obligatoire de `poll`, la non-utilisation de fork, la liste des commandes minimales et les modes opérateur à implémenter. Ce README synthétise leur implémentation dans ce dépôt.
