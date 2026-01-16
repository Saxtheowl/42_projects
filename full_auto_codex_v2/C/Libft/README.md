# Libft

Statut : DONE

Derniere mise a jour (2026-01-04 13:54:43) : ajout d'un harness `tests_realisation` (tests memmove/strlen/strtrim/itoa/split) et `./tests_realisation/run_tests.sh` OK.

## Synthèse
Reconstitution des fonctions de base de la libc + fonctions supplémentaires usuelles pour disposer d’une bibliothèque autonome (`libft.a`). Ce socle couvre les 23 fonctions de la partie 1 (mémoire, chaînes, conversions, tests de caractères) ainsi que les 9 fonctions de la partie 2 (manipulation de chaînes/IO). Les fonctions bonus de gestion de listes ne sont pas encore intégrées.

## Architecture
- `inc/libft.h` : prototypes des fonctions (parties 1 & 2).
- `src/ft_memory.c` : `memset`, `bzero`, `memcpy`, `memccpy`, `memmove`, `memchr`, `memcmp`, `calloc`, `strdup`.
- `src/ft_string.c` : `strlen`, `strlcpy`, `strlcat`, `strchr`, `strrchr`, `strnstr`, `strncmp`.
- `src/ft_char.c` : fonctions de classification (`is*`), conversion (`toupper`, `tolower`) et `atoi`.
- `src/ft_additional.c` : `substr`, `strjoin`, `strtrim`, `strmapi`, `itoa`.
- `src/ft_split.c` : implémentation de `ft_split`.
- `src/ft_put.c` : fonctions d’écriture sur descripteur (`put*`).

## Compilation
```bash
make        # produit libft.a
make clean  # supprime les objets
make fclean # supprime libft.a
make re     # rebuild complet
```

## Tests
`./tests_realisation/run_tests.sh` compile un binaire de validation et execute un set minimal (memmove overlap, strlen, strdup, atoi, strtrim, itoa, split).
La bibliothèque reste compatible avec les batteries externes usuelles (libft-unit-test, Francinette).

## PDF
- `Sujet_Libft.pdf`
