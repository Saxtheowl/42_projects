# ft_linear_regression

## Synthèse
Mini-projet de machine learning : implémenter une régression linéaire univariée (prix de voiture vs kilométrage). Deux programmes :
1. `train.py` — entraîne le modèle via gradient descent et persiste les paramètres.
2. `predict.py` — charge le modèle et renvoie un prix estimé pour un kilométrage donné.

## Contraintes principales
- Langage libre, mais interdiction d’utiliser une fonction qui résout directement la régression (`numpy.polyfit`, etc.).
- Utiliser les formules de gradient descent fournies dans le sujet.
- Initialiser `theta0` et `theta1` à 0 avant le premier entraînement.

## Architecture
- `data/data.csv` — jeu d’entraînement (kilométrage en km, prix en €).
- `src/utils.py` — chargement CSV, sauvegarde du modèle (`theta.json`) avec moyenne/échelle pour la normalisation.
- `src/train.py` — gradient descent batch (normalise la feature avant apprentissage).
- `src/predict.py` — CLI interactive ou via argument (utilise les paramètres appris).
- `scripts/` —
  - `train.sh`, `predict.sh` : raccourcis pour lancer les programmes,
  - `run_tests.sh` : exécute Pytest,
  - `evaluate.py` : calcule la RMSE sur un dataset donné,
  - `plot.py` : trace le nuage de points et la droite apprise.
- `tests_realisation/` — tests Pytest + `COMMANDS.md` listant les commandes de validation.

## Installation
```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

## Entraînement & utilisation
```bash
# Entraînement (met à jour data/theta.json)
./scripts/train.sh --learning-rate 0.1 --iterations 1000 --scheduler linear --decay 0.95

# Prédiction (argument ou invite utilisateur)
./scripts/predict.sh --mileage 65000

# Qualité du modèle (RMSE)
./scripts/evaluate.py data/data.csv

# Visualisation
./scripts/plot.py --output plots/regression.png
```

## Tests
```bash
./scripts/run_tests.sh
```
Les tests incluent un dataset synthétique (`y = 2x + 1`) pour vérifier la convergence de l’algorithme.

## Stratégie & métriques
- De nouvelles options `--scheduler {constant,linear,exponential}`, `--decay`, `--min-lr` pilotent le comportement du learning rate pendant l’entraînement ; vous pouvez combiner `linear`/`exponential` avec la commande `./scripts/train.sh` pour voir l’impact sur la convergence.
- Le flag `--history path` (automatiquement `data/history.json` via `scripts/train.sh`) enregistre l’historique RMSE/learning_rate par itération. Utilisez `scripts/reports/rmse_plot.py data/history.json [--png output.png]` pour synthétiser la courbe (résumé, sparkline ASCII, option PNG si `matplotlib` est installé).

## Notes
- Les kilométrages sont normalisés (centrés puis divisés par l’étendue) pour stabiliser le gradient.
- Les paramètres `theta`, la moyenne et l’échelle sont sauvegardés dans `data/theta.json`.
- Bonus envisageables : script de visualisation (matplotlib) ou métriques supplémentaires.
