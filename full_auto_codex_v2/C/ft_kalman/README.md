# ft_kalman

Statut : DONE

Dernière mise à jour (2026-01-17 03:10:08) : cloture (tests unit + udp mock, doc tests complete).

Dernière mise à jour (2026-01-17 03:05:21) : ajout cibles Makefile test-udp/test-all + doc associee.

Dernière mise à jour (2026-01-17 03:00:45) : ajout run_udp (mock) + skip si sockets interdites.

Dernière mise à jour (2026-01-17 02:55:08) : ajout test determinant 3x3 + run_unit OK.

Dernière mise à jour (2026-01-17 02:49:59) : doc tests_realisation (run_unit + couverture).

Dernière mise à jour (2026-01-17 02:45:07) : ajout test produit avec matrice identite + tests OK.

Dernière mise à jour (2026-01-17 02:40:09) : ajout test transpose matrice + tests OK.

Dernière mise à jour (2026-01-17 02:36:52) : ajout tests inverse 3x3 + erreur -Werror host non utilise corrigee.

## Synthèse actuelle
Implémentation MVP d’un filtre de Kalman linéaire 6D (position/vitesse) en C++17 avec matrice fixe maison. Le binaire `kalman_demo` simule une trajectoire et applique les étapes predict/update à partir d’accélérations et mesures de position bruitées. Un wrapper `UdpSocket` minimal et un client brut (`kalman_client`) ont été ajoutés (bind/timeout/send/recv) pour sniffer le flux `imu-sensor-stream` dès qu’il sera disponible. Un mode `--udp` permet désormais d’écouter des paquets UDP `dt ax ay az mx my mz`, de mettre à jour le filtre et de renvoyer l’état en JSON. Reste à intégrer l’orientation, le parsing du flux réel et l’adaptation des bruits au sujet.

## Architecture
- `include/matrix.hpp` : matrice fixe avec +, -, *, transpose, inverse 3x3.
- `include/kalman.hpp` + `src/kalman.cpp` : filtre 6D (pos/vel), matrices F/B/H/Q/R configurables.
- `src/main.cpp` : scénario démo synthétique (affiche les états).
- `docs/model.md` : notes sur le modèle MVP et les prochaines extensions.
- `tests_realisation/run_unit.sh` : build + exécution rapide du démo et du test unitaire.
- `tests_realisation/test_kalman.cpp` : test de cohérence (predict/update de base).

## Utilisation
```bash
cd C/ft_kalman
make
./kalman_demo | head
```
ou via le script dédié :
```bash
./tests_realisation/run_unit.sh

# Client UDP brut (sniff/handshake)
make client
./kalman_client 127.0.0.1 4242 "HELLO" 3

# Boucle UDP simulée (écoute locale, renvoie l'état en JSON)
./kalman_demo --udp 4242 10   # lance le serveur (10 paquets max)
./scripts/mock_stream.py 4242 # envoie des mesures synthétiques et affiche les réponses
```

## Notes réseau (préparation)
- `include/udp.hpp` / `src/udp.cpp` fournissent un socket UDP RAII (bind, timeout, send/recv).
- À brancher sur `imu-sensor-stream` (CLI indiqué par le sujet : `./imu-sensor-stream -s <seed> -d <duration> -p <port>`). Handshake/parsing restent à déduire dès que le binaire sera accessible; en attendant, le mode `--udp` permet de tester la boucle avec des paquets texte.

## Prochaines étapes
1. Inspecter `imu-sensor-stream -h` et formaliser le format des paquets UDP (handshake + cadence). _(bloqué : binaire absent sur l'environnement actuel)_.
2. Étendre le modèle avec orientation (EKF) et biais IMU; normalisation quaternion.
3. Brancher la boucle réseau sur le vrai flux (parseur binaire/JSON selon protocole) en réutilisant la trame `--udp`.
4. Calibrer `Q`/`R` sur traces réelles et ajouter tests automatisés (comparaison à vérité terrain/sim). Ajouter un fetcheur de traces (`scripts/download_dataset.sh` fourni en squelette).
