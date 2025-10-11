# Libft - Ma Première Bibliothèque C

## 📚 Description du Projet

**Libft** est le premier projet du cursus de l'école 42. L'objectif est de recoder une bibliothèque de fonctions C standard ainsi que des fonctions additionnelles qui serviront de base pour tous les projets futurs.

Ce projet permet de :
- Comprendre le fonctionnement interne des fonctions de la libc
- Apprendre la gestion manuelle de la mémoire
- Maîtriser les pointeurs et les structures de données
- Respecter une norme de codage stricte

## 🎯 Compréhension du Projet

### Partie 1 : Fonctions Libc

Recréation de 34 fonctions de la bibliothèque standard C (`<string.h>`, `<stdlib.h>`, `<ctype.h>`), avec le préfixe `ft_` :

**Manipulation de mémoire** :
- `ft_memset`, `ft_bzero`, `ft_memcpy`, `ft_memccpy`
- `ft_memmove`, `ft_memchr`, `ft_memcmp`

**Manipulation de chaînes** :
- `ft_strlen`, `ft_strlcpy`, `ft_strlcat`
- `ft_strchr`, `ft_strrchr`, `ft_strnstr`, `ft_strncmp`

**Vérification de caractères** :
- `ft_isalpha`, `ft_isdigit`, `ft_isalnum`
- `ft_isascii`, `ft_isprint`

**Conversion** :
- `ft_toupper`, `ft_tolower`, `ft_atoi`

**Allocation mémoire** :
- `ft_calloc`, `ft_strdup`

### Partie 2 : Fonctions Additionnelles

11 fonctions qui ne font pas partie de la libc ou avec des comportements différents :

**Manipulation de sous-chaînes** :
- `ft_substr` - Extrait une sous-chaîne
- `ft_strjoin` - Concatène deux chaînes
- `ft_strtrim` - Supprime des caractères aux extrémités
- `ft_split` - Découpe une chaîne selon un délimiteur

**Conversion et transformation** :
- `ft_itoa` - Convertit un entier en chaîne
- `ft_strmapi` - Applique une fonction à chaque caractère

**Écriture sur descripteur de fichier** :
- `ft_putchar_fd` - Écrit un caractère
- `ft_putstr_fd` - Écrit une chaîne
- `ft_putendl_fd` - Écrit une chaîne + retour à la ligne
- `ft_putnbr_fd` - Écrit un nombre

### Partie Bonus : Listes Chaînées

9 fonctions pour manipuler des listes chaînées (`t_list`) :

- `ft_lstnew` - Crée un nouvel élément
- `ft_lstadd_front` - Ajoute en début de liste
- `ft_lstadd_back` - Ajoute en fin de liste
- `ft_lstsize` - Compte les éléments
- `ft_lstlast` - Retourne le dernier élément
- `ft_lstdelone` - Supprime un élément
- `ft_lstclear` - Vide toute la liste
- `ft_lstiter` - Itère sur la liste
- `ft_lstmap` - Applique une fonction et crée une nouvelle liste

## 🛠️ Compilation

### Prérequis

- Compilateur C (`gcc` ou `clang`)
- `make`
- Système Unix/Linux

### Commandes de Compilation

```bash
# Compiler la bibliothèque (partie obligatoire uniquement)
make

# Compiler avec les bonus
make bonus

# Nettoyer les fichiers objets
make clean

# Nettoyer tous les fichiers générés
make fclean

# Recompiler depuis zéro
make re
```

Le Makefile génère le fichier `libft.a`, une bibliothèque statique contenant toutes les fonctions compilées.

### Flags de Compilation

Le projet est compilé avec les flags suivants (conformément à la norme 42) :
- `-Wall` : Active tous les avertissements
- `-Wextra` : Active des avertissements supplémentaires
- `-Werror` : Traite les avertissements comme des erreurs

## 🚀 Utilisation

### Dans vos Programmes

```c
#include "libft.h"

int main(void)
{
    char *str = "Hello, World!";
    size_t len = ft_strlen(str);

    char **words = ft_split("Hello World Test", ' ');

    // Utiliser les fonctions...

    // Libérer la mémoire
    for (int i = 0; words[i]; i++)
        free(words[i]);
    free(words);

    return (0);
}
```

### Compiler avec libft

```bash
# Méthode 1 : Linker avec la bibliothèque
cc -Wall -Wextra -Werror mon_programme.c -L. -lft -o mon_programme

# Méthode 2 : Inclure directement la bibliothèque
cc -Wall -Wextra -Werror mon_programme.c libft.a -o mon_programme
```

## 🧪 Tests

### Structure des Tests

