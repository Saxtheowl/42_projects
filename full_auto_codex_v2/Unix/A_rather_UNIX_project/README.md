# ft_malloc

## Synthèse
Réimplémentation d'un allocateur dynamique de mémoire (remplacement de `malloc`, `free`, `realloc` et `show_alloc_mem`) respectant les contraintes du sujet *A_rather_UNIX_project.pdf*. L'allocateur gère trois types de zones (TINY, SMALL, LARGE) basées sur des réserves pré-allouées via `mmap`, avec coalescence des blocs libres et protection par mutex (`pthread`) pour la sûreté en environnement multi-thread.

## Architecture & approche
- `Makefile` : construit `libft_malloc_$HOSTTYPE.so` (avec lien `libft_malloc.so`) et reconstruit la `libft` embarquée.
- `inc/malloc_internal.h` : API interne, structures de zones/blocs et constantes (seuils TINY/SMALL, alignement 16 octets).
- `src/core/` :
  - `malloc_state.c` : état global, initialisation (`getpagesize`) et verrouillage `pthread_mutex_t`.
  - `utils.c` : gestion des zones (création via `mmap`, division/coalescence des blocs, release `munmap`).
  - `malloc.c` : implémentations publiques `malloc/free/realloc/show_alloc_mem`, sélection des zones et suivi des octets utilisés.
  - `show_alloc_mem.c` : formatage ASCII de l'état des allocations.
- `libft/` : fonctions utilitaires minimales (`ft_put*`, `ft_memcpy`, `ft_calloc` ...).
- `tests_realisation/` : script de test, binaire de démonstration et documentation.
- `Sujet_A_rather_UNIX_project.pdf` : lien symbolique vers le sujet.

Paramètres :
- `TINY_MAX_SIZE = 128` octets, `SMALL_MAX_SIZE = 1024` octets.
- Chaque zone “TINY/SMALL” contient au moins 100 blocs potentiels ; les allocations “LARGE” disposent de leur propre mapping (taille arrondie à la taille de page).

## Compilation & utilisation
```bash
make                 # construit la bibliothèque partagée et le lien symbolique
LD_PRELOAD=./libft_malloc.so ./votre_programme
```

`show_alloc_mem()` peut être invoqué depuis un programme LD_PRELOAD pour visualiser l'état:
```
TINY : 0x0000...
0x... - 0x... : 128 bytes
...
Total : 1024 bytes
```

## Tests
- `./tests_realisation/run_tests.sh` :
  1. `make re`
  2. Compilation d’un binaire de test C.
  3. Exécution de scénarios `malloc/free`, `realloc`, allocations larges et vérification de la sortie `show_alloc_mem` via `unittest` Python.

## Répartition des PDF
- `Sujet_A_rather_UNIX_project.pdf` : description officielle du projet malloc.
