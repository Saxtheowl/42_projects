# Libft

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
Les tests unitaires ne sont pas fournis ici mais `libft.a` est prête à être utilisée avec les batteries de tests externes habituelles (libft-unit-test, Francinette, etc.).

## PDF
- `Sujet_Libft.pdf`