Le répertoire `tests_realisation/` contient :
- `test_commands.md` - Liste de toutes les commandes de test
- `run_all_tests.py` - Script Python pour tests automatisés

### Exécuter les Tests Automatisés

```bash
# Exécuter tous les tests Python
python3 tests_realisation/run_all_tests.py
```

Le script effectue :
1. ✅ Compilation de la bibliothèque (partie obligatoire et bonus)
2. ✅ Tests unitaires sur les fonctions principales
3. ✅ Vérification des fuites mémoire (si valgrind est installé)
4. ✅ Rapport détaillé des résultats

### Tests Manuels

```bash
# Créer un programme de test simple
cat > test.c << 'EOF'
#include "libft.h"
#include <stdio.h>

int main(void)
{
    printf("ft_strlen(\"test\") = %zu\n", ft_strlen("test"));
    printf("ft_atoi(\"42\") = %d\n", ft_atoi("42"));
    return (0);
}
EOF

# Compiler et exécuter
cc test.c libft.a -o test
./test
```

### Tests avec Valgrind (Fuites Mémoire)

```bash
valgrind --leak-check=full --show-leak-kinds=all ./test
```

## 📁 Structure du Projet

```
libft/
├── Makefile              # Fichier de compilation
├── libft.h               # Header principal avec tous les prototypes
│
├── ft_*.c                # Fonctions de la partie obligatoire (34 fichiers)
├── ft_*_bonus.c          # Fonctions bonus pour listes (9 fichiers)
│
├── tests_realisation/    # Répertoire de tests
│   ├── test_commands.md  # Documentation des commandes de test
│   └── run_all_tests.py  # Script de test automatisé Python
│
└── README.md             # Ce fichier
```

## 📝 Norme 42

Le projet respecte la **norme 42** :

✅ **Règles de codage** :
- Maximum 25 lignes par fonction
- Maximum 5 fonctions par fichier
- Pas de variables globales
- Indentation avec des tabulations
- Nommage cohérent

✅ **Gestion mémoire** :
- Pas de fuites mémoire
- Libération correcte de toute mémoire allouée
- Protection contre les segfaults

✅ **Makefile** :
- Ne doit pas relink
- Règles : `all`, `clean`, `fclean`, `re`, `bonus`

## 🔧 Comment Ça Fonctionne

### Exemple : ft_split

`ft_split` découpe une chaîne selon un délimiteur :

```c
char **result = ft_split("Hello World Test", ' ');
// result[0] = "Hello"
// result[1] = "World"
// result[2] = "Test"
// result[3] = NULL
```

**Algorithme** :
1. Compter le nombre de mots
2. Allouer un tableau de pointeurs
3. Pour chaque mot :
   - Allouer de la mémoire
   - Copier le mot
   - Stocker le pointeur
4. Terminer avec NULL

### Exemple : Listes Chaînées (Bonus)

```c
t_list *list = NULL;

// Créer et ajouter des éléments
ft_lstadd_back(&list, ft_lstnew("Premier"));
ft_lstadd_back(&list, ft_lstnew("Deuxième"));
ft_lstadd_back(&list, ft_lstnew("Troisième"));

// Parcourir la liste
t_list *current = list;
while (current)
{
    printf("%s\n", (char *)current->content);
    current = current->next;
}

// Libérer la mémoire
ft_lstclear(&list, free);
```

## 🎓 Compétences Acquises

- ✅ Gestion manuelle de la mémoire (`malloc`, `free`)
- ✅ Manipulation de pointeurs
- ✅ Structures de données (listes chaînées)
- ✅ Respect d'une norme de codage stricte
- ✅ Tests unitaires et validation
- ✅ Utilisation de Makefile
- ✅ Debugging et résolution de problèmes

## 🐛 Debugging

### Problèmes Courants

**Segmentation Fault** :
```bash
# Utiliser gdb pour débugger
gdb ./mon_programme
(gdb) run
(gdb) bt  # Backtrace
```

**Fuites Mémoire** :
```bash
# Vérifier avec valgrind
valgrind --leak-check=full ./mon_programme
```

**Erreurs de Compilation** :
```bash
# Vérifier la norme
norminette *.c *.h

# Recompiler proprement
make fclean && make
```

## 📚 Ressources Utiles

- [Man pages Linux](https://man7.org/linux/man-pages/)
- [Norm 42](https://github.com/42School/norminette)
- [Testeurs externes pour libft](https://github.com/alelievr/libft-unit-test)

## 👨‍💻 Auteur

Projet réalisé dans le cadre du cursus de l'école 42.

---

**Note** : Cette bibliothèque sera réutilisée dans tous les projets C futurs du cursus 42 (ft_printf, get_next_line, minishell, etc.).
