# ft_printf – Tests

- `make` — compilation de la bibliothèque `libftprintf.a`.
- `cc -Wall -Wextra -Werror -Iinclude tests_realisation/test_main.c libftprintf.a -o tests_realisation/test_runner` — compilation manuelle du binaire de tests.
- `./tests_realisation/test_runner` — exécution des comparaisons `ft_printf` vs `printf`.
- `./scripts/run_tests.sh` — orchestrateur complet : `make re`, compilation du binaire de test puis exécution des scénarios standards.
- Cas manuels à garder en tête : chaînes `NULL`, entiers min/max (`INT_MIN`, `UINT_MAX`), pointeurs nuls/non nuls, combinaisons de conversions sur une même ligne, propagation des erreurs d’écriture (`write`).
