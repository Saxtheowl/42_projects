# Questions pour la review

1. *(Priorité haute)*
   - **Sujet** : réglage hyperparamètres gradient descent (`src/train.py`).
   - **Contexte** : learning rate 0.1 + 1000 itérations → RMSE ~410 €, convergence mais oscillations possibles.
   - **Tests déjà faits** : grid search rapide (1e-3 à 0.5) ; normalisation min-max (mean/scale) appliquée.
   - **Question** : quelles stratégies recommander pour ajuster automatiquement le learning rate (scheduler, early stopping) dans ce contexte univarié ?

2. *(Priorité moyenne)*
   - **Sujet** : séparation train/test et évaluation.
   - **Contexte** : dataset unique de 10 lignes. Besoin d’un protocole simple pour éviter overfitting.
   - **Question** : comment structurer le dataset / synthétiser des données supplémentaires pour valider le modèle ? Idées de validation croisée adaptée ?

3. *(Bonus)*
   - **Sujet** : Visualisation & UX.
   - **Question** : recommandation outils (matplotlib / seaborn) et intégration dans workflow pour tracer la droite d’ajustement + courbe d’erreur à chaque itération.

Prévoir : montrer `src/train.py` (calc gradient), `scripts/evaluate.py`, logs RMSE.
