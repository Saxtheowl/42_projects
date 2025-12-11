# FT Services Helpers Reference

Ce document regroupe tous les scripts d'assistance pour la revue :

## 1. Vérifier la configuration
- `scripts/show_config.sh [config]`: affiche `port`, `backlog`, `log_path` et `max_connections` afin de confirmer que les autres helpers exécutent les mêmes paramètres que le démon.

## 2. Nettoyer le log
- `scripts/clean_log.sh [config]`: efface et recrée le `log_path` défini par le fichier de configuration, garantissant que chaque démonstration commence avec un journal vierge.

## 3. Workflow santé + charge
- `scripts/monitor_status.sh [config [max]]`: nettoie le log, attend `STATUS: OK`, consulte `COUNT` puis déclenche `test_max_connections.sh` (par défaut 10 `STATUS`). Idéal pour montrer en une seule commande que le daemon gère santé, compteur et surcharge.
- `scripts/client_demo.py [--config config] [--commands ...]`: ouvre une connexion TCP et envoie une série de commandes (`STATUS`, `COUNT`, etc.), imprimant chaque requête et réponse. Utile pour illustrer les échanges et la réponse `connections: <n>`.
- `scripts/stress_max_connections.sh [config [max]]`: envoie des `STATUS` successifs via `nc` jusqu’à obtenir `overloaded: <n>` et confirme que `max_connections` répond sous charge.

## 4. Démonstration recommandée
1. Démarrez `./ft_services --config tests/env/ft_services_status.conf` dans un terminal (service compilé via le `Makefile`).
2. Dans un second terminal, exécutez `scripts/monitor_status.sh tests/env/ft_services_status.conf 15` pour nettoyer le log, valider santé, regarder le compteur et déclencher l’état `overloaded: <n>`.
3. Lancez `scripts/show_config.sh tests/env/ft_services_status.conf` pour confirmer les paramètres.
4. Ensuite, envoyez des commandes en direct avec `scripts/client_demo.py --config tests/env/ft_services_status.conf --commands STATUS COUNT STATUS` afin de montrer les réponses du démon.
5. Réitérez éventuellement en supprimant le log avec `scripts/clean_log.sh` avant de relancer le workflow pour garder le journal clair.
