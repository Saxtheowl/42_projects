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
1. Sélectionner le projet bloqué actuel et décrire le contexte.
2. Rédiger les questions rédigées en amont.
3. Utiliser le script de préparation pour vérifier que tout est prêt avant la review.
4. Après la session, remplir `notes/debrief.md` (ce document sera utilisé pour alimenter `progress.md` du projet concerné).
