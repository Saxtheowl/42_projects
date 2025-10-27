# Libunit

## Vue d'ensemble
Libunit fournit une micro-bibliothèque de tests unitaires destinée aux projets 42. Elle expose une API minimale pour charger des tests (`load_test`) et les exécuter isolément (`launch_tests`) via `fork`, avec reporting coloré `[OK]/[KO]`, détection des signaux (SEGFAULT, BUS, ABORT, timeout) et comptage des échecs.

Fonctions publiques :
- `int load_test(t_unit_test **list, const char *name, int (*fn)(void));`
- `int launch_tests(t_unit_test **list, const char *suite_name);`
- `void clear_tests(t_unit_test **list);`

Chaque test est une fonction retournant `0` en cas de succès, une valeur non nulle sinon. Les tests s'exécutent dans un processus fils avec un timeout configurable (`LIBUNIT_TIMEOUT_SECONDS`, valeur par défaut : 2 s).

## Arborescence
- `include/libunit.h` — structures, macros couleurs, prototypes et durée du timeout.
- `src/load_test.c` — gestion de la liste chaînée (insertion, nettoyage).
- `src/launch_tests.c` — boucle d’exécution (`fork`, `waitpid`, détection signaux/exit code, affichage).
- `tests_realisation/test_sample.c` — suite d’exemple (deux tests réussis) utilisée par le script.
- `scripts/run_tests.sh` — reconstruit la lib, compile le binaire d’exemple et l’exécute.

## Compilation & utilisation
```sh
make            # construit libunit.a
make clean      # supprime les objets
make fclean     # supprime objets + lib
make re         # reconstruire proprement
make test       # build + exécution de la suite d'exemple
```

Intégration dans un projet :
```sh
cc -Wall -Wextra -Werror -Iinclude my_suite.c libunit.a -o my_suite
./my_suite
```

Extrait minimal :
```c
#include "libunit.h"

static int sample(void) { return (0); }

t_unit_test *tests = NULL;
load_test(&tests, "sample", &sample);
int failures = launch_tests(&tests, "My tests");
return (failures == 0 ? EXIT_SUCCESS : EXIT_FAILURE);
```

## Tests
- `make test` ou `./scripts/run_tests.sh` exécute le scénario d'exemple. Résultat attendu :
  ```
  === Sample Suite ===
    [OK] Simple success 1
    [OK] Simple success 2
  2/2 tests passed
  ```
- `tests_realisation/COMMANDS.md` récapitule les commandes manuelles.

## Points en attente
- Campagne `valgrind` / AddressSanitizer (outil absent/bruit possible).
- Contrôle norme 42 (`norminette`) dès que disponible.
- Bonus sujets (`ft_list_*`, `ft_atoi_base`, hooks setup/teardown) non traités pour l’instant.
