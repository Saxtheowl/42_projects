# mod1 – Simulateur de surface et d’écoulement d’eau

## Synthèse
- Génération d’un relief continu à partir de points de contrôle `.mod1` (interpolation IDW).
- Trois scénarios d’animation fournis : montée uniforme, vague progressive, pluie + ruissellement.
- Rendu ASCII PPM sans dépendances externes : chaque frame est un fichier `*.ppm` listant les couleurs RGB.
- Outil en Python 3 avec exécutable `./mod1` qui gère la génération complète.

## Étapes principales
- Parse des fichiers `.mod1`, calcul des bornes et interpolation inverse-distance pour obtenir une grille régulière (`terrain.py`).
- Moteur d’eau : montée uniforme, propagation de vague, pluie + diffusion latérale (`water.py`, `scenarios.py`).
- Génération d’images PPM colorisées (relief vs eau) dans des dossiers dédiés (`renderer.py`).
- Tests unitaires (parser, interpolation, diffusion d’eau) pour sécuriser les comportements clés.

## Compilation / Installation
Pas de compilation nécessaire (Python 3 standard). Vérifier que le script est exécutable :
```sh
chmod +x mod1
```

## Exécution
```sh
./mod1 resources/example.mod1 --scenario all --frames 30 --resolution 64 --output outputs
```
- `--scenario` : `uniform`, `wave`, `rain` ou `all` (défaut).
- `--frames` : nombre d’images générées par scénario (défaut 60).
- `--resolution` : taille de la grille utilisée pour l’interpolation (défaut 64).
- `--output` : dossier où les frames PPM sont écrites (`outputs/` par défaut).
- Les images produites peuvent être visualisées par n’importe quel lecteur compatible PPM ou converties en GIF via `convert frame_*.ppm animation.gif`.

## Tests
```sh
python3 tests_realisation/run_tests.py
```
- Lance `unittest` sur la suite située dans `tests_realisation/`.
- Les commandes récapitulatives sont disponibles dans `tests_realisation/COMMANDES.md`.
