# Contexte review

- **Projet cible** : `C/ft_linear_regression`
- **État actuel** :
  - ~70 % d’avancement
  - Gradient descent batch opérationnel avec normalisation (features centrées / scale)
  - Scripts `train.sh`, `predict.sh`, `evaluate.py`, tests Pytest (`./scripts/run_tests.sh`)
  - RMSE actuelle sur dataset fourni : ~410 €
- **Blocages identifiés** :
  - Choix des hyperparamètres (learning rate / iterations) encore empiriques
  - Pas de visualisation des courbes d’apprentissage → difficile d’ajuster la convergence
  - Pas de métriques sur dataset de validation ; besoin conseil sur structuration dataset (train/test split)
  - Question sur amélioration du modèle (standardisation vs min-max, ajout normalisation automatique)

Objectif de la review : valider les choix mathématiques et identifier les améliorations pour convergence, visualisation et évaluation du modèle.
