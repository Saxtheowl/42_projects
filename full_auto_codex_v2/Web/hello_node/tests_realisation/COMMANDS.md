# Tests hello_node

- `./tests_realisation/run_tests.sh` — exécute la batterie de tests Node.js (ex00 → ex09) avec un serveur HTTP/TCP local simulé.
- `HELLO_NODE_SKIP_NET=1 ./tests_realisation/run_tests.sh` — saute les tests réseau si l'environnement bloque les sockets locales.
- `./tests_realisation/run_tests_skip_net.sh` — raccourci pour lancer les tests avec `HELLO_NODE_SKIP_NET=1`.
- `./tests_realisation/run_tests_auto.sh` — tente les tests réseau et bascule automatiquement en mode sans réseau si la socket locale est bloquée.
