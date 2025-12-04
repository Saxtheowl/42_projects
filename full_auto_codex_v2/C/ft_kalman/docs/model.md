## Modèle MVP

- Vecteur d'état 6D : position `(x, y, z)` et vitesse `(vx, vy, vz)`.
- Matrices :
  - `F` transition discrète avec intégration constante de la vitesse (dt) ;
  - `B` contrôle pour accélérations (0.5·dt² sur position, dt sur vitesse) ;
  - `H` observation directe de la position (mesure GPS-like) ;
  - `Q` bruit de processus isotrope (tunable, valeur par défaut 0.05) ;
  - `R` bruit de mesure position (sigma ≈ 2 m -> variance 4).
- Pas de rotation/orientation dans cette itération (extension EKF à prévoir).

## À valider
- Ajuster `Q`/`R` à partir de la variance réelle des capteurs.
- Étendre le modèle pour inclure orientation (quaternion) et biais IMU.
- Comparer output avec flux réel `imu-sensor-stream` (scripts à écrire).
