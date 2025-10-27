# Plan de mise en œuvre Minishell

## Étape 1 – Infrastructure
- [x] Configurer le build (Makefile, règles norme 42, dépendances readline).
- [x] Mettre en place la structure `src/`, `include/`.
- [x] Ajouter scripts helper (`scripts/run_tests.sh`, `scripts/format.sh`).

## Étape 2 – Boucle interactive
- [x] Implémenter `main()` avec boucle `readline` + prompt dynamique.
- [x] Gérer `SIGINT`/`SIGQUIT` en mode interactif.
- [x] Stocker l'historique (readline).

## Étape 3 – Lexer & expansions simples
- [x] Tokeniser séquences (`|`, `<`, `>`, `<<`, `>>`).
- [x] Support des quotes `'"` et expansions associées.
- [x] Expansion `$?` et variables simples.

## Étape 4 – Parser
- [x] Construire AST (commandes, pipelines, redirections).
- [x] Détecter syntax errors avec codes retour corrects.

## Étape 5 – Exécution & builtins
- [x] Résolution des binaires via `PATH`.
- [x] Gestion redirections (`<`, `>`, `>>`, `<<`) avec pré-lecture des heredocs.
- [x] Implémenter builtins requis (exec parent si nécessaire). *(bonus possibles : builtins optionnels supplémentaires).* 
- [x] Expansions avancées (`~`, `~+`, `~-`, opérateur `export +=`).

## Étape 6 – Tests & validation
- [x] Tests unitaires (lexer/parser) avec `criterion` ou harness perso. *(couverture via `tests_realisation/unit_tests.py`)*
- [x] Tests end-to-end (scripts bash/expect vs bash). *(comparaison `e2e_tests.py` vs bash)*
- [x] Analyse mémoire via AddressSanitizer (`make SANITIZE=address` + suites automatiques).
- [ ] Analyse mémoire `valgrind` — outil absent sur l'environnement courant (à relancer dès installation).

## Étape 7 – Finition
- [ ] Norme 42 (norminette) — à exécuter dès que l'outil est disponible.
- [x] Documentation de travail (README, commandes tests) – relecture finale réalisée.
- [x] Binaire & archive prêtes pour rendu (`scripts/package_release.sh` générant `minishell_submission.tar.gz`).
