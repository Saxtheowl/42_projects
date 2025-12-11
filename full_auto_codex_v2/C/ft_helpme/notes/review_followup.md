# Review follow-up actions

Ce document capture les décisions validées pendant la review et les tâches concrètes à exécuter sur `C/ft_linear_regression`.

## À valider pendant la review
- [ ] Choix du scheduler LR (exponentiel, plateau ou cosine annealing) + seuils d'early stopping.
- [ ] Fractionnement dataset limité : recommandation (k-fold minimal), éventuellement bootstrapping ou augmentation synthétique.
- [ ] Visualisation des courbes : outils (matplotlib/seaborn) + fréquence de sortie (chaque époch ou log RMSE).

## Actions prévues post-review
1. Implémenter le scheduler approuvé (`scripts/train.sh` ou module `lr_scheduler.py`).
2. Ajouter `scripts/reports/rmse_plot.py` et intégrer dans le `train` (sauvegarder plot PNG + historique JSON).
3. Documenter la stratégie validation (split + metrics) dans `notes/review_followup.md` et `C/ft_linear_regression/README.md`.
4. Mettre à jour `notes/debrief.md` pour consigner les réponses apportées pendant la review.

## Notes
- Penser à lier chaque action à un ticket ou issue dans `ft_linear_regression` pour le suivi.
- Garder la session de review sous 30 minutes : équipe 42Net notified, préparation prête.
