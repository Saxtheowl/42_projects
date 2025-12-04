# ft_kalman

## Synthèse actuelle
Implémentation MVP d’un filtre de Kalman linéaire 6D (position/vitesse) en C++17 avec matrice fixe maison. Le binaire `kalman_demo` simule une trajectoire et applique les étapes predict/update à partir d’accélérations et mesures de position bruitées. Reste à intégrer l’orientation, le parsing du flux UDP et l’adaptation des bruits au sujet réel.

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
```

## Prochaines étapes
1. Inspecter `imu-sensor-stream -h` et formaliser le format des paquets UDP (handshake + cadence). _(bloqué : binaire absent sur l'environnement actuel)_
2. Étendre le modèle avec orientation (EKF) et biais IMU; normalisation quaternion.
3. Écrire la boucle réseau (recv capteurs -> update -> send estimation) avec timeouts.
4. Calibrer `Q`/`R` sur traces réelles et ajouter tests automatisés (comparaison à vérité terrain/sim). Ajouter un fetcheur de traces (`scripts/download_dataset.sh` fourni en squelette).
