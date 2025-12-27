# pipex

Dernière mise à jour (2025-12-26 01:27:46) : pipelines multi-commandes + here_doc (append) stabilisés (FD fixes, exit code de la dernière commande), tests Bash étendus OK. Projet considéré terminé.

## Synthèse
`pipex` reproduit le comportement du shell pour `infile cmd1 | cmd2 > outfile`. Le programme lit `infile`, exécute `cmd1` puis passe la sortie à `cmd2`, et écrit le résultat final dans `outfile`. Les commandes sont résolues via la variable d’environnement `PATH`, et les arguments sont analysés en respectant des guillemets simples ou doubles.

## Architecture
- `src/pipex.c` : point d’entrée, ouverture des fichiers, création du pipe et gestion des forks/exec.
- `src/utils.c` / `src/parse.c` : fonctions utilitaires (chaînes, découpe de commandes, recherche dans `PATH`).
- `src/errors.c` : affichage des erreurs et nettoyage.
- `inc/pipex.h` : structures et prototypes.
- `tests_realisation/` : script Bash comparant les résultats avec ceux du shell.

## Compilation
```bash
make          # produit l’exécutable pipex
make clean    # supprime les .o
make fclean   # supprime binaire + .o
make re       # clean + rebuild
```

## Utilisation
```bash
./pipex infile "cmd1 arg" "cmd2" outfile
# Bonus here_doc
./pipex here_doc LIMITER "cmd1 arg" "cmd2" outfile   # lit stdin jusqu'au LIMITER puis ajoute à outfile
```
Exemple :
```bash
./pipex input.txt "grep hello" "wc -l" output.txt
printf 'hello\nEND\n' | ./pipex here_doc END "cat" "wc -l" output_append.txt
```

## Tests
- `./tests_realisation/run_tests.sh` : exécute pipex puis `sh -c` avec la même commande et compare les sorties.

## PDF
- `Sujet_Pipex.pdf`
