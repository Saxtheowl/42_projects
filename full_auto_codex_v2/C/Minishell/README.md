# Minishell

## Synthèse
Création d'un mini shell POSIX‐like en C respectant la norme 42. L’objectif est de reproduire une boucle `read → parse → execute` proche de `bash`, avec gestion des redirections, pipes, variables d’environnement et gestion fine des erreurs/signal. État actuel : boucle interactive + lexeur + parser stabilisés, exécution des commandes externes (pipes, redirections, heredoc pré-collectés), ensemble des builtins requis (`echo`, `pwd`, `env`, `exit`, `cd`, `export`, `unset`) et expansions avancées clés (`~`, `~+`, `~-`, opérateur `export +=`). Un harness de tests (unit + e2e) permet de valider les principaux comportements ; restent à mener la campagne valgrind et la mise en conformité norme 42.

## Architecture ciblée
- `src/main.c` : boucle principale (lecture ligne, dispatch).
- `src/lexer/` : tokenisation (quotes, métacaractères, expansions).
- `src/parser/` : construction d’un AST (pipeline, redirections, commandes simples).
- `src/executor/` : exécution des commandes (fork/exec, redirections, pipelines) avec pré-lecture des heredocs côté parent et restauration des signaux en mode enfant.
- `src/builtins/` : `echo`, `cd`, `pwd`, `export`, `unset`, `env`, `exit` (implémentés côté parent quand requis).
- `src/env/` : gestion des variables d’environnement et `SHLVL`.
- `src/signals/` : configuration des gestionnaires (mode interactif / fork).
- `include/` : en-têtes publiques (AST, contextes d’exécution, protos).
- `tests_realisation/` : scripts de tests automatisés (unitaires + end-to-end, Python).
- `scripts/format.sh`, `scripts/run_tests.sh` : outils de formatage/validation (`run_tests.sh` orchestre toutes les suites).

## Approche de réalisation
1. **Bootstrap** : implémenter lecture + affichage prompt minimal (`readline`) avec gestion signaux interactifs. ✅
2. **Lexer** : produire une liste de tokens (mots, opérateurs, redirections) avec gestion quoting et séquences spéciales (`$?`, `$VAR`). ✅
3. **Parser** : convertir les tokens en AST (commandes simples, pipelines, redirections) en respectant la priorité syntaxique. ✅
4. **Executor** : exécuter l’AST (fork/exec, pipes, redirections, fermeture fd). ✅ *(heredoc pré-collectés dans le parent, signaux enfants restaurés).* 
5. **Builtins** : implémenter les builtins requis (exécuter dans le processus parent quand nécessaire). ✅ *(core terminé, append `export +=` inclus).* 
6. **Expansions avancées** : variables, `~`, suppression quotes après expansion. ✅ *(prise en charge `~`, `~+`, `~-`, append `export +=`).*
7. **Tests** : ajouter harness tests (unitaires + scénarios end-to-end via expect/bash). ✅ *(scripts Python + wrappers shell)*
8. **Durcissement** : gestion exhaustive des erreurs, fuite mémoire (valgrind), conformité norme.

## Commandes utiles
- `make` : compile `minishell` (utilise un stub interne si `readline` n’est pas disponible sur le système).
- `make USE_SYSTEM_READLINE=1` : force la compilation avec la `libreadline` système (`-lreadline -lncurses`).
- `make run` : exécute le binaire compilé.
- `make clean` / `make fclean` / `make re` : gestion des artefacts de build.
- `make SANITIZE=address` : build instrumenté AddressSanitizer.
- `./scripts/package_release.sh [nom_archive]` : produit une archive tar.gz prête pour un rendu (par défaut `minishell_submission.tar.gz`).
- `./scripts/run_valgrind.sh` : fumigènes mémoire (échoue si `valgrind` absent).

> Sans `libreadline`, le stub interne repose sur `getline(3)` : l’historique est local au processus (non persistant).

## Tests
Les scripts de validation se trouvent dans `tests_realisation/` :
- `run_unit_tests.sh` appelle `unit_tests.py` (Python) pour valider les builtins et le cycle `exit`.
- `run_e2e_tests.sh` compare la sortie de `minishell` avec `bash --noprofile --norc` sur plusieurs scénarios (pipeline, heredoc, redirections).
- `./scripts/run_valgrind.sh` (optionnel) exécute quelques scénarios sous `valgrind` quand l’outil est installé.
- `scripts/run_tests.sh` orchestre l’ensemble des suites et affiche un résumé.

Vérifications manuelles rapides :
```bash
make
./scripts/run_tests.sh
printf 'echo $USER | cat\n' | ./minishell
printf 'echo hi > /tmp/minishell_test.txt\n' | ./minishell
printf 'echo foo | tr a-z A-Z\n' | ./minishell
printf 'export MINI=42\nunset MINI\n' | ./minishell
printf 'cd ..\ncd -\n' | ./minishell
printf 'cat |\n' | ./minishell        # erreur de syntaxe attendue
```
(`make fclean` ensuite pour nettoyer.)

## PDF
- `Sujet_Minishell.pdf` (module principal, lien symbolique vers le sujet d’origine).
