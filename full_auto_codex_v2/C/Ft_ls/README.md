# ft_ls

## Synthèse préliminaire
Réimplémentation partielle de la commande `ls` en C selon le sujet 42. Le programme `ft_ls` doit lister le contenu des répertoires en respectant un sous-ensemble d’options (habituellement `-l`, `-R`, `-a`, `-r`, `-t`) et en se conformant aux règles de tri/affichage POSIX. Les contraintes principales portent sur la gestion des structures `stat`, la récursion, les formats d’affichage et la gestion d’erreurs.

## Architecture envisagée
- `include/ft_ls.h` — prototypes, structures de configuration (options, listes de fichiers).
- `src/` — parsing des options, collecte des entrées via `opendir/readdir`, tri, formatage long listing, récursion.
- `tests_realisation/` — scripts comparant `ft_ls` à `/bin/ls` sur des scénarios clés.
- `scripts/run_tests.sh` — orchestration automatisée des comparaisons.

## Contraintes identifiées (selon le sujet classique)
- Options supportées : `-l`, `-R`, `-a`, `-r`, `-t`.
- Respect de l’ordre des arguments : d’abord options, puis fichiers/répertoires.
- Tri alphabétique par défaut, inversion avec `-r`, tri par date avec `-t`.
- Format `-l` : droits, nombre de liens, propriétaire, groupe, taille, date formatée, nom.
- Gestion robuste des erreurs (`perror`, codes de retour) et d’entrées spéciales (`.` `..`).

## Prochaines étapes
1. Lire `Sujet_ft_ls.pdf` pour confirmer les options exactes et la portée.
2. Définir un plan (`PLAN.md`) : parsing, structures de données (listes chaînées ou tableau dynamique), stratégies de tri.
3. Mettre en place l’infrastructure (Makefile, headers, dossiers).  
4. Implémenter progressivement : parsing options, collecte, tri, affichage simple, puis options supplémentaires.
5. Construire un jeu de tests (`tests_realisation/`) comparant `ft_ls` à `ls` sur différents dossiers.

> Attention à la gestion des liens symboliques, permissions, et à la compatibilité des dates (utilisation de `strftime`).

## État courant
- Parsing des options `-l`, `-R`, `-a`, `-r`, `-t` opérationnel avec messages d'erreur conformes.
- Parcours de répertoires avec tri (`-r`, `-t`), affichage simple et long (`-l`) conformes ; option `-R` assurant la récursivité.
- Sortie détaillée (`-l`) et récursivité `-R` disponibles ; comparaison automatisée disponible via `./scripts/run_tests.sh` avec `/bin/ls`.

- `./scripts/run_tests.sh` — reconstruit le binaire et compare `ft_ls` avec `/bin/ls` sur les fixtures (`tests_realisation/fixtures`).
