# Plan ft_linear_regression

## Étape 1 – Analyse
- [x] Lire `Sujet_ft_linear_regression.pdf`.
- [x] Choisir format dataset (CSV `mileage,price`).

## Étape 2 – Infrastructure
- [x] Écrire loader CSV (`src/utils.py`).
- [x] Gérer sauvegarde `theta.json`.
- [x] Setup CLI (argparse) pour train/predict.

## Étape 3 – Gradient Descent
- [x] implémenter `estimate_price(theta, mileage)`.
- [x] implémenter `gradient_step` selon formules.
- [x] Config learning rate, iterations ; support normalisation.

## Étape 4 – Programmes
- [x] `train.py` : parse dataset, exécuter gradient descent, sauvegarder `theta` + normalisation.
- [x] `predict.py` : charger `theta`, interagir (input user) ou via argument.
- [x] Scripts shell (`train.sh`, `predict.sh`, `run_tests.sh`) et `evaluate.py` (RMSE).

## Étape 5 – Tests
- [x] Dataset synthétique (généré) pour valider convergence (test unitaire).
- [x] Tests usage CLI (script shell) + documentation `tests_realisation/COMMANDS.md`.

## Étape 6 – Bonus / Visualisation
- [ ] Script `scripts/plot.py` (matplotlib) pour afficher points + droite.
- [ ] Calcul RMSE (scripts/evaluate.py).
*** End Patch
