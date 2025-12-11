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
4. Pendant la session 30 min : partager le contexte mentionné, les extraits listés et cocher chaque question avec le reviewer.
5. Après la session : regarder `notes/debrief.md`, remplir `notes/review_followup.md`, puis reporter les décisions dans `C/ft_linear_regression/progress.md`.

## Suivi post-review
- `notes/review_followup.md` accueille les actions décidées (scheduler, validation, visualisation) pour garder la trace de ce qui doit être implémenté dans `C/ft_linear_regression`.
- Documenter chaque changement (scripts/train, scripts/reports, docs) dans le follow-up pour accélérer la mise à jour du projet ciblé.

## Constat actuel
- Projet ciblé : `C/ft_linear_regression`, gradient descent stable (RMSE ≈ 410) mais hyperparamètres encore empiriques.
- Checklist prête : contexte descriptif, questions hiérarchisées, script de préparation renforcé (il alerte également quand `notes/debrief.md` est vide).
- Prochaine action : planifier la review avec un reviewer de la piscine pour valider scheduler/visualisation/validation, exécuter `scripts/prepare_review.sh` juste avant le créneau.
