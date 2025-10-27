# Plan de mise en œuvre Libunit

## Étape 1 – Analyse
- [x] Lire `Sujet_Libunit.pdf` et confirmer l'API obligatoire (`load_test`, `launch_tests`, structure t_unit_test...).
- [x] Recenser les statuts à détecter (OK, KO, signal, timeout) et le format de reporting.
- [x] Identifier les besoins en signaux (`fork`, `waitpid`, `alarm`).

## Étape 2 – Infrastructure
- [x] Rédiger le `Makefile` (cibles `all`, `clean`, `fclean`, `re`, `test`).
- [x] Définir `include/libunit.h` (structures, enums, prototypes utilitaires).
- [x] Préparer la structure des sources (`src/load_test.c`, `src/launch_tests.c`).

## Étape 3 – Gestion de la liste de tests
- [x] Implémenter `load_test` (insertion en fin de liste, duplication du nom).
- [x] Fournir un helper de nettoyage (`clear_tests`).

## Étape 4 – Exécution
- [x] Implémenter `launch_tests` : `fork`/`waitpid`, analyse des codes de retour.
- [x] Gérer les signaux (`SIGSEGV`, `SIGBUS`, `SIGABRT`, `SIGALRM`, etc.).
- [x] Timeout simple via `alarm(LIBUNIT_TIMEOUT_SECONDS)`.

## Étape 5 – Reporting
- [x] Afficher le nom de la suite + résultat `[OK]`/`[KO]` avec couleurs.
- [x] Retourner le nombre de tests échoués.
- [x] Gestion de messages spécifiques (signal, erreur système).

## Étape 6 – Tests & exemples
- [x] Écrire une suite d'exemple (`tests_realisation/test_sample.c`).
- [x] Ajouter `scripts/run_tests.sh` pour construire + exécuter.
- [x] Mettre à jour `tests_realisation/COMMANDS.md`.

## Étape 7 – Validation
- [ ] Vérifier l'absence de fuites mémoire (valgrind si dispo).
- [ ] Vérifier la norme 42 (`norminette` si dispo).
- [x] Préparer la documentation finale.
