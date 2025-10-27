# Libasm

## Synthèse préliminaire
Rewriting de fonctions de la libc en assembleur x86_64 (NASM) conformément au sujet 42. Objectifs principaux : fournir une bibliothèque statique `libasm.a` implémentant un sous-ensemble ciblé (`ft_strlen`, `ft_strcpy`, `ft_strcmp`, `ft_write`, `ft_read`, `ft_strdup`, etc.), respecter la norme 42 et gérer toutes les erreurs système (`errno`).

## Architecture envisagée
- `src/` : fichiers assembleur `.s` (un par fonction) et un éventuel wrapper C pour tests.
- `include/libasm.h` : prototypes exposés aux clients C.
- `Makefile` : construction via `nasm` (format `elf64`) puis édition de liens en bibliothèque statique.
- `tests_realisation/` : harness de tests C comparant à la libc officielle.
- `scripts/run_tests.sh` : compilation et exécution automatique des scénarios.

## Contraintes identifiées
- Utiliser **NASM** (`nasm -f elf64`), pas GAS/AT&T.
- Respect du calling convention System V AMD64.
- Préserver les registres non volatils (`rbx`, `rbp`, `r12`–`r15`).
- Gérer correctement `errno` pour `ft_read`/`ft_write`.
- Fournir un Makefile avec les cibles standard (`all`, `clean`, `fclean`, `re`).

## Prochaines étapes
1. Lire en détail `Sujet_Libasm.pdf` pour confirmer la liste des fonctions et les exigences bonus éventuelles (`ft_atoi_base`, `ft_list_push_front`, `ft_list_size`, etc.).
2. Formaliser le plan (`PLAN.md`) : ordre des fonctions, stratégie d'assemblage, tests.
3. Mettre en place l’infrastructure de build (Makefile, règles NASM + ar).
4. Implémenter progressivement chaque fonction avec tests associés.

> Les tests automatiques devront comparer le comportement à la libc (`strlen`, `strcmp`, etc.) et couvrir les cas d’erreur (`write`/`read` invalides`).

## État courant
- Infrastructure complète : Makefile NASM, en-têtes et script de test (`scripts/run_tests.sh`).
- Fonctions obligatoires codées en assembleur (mais non assemblées faute de `nasm` sur l’environnement courant).
- Harness C `tests_realisation/test_main.c` prêt à comparer les résultats avec la libc.

> ⚠️ Outillage manquant : le binaire `nasm` n’est pas disponible dans l’environnement actuel. La compilation/validation reste bloquée jusqu’à son installation.
