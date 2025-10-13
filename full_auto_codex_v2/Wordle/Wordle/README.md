# Wordle

## Synthèse
Implémentation console du jeu Wordle conforme au rush `Wordle.pdf`. Le projet propose un moteur Python réutilisable (`wordle.game`) et une interface CLI (`play.py`) permettant de jouer localement avec un dictionnaire de cinq lettres fourni.

## Architecture & approche
- `play.py` : point d'entrée CLI (options `--target`, `--seed`, `--dictionary`, `--max-attempts`).
- `wordle/` : package Python avec la logique (évaluation des lettres, validation, rendu ASCII).
- `data/allowed_words.txt` : dictionnaire minimal de mots autorisés (5 lettres, ASCII).
- `tests_realisation/` : tests unitaires et script de lancement (`run_tests.sh`).
- `Sujet_Wordle.pdf` : lien symbolique vers le sujet officiel.

Le coeur (`WordleGame`) suit les règles officielles : 6 essais maximum, vérification de la présence/le placement des lettres avec gestion des doublons. L'interface texte affiche le feedback par symbole `[G]`, `[Y]`, `[_]`.

## Exécution
Depuis la racine du projet :

```bash
python3 play.py              # partie aléatoire
python3 play.py --seed 42     # partie déterministe
python3 play.py --target crane --quiet  # cible imposée (utile pour réviser)
```

Le dictionnaire peut être remplacé via `--dictionary` pour élargir la liste de mots.

## Tests
- `./tests_realisation/run_tests.sh` : lance `python3 -m unittest` (logique d'évaluation, gestion des doublons, scénario CLI gagnant).

## Répartition des PDF
- `Sujet_Wordle.pdf` : sujet principal décrivant les règles du rush.
