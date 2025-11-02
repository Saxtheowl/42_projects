# Plan de mise en œuvre ft_kalman

## Étape 1 – Analyse
- [x] Lire `Sujet_ft_kalman.pdf`, comprendre contraintes (latence, précision, bruit).
- [ ] Examiner `imu-sensor-stream -h` pour connaître protocole UDP exact.
- [ ] Rechercher rappels Kalman/Extended Kalman (docs perso).

## Étape 2 – Modélisation
- [ ] Définir vecteur d’état (position, vitesse, orientation).
- [ ] Déduire matrices F (transition), B (contrôle via acceleration), Q (process noise), H (measurement), R (measurement noise) en tenant compte des sigmas.
- [ ] Décider representation orientation (Euler angles vs Quaternion) et conversions.

## Étape 3 – Infrastructure
- [ ] Mettre en place build C++17 (CMake ou Makefile) + tests unitaires.
- [ ] Implémenter bibliothèque matrice (taille fixe) ou intégrer lib autorisée (Eigen? statique).
- [ ] Créer wrappers UDP (socket connect, sendto/recvfrom, timeouts).

## Étape 4 – Implémentation filtre
- [ ] Codifier étapes predict/update (kalman classique ou EKF).
- [ ] Gérer timestamps (delta t variable based on sensor sampling).
- [ ] Normaliser orientation après update.

## Étape 5 – Boucle application
- [ ] Handshake initial + parsing message init.
- [ ] Boucle : réception sensor packet -> update -> renvoi estimation -> logs.
- [ ] Gestion erreurs (timeout, estimation > 5m -> ajustement).

## Étape 6 – Tests & validation
- [ ] Script `scripts/run_sensor.sh` (lance `imu-sensor-stream` avec seed/duration).
- [ ] `tests_realisation/` : cas standard (90 min), bruit augmenté, latence.
- [ ] Unit tests math (prédict update) + bench latence.

## Étape 7 – Documentation
- [ ] `docs/model.md` (détails matrices, conversions).
- [ ] `README.md` mise à jour (usage, architecture finale).
- [ ] Visualisation bonus (optionnel, Python Matplotlib).
