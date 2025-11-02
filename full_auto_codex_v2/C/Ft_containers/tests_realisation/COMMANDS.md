# ft_containers – Tests

## Automatisés
- `./scripts/run_tests.sh`
  - Reconstruit la bibliothèque et le binaire de démonstration (`make re`).
  - Exécute `ft_containers` et valide la bannière + un scénario `vector`.
  - Compile/exécute en double (std/ft) les programmes de comparaison :
    - `tests_realisation/vector_compare.cpp`
    - `tests_realisation/list_compare.cpp`
    - `tests_realisation/map_compare.cpp`
  - Diff des sorties pour garantir l’alignement de comportement.

## Manuels
1. `make run` — vérifie l’exécutable de démonstration.
2. Comparaisons ciblées :
   - `g++ -std=c++98 -DUSE_FT -Iinclude tests_realisation/vector_compare.cpp && ./a.out`
   - `g++ -std=c++98 tests_realisation/vector_compare.cpp && ./a.out`
   - `g++ -std=c++98 -DUSE_FT -Iinclude tests_realisation/list_compare.cpp && ./a.out`
   - `g++ -std=c++98 tests_realisation/list_compare.cpp && ./a.out`
   - `g++ -std=c++98 -DUSE_FT -Iinclude tests_realisation/map_compare.cpp && ./a.out`
   - `g++ -std=c++98 tests_realisation/map_compare.cpp && ./a.out`
