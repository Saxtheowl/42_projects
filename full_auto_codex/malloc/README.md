# malloc – Allocateur mémoire dynamique

## Synthèse
- Réimplémentation des fonctions `malloc`, `free`, `realloc` et de l’inspecteur `show_alloc_mem` sous la forme d’une bibliothèque partagée (`libft_malloc_$HOSTTYPE.so`).
- Découpage en zones `TINY`, `SMALL` et allocations `LARGE` mappées avec `mmap`, gestion des blocs avec coalescence et découpe alignée (16 octets).
- Thread-safety assurée via un mutex global et gestion interne des métadonnées sans appel à `malloc` système.
- Visualisation des allocations actives ordonnées par adresse via `show_alloc_mem` (format demandé).

## Étapes principales
- Initialisation des zones (`state.c`, `zone.c`) : préallocation d’au moins 100 blocs par zone à partir de la taille de page (`getpagesize`).
- Allocation/libération (`malloc.c`, `free.c`) : recherche de blocs libres, scission, fusion, libération des zones vides, traitement spécifique des gros blocs.
- Réallocation (`realloc.c`) : tentative d’extension in-place (fusion) puis fallback avec copie si nécessaire, conservation des données.
- Impression (`show.c`) : sortie directe via `write` pour éviter toute dépendance externe.

## Compilation
```sh
make
```
- Produit la bibliothèque `libft_malloc_$HOSTTYPE.so` et le lien symbolique `libft_malloc.so`.
- Compilation avec `-Wall -Wextra -Werror` et `-fPIC`, lien en mode partagé `-shared` + `-pthread`.

## Utilisation
- Précharger la bibliothèque pour l’injecter dans un binaire existant :
  ```sh
  LD_PRELOAD=./libft_malloc.so <commande>
  ```
- Ou lier dynamiquement lors de la compilation d’un programme de test.
- La fonction `show_alloc_mem()` peut être appelée pour afficher l’état des allocations.

## Tests
```sh
python3 tests_realisation/run_tests.py
```
- Construit la bibliothèque, compile un exécutable de test (`test_allocator`) et l’exécute avec `LD_PRELOAD` pour valider allocations, réallocations et libérations.
- Les commandes de test sont détaillées dans `tests_realisation/COMMANDES.md`.
