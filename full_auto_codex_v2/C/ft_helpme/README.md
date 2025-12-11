# ft_helpme

## Synthèse
Projet d’accompagnement pédagogique : il ne s’agit pas de livrer du code, mais de préparer une session d’aide structurée avec un pair. L’objectif est de formaliser ses blocages sur un projet principal, lister les questions précises et organiser la review (30 minutes). On peut déposer dans le dépôt `ft_helpme` des extraits de code du projet bloqué ou des notes qui faciliteront l’échange.

## Démarche proposée
1. Identifier le projet sur lequel on est bloqué (ex : `ft_containers`).
2. Lister les points de blocage (fichier/code précis, message d’erreur, design API…).
3. Préparer les questions ouvertes à poser au reviewer.
4. Déposer dans ce repo :
   - `notes/questions.md` — liste ordonnée des questions,
   - `code/` — extraits ciblés du projet concerné (facultatif),
   - `diary.md` — retour de session pour capitaliser.
5. Planifier la review 42Net (30 minutes) et consigner le feedback.

## Structure recommandée
- `notes/questions.md` — questions & hypothèses.
- `notes/context.md` — résumé du projet bloqué + étapes déjà tentées.
- `code/` — extraits anonymisés pour discussion (optionnel).
- `scripts/prepare_review.sh` — script rappelant la checklist (questions, logs, timing).
- `README.md` (ce fichier) — guide synthétique.

## Prochaines étapes
1. Sélectionner le projet bloqué actuel et décrire le contexte (`notes/context.md` occupe la place de `ft_linear_regression` pour le moment).
2. Rédiger les questions en priorité (celles présentes dans `notes/questions.md` ciblent les hyperparamètres, la validation et la visualisation).
3. Lancer `scripts/prepare_review.sh` pour vérifier la check-list (questions, contexte, éventuels extraits + débrief déjà rédigé) avant la review.
4. Pendant la session 30 min (planifiée 2025-12-12 15h avec reviewer 42Net) : partager le contexte, les extraits, cocher chaque question et noter les réponses dans `notes/debrief.md`.
5. Après la session : remplir à jour `notes/review_followup.md`, reporter les décisions dans `C/ft_linear_regression/progress.md` et lancer les actions follow-up (scheduler, validation, visualisation) ; consigner les conclusions dans `notes/review_outcome.md` (exponentiel/decay, rmse plot, validation folds).

## Suivi post-review
- `notes/review_followup.md` accueille les actions décidées (scheduler, validation, visualisation) pour garder la trace de ce qui doit être implémenté dans `C/ft_linear_regression`.
- Documenter chaque changement (scripts/train, scripts/reports, docs) dans le follow-up pour accélérer la mise à jour du projet ciblé.
- Avant de lancer la session, exécuter `scripts/prepare_review.sh`.
- Pendant la revue 30 min, partager l’extrait `code/gradient_notes.md`, `src/train.py` et `scripts/evaluate.py` pour illustrer les hyperparamètres et la métrique RMSE.
- Après avoir complété les réponses, valider le follow-up avec `scripts/validate_followup.sh` pour vérifier que les mots-clés scheduler/rmse_plot/validation sont bien présents et que `notes/debrief.md` n’est pas vide.
- Visualisation RMSE : `scripts/reports/rmse_plot.py path/to/history.json [--png plot.png]` lit l’historique JSON du gradient descent, affiche un résumé (avg/best/worst RMSE), trace un sparkline ASCII et peut enregistrer un PNG si `matplotlib` est disponible.
- Validation folds : `python3 C/ft_linear_regression/scripts/validation.py data/data.csv --folds 5 --test-size 0.2 --learning-rate 0.1 --iterations 1000 --scheduler exponential --decay 0.95` to show RMSE per split; the review concluded this configuration keeps RMSE stable and is now recorded in `notes/review_outcome.md`.
- Validation folds : `python3 C/ft_linear_regression/scripts/validation.py data/data.csv --folds 5 --test-size 0.2 --learning-rate 0.1 --iterations 1000` démontre l’impact du scheduler/validation, et les RMSE par fold seront commentés pendant la review.
- Avant de partager les artefacts, utilisez `python3 C/ft_linear_regression/scripts/preview_validation.py --archive` : il régénère `docs/validation_summary.*`, relance `scripts/check_validation_stability.py` (avg<1200) et archive le HTML dans `docs/archive/`, donnant au reviewer un snapshot figé à valider.
- Pour éviter que le dossier `docs/archive/` ne grossisse indéfiniment, purge les snapshots éventuels en lançant `python3 C/ft_linear_regression/scripts/prune_validation_archives.py --days 30` (ajustez le nombre de jours) avant la revue.
- Après avoir archivé un snapshot, lancez `python3 C/ft_linear_regression/scripts/verify_archive_summary.py` pour confirmer que la dernière archive reflète bien `docs/validation_summary.json` (best/worst/average RMSE) avant de l’envoyer au reviewer.
- Le trio `preview_validation.py --archive`, `prune_validation_archives.py`, `verify_archive_summary.py` peut être lancé ensemble via `python3 C/ft_linear_regression/scripts/refresh_validation_artifacts.py` pour simplifier la préparation des artefacts juste avant la session.
- Besoin de fournir le résumé dans un tableau ou une CI simple ? Exécutez `python3 C/ft_linear_regression/scripts/export_validation_summary_csv.py` pour générer `docs/validation_summary.csv` (timestamp, fold count, best/worst/average) destiné à la revue ou à l’intégration avec vos outils automation.
- Le pipeline `scripts/refresh_validation_artifacts.py` exécute aussi cette exportation CSV après les étapes preview/prune/verify pour que chaque partage de snapshot inclue la table `docs/validation_summary.csv`.

## Constat actuel
- Projet ciblé : `C/ft_linear_regression`, gradient descent stable (RMSE ≈ 410) mais hyperparamètres encore empiriques.
- Checklist prête : contexte descriptif, questions hiérarchisées, script de préparation renforcé (il alerte également quand `notes/debrief.md` est vide).
- Prochaine action : planifier la review avec un reviewer de la piscine pour valider scheduler/visualisation/validation, exécuter `scripts/prepare_review.sh` juste avant le créneau.

## Retour sur la review 12/12/2025 15h
- Session 42Net réalisée : `notes/debrief.md` détaille les questions traitées (scheduler/early stopping, validation, visualisation) et les réponses apportées.
- `notes/review_outcome.md` synthétise les décisions validées : scheduler `exponential` + `decay 0.95`, suivi RMSE via `data/history.json`/`scripts/reports/rmse_plot.py`, validation folds + bootstrap relevés par `scripts/validation.py`.
- Pour chaque validation run, `docs/validation_summary.txt` est maintenant partagé : il résume best/worst fold + moyenne sans refaire tourner les splits, donc la revue peut attester la stabilité RMSE sans relancer `scripts/validation.py`. On y appose aussi `scripts/check_validation_stability.py` (avg=978.62) comme vérification complémentaire avant d’envoyer les artefacts au reviewer.
- `notes/review_followup.md` a été mis à jour pour marquer les points traités et la checklist `scripts/validate_followup.sh` garantit la présence de `scheduler`, `rmse_plot` et `validation` dans les artefacts.
- Le suivi post-review reste ouvert : tant que `C/ft_linear_regression` continue de s'améliorer, on garde la session inscrite ici et on utilise la documentation pour guider les prochains échanges.
