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
- [x] Ajouter un scheduler ajustant dynamiquement le learning rate et logger un historique RMSE/learning_rate (JSON) pour alimenter l’analyse post-review.
- [ ] Introduire early stopping (patience, min delta) pour interrompre les runs quand le RMSE ne s’améliore plus, ce qui est utile pour la revue ft_helpme.

## Étape 4 – Programmes
- [x] `train.py` : parse dataset, exécuter gradient descent, sauvegarder `theta` + normalisation.
- [x] `predict.py` : charger `theta`, interagir (input user) ou via argument.
- [x] Scripts shell (`train.sh`, `predict.sh`, `run_tests.sh`) et `evaluate.py` (RMSE).

## Étape 5 – Tests
- [x] Dataset synthétique (généré) pour valider convergence (test unitaire).
- [x] Tests usage CLI (script shell) + documentation `tests_realisation/COMMANDS.md`.
- [ ] Ajouter `scripts/validation.py` : splits aléatoires, RMSE moyen, scheduler/validation config, utile pour la revue/coverage.

## Étape 6 – Bonus / Visualisation
- [x] Script `scripts/plot.py` (matplotlib) pour afficher points + droite.
- [x] Calcul RMSE (scripts/evaluate.py).
- [ ] Documenter `scripts/reports/rmse_plot.py` et l’intégrer dans la roadmap post-review.
*** End Patch
