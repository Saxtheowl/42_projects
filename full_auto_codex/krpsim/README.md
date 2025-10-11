# krpsim – Planification de procédés

## Synthèse
- `krpsim` simule une chaîne de processus décrite par un fichier de configuration (stocks initiaux, besoins, productions, durée, objectifs d’optimisation).
- `krpsim_verif` rejoue une trace `cycle:processus` et vérifie qu’elle respecte les contraintes et stocks.
- Implémentation en Python (aucune dépendance externe) : heuristique gloutonne guidée par la section `optimize:`.
- Sorties compatibles avec l’outil de vérification et récapitulatif des stocks finaux.

## Étapes principales
- Parsing robuste du format (`common.py`) avec gestion des erreurs.
- Simulation événementielle (`simulator.py`), priorisant les processus pertinents via la clause `optimize` et planifiant les terminaisons.
- Vérification (`verifier.py`) qui contrôle l’ordre temporel et la disponibilité des ressources avant de rejouer la trace.

## Utilisation
```sh
./krpsim <config> <delay>
```
- Exemple : `./krpsim configs/sample_consuming.cfg 120`.
- La sortie affiche le temps atteint, la trace (`cycle:process`) puis les stocks restants.

```sh
./krpsim_verif <config> <trace_file>
```
- Affiche « Trace valid up to … » et l’état final, sinon indique le cycle fautif.

## Tests
```sh
python3 tests_realisation/run_tests.py
```
- Génère deux simulations (consommation et boucle) et valide ensuite les traces via `krpsim_verif`.
- Commandes résumées dans `tests_realisation/COMMANDES.md`.
