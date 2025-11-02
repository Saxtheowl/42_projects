# Plan de mise en œuvre ft_containers

## Étape 1 – Analyse
- [x] Lire `Sujet_ft_containers.pdf` et noter les conteneurs obligatoires (vector, list, map, stack, queue).
- [x] Identifier les exigences générales : namespace `ft`, compatibilité C++98, interdiction d'utiliser l'STL équivalent.
- [x] Dresser la liste précise des membres/méthodes à implémenter pour chaque conteneur (voir `docs/requirements.md`).

## Étape 2 – Infrastructure
- [x] Mettre en place l'arborescence :
  - `include/ft/` pour les headers (vector.hpp, list.hpp, …).
  - `src/` pour les sources de tests éventuels.
  - `tests_realisation/` avec banc d'essai comparatif.
- [x] Rédiger un `Makefile` générant une bibliothèque statique (`libftcontainers.a`) et un binaire de démonstration (`ft_containers`).
- [x] Définir un header commun (`config.hpp`) regroupant traits/utilitaires partagés.

- [x] Implémenter les helpers génériques :
  - itérateurs (random access, bidirectional),
  - `iterator_traits`, `enable_if`, `is_integral`, **(partiellement ✅)**,
  - `lexicographical_compare`, `equal` **(✅)**,
  - allocateurs wrappers.
- [x] Mettre en place le système de tests unitaires minimal (gabarits de comparaison avec `std`).

## Étape 4 – Conteneurs séquentiels
- [x] `vector`: stockage dynamique, itérateurs random access, gestion capacité/réallocation **(construction & modificateurs principaux en cours)**.
- [x] `list`: double liste chaînée, itérateurs bidirectionnels, opérations `splice`, `merge`, etc.
- [x] `stack` et `queue`: adaptateurs basés sur `vector`/`list` (ou conteneur template configurable).

## Étape 5 – Conteneurs associatifs
- [x] `map`: arbre bicolore (RB-tree) ou structure équilibrée équivalente, itérateurs ordonnés, comparateurs.
- [x] Requêtes de recherche (`find`, `lower_bound`, `upper_bound`, `equal_range`).
- [x] Gestion des opérations insert/erase & allocation.

## Étape 6 – Tests & validation
- [x] `main.cpp` comparant la sortie/comportement de `ft::` vs `std::`.
- [x] Scripts (`scripts/run_tests.sh`) pour lancer les benchmarks comparatifs.
- [x] Jeux de données/benchmarks dans `tests_realisation/`.

## Étape 7 – Documentation & finalisation
- [x] Rédiger `README.md` (synthèse, architecture, usage, tests).
- [x] Mettre à jour `progress.md` selon l'avancement.
- [ ] Préparer notes sur la conformité (norme 42 C++ non imposée mais clarté exigée).
