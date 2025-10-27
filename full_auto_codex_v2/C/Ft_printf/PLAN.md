# Plan de mise en œuvre ft_printf

## Étape 1 – Analyse & exigences
- [x] Lire `Sujet_ft_printf.pdf` et lister les conversions obligatoires.
- [x] Recenser les fonctions autorisées (en général `write`, `malloc`, `free`, `va_start`, `va_arg`, `va_end`…).
- [x] Identifier les cas limites (NULL string, pointeurs nuls, entiers min/max, etc.).

## Étape 2 – Infrastructure
- [x] Créer le `Makefile` (règles `all`, `clean`, `fclean`, `re`, lib statique `libftprintf.a`).
- [x] Définir l’arborescence source (`src/core`, `src/conversions`, `src/utils`, `include`).
- [x] Poser l’API publique (`ft_printf.h`) et les structures internes (buffer, contexte de conversion).

## Étape 3 – Buffer & parsing
- [x] Implémenter un buffer interne (accumulateur, flush via `write`).
- [x] Écrire le parseur du format (iterate string, détecter `%`, dispatcher).
- [x] Gérer les erreurs d’écriture (retour `-1` si `write` échoue).

## Étape 4 – Conversions
- [x] `%c` / `%s` / `%` (caractères et chaînes, gestion `NULL`).
- [x] `%d` / `%i` / `%u` (entiers signés & non signés).
- [x] `%x` / `%X` (hexadécimal lowercase/uppercase).
- [x] `%p` (pointeur avec préfixe `0x`, `0x0` si pointeur nul).

## Étape 5 – Utils & conformité
- [x] Fonctions utilitaires (base 10/16, taille des chaînes, itoa custom, etc.).
- [ ] Respect norme 42 (découper en fonctions ≤ 25 lignes) — **en attente** : `norminette` indisponible sur l’environnement actuel.
- [x] Nettoyage mémoire (aucune fuite, flush final du buffer).

## Étape 6 – Tests & documentation
- [x] Implémenter `scripts/run_tests.sh` (comparaison `ft_printf` vs `printf`).
- [x] Rédiger `tests_realisation/COMMANDS.md` (commandes manuelles + automatisées).
- [x] Compléter `README.md` avec synthèse finale, instructions build/test.
- [x] Mettre à jour `progress.md` après chaque jalon.

## Étape 7 – Validation finale
- [x] Exécuter les tests automatisés et manuels.
- [ ] Vérifier la norme (si `norminette` disponible) et l’absence de fuites (valgrind/asan) — **bloqué** tant que les outils ne sont pas installés.
- [x] Préparer documentation finale + instructions de rendu.
