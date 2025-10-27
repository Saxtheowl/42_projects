# ft_containers

## Synthèse préliminaire
Recode pédagogique d'une partie de la STL en C++98. Le sujet impose d'implémenter les conteneurs `vector`, `list`, `map`, `stack` et `queue` dans le namespace `ft`, avec leurs itérateurs et surcharges non-membres. Les interdits notables : pas de `using namespace`, pas de `friend` hors justifications nécessaires, pas d'utilisation de l'STL équivalente.

## Architecture envisagée
- `include/ft/` — headers par conteneur (`vector.hpp`, `list.hpp`, `map.hpp`, `stack.hpp`, `queue.hpp`) et utilitaires communs (`type_traits.hpp`, `iterator.hpp`, `algorithm.hpp`, `utility.hpp`).
- `src/` — implémentations spécifiques si besoin (tests) : le projet étant principalement template, l'essentiel résidera dans les headers.
- `tests_realisation/` — jeux de tests comparant `ft::` aux `std::` (unitaires + performance basique).
- `scripts/` — scripts d'automatisation (`run_tests.sh`, benchs).
- `docs/` — références et notes de conception éventuelles.

## Pistes de conception
1. **Utilitaires template** : reproduire `iterator_traits`, `enable_if`, `is_integral`, comparateurs lexicographiques.
2. **Itérateurs** : écrire des itérateurs bidirectionnels/random access pour `list` et `vector`, plus des itérateurs const.
3. **Gestion mémoire** : respecter les allocateurs (`std::allocator` par défaut), exposer `allocator_type` et utiliser `construct/destroy`.
4. **Containers adaptateurs** : `stack` et `queue` reposent sur un conteneur sous-jacent (par défaut `vector`/`deque` maison).
5. **Map** : implémenter un arbre équilibré (RB-tree) pour garantir les complexités logarithmiques, gérer comparateurs (`value_compare`, `key_compare`).

### Implémenté à ce stade
- `ft::enable_if`, `ft::is_integral`, `ft::iterator_traits`, `ft::reverse_iterator`, `ft::distance`, `ft::iter_swap`.
- Algorithmes de base : `ft::equal`, `ft::lexicographical_compare`.
- Utilitaires génériques : `ft::pair`, `ft::make_pair`, `ft::swap`.
- Début d'implémentation de `ft::vector` (constructeurs, itérateurs, accès, `push_back`, `insert`, `erase`, comparaisons).

## Tests
- `./scripts/run_tests.sh` — reconstruit le projet, exécute le binaire de démonstration et compare les sorties d'un scénario vector entre `std::vector` et `ft::vector` (`tests_realisation/vector_compare.cpp`).
- Voir `tests_realisation/COMMANDS.md` pour les commandes manuelles additionnelles.

## Prochaines étapes
1. Finaliser `ft::vector` (const-correctness approfondie, parcours via itérateurs dédiés, validation edge cases).
2. Implémenter les itérateurs bidirectionnels et la structure de base de `ft::list`.
3. Étendre les tests comparatifs (list/map) et préparer des benchmarks de performance.

> Rappel : le projet doit rester C++98 (pas de C++11) et respecter les conventions du sujet (namespace `ft`, pas de STL). Les tests devront vérifier la compatibilité API/comportement avec `std`.
