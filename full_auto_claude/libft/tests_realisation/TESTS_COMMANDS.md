# Commandes de Tests - Libft

Ce document liste toutes les commandes pour tester la bibliothèque Libft.

## Table des matières
1. [Tests Automatisés Python](#tests-automatisés-python)
2. [Tests Manuels](#tests-manuels)
3. [Vérification de la Norme](#vérification-de-la-norme)
4. [Tests avec des Testers Externes](#tests-avec-des-testers-externes)

---

## Tests Automatisés Python

### Lancer tous les tests
```bash
cd tests_realisation
python3 test_libft.py
```

**Explication:** Ce script Python exécute automatiquement tous les tests pour les fonctions de la partie 1, partie 2 et bonus. Il compile la bibliothèque, crée des programmes de test, les exécute et vérifie les résultats.

**Ce qu'il teste:**
- ✅ Fonctions mémoire (memset, bzero, memcpy, memcmp, etc.)
- ✅ Fonctions string (strlen, strchr, strdup, strncmp, etc.)
- ✅ Fonctions caractères (isalpha, isdigit, toupper, tolower, atoi)
- ✅ Fonctions additionnelles (substr, strjoin, strtrim, split, itoa)
- ✅ Fonctions bonus (listes chaînées)

**Sortie attendue:**
- Tests réussis en VERT
- Tests échoués en ROUGE
- Résumé final avec taux de réussite

---

## Tests Manuels

### 1. Compilation de base
```bash
cd ..
make
```
**Explication:** Compile la bibliothèque libft.a avec toutes les fonctions obligatoires (Part 1 + Part 2).

### 2. Compilation avec bonus
```bash
make bonus
```
**Explication:** Compile la bibliothèque avec les fonctions bonus (listes chaînées) incluses.

### 3. Nettoyage des fichiers objets
```bash
make clean
```
**Explication:** Supprime tous les fichiers .o (fichiers objets).

### 4. Nettoyage complet
```bash
make fclean
```
**Explication:** Supprime tous les fichiers .o ET le fichier libft.a.

### 5. Recompilation complète
```bash
make re
```
**Explication:** Équivalent à `make fclean` puis `make`. Recompile tout depuis zéro.

---

## Test Manuel d'une Fonction Spécifique

### Exemple: Tester ft_strlen

1. **Créer un fichier de test:**
```bash
cd tests_realisation
cat > test_manual.c << 'EOF'
#include <stdio.h>
#include "../libft.h"

int main(void)
{
    char *str = "Hello, World!";
    size_t len = ft_strlen(str);
    printf("Longueur de '%s': %zu\n", str, len);
    return (0);
}
EOF
```

2. **Compiler le test:**
```bash
cc -Wall -Wextra -Werror test_manual.c -L.. -lft -I.. -o test_manual
```

3. **Exécuter le test:**
```bash
./test_manual
```

**Sortie attendue:**
```
Longueur de 'Hello, World!': 13
```

---

## Vérification de la Norme

### Installer norminette (si pas déjà fait)
```bash
pip3 install norminette
```

### Vérifier tous les fichiers
```bash
cd ..
norminette *.c *.h
```

**Explication:** Vérifie que tous les fichiers .c et .h respectent la norme 42.

**Sortie attendue:** Aucune erreur, seulement des messages "OK!" pour chaque fichier.

---

## Tests avec des Testers Externes

### 1. Tripouille Tester
```bash
cd ..
git clone https://github.com/Tripouille/libftTester.git
cd libftTester
make
```

**Explication:** Clone et exécute le tester de Tripouille, un des testers les plus complets pour Libft.

### 2. Francinette (avec Docker recommandé)
```bash
cd ..
bash -c "$(curl -fsSL https://raw.github.com/xicodomingues/francinette/master/bin/install.sh)"
francinette
```

**Explication:** Installe et exécute Francinette, un framework de test complet pour les projets 42.

### 3. War Machine
```bash
cd ..
git clone https://github.com/0x050f/libft-war-machine.git
cd libft-war-machine
bash grademe.sh
```

**Explication:** Clone et exécute War Machine, un autre tester populaire.

---

## Tests de Fuites Mémoire avec Valgrind

### Installer Valgrind
```bash
sudo apt-get install valgrind  # Sur Ubuntu/Debian
```

### Tester une fonction avec Valgrind
```bash
cd tests_realisation

# Compiler un test
cc -g test_manual.c -L.. -lft -I.. -o test_manual

# Exécuter avec Valgrind
valgrind --leak-check=full --show-leak-kinds=all ./test_manual
```

**Explication:** Valgrind détecte les fuites mémoire, les accès invalides, etc.

**Sortie attendue:**
```
HEAP SUMMARY:
    in use at exit: 0 bytes in 0 blocks
  total heap usage: X allocs, X frees, Y bytes allocated

All heap blocks were freed -- no leaks are possible
```

---

## Tests Spécifiques par Catégorie

### Test Part 1 uniquement
```bash
cd tests_realisation
python3 -c "
from test_libft import LibftTester
t = LibftTester()
t.setup()
t.test_part1_mem()
t.test_part1_str()
t.test_part1_char()
t.print_summary()
"
```

### Test Part 2 uniquement
```bash
python3 -c "
from test_libft import LibftTester
t = LibftTester()
t.setup()
t.test_part2()
t.print_summary()
"
```

### Test Bonus uniquement
```bash
python3 -c "
from test_libft import LibftTester
t = LibftTester()
t.setup()
t.test_bonus()
t.print_summary()
"
```

---

## Vérification Rapide de la Bibliothèque

### Vérifier que libft.a existe et contient les bonnes fonctions
```bash
cd ..
ls -lh libft.a
ar -t libft.a | head -20
```

**Explication:**
- `ls -lh libft.a` : affiche la taille de la bibliothèque
- `ar -t libft.a` : liste tous les fichiers objets dans la bibliothèque

### Compter le nombre de fonctions
```bash
ar -t libft.a | wc -l
```

**Attendu:** 34 pour la version de base, 43 avec bonus

---

## Dépannage

### Erreur: "library not found"
```bash
# Assurez-vous d'être dans le bon répertoire
pwd
# Devrait afficher: .../libft/tests_realisation

# Vérifiez que libft.a existe
ls -l ../libft.a
```

### Erreur de compilation
```bash
# Recompiler depuis zéro
cd ..
make fclean
make bonus
```

### Les tests Python ne s'exécutent pas
```bash
# Vérifier la version de Python
python3 --version  # Devrait être >= 3.6

# Rendre le script exécutable
chmod +x tests_realisation/test_libft.py

# Exécuter directement
./tests_realisation/test_libft.py
```

---

## Résumé des Commandes Principales

| Commande | Description |
|----------|-------------|
| `make` | Compile libft.a (obligatoire) |
| `make bonus` | Compile avec bonus |
| `make clean` | Supprime les .o |
| `make fclean` | Supprime tout |
| `make re` | Recompile tout |
| `python3 tests_realisation/test_libft.py` | Lance tous les tests auto |
| `norminette *.c *.h` | Vérifie la norme |
| `ar -t libft.a` | Liste le contenu de libft.a |

---

## Checklist avant Soumission

- [ ] `make` compile sans erreur ni warning
- [ ] `make bonus` compile sans erreur ni warning
- [ ] `make re` fonctionne correctement
- [ ] `norminette *.c *.h` ne trouve aucune erreur
- [ ] `python3 tests_realisation/test_libft.py` : tous les tests passent
- [ ] Aucune fuite mémoire détectée avec Valgrind
- [ ] libft.a existe et a une taille raisonnable (≈ 50-70 Ko)
- [ ] Tous les fichiers nécessaires sont présents (*.c, libft.h, Makefile)

---

**Auteur:** Claude Code - Tests automatisés pour Libft
**Date:** 2025
