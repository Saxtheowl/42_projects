# Minishell – Jeux de tests

- `make` : compile le binaire `minishell` (stub interne si `readline` absente).
- `make USE_SYSTEM_READLINE=1` : compile en liant la `libreadline` système (si disponible).
- `./scripts/run_tests.sh` *(stub actuel)* : rappelle les suites prévues (unitaires + intégration).
- `./tests_realisation/run_unit_tests.sh` *(à créer)* : exécute les tests unitaires (lexer/parser).
- `./tests_realisation/run_e2e_tests.sh` *(à créer)* : scénarios end-to-end via `bash` ou `expect`.
- `printf 'echo $USER\n' | ./minishell` : vérifie rapidement la génération de tokens (expansion + pipe).
- `printf 'cat |\n' | ./minishell` : valide la détection d'une erreur de syntaxe (pipeline incomplet).
- `printf 'echo foo | tr a-z A-Z\n' | ./minishell` : teste l’exécution d’un pipeline simple.
- `printf 'echo hi > /tmp/minishell_test.txt\n' | ./minishell` : vérifie la redirection de sortie (penser à nettoyer `/tmp/minishell_test.txt`).
- `printf 'exit 2\n' | ./minishell ; echo $?` : contrôle le statut de sortie du builtin `exit`.
- `printf 'export MINI=42\nunset MINI\n' | ./minishell` : vérifie la persistance des variables et la suppression via `unset`.
- `printf 'cd ..\ncd -\n' | ./minishell` : contrôle la mise à jour de `PWD`/`OLDPWD`.

> Compléter ce fichier au fur et à mesure de l’implémentation.
