# Minishell

## Synthèse
Création d'un mini shell POSIX‐like en C respectant la norme 42. L’objectif est de reproduire une boucle `read → parse → execute` proche de `bash`, avec gestion des redirections, pipes, variables d’environnement et gestion fine des erreurs/signal. État actuel : boucle interactive + lexeur + parser opérationnels, exécution des commandes externes (pipes, redirections) et premiers builtins (`echo`, `pwd`, `env`, `exit`). `heredoc`, `cd`, `export`, `unset` restent à implémenter.

## Architecture ciblée
- `src/main.c` : boucle principale (lecture ligne, dispatch).
- `src/lexer/` : tokenisation (quotes, métacaractères, expansions).
- `src/parser/` : construction d’un AST (pipeline, redirections, commandes simples).
- `src/executor/` : exécution des commandes (fork/exec, redirections, pipelines). *Heredoc en attente, gestion signaux enfants à affiner.*
- `src/builtins/` : `echo`, `cd`, `pwd`, `export`, `unset`, `env`, `exit` (implémentés côté parent quand requis).
- `src/env/` : gestion des variables d’environnement et `SHLVL`.
- `src/signals/` : configuration des gestionnaires (mode interactif / fork).
- `include/` : en-têtes publiques (AST, contextes d’exécution, protos).
- `tests_realisation/` : scripts de tests automatisés (unitaires + end-to-end).
- `scripts/format.sh`, `scripts/run_tests.sh` (à définir) : outils de build/test.

## Approche de réalisation
1. **Bootstrap** : implémenter lecture + affichage prompt minimal (`readline`) avec gestion signaux interactifs. ✅
2. **Lexer** : produire une liste de tokens (mots, opérateurs, redirections) avec gestion quoting et séquences spéciales (`$?`, `$VAR`). ✅
3. **Parser** : convertir les tokens en AST (commandes simples, pipelines, redirections) en respectant la priorité syntaxique. ✅
4. **Executor** : exécuter l’AST (fork/exec, pipes, redirections, fermeture fd). 🔄 *(Heredoc à couvrir, gestion signaux enfants à affiner.)*
5. **Builtins** : implémenter les builtins requis (exécuter dans le processus parent quand nécessaire). 🔄 *(`echo`, `pwd`, `env`, `exit`, `cd`, `export`, `unset` faits ; reste `export +=`, validations avancées, variables spéciales).* 
6. **Expansions avancées** : variables, `~`, suppression quotes après expansion.
7. **Tests** : ajouter harness tests (unitaires + scénarios end-to-end via expect/bash).
8. **Durcissement** : gestion exhaustive des erreurs, fuite mémoire (valgrind), conformité norme.

## Commandes utiles
- `make` : compile `minishell` (utilise un stub interne si `readline` n’est pas disponible sur le système).
- `make USE_SYSTEM_READLINE=1` : force la compilation avec la `libreadline` système (`-lreadline -lncurses`).
- `make run` : exécute le binaire compilé.
- `make clean` / `make fclean` / `make re` : gestion des artefacts de build.

> Sans `libreadline`, le stub interne repose sur `getline(3)` : l’historique est local au processus (non persistant).

## Tests
Les scripts de tests seront placés dans `tests_realisation/`. Un fichier `COMMANDS.md` recense les commandes à exécuter (voir plus bas). À ce stade, seul le squelette des scripts (`scripts/run_tests.sh`) est disponible et affiche les suites prévues.

Vérifications manuelles rapides :
```bash
make && printf 'echo $USER | cat\n' | ./minishell
printf 'echo hi > /tmp/minishell_test.txt\n' | ./minishell
printf 'echo foo | tr a-z A-Z\n' | ./minishell
printf 'export MINI=42\nunset MINI\n' | ./minishell
printf 'cd ..\ncd -\n' | ./minishell
printf 'cat |\n' | ./minishell        # erreur de syntaxe attendue
```
(`make fclean` ensuite pour nettoyer.)

## PDF
- `Sujet_Minishell.pdf` (module principal, lien symbolique vers le sujet d’origine).
