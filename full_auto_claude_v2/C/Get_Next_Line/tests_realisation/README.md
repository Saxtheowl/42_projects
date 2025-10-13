# Tests pour Get_Next_Line

## Description

Suite de tests complète pour valider l'implémentation de `get_next_line`.

## Exécution rapide

```bash
./run_tests.sh
```

## Tests inclus

### 1. Fichiers standards
- ✅ Fichier simple avec plusieurs lignes
- ✅ Fichier sans `\n` final
- ✅ Fichier vide
- ✅ Fichier avec une seule ligne
- ✅ Lignes très longues (> 10000 caractères)
- ✅ Lignes vides multiples

### 2. Cas d'erreur
- ✅ File descriptor invalide (-1)
- ✅ File descriptor fermé
- ✅ BUFFER_SIZE invalide (testé via compilation)

### 3. Différentes tailles de BUFFER_SIZE
- BUFFER_SIZE = 1 (cas minimal)
- BUFFER_SIZE = 42 (cas standard)
- BUFFER_SIZE = 10000 (cas de grand buffer)

### 4. Vérification mémoire
- Fuites mémoire (valgrind)
- Double free
- Invalid read/write

## Compilation manuelle

### Test basique

```bash
cc -Wall -Wextra -Werror -D BUFFER_SIZE=42 test_main.c ../get_next_line.c ../get_next_line_utils.c -o test
./test
```

### Test avec petit buffer

```bash
cc -Wall -Wextra -Werror -D BUFFER_SIZE=1 test_main.c ../get_next_line.c ../get_next_line_utils.c -o test
./test
```

### Test avec valgrind

```bash
cc -g -D BUFFER_SIZE=42 test_main.c ../get_next_line.c ../get_next_line_utils.c -o test
valgrind --leak-check=full --show-leak-kinds=all ./test
```

## Tests bonus (multi-fd)

Pour tester la version bonus qui gère plusieurs file descriptors :

```bash
cc -Wall -Wextra -Werror -D BUFFER_SIZE=42 test_bonus.c ../get_next_line_bonus.c ../get_next_line_utils_bonus.c -o test_bonus
./test_bonus
```

## Fichiers de test générés

Le script `run_tests.sh` créé automatiquement :

- `test_files/simple.txt` : Fichier simple multi-lignes
- `test_files/no_final_nl.txt` : Sans '\n' final
- `test_files/empty.txt` : Fichier vide
- `test_files/single.txt` : Une seule ligne
- `test_files/long_line.txt` : Ligne de 10000 caractères
- `test_files/empty_lines.txt` : Lignes vides

## Commandes de test détaillées

### Test lecture stdin

```bash
echo -e "line1\nline2\nline3" | ./test_stdin
```

### Test lecture alternée (bonus)

```bash
./test_multi_fd file1.txt file2.txt file3.txt
```

## Résultats attendus

✅ Tous les tests doivent passer
✅ Aucune fuite mémoire
✅ Comportement identique quel que soit BUFFER_SIZE
✅ Gestion correcte des cas limites

## Debugging

### Afficher ce qui est lu

Modifier temporairement get_next_line.c pour afficher :
```c
printf("DEBUG: Read %d bytes: [%s]\n", bytes_read, temp_buffer);
```

### Vérifier le buffer statique

Ajouter dans get_next_line.c :
```c
printf("DEBUG: Static buffer = [%s]\n", buffer);
```

## Notes importantes

- La ligne retournée doit inclure le '\n' (sauf EOF)
- Libérer chaque ligne retournée
- Tester avec BUFFER_SIZE = 1 est critique
- Les fichiers sans '\n' final sont valides
- NULL retourné uniquement à la fin ou sur erreur
