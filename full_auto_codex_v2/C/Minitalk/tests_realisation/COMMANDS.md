# Tests Minitalk

- `make re` — reconstruit proprement les binaires client et serveur.
- `./server` — lance le serveur et affiche le PID à utiliser côté client.
- `./client <PID> "message"` — envoie la chaîne fournie au serveur.
- `./client <PID> ""` — valide la gestion des chaînes vides (seule la fin de message est transmise).
- `./scripts/run_tests.sh` — exécute la batterie automatisée : compilation, démarrage serveur isolé, envoi de messages (non vide + vide) et vérification du log généré.
