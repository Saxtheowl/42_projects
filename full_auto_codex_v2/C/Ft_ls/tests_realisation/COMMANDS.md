# ft_ls – Tests prévus

- `make` — compilation du binaire `ft_ls`.
- `./ft_ls` — exécution de base sur le répertoire courant.
- `./ft_ls -l` — affichage détaillé.
- `./ft_ls -R` — récursion.
- `./scripts/run_tests.sh` — script de comparaison automatique avec `/bin/ls` (à implémenter).

- Cas couverts automatiquement : `./scripts/run_tests.sh` (diff avec `/bin/ls` sur `tests_realisation/fixtures`).
