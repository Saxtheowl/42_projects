# Commandes de test

- `python3 tests_realisation/run_tests.py` : compile les exécutables `ft_nm`/`ft_otool`, construit un binaire d’exemple et vérifie la présence du symbole `main` et le dump de la section texte.
- `./ft_nm tests_realisation/sample` : après les tests, relance manuellement `ft_nm` sur l’exécutable généré.
- `./ft_otool tests_realisation/sample` : inspection manuelle de la section texte.
