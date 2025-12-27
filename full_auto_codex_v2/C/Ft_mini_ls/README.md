# ft_mini_ls

Dernière mise à jour (2025-12-26 03:00:05) : implémentation minimale conforme à `ls -1tr` sans arguments (tri par date modif ascendante, cache les fichiers cachés), gestion d’erreur si arguments fournis, tests comparant à `ls -1tr` (make test).

## Usage
```bash
./ft_mini_ls
```
- Aucun argument accepté (message d’erreur sinon).
- Liste le répertoire courant comme `ls -1tr` (un nom par ligne, tri par mtime inverse du `-t`, cache les fichiers cachés).

## Build & tests
```bash
make
make test   # lance tests_realisation/run_tests.sh
```
