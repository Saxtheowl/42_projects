# Tests ft_kalman

## Exécution rapide
```bash
./tests_realisation/run_unit.sh
```
ou via Makefile :
```bash
make test
```

## Test UDP local (mock)
```bash
./tests_realisation/run_udp.sh
```
ou via Makefile :
```bash
make test-udp
```
Note: le script ignore le test si l'environnement interdit l'ouverture de sockets UDP.

## Ce que couvre `run_unit.sh`
- build complet (demo + tests)
- `kalman_demo` sur scénario synthétique (affiche 5 lignes)
- `kalman_test` (sanity checks filtre + maths matrice: inverse 3x3, transpose, identité)

## Ce que couvre `run_udp.sh`
- compile et lance `kalman_demo --udp`
- envoie un flux UDP simulé via `scripts/mock_stream.py`
- vérifie que chaque paquet reçoit une réponse JSON

## Tout lancer
```bash
make test-all
```

## Pistes restantes
- TODO: scripts pour lancer `imu-sensor-stream`.
- Prévoir comparatif trajectoire (CSV -> Python).
