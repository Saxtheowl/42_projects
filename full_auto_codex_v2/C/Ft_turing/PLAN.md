# Plan ft_turing

## Objectif
Simuler une machine de Turing décrite dans un fichier, valider la description et déterminer si une chaîne est acceptée. Afficher les transitions (option verbose) et empêcher les boucles infinies via un seuil de pas.

## Étapes prévues
1) **Lecture sujet + format** : recenser le format exact (alphabet, états, transitions, ruban initial, état initial, états acceptants, blanc).
2) **Choix langage** : C++17 pour gestion containers/strings.
3) **Structures** : `State`, `Transition`, `Machine` (maps des transitions, alphabet, blank), ruban dynamique (deque ou map index->char), limite de pas configurable.
4) **Parser** : valider cohérence (états référencés, alphabet restreint, transitions complètes), lever des erreurs claires.
5) **Simulation** : boucle sur les transitions (write, move L/R, next state), terminaison si état acceptant ou pas de transition; option verbose pour tracer les pas.
6) **CLI** : `./ft_turing <machine_file> <input> [-v] [-s max_steps]`.
7) **Tests** : machines de test accept/reject/boucle, ruban vide, symboles inconnus.

## Risques / blocages
- Format exact à confirmer dans le PDF.
- Pas d'exécution des tests dans l'environnement actuel (pas de build obligatoire aujourd'hui).

## Prochaines actions
- Lire le PDF et ajuster le format/erreurs attendues.
- Esquisser les structures et le squelette CLI/Makefile.
