# Debrief review ft_helpme

- **Date / Reviewer** : (prévu) 2025-12-11 15h00, reviewer à confirmer.
- **Projet concerné** : `C/ft_linear_regression` (tuning gradient descent + validation).
- **Questions abordées** :
  - Q1 (hyperparamètres) : noter les recommandations sur scheduler/early stopping + heuristiques de batch.
  - Q2 (validation) : synthèse des options de split/validation croisée pour dataset réduit + idée de boostrap simple.
  - Q3 (visualisation) : outils à brancher (matplotlib/seaborn) pour suivre RMSE et ajouts.
- **Actions à mener après la review** :
  - [ ] Intégrer la stratégie de scheduler validée (`scripts/train.sh`).
  - [ ] Ajouter un module de visualisation (courbes RMSE + droite d’ajustement) dans `scripts/reports/`.
  - [ ] Documenter la nouvelle validation (train/test/boot) dans `notes/review_followup.md`.
- **Feedback global** :
  - Ce qui a permis de débloquer : hypothèses sur learning rate + trace RMSE.
  - Points à creuser plus tard : regularisation, détection d’overfitting, pipeline de tests.
