# Debrief review ft_helpme

- **Date / Reviewer** : planifié 2025-12-12 15h00 avec un reviewer 42Net.
- **Projet concerné** : `C/ft_linear_regression` (tuning gradient descent + validation).
- **Questions abordées** :
  - Q1 (hyperparamètres) : recommendations sur scheduler/early stopping + heuristiques de batch.
  - Q2 (validation) : options de split + bootstrap pour un dataset réduit ; métriques minimales.
  - Q3 (visualisation) : intégration Matplotlib/Seaborn pour tracer RMSE/la droite d’ajustement.
- **Actions à mener après la review** :
  - [ ] Implémenter le scheduler validé dans `scripts/train.sh`, documenter ses paramètres et les valeurs conseillées.
  - [ ] Ajouter `scripts/reports/rmse_plot.py` (PNG + historique JSON) pour suivre RMSE & droite lors des runs.
  - [ ] Mettre à jour `notes/review_followup.md` et `C/ft_linear_regression/README.md` avec la nouvelle stratégie de validation (split, bootstrap, metrics).
- **Feedback global** :
  - Ce qui a permis de débloquer : priorisation des questions sur hyperparamètres, visualisation, validation.
  - Points à creuser plus tard : regularization, détection d’overfitting, tests de convergence rapides.
