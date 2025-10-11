# Commandes de test

- `python3 tests_realisation/run_tests.py` : exécute deux simulations (`configs/sample_consuming.cfg`, `configs/sample_endless.cfg`), génère les traces et les valide avec `krpsim_verif`.
- `./krpsim configs/sample_consuming.cfg 120` : lancer manuellement la simulation de consommation.
- `./krpsim_verif configs/sample_consuming.cfg tests_realisation/sample_consuming.trace` : rejouer et vérifier la trace générée.
