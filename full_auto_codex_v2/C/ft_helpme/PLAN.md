# Plan de mise en œuvre ft_helpme

## Étape 1 – Analyse
- [x] Lire le sujet `ft_helpme.pdf` : projet centré sur la préparation/passage d’une review.
- [x] Identifier le projet principal à reviewer (ex: `ft_containers` ou autre en cours).
- [x] Recenser les blocages précis et les fichiers/code concernés.

## Étape 2 – Préparation review
- [x] Créer `notes/context.md` résumant le projet cible + état d’avancement.
- [x] Lister les questions dans `notes/questions.md` (priorisées).
- [ ] Collecter extraits `code/` si nécessaire.

## Étape 3 – Outils/logistique
- [x] Script `scripts/prepare_review.sh` (checklist : questions prêtes, build/test, logs).
- [ ] Template `notes/debrief.md` pour retour post-review.
- [x] Mettre à jour `README.md` avec les instructions (fait).

- ## Étape 4 – Passage de la review
- [ ] Planifier l’échange (30 min) sur 42 Intra.
- [ ] Pendant la session : partager questions, montrer code, prendre notes.
- [ ] Après session : remplir `notes/debrief.md`, compléter `notes/review_followup.md` et valider le suivi via `scripts/validate_followup.sh`.

## Étape 5 – Suivi
- [ ] Mettre à jour `progress.md` du projet principal en fonction des avancées.
- [ ] Ajouter `scripts/reports/rmse_plot.py` au dépôt (fait) et, après la session, l’utiliser une première fois pour résumer l’historique (passer la JSON générée par `scripts/train.sh`).
- [ ] Si besoin, prévoir une review de suivi.
