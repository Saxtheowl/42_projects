# Plan de mise en œuvre Libasm

## Étape 1 – Analyse
- [x] Lire `Sujet_Libasm.pdf` / consolider la liste standard (`ft_strlen`, `ft_strcpy`, `ft_strcmp`, `ft_write`, `ft_read`, `ft_strdup`, bonus éventuels).
- [x] Inventorier les prototypes et contraintes (`errno`, valeurs de retour, respect conventions d'appel).
- [x] Identifier les dépendances outillage (NASM, ar, toolchain C pour tests).

## Étape 2 – Infrastructure
- [x] Rédiger le `Makefile` (NASM → `.o`, archive `libasm.a`, cibles standards + `test`).
- [x] Définir `include/libasm.h` avec les prototypes exposés.
- [x] Préparer un wrapper/tests C (`tests_realisation/test_main.c`) et script `run_tests.sh`.

## Étape 3 – Fonctions de base
- [x] Implémenter `ft_strlen`, `ft_strcpy`, `ft_strcmp` en assembleur (NASM).
- [x] Ajouter validations dans le harness (comparaison libc).

## Étape 4 – Fonctions système
- [x] Implémenter `ft_write` / `ft_read` (syscall + `errno`).
- [x] Prévoir tests via `pipe()` + cas d'erreur (`EBADF`).

## Étape 5 – Allocation / duplication
- [x] Implémenter `ft_strdup` (appel `malloc`, copie via `ft_strcpy`).
- [ ] Bonus (`ft_atoi_base`, `ft_list_*`) — à aborder après outils disponibles.

## Étape 6 – Tests & automatisation
- [x] Compléter `tests_realisation/COMMANDS.md` (scénarios prévus).
- [x] Implémenter `scripts/run_tests.sh` (build + exécution du binaire de tests).
- [x] Mettre en place le binaire de tests C couvrant cas nominal/erreur.

## Étape 7 – Validation finale
- [ ] Exécuter toutes les suites (bloqué : `nasm` manquant → compilation impossible).
- [ ] Vérifier conformité norme 42 et mémoire lorsque l'outillage sera disponible.
- [x] Documenter l'état d'avancement (README, progress.md).
