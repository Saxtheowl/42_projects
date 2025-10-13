# Get Next Line

## Description

Fonction qui lit et retourne une ligne depuis un file descriptor. Ce projet permet d'apprendre l'utilisation des **variables statiques** en C, un concept fondamental pour conserver un état entre les appels de fonction.

## Concept clé : Variables statiques

Les variables statiques conservent leur valeur entre les appels successifs d'une fonction, ce qui permet de :
- Mémoriser ce qui a déjà été lu
- Reprendre la lecture là où elle s'était arrêtée
- Gérer plusieurs fichiers simultanément (bonus)

## Prototype

```c
char *get_next_line(int fd);
```

**Paramètres** :
- `fd` : file descriptor depuis lequel lire

**Retour** :
- La ligne lue (incluant le `\n` sauf à la fin du fichier)
- `NULL` si fin de fichier ou erreur

## Architecture

```
Get_Next_Line/
├── get_next_line.h              # Header mandatory
├── get_next_line.c              # Fonction principale
├── get_next_line_utils.c        # Fonctions utilitaires
├── get_next_line_bonus.h        # Header bonus
├── get_next_line_bonus.c        # Version multi-fd
├── get_next_line_utils_bonus.c  # Utils bonus
├── README.md                    # Documentation
└── tests_realisation/           # Tests complets
```

## Compilation

### Version mandatory (un seul fd)

```bash
cc -Wall -Wextra -Werror -D BUFFER_SIZE=42 get_next_line.c get_next_line_utils.c main.c
```

### Version bonus (multi-fd)

```bash
cc -Wall -Wextra -Werror -D BUFFER_SIZE=42 get_next_line_bonus.c get_next_line_utils_bonus.c main.c
```

### Différentes tailles de buffer

```bash
# Petit buffer
cc -Wall -Wextra -Werror -D BUFFER_SIZE=1 get_next_line.c get_next_line_utils.c main.c

# Buffer moyen
cc -Wall -Wextra -Werror -D BUFFER_SIZE=42 get_next_line.c get_next_line_utils.c main.c

# Grand buffer
cc -Wall -Wextra -Werror -D BUFFER_SIZE=10000 get_next_line.c get_next_line_utils.c main.c
```

## Utilisation

### Exemple simple

```c
#include "get_next_line.h"
#include <fcntl.h>
#include <stdio.h>

int main(void)
{
    int     fd;
    char    *line;

    fd = open("file.txt", O_RDONLY);
    while ((line = get_next_line(fd)) != NULL)
    {
        printf("%s", line);
        free(line);
    }
    close(fd);
    return (0);
}
```

### Lecture depuis stdin

```c
char *line;

while ((line = get_next_line(0)) != NULL)
{
    printf("You entered: %s", line);
    free(line);
}
```

### Bonus : Plusieurs fichiers simultanément

```c
int fd1 = open("file1.txt", O_RDONLY);
int fd2 = open("file2.txt", O_RDONLY);
int fd3 = open("file3.txt", O_RDONLY);

// Lecture alternée
char *line1 = get_next_line(fd1);
char *line2 = get_next_line(fd2);
char *line3 = get_next_line(fd3);
char *line1_bis = get_next_line(fd1); // Continue file1
```

## Fonctionnement interne

### Algorithme

1. **Lecture** : Lit BUFFER_SIZE octets depuis le fd
2. **Accumulation** : Stocke les données dans un buffer statique
3. **Extraction** : Cherche un `\n` et extrait la ligne
4. **Reste** : Conserve ce qui suit le `\n` pour le prochain appel
5. **Répétition** : Continue jusqu'à EOF ou erreur

### Gestion de la mémoire

- Le buffer statique persiste entre les appels
- Chaque ligne retournée doit être libérée par l'appelant
- Le buffer interne est libéré automatiquement à la fin

## Cas particuliers gérés

✅ Fichiers avec/sans `\n` final
✅ Fichiers vides
✅ Lignes très longues
✅ BUFFER_SIZE = 1
✅ BUFFER_SIZE très grand (10000000)
✅ Lecture depuis stdin
✅ Fichiers binaires (comportement non défini mais pas de crash)
✅ File descriptor invalide
✅ Erreurs de lecture

## Tests

```bash
cd tests_realisation
./run_tests.sh
```

Les tests vérifient :
- Lecture de fichiers normaux
- Différentes tailles de BUFFER_SIZE
- Fichiers sans `\n` final
- Fichiers vides
- Lignes très longues
- Lecture depuis stdin
- Multi-fd (bonus)
- Fuites mémoire (valgrind)

## Fonctions externes autorisées

- `read` : Lecture depuis un fd
- `malloc` : Allocation mémoire
- `free` : Libération mémoire

## Normes

- Respect de la norme 42
- Pas de variables globales
- Pas de `lseek`
- Pas de libft
- Variables statiques autorisées et nécessaires
- Gestion correcte de la mémoire

## Bonus

### Multi-fd (gestion de plusieurs fichiers)

La version bonus utilise un tableau statique pour gérer jusqu'à 1024 file descriptors simultanément :

```c
static char *buffer[FD_MAX];  // Un buffer par fd
```

Cela permet de lire plusieurs fichiers en parallèle sans perdre la position de lecture dans chaque fichier.

### Avantages

- Lecture simultanée de plusieurs fichiers
- Conservation de l'état pour chaque fd
- Pas de limite sur l'ordre de lecture

## Auteur

Projet généré automatiquement dans le cadre de l'automatisation des projets 42.

## Licence

Ce projet est destiné à des fins éducatives dans le cadre du cursus de l'école 42.
