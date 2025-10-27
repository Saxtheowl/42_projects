# Questions et hypothèses Minitalk

## Hypothèses basées sur sujets précédents
- Serveur : affiche les messages reçus, relance immédiatement la boucle (pas d'arrêt auto).
- Client : prend PID serveur + message, envoie bit par bit via `SIGUSR1`/`SIGUSR2`.
- Ordre des bits pressenti : du bit le plus significatif au moins significatif.
- Fréquence d'envoi : introduire un `usleep()` configurable pour éviter perte de signaux.
- Octet de terminaison : envoyer '\0' pour signaler fin de message.
- Bonus envisagés : accusé de réception, support Unicode, interface interactive.

## Points à confirmer après lecture du PDF
1. Temps de pause recommandé entre signaux ?
2. Gestion des signaux simultanés (accusés de réception obligatoires ?).
3. Organisation des bonus (client/serveur bonus distincts ?).
4. Contraintes de Makefile (targets imposées : `server`, `client`, `bonus`, `clean`, ...).
5. Gestion des erreurs (messages d'erreur spécifiques ?).
6. Support obligatoire pour plusieurs clients successifs ?

## Actions à venir
- Lecture manuelle du sujet pour valider/ajuster ces hypothèses.
- Écriture du protocole définitif (schéma, pacing, ack éventuel).
- Définir structure `t_msg_state` côté serveur (accumulateur bits).
- Définir interface utilitaire `send_bit(pid_t pid, int bit)` côté client.
