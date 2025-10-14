# Libft - Your Very First Own Library

## Description

Libft est le premier projet de la branche commune de 42. Ce projet consiste à créer sa propre bibliothèque C qui implémente des fonctions standard de la libc ainsi que des fonctions utilitaires additionnelles.

Cette bibliothèque sera réutilisée dans de nombreux projets futurs de 42.

## Fonctions implémentées

### Part 1 - Fonctions de la libc (34 fonctions)

#### Fonctions mémoire
- `ft_memset` - Remplit une zone mémoire avec une valeur
- `ft_bzero` - Met à zéro une zone mémoire
- `ft_memcpy` - Copie une zone mémoire
- `ft_memccpy` - Copie une zone mémoire jusqu'à un caractère
- `ft_memmove` - Copie une zone mémoire (gestion des chevauchements)
- `ft_memchr` - Recherche un caractère dans une zone mémoire
- `ft_memcmp` - Compare deux zones mémoire

#### Fonctions de chaînes
- `ft_strlen` - Calcule la longueur d'une chaîne
- `ft_strlcpy` - Copie une chaîne avec limite de taille
- `ft_strlcat` - Concatène des chaînes avec limite de taille
- `ft_strchr` - Recherche un caractère dans une chaîne
- `ft_strrchr` - Recherche la dernière occurrence d'un caractère
- `ft_strnstr` - Recherche une sous-chaîne
- `ft_strncmp` - Compare deux chaînes

#### Fonctions de vérification de caractères
- `ft_isalpha` - Vérifie si c'est une lettre
- `ft_isdigit` - Vérifie si c'est un chiffre
- `ft_isalnum` - Vérifie si c'est alphanumérique
- `ft_isascii` - Vérifie si c'est un caractère ASCII
- `ft_isprint` - Vérifie si c'est un caractère imprimable

#### Fonctions de conversion
- `ft_toupper` - Convertit en majuscule
- `ft_tolower` - Convertit en minuscule
- `ft_atoi` - Convertit une chaîne en entier

#### Fonctions d'allocation
- `ft_calloc` - Alloue et initialise de la mémoire
- `ft_strdup` - Duplique une chaîne

### Part 2 - Fonctions additionnelles (11 fonctions)

#### Manipulation de chaînes
- `ft_substr` - Extrait une sous-chaîne
- `ft_strjoin` - Concatène deux chaînes
- `ft_strtrim` - Supprime des caractères au début/fin
- `ft_split` - Découpe une chaîne selon un délimiteur

#### Conversion et mapping
- `ft_itoa` - Convertit un entier en chaîne
- `ft_strmapi` - Applique une fonction à chaque caractère

#### Sortie sur descripteur de fichier
- `ft_putchar_fd` - Écrit un caractère
- `ft_putstr_fd` - Écrit une chaîne
- `ft_putendl_fd` - Écrit une chaîne suivie d'un retour à la ligne
- `ft_putnbr_fd` - Écrit un nombre

### Bonus - Fonctions de listes chaînées (9 fonctions)

- `ft_lstnew` - Crée un nouvel élément
- `ft_lstadd_front` - Ajoute un élément au début
- `ft_lstsize` - Compte le nombre d'éléments
- `ft_lstlast` - Retourne le dernier élément
- `ft_lstadd_back` - Ajoute un élément à la fin
- `ft_lstdelone` - Supprime un élément
- `ft_lstclear` - Supprime toute la liste
- `ft_lstiter` - Itère sur la liste
- `ft_lstmap` - Applique une fonction et crée une nouvelle liste

## Compilation

```bash
# Compiler la partie obligatoire
make

# Compiler avec les bonus
make bonus

# Nettoyer les fichiers objets
make clean

# Nettoyer tout
make fclean

# Recompiler
make re
```

## Utilisation

```c
#include "libft.h"

int main(void)
{
    char *str = ft_strdup("Hello, 42!");
    ft_putstr_fd(str, 1);
    ft_putchar_fd('\n', 1);
    free(str);
    return (0);
}
```

Compiler avec libft:
```bash
gcc main.c -L. -lft -o program
```

## Structure du projet

```
libft/
├── libft.h              # Header principal
├── Makefile             # Fichier de compilation
├── ft_*.c               # Fichiers sources (Part 1 & 2)
├── ft_*_bonus.c         # Fichiers sources bonus
└── README.md            # Ce fichier
```

## Tests

La bibliothèque compile sans erreurs ni warnings avec les flags `-Wall -Wextra -Werror`.

**Total: 54 fonctions implémentées** (34 Part 1 + 11 Part 2 + 9 Bonus)

## Normes

- Toutes les fonctions respectent la Norme de 42
- Pas de variables globales
- Gestion des erreurs et cas limites
- Pas de fuites mémoire
- Les fonctions auxiliaires sont déclarées en `static`

## Auteur

Généré automatiquement pour le cursus 42.

---

**Note**: Cette bibliothèque sera utilisée dans tous les projets futurs du cursus.
