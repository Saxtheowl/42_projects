# ft_printf

## Synthèse préliminaire
Recréation de la fonction standard `printf` (sous-ensemble défini par le sujet 42) avec gestion des conversions usuelles, du buffering et d’un moteur de formatage robuste en C. L’implémentation doit respecter la norme 42, fournir un **Makefile** générant `libftprintf.a` et exposer une interface compatible avec `int ft_printf(const char *fmt, ...)`.

## Architecture envisagée
- `src/core/` — boucle de parsing du format, dispatch des conversions et gestion du compteur de caractères.
- `src/conversions/` — implémentation de chaque conversion (`c`, `s`, `p`, `d`, `i`, `u`, `x`, `X`, `%`) avec buffering sur `t_buffer`.
- `src/utils/` — fonctions d’aide (itoa, gestion base 16, outils chaînes/mémoires).
- `include/ft_printf.h` — API publique, structures internes (buffer, conversion context) et prototypes.
- `libft/` (optionnel) — réutilisation minimale d’une libft custom (uniquement les fonctions autorisées par le sujet).
- `tests_realisation/` — scripts/suites comparant le résultat de `ft_printf` avec `printf`.
- `scripts/run_tests.sh` — orchestrateur des tests unitaires et end-to-end.

## Compilation
```sh
make            # construit libftprintf.a
make clean      # supprime les objets
make fclean     # supprime objets + librairie
make re         # reconstruit après nettoyage
```

Linking d’un binaire de test :
```sh
cc -Wall -Wextra -Werror -Iinclude main.c libftprintf.a
```

## Tests
- `./scripts/run_tests.sh` : recompilation propre, compilation du binaire `tests_realisation/test_runner` puis comparaison de plusieurs formats (`%c`, `%s`, `%p`, `%d`, `%i`, `%u`, `%x`, `%X`, `%%`) avec le `printf` système.  
  Les sorties sont capturées via redirection de descripteurs et normalisées pour accepter la représentation 42 (`0x0`) d’un pointeur nul.
- `tests_realisation/COMMANDS.md` : liste des commandes manuelles et rappel des cas à couvrir (valeurs extrêmes, erreurs d’écriture, etc.).

## Suivi
- `PLAN.md` expose le découpage du développement (analyse, buffer, conversions, tests).
- `progress.md` consigne les jalons et l’état d’avancement.

## Contraintes aperçues
- Respect strict de la norme 42 (fichiers ≤ 25 lignes, indentation…).
- Conversion minimale : `%c`, `%s`, `%p`, `%d`, `%i`, `%u`, `%x`, `%X`, `%%`.
- Gestion de la valeur de retour (nombre de caractères écrits) et propagation des erreurs d’écriture.
- Aucune fonction interdite (pas de `printf` original, pas d’allocs injustifiées, respect des fonctions autorisées).
- Un **Makefile** fournissant au minimum les règles `all`, `clean`, `fclean`, `re`.

## Points restants
1. Lancer `norminette` dès que l’outil sera disponible afin de valider la conformité 42.
2. Exécuter des fumigènes mémoire (`valgrind` ou build ASan) lorsque ces outils seront installés.
