# ft_script

Statut : DONE

Dernière mise à jour (2026-01-17 00:09:52) : passage DONE (tests OK).

Dernière mise à jour (2025-12-26 03:23:36) : pty interactif (resize géré via SIGWINCH) avec fallback pipe, options -a/-c/-e/-f/-q, retour code enfant optionnel, flush immédiat testé, suite de tests auto verte (`make test`).

## Usage
```bash
./ft_script [-a] [-e] [-f] [-q] [-c command] [outfile]
```
- `outfile` par défaut : `typescript`.
- Lance un shell interactif ou exécute `command` avec `-c`; la sortie est dupliquée à l’écran et dans le fichier.
- Avec `-e`, le code de retour reflète celui du shell/commande enfant (sinon 0).

## Build & tests
```bash
make
make test   # lance tests_realisation/run_tests.sh
```
