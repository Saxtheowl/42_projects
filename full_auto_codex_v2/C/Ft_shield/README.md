# ft_shield

Statut : DONE

Derniere mise a jour (2026-01-17 03:40:30) : tests ajoutés (exit code + usage erreurs), run_tests OK.

Dernière mise à jour (2025-12-26 04:24:00) : prototype trojan étendu : copie binaire + log, commande leurre (`-c`) et ajout d’un hook dans `~/.bashrc` via `-i` (persistant). Tests auto vérifient copie, log, hook et sortie leurre.

## Build & tests
```bash
make
make test   # lance tests_realisation/run_tests.sh
```

## Usage
```bash
./ft_shield           # exécute un leurre inoffensif
./ft_shield -c "echo hello"  # exécute la commande spécifiée
./ft_shield -c "echo hello" -i "source ~/.ft_shield/ft_shield.bin >/dev/null 2>&1"  # ajoute un hook bashrc
```
- Crée `~/.ft_shield` (mode 700), copie binaire `ft_shield.bin` et append un log `log.txt`.
- Le log contient timestamp, commande, user/host.
- Le code de retour reflète celui de la commande exécutée.
