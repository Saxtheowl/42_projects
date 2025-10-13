# ft_printf

## Description

Implémentation personnalisée de la fonction `printf()` de la libc. Ce projet fait partie du cursus de l'école 42 et permet d'apprendre à utiliser les fonctions variadiques en C.

## Sujet

Le projet consiste à recoder la fonction `printf()` avec les conversions suivantes :
- `%c` : affiche un caractère
- `%s` : affiche une chaîne de caractères
- `%p` : affiche un pointeur en hexadécimal
- `%d` : affiche un nombre décimal (base 10)
- `%i` : affiche un entier en base 10
- `%u` : affiche un nombre décimal non signé (base 10)
- `%x` : affiche un nombre en hexadécimal (base 16) minuscule
- `%X` : affiche un nombre en hexadécimal (base 16) majuscule
- `%%` : affiche le symbole %

## Architecture

Le projet est structuré de manière modulaire :

```
ft_printf/
├── ft_printf.h              # Header principal
├── ft_printf.c              # Fonction principale et dispatcher
├── ft_print_char.c          # Gestion de %c
├── ft_print_str.c           # Gestion de %s
├── ft_print_ptr.c           # Gestion de %p
├── ft_print_nbr.c           # Gestion de %d et %i
├── ft_print_unsigned.c      # Gestion de %u
├── ft_print_hex.c           # Gestion de %x et %X
├── ft_utils.c               # Fonctions utilitaires
└── Makefile                 # Compilation
```

## Compilation

### Compiler la bibliothèque

```bash
make
```

Cela génère `libftprintf.a` à la racine du projet.

### Nettoyer

```bash
make clean      # Supprime les fichiers objets
make fclean     # Supprime les objets et la bibliothèque
make re         # Recompile complètement
```

## Utilisation

### Exemple d'utilisation

```c
#include "ft_printf.h"

int main(void)
{
    int count;

    count = ft_printf("Hello %s!\n", "World");
    ft_printf("Caractères imprimés: %d\n", count);

    ft_printf("Caractère: %c\n", 'A');
    ft_printf("Nombre: %d\n", 42);
    ft_printf("Hexadécimal: %x\n", 255);
    ft_printf("Pointeur: %p\n", (void *)&count);
    ft_printf("Pourcentage: %%\n");

    return (0);
}
```

### Compiler avec ft_printf

```bash
cc -Wall -Wextra -Werror main.c -L. -lftprintf -o program
./program
```

## Tests

Les tests sont disponibles dans le dossier `tests_realisation/`. Voir le fichier `tests_realisation/README.md` pour plus de détails.

## Procédure de test

1. Compiler la bibliothèque :
   ```bash
   make
   ```

2. Compiler le programme de test :
   ```bash
   cd tests_realisation
   ./run_tests.sh
   ```

3. Les tests comparent la sortie de `ft_printf` avec celle de `printf` standard.

## Normes

Le code respecte la norme de l'école 42 :
- Pas de `for`, `do...while`, `switch`, etc.
- Maximum 25 lignes par fonction
- Maximum 5 fonctions par fichier
- Noms de variables explicites
- Pas de variables globales
- Gestion appropriée de la mémoire (pas de fuites)

## Fonctions externes autorisées

- `malloc`, `free`
- `write`
- `va_start`, `va_arg`, `va_copy`, `va_end`

## Valeur de retour

La fonction retourne le nombre de caractères imprimés, comme `printf()` standard.

## Cas particuliers gérés

- Pointeur NULL pour `%s` → affiche "(null)"
- Pointeur NULL pour `%p` → affiche "(nil)"
- `INT_MIN` pour `%d` et `%i`
- Grands nombres pour `%u`, `%x`, `%X`

## Auteur

Projet généré automatiquement dans le cadre de l'automatisation des projets 42.

## Licence

Ce projet est destiné à des fins éducatives dans le cadre du cursus de l'école 42.
