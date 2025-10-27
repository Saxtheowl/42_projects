# Plan de mise en œuvre Minitalk

## Étape 1 – Analyse & Design
- [x] Extraire les exigences du sujet (client/serveur, format messages, contraintes signaux).
- [x] Définir protocole de transmission (encodage bits, ack, terminaison).
- [x] Lister cas limites (messages longs, Unicode, erreurs signal).

## Étape 2 – Infrastructure
- [x] Créer arborescence `src/`, `include/`, `tests_realisation/`, `scripts/`.
- [x] Écrire `Makefile` simple (sources client/serveur, bonus éventuel).
- [x] Définir headers partagés (`minitalk.h`, utilitaires signal/bit).

## Étape 3 – Serveur
- [x] Implémenter réception bit à bit via `SIGUSR1/SIGUSR2`.
- [x] Reconstituer octets, gérer caractères fin de message.
- [x] Accuser réception si protocole le requiert (bonus).

## Étape 4 – Client
- [x] Encoder chaîne argument en signaux (tempo configurable).
- [x] Gérer retour du serveur (ack/nack) pour fiabilité.
- [x] Supporter messages multi-octets (UTF-8).

## Étape 5 – Outils & Documentation
- [x] Rédiger `README.md` (synthèse, architecture, commandes build/run).
- [x] Ajouter scripts tests (`tests_realisation/COMMANDS.md`, suites shell/Python).
- [x] Documenter coversions signaux/temps (scripts utilitaires).

## Étape 6 – Validation
- [x] Tests manuels (messages variés, cas limites).
- [x] Tests automatisés (client/server orchestrés par script).
- [ ] Vérifications mémoire (ASan/valgrind si dispo) et norme 42 — valgrind indisponible sur l’environnement courant (à relancer ultérieurement).
