# ft_containers – Tests

## Automatisés
- `./scripts/run_tests.sh`
  - Reconstruit la bibliothèque et le binaire de démonstration (`make re`).
  - Exécute `ft_containers` et vérifie la bannière + un scénario vector (push_back/front/back).
  - Compile `tests_realisation/vector_compare.cpp` avec `std::vector` et `ft::vector`, compare les sorties.

## Manuels
1. `make run` — vérifie l’exécutable de démonstration.
2. `g++ -std=c++98 -DUSE_FT -Iinclude tests_realisation/vector_compare.cpp && ./a.out` — exécuter la version `ft`.
3. `g++ -std=c++98 tests_realisation/vector_compare.cpp && ./a.out` — exécuter la version `std` et comparer les sorties.

> Les tests seront enrichis au fur et à mesure de l’implémentation des autres conteneurs (`list`, `map`, ...).
