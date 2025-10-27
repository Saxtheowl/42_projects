# Libasm – Tests prévus

- `make` — construit la bibliothèque `libasm.a`.
- `cc -Wall -Wextra -Werror -Iinclude tests_realisation/main.c libasm.a` — exemple de linkage manuel pour les tests.
- `./scripts/run_tests.sh` — script d'automatisation (à implémenter) comparant les fonctions à la libc.
- Tests manuels à prévoir : longueurs de chaînes, chaînes vides, erreurs `write`/`read`, comportement sur `NULL`, listes chainées pour les bonus.
