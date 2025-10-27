# Minitalk

## Synthèse du projet
Minitalk met en place un échange de données entre deux processus via les signaux POSIX `SIGUSR1` et `SIGUSR2`.  
Le serveur reconstitue les octets envoyés bit à bit depuis le client, affiche le message reçu et reste actif pour traiter d’autres requêtes.  
Le client prend en argument le PID du serveur et une chaîne à transmettre ; il encode chaque caractère en émettant les signaux correspondants.

## Architecture
- `src/server.c` : boucle de réception, reconstruction des octets, accusés de réception.
- `src/client.c` : encodage des caractères, attente des acks, détection de complétion.
- `src/utils/` : helpers communs (I/O minimalistes, validation PID, chaînes).
- `include/minitalk.h` : déclarations partagées et dépendances POSIX.
- `scripts/run_tests.sh` : scénario d’intégration automatisé.
- `tests_realisation/COMMANDS.md` : liste commentée des commandes de test.
- `Sujet_Minitalk.pdf` : énoncé principal du module.

## Protocole d’échange
- `SIGUSR1` représente le bit `0`, `SIGUSR2` le bit `1` (ordre MSB → LSB).
- Le serveur envoie `SIGUSR1` en accusé de réception pour chaque bit traité.
- Lorsque le caractère nul `'\0'` est reçu, le serveur termine la ligne affichée et expédie `SIGUSR2` pour signaler la fin complète du message.
- Un changement de PID côté client réinitialise la séquence de reconstruction serveur pour garantir l’isolation des conversations.

## Compilation
```sh
make            # construit server et client
make clean      # supprime les objets
make fclean     # supprime objets + binaires
make re         # reconstruit après nettoyage
```

## Exécution
1. Lancer le serveur et noter le PID affiché :
   ```sh
   ./server
   ```
2. Dans une autre session, transmettre un message :
   ```sh
   ./client <PID_SERVEUR> "Hello Minitalk!"
   ```
3. Le serveur affiche le message et reste prêt pour d’autres clients.

## Tests
- `./scripts/run_tests.sh` compile le projet, démarre un serveur isolé, éxécute plusieurs clients (message non vide + message vide) et vérifie les sorties.
- Voir `tests_realisation/COMMANDS.md` pour le détail des commandes lancées et des hypothèses couvertes.

## Répartition des PDF
- `Sujet_Minitalk.pdf` : module principal décrivant les attendus obligatoires et bonus éventuels.
