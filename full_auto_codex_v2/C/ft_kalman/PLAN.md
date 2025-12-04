# Plan de mise en œuvre ft_kalman

## Étape 1 – Analyse
- [x] Lire `Sujet_ft_kalman.pdf`, comprendre contraintes (latence, précision, bruit).
- [ ] Examiner `imu-sensor-stream -h` pour connaître protocole UDP exact. _(bloqué : binaire absent sur l'environnement actuel)_
- [ ] Rechercher rappels Kalman/Extended Kalman (docs perso).

## Étape 2 – Modélisation
- [x] Définir vecteur d’état (position, vitesse linéaires 3D pour MVP).
- [x] Déduire matrices F (transition), B (contrôle via acceleration), Q (process noise), H (measurement), R (measurement noise) en tenant compte des sigmas (valeurs par défaut à affiner).
- [ ] Décider representation orientation (Euler angles vs Quaternion) et conversions (non couvert dans MVP).

## Étape 3 – Infrastructure
- [x] Mettre en place build C++17 (Makefile) + binaire démo.
- [x] Implémenter bibliothèque matrice (taille fixe) minimale (opérations +, -, *, inverse 3x3).
- [ ] Créer wrappers UDP (socket connect, sendto/recvfrom, timeouts).

## Étape 4 – Implémentation filtre
- [x] Codifier étapes predict/update (Kalman linéaire 6D position/vitesse).
- [x] Gérer timestamps (delta t passé en paramètre).
- [ ] Normaliser orientation après update (en attente design orientation).
- [x] Ajouter tests unitaires rapides (cible `make test`).

## Étape 5 – Boucle application
- [ ] Handshake initial + parsing message init (bloqué sans `imu-sensor-stream`).
- [ ] Boucle : réception sensor packet -> update -> renvoi estimation -> logs.
- [ ] Gestion erreurs (timeout, estimation > 5m -> ajustement).

## Étape 6 – Tests & validation
- [ ] Script `scripts/run_sensor.sh` (lance `imu-sensor-stream` avec seed/duration) _(bloqué)_
- [ ] `tests_realisation/` : cas standard (90 min), bruit augmenté, latence.
- [x] Unit tests math (prédict/update) + bench latence (test minimal `kalman_test`).

## Étape 7 – Documentation
- [ ] `docs/model.md` (détails matrices, conversions).
- [ ] `README.md` mise à jour (usage, architecture finale).
- [ ] Visualisation bonus (optionnel, Python Matplotlib).
