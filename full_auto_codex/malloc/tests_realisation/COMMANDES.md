# Commandes de test

- `python3 tests_realisation/run_tests.py` : construit la bibliothèque personnalisée, compile le binaire `test_allocator` et l’exécute avec `LD_PRELOAD=./libft_malloc.so` pour vérifier le comportement de l’allocateur.
- `LD_PRELOAD=./libft_malloc.so ./tests_realisation/test_allocator` : relance manuellement le test binaire pour observer les sorties de `show_alloc_mem` ou reproduire un scénario précis.
