# Plan de mise en œuvre ft_irc

## Étape 1 – Analyse
- [x] Lire `Sujet_ft_irc.pdf`.
- [ ] Rassembler ressources RFC1459/2812 (spec commandes).
- [ ] Choisir client de référence (ex: irssi) pour tests.

## Étape 2 – Infrastructure
- [x] Créer `Makefile` (c++98, -Wall -Wextra -Werror, règles standard).
- [ ] Définir structures `Server`, `Client`, `Channel`, `Command`.
- [ ] Mettre en place boucle `poll`/`select` non bloquante.

## Étape 3 – Connexion & Auth
- [ ] Gestion PASS (mot de passe), NICK, USER, CAP LS (optionnel).
- [ ] Messages de bienvenue (`001` à `004`) une fois auth complet.
- [ ] Détecter collisions de nick.

## Étape 4 – Gestion Channels
- [ ] Implémenter JOIN/PART, création channel si inexistant.
- [ ] Maintenir liste clients & opérateurs, modes simples (`o`, `t`).
- [ ] Gestion PRIVMSG/NOTICE vers user ou channel.

## Étape 5 – Commandes opérateur
- [ ] MODE (ajout/removal `o`, `k`, `l` basique).
- [ ] KICK, TOPIC (avec restrictions opérateurs).
- [ ] PING/PONG.

## Étape 6 – Gestion I/O & erreurs
- [ ] Bufferisation lecture/écriture (gestion partial read/write).
- [ ] Timeout/ déconnexion ordonnée (QUIT).
- [ ] Logs / monitoring.

## Étape 7 – Tests
- [ ] Script `scripts/nc_basic.sh` (connexion, join, msg).
- [ ] Guide `tests_realisation/COMMANDS.md` (irssi/weechat).
- [ ] Tests multi-clients (broadcast channel).

## Étape 8 – Documentation
- [x] README initial (usage, commandes supportées, client référence).
- [ ] Documentation finale + logs build/test.
*** End Patch
