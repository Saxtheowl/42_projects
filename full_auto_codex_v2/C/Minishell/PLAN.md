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
- [x] Gestion redirections (`<`, `>`, `>>`). *(Heredoc à implémenter.)*
- [ ] Implémenter builtins requis (exec parent si nécessaire). *(`echo`, `pwd`, `env`, `exit` faits ; `cd`, `export`, `unset` à venir).*

## Étape 6 – Tests & validation
- [ ] Tests unitaires (lexer/parser) avec `criterion` ou harness perso.
- [ ] Tests end-to-end (scripts bash/expect vs bash).
- [ ] Analyse mémoire (`valgrind`), fuites et erreurs.

## Étape 7 – Finition
- [ ] Norme 42 (norminette).
- [ ] Documentation finale (README, commandes tests).
- [ ] Binaire & archive prêtes pour rendu.
