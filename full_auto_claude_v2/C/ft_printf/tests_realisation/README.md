# Tests pour ft_printf

## Description

Ce dossier contient tous les tests pour valider l'implémentation de `ft_printf`.

## Structure

- `test_main.c` : Programme de test principal qui compare ft_printf avec printf
- `run_tests.sh` : Script pour compiler et exécuter tous les tests
- `test_commands.txt` : Liste des commandes de test avec explications

## Commandes de test

### Compilation du test

```bash
# Dans le dossier parent (ft_printf/), compiler la bibliothèque
cd ..
make

# Revenir dans tests_realisation/ et compiler le test
cd tests_realisation
cc -Wall -Wextra -Werror test_main.c -L.. -lftprintf -o test_printf
```

### Exécution

```bash
./test_printf
```

ou utiliser le script automatisé :

```bash
./run_tests.sh
```

## Tests couverts

### Conversions de base
1. `%c` - Caractère simple
2. `%s` - Chaînes de caractères
3. `%d` et `%i` - Nombres entiers
4. `%u` - Nombres non signés
5. `%x` et `%X` - Hexadécimal
6. `%p` - Pointeurs
7. `%%` - Symbole pourcent

### Cas limites
- Chaîne NULL pour `%s` → "(null)"
- Pointeur NULL pour `%p` → "(nil)"
- INT_MIN et INT_MAX pour `%d`
- UINT_MAX pour `%u`
- Zéro pour toutes les conversions numériques
- Caractères spéciaux

### Vérifications
- Valeur de retour (nombre de caractères imprimés)
- Sortie exacte comparée avec printf
- Pas de fuites mémoire (à vérifier avec valgrind)

## Commandes supplémentaires

### Vérification des fuites mémoire

```bash
valgrind --leak-check=full --show-leak-kinds=all ./test_printf
```

### Comparaison avec printf

Le programme de test affiche côte à côte les résultats de `printf` et `ft_printf` pour faciliter la comparaison.

## Résultats attendus

Tous les tests doivent passer avec :
- ✅ Sortie identique à printf
- ✅ Valeur de retour correcte
- ✅ Pas de fuites mémoire
- ✅ Pas de segfault

## Notes

- Les tests utilisent des macros pour simplifier la comparaison
- Chaque test affiche "OK" si réussi, "KO" sinon
- Un compteur de tests passés/totaux est affiché à la fin
