# Commandes de test

- `make` : depuis la racine du projet, construit le binaire `2048` avec `ncurses` pour vérifier que la compilation principale passe sans avertissement.
- `python3 tests_realisation/run_tests.py` : compile un exécutable de test dédié à partir de `tests_realisation/test_logic.c` et des sources du jeu, puis l’exécute pour valider les opérations de déplacement, de fusion et la détection de victoire.
