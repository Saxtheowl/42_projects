# push_swap

## Synthèse
Implémentation complète de `push_swap` : parsing robuste des arguments, opérations de piles (swap/push/rotate) et algorithme de tri hybride (cas ≤5 éléments optimisés, sinon tri radix sur indices). Les instructions générées sont directement écrites sur `stdout` et peuvent être validées avec le simulateur fourni.

## Architecture
- `inc/push_swap.h` : structures `t_stack`, `t_node`, prototypes utilitaires et opérations.
- `src/parsing.c` : lecture/validation des entrées, détection des doublons/dépassements, remplissage de la pile `a`.
- `src/stack.c` : primitives de manipulation de piles (ajout/retrait de nœuds, vérification d’ordre).
- `src/utils.c` : fonctions d’aide (split, atoi sécurisé, affichage, enregistrement d’instructions).
- `src/ops_*.c` : implémentations des commandes `sa/sb/ss`, `pa/pb`, `ra/rb/rr`, `rra/rrb/rrr`.
- `src/sort.c` : attribution des indices, tri optimisé (petites tailles + radix).
- `tests_realisation/` : script `run_tests.sh` et simulateur Python vérifiant que les opérations trient correctement.

## Compilation
```bash
make            # build
make clean      # supprime les .o
make fclean     # supprime binaire + .o
make re         # rebuild complet
```

## Utilisation
```bash
./push_swap 2 1 3         # imprime "sa"
./push_swap "3 2 1"      # imprime la séquence pour trier 3 2 1
```
Les arguments peuvent être passés séparément ou regroupés dans des chaînes contenant des espaces.

## Tests
- `./tests_realisation/run_tests.sh` : compare la sortie de `push_swap` avec un simulateur pour plusieurs ensembles d’arguments et vérifie la gestion des erreurs.

## PDF
- `Sujet_Push_swap.pdf`
