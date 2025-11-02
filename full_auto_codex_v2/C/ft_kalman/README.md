# ft_kalman

## Synthèse préliminaire
Projet algorithmique : implémenter un filtre de Kalman pour estimer la trajectoire d’un véhicule en 3D à partir de mesures bruitées (accélération, gyroscope, GPS) transmises via UDP. Il faut maintenir précision (< 5 m d’erreur) et latence (< 1 s). Les données initiales sont envoyées après handshake; le programme répond avec estimations successives.

## Architecture visée (draft)
- `include/` — headers C++ (structures state, matrices, réseau).
- `src/` — modules :
  - `network.cpp` (socket UDP client, handshake, boucle IO),
  - `kalman.cpp` (predict/update, matrices F/Q/H/R),
  - `math.cpp` (lin alg minimal : matrices 9x9 etc),
  - `main.cpp` (point d’entrée),
  - `parser.cpp` (décodage messages capteurs).
- `docs/` — notes sur le filtre, bruits, conversions.
- `tests_realisation/` — scripts paramétrant le sensor-stream pour tests (latence, bruit élevé).
- `scripts/` — build + run (e.g. wrapper `./scripts/run_sensor.sh`).

## Hypothèses/MVP
- Implémentation C++17, sans lib externe (lin alg maison ou petite lib matricielle autorisée si statique).
- State vector (pos, vel, orientation?); measurement vector (GPS position, accelerations etc). Approche : Extended Kalman (linéaire via Jacobiennes) car orientation non linéaire.
- Utiliser chrono haute résolution pour respecter timing.

## Prochaines étapes
1. Étudier format exact messages `imu-sensor-stream` (parser structure, voir option `-h`).
2. Définir modèle d’état (12D ? 9D ?) et matrices F, Q, H, R.
3. Implémenter math utils (matrices, inversions, Quaternions/Euler conversions).
4. Intégrer boucle réseau (UDP read -> update -> send). Gestion timeouts/erreurs.
5. Scripts tests + doc (comment lancer stream + analyser log). Ajout visualisation bonus possible (Python).

> Étape critique : validation math (unit tests sur predict/update) avant intégration réseau.
