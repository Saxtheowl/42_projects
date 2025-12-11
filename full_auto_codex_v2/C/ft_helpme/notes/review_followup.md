# Review follow-up actions

Ce document capture les décisions validées pendant la review et les tâches concrètes à exécuter sur `C/ft_linear_regression`.

## À valider pendant la review
- [x] Choix du scheduler LR (exponentiel, plateau ou cosine annealing) + seuils d'early stopping.
- [x] Fractionnement dataset limité : recommandation (k-fold minimal), éventuellement bootstrapping ou augmentation synthétique.
- [x] Visualisation des courbes : outils (matplotlib/seaborn) + fréquence de sortie (chaque époch ou log RMSE).

## Actions prévues post-review
1. Implémenter le scheduler approuvé (`scripts/train.sh` ou module `lr_scheduler.py`). *(en place : `scripts/train.sh` conserve les options recommandées, `train.py` expose `--scheduler exponential`, `--decay 0.95`, `--min-lr`.)*
2. Ajouter `scripts/reports/rmse_plot.py` et intégrer dans le `train` (sauvegarder plot PNG + historique JSON). *(script ajouté ; `train.sh` génère désormais `data/history.json` et on peut produire un PNG via la commande documentée.)*
3. Documenter la stratégie validation (split + metrics) dans `notes/review_followup.md` et `C/ft_linear_regression/README.md`. *(validation commandée (k-fold + bootstrap idée) via `scripts/validation.py`; README mise à jour pour rappeler ces étapes.)*
4. Mettre à jour `notes/debrief.md` pour consigner les réponses apportées pendant la review. *(débrief rempli et référencé dans `notes/review_outcome.md`/README. )*

## Artefacts de validation
- `docs/validation_summary.txt` et `docs/validation_summary.md` dans `ft_linear_regression` résument best/worst/average RMSE (timestampé) ; partager ces fichiers avec le reviewer permet de prouver la stabilité des splits sans relancer `scripts/validation.py`.

## Notes
- Penser à lier chaque action à un ticket ou issue dans `ft_linear_regression` pour le suivi.
- Garder la session de review sous 30 minutes : équipe 42Net notified, préparation prête.
