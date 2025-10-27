# Libunit – Tests prévus

- `make` — construit la bibliothèque `libunit.a`.
- `./scripts/run_tests.sh` — compile la lib, puis lance la suite d'exemple (`tests_realisation/`).
- `cc -Wall -Wextra -Werror -Iinclude tests_realisation/test_sample.c libunit.a` — compilation manuelle d'une suite.

TODO : lister précisément les scénarios (tests réussis, échec, segmentation fault, timeout).
