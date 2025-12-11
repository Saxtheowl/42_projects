# Extrait pour la review

Ce document extrait décrit les morceaux clés du modèle `ft_linear_regression` pour la review.

## `src/train.py`
- Fonction `gradient_step(data, params)` : calcule `rmse` et met à jour `params` via `lr * grad`.
- Commentaire : on note que le learning rate actuel est 0.1 et que les gradients oscillent légèrement après 1000 itérations ; la review cherchera à valider le scheduler/early stopping.

## `scripts/evaluate.py`
- Compare `predict.csv` vs `target.csv` et affiche le RMSE.
- À partager pour illustrer la métrique de suivi.

## Points à montrer
1. Le log `training.log` (RMSE, epoch) pour expliquer la courbe à tracer.
2. Le fichier `scripts/train.sh` montrant les paramètres actuels (lr, epochs, seed).
3. Le module `scripts/reports/rmse_plot.py` (nouveau) qui pourra produire un PNG pour la review.
