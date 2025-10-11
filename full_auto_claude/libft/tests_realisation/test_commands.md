# Commandes de Test pour Libft

Ce fichier liste toutes les commandes de test disponibles pour la bibliothèque libft.

## Compilation de la bibliothèque

```bash
# Compiler la bibliothèque sans les bonus
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

## Tests unitaires automatisés

### Test simple avec un programme de test

```bash
# Compiler un programme de test
cc -Wall -Wextra -Werror test_main.c libft.a -o test_libft

# Exécuter les tests
./test_libft
```

### Tester des fonctions spécifiques

```bash
# Tester ft_strlen
cc -Wall -Wextra -Werror tests_realisation/test_strlen.c -L. -lft -o test_strlen
./test_strlen

# Tester ft_split
cc -Wall -Wextra -Werror tests_realisation/test_split.c -L. -lft -o test_split
./test_split

# Tester les fonctions de liste
cc -Wall -Wextra -Werror tests_realisation/test_lists.c -L. -lft -o test_lists
./test_lists
```

## Tests Python automatisés

Les scripts Python ci-dessous permettent de tester automatiquement les fonctions de libft :

### Exécuter tous les tests

```bash
python3 tests_realisation/run_all_tests.py
```

### Tester une catégorie spécifique

```bash
# Tester les fonctions de mémoire
python3 tests_realisation/test_memory.py

# Tester les fonctions de chaînes
python3 tests_realisation/test_strings.py

# Tester les fonctions additionnelles
python3 tests_realisation/test_additional.py
```

## Tests avec des testeurs externes (optionnel)

```bash
# Cloner et utiliser libft-unit-test
git clone https://github.com/alelievr/libft-unit-test.git
cd libft-unit-test
make f

# Cloner et utiliser Tripouille
git clone https://github.com/Tripouille/libftTester.git
cd libftTester
make a
```

## Vérification de la norme 42

```bash
# Si norminette est installé
norminette *.c *.h
```

## Vérification des fuites mémoire

```bash
# Utiliser valgrind pour détecter les fuites
valgrind --leak-check=full --show-leak-kinds=all ./test_libft
```

## Tests de performance

```bash
# Mesurer le temps d'exécution
time ./test_libft
```

## Description des tests Python

- **run_all_tests.py** : Script principal qui exécute tous les tests
- **test_memory.py** : Teste les fonctions de manipulation de mémoire
- **test_strings.py** : Teste les fonctions de manipulation de chaînes
- **test_additional.py** : Teste les fonctions additionnelles (partie 2)
- **test_bonus.py** : Teste les fonctions bonus (listes chaînées)

## Résultats attendus

Tous les tests doivent passer sans erreur. Le retour attendu est :

```
✅ Test ft_strlen: PASSED
✅ Test ft_memcpy: PASSED
✅ Test ft_split: PASSED
...
Total: X tests, X passed, 0 failed
```
