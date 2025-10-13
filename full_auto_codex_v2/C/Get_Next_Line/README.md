# get_next_line

## Synthèse
Cette implémentation fournit la fonction `get_next_line(int fd)` qui lit un flux fichier/STDIN ligne par ligne. Elle supporte plusieurs descripteurs simultanés grâce à une liste chaînée de tampons et respecte les contraintes du sujet (aucune fonction externe autre que `read`, `malloc`, `free`).

## Architecture
- `src/get_next_line.c` : logique principale de lecture, gestion des stashes par fd.
- `src/get_next_line_utils.c` : utilitaires (strlen, strchr, join, substr).
- `src/get_next_line.h` : API publique et prototypes.
- `Makefile` : construit la bibliothèque statique `get_next_line.a` avec `-D BUFFER_SIZE=42` par défaut.
- `tests_realisation/` : programme de test et script shell pour vérifier lecture fichier + stdin.

## Compilation
```bash
make            # produit get_next_line.a
make clean      # supprime les objets
```
Pour intégrer à un projet :
```bash
cc main.c src/get_next_line.c src/get_next_line_utils.c -D BUFFER_SIZE=128
```

## Tests
- `./tests_realisation/run_tests.sh` : compile un binaire de test, vérifie la lecture d’un fichier et via stdin.

## PDF
- `Sujet_Get_Next_Line.pdf`
