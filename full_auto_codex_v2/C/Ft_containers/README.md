# ft_containers

## Présentation
Recode pédagogique de plusieurs conteneurs de la STL en C++98. Toutes les implémentations résident dans le namespace `ft` et respectent les signatures de la bibliothèque standard (itérateurs, typedef, comparateurs, fonctions non-membres). Les dépendances externes se limitent aux headers C++ classiques (`<memory>`, `<functional>`, …).

## Arborescence
- `include/ft/` — en-têtes des conteneurs (`vector`, `list`, `map`, `stack`, `queue`) et utilitaires (`type_traits`, `iterator`, `algorithm`, `utility`, `config`).
- `src/` — binaire de démonstration (`ft_containers`) et stub de bibliothèque.
- `tests_realisation/` — programmes de comparaison std/ft et artefacts générés.
- `scripts/` — automatisation (`run_tests.sh`).
- `docs/` — notes de cadrage (`requirements.md`).

## Implémentation
- **Utilitaires génériques**
  - `ft::iterator_traits`, tags et `ft::reverse_iterator`.
  - Métaprogrammation : `ft::enable_if`, `ft::is_integral`.
  - Algorithmes : `ft::equal`, `ft::lexicographical_compare`.
  - `ft::pair`, `ft::make_pair`, `ft::swap`.

- **ft::vector**
  - Stockage contiguous avec gestion de capacité amortie.
  - Constructions fill/range, assign, insertion toutes signatures, itérateurs const et reverse.
  - Stratégie de (ré)allocation garantissant la forte exception pour `insert` via buffer temporaire.

- **ft::list**
  - Liste doublement chaînée sur sentinelle, itérateurs bidirectionnels.
  - Opérations STL : `splice` (3 variantes), `remove`, `remove_if`, `unique`, `merge`, `sort` (merge sort), `reverse`.
  - Adaptateurs `ft::stack` (basé sur `ft::vector`) et `ft::queue` (basé sur `ft::list`).

- **ft::map**
  - Arbre rouge-noir avec sentinelle `_nil`, rotations gauche/droite et équilibrage insertion/suppression.
  - Itérateurs bidirectionnels cohérents (`++/--`, `lower_bound`, `upper_bound`, `equal_range`).
  - Surfaces d'API STL : insert (avec hint), erase (clé, itérateur, plage), swap, comparateurs.

## Compilation & usage
```bash
make            # libftcontainers.a + binaire de démonstration
make run        # lance ./ft_containers
```

Pour utiliser les conteneurs dans un autre projet, inclure `include/` et lier avec `libftcontainers.a` si nécessaire (les conteneurs étant template, il suffit souvent des headers).

## Jeux de tests
- `./scripts/run_tests.sh`
  - Reconstruit le projet.
  - Exécute `ft_containers` et vérifie un scénario de base.
  - Compile/compare les programmes `vector_compare.cpp`, `list_compare.cpp`, `map_compare.cpp` en double (`std` vs `ft`) via diff.
- Détails supplémentaires et commandes manuelles : `tests_realisation/COMMANDS.md`.

Les programmes de test mettent en regard les comportements (construction, mutations, itérateurs, accès) avec ceux de la STL et servent de non-régression.

## Points d'attention
- Respect strict du standard C++98 (pas de C++11).
- Pas d'utilisation des conteneurs équivalents de la STL, hormis pour la comparaison dans les tests.
- Les itérateurs restent valides tant que la STL le garantit (cf. vector invalidant après réallocation, etc.).
