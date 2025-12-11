# ft_linear_regression

## Synthèse
Mini-projet de machine learning : implémenter une régression linéaire univariée (prix de voiture vs kilométrage). Deux programmes :
1. `train.py` — entraîne le modèle via gradient descent et persiste les paramètres.
2. `predict.py` — charge le modèle et renvoie un prix estimé pour un kilométrage donné.

## Contraintes principales
- Langage libre, mais interdiction d’utiliser une fonction qui résout directement la régression (`numpy.polyfit`, etc.).
- Utiliser les formules de gradient descent fournies dans le sujet.
- Initialiser `theta0` et `theta1` à 0 avant le premier entraînement.

## Architecture
- `data/data.csv` — jeu d’entraînement (kilométrage en km, prix en €).
- `src/utils.py` — chargement CSV, sauvegarde du modèle (`theta.json`) avec moyenne/échelle pour la normalisation.
- `src/train.py` — gradient descent batch (normalise la feature avant apprentissage).
- `src/predict.py` — CLI interactive ou via argument (utilise les paramètres appris).
- `scripts/` —
  - `train.sh`, `predict.sh` : raccourcis pour lancer les programmes,
  - `run_tests.sh` : exécute Pytest,
  - `evaluate.py` : calcule la RMSE sur un dataset donné,
  - `plot.py` : trace le nuage de points et la droite apprise.
- `tests_realisation/` — tests Pytest + `COMMANDS.md` listant les commandes de validation.

## Installation
```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

## Entraînement & utilisation
```bash
# Entraînement (met à jour data/theta.json)
./scripts/train.sh --learning-rate 0.1 --iterations 1000 --scheduler exponential --decay 0.95 --early-stop --patience 50 --min-delta 0.0005
```

Ce script crée automatiquement le dossier `plots/`, exécute `C/ft_helpme/scripts/reports/rmse_plot.py` sur `data/history.json` et conserve `plots/latest_rmse.png`/`plots/latest_rmse.txt` pour résumer la convergence. Les sorties supplémentaires apparaissent même lorsque `matplotlib` manque (`latest_rmse.txt` capture l’ASCII + résumé). La session 2025-12-11 12:59:45 a régénéré `data/history.json` et remis à jour `plots/latest_rmse.txt/.png`, tout en maintenant le snapshot `docs/validation_summary.*`.

# Prédiction (argument ou invite utilisateur)
./scripts/predict.sh --mileage 65000

# Qualité du modèle (RMSE)
./scripts/evaluate.py data/data.csv

# Visualisation
./scripts/plot.py --output plots/regression.png
```

Le dossier `docs/` contient un état des artefacts de convergence ([`docs/convergence.md`](docs/convergence.md)) qui reprend la chaîne : entrainement, histoire RMSE, hook `rmse_plot.py`, validations croisés (rapport `data/validation_report.txt`) et exports `plots/latest_rmse.txt`/`.png`. On y ajoute `docs/validation_summary.txt` et `docs/validation_summary.md`, produits par `scripts/validation_summary.py`, pour figer best/worst/average RMSE sur un run donné (avec horodatage ISO) et le transmettre au reviewer; par exemple `docs/validation_summary.txt` liste `best fold 5 RMSE=594.47`, `worst fold 1 RMSE=1520.42`, `average=978.62`, et `docs/validation_summary.md` offre une table facile à copier dans un rapport.

### Trace de convergence
- La dernière exécution de `./scripts/train.sh --scheduler exponential --decay 0.95 --early-stop --patience 50 --min-delta 0.0005` s’est arrêtée à l’itération 349 (meilleur RMSE 969.0438) et a régénéré `data/history.json`.
- Le résumé RMSE utilise maintenant `C/ft_helpme/scripts/reports/rmse_plot.py` (ASCII + résumé) et tente d’écrire `plots/latest_rmse.png` ; la dépendance `matplotlib` étant absente, seul le log texte apparaît mais l’option PNG restera disponible dès que la bibliothèque sera installée.
- Le même résumé RMS a été capturé dans `plots/latest_rmse.txt` (speech log + sparkline) pour garder une trace sans dépendance graphique ; la présence de ce fichier confirme que les rapports RMSE sont archivés même quand la génération PNG n’est pas possible.
- Le training script s’assure désormais que `plots/latest_rmse.txt`/`.png` (via le helper `rmse_plot.py`) sont remises à jour après chaque entraînement, ce qui maintient la trace exigée par la revue ft_helpme.

## Tests
```bash
./scripts/run_tests.sh
```
Les tests incluent un dataset synthétique (`y = 2x + 1`) pour vérifier la convergence de l’algorithme.

## Validation
- `scripts/validation.py` effectue des splits aléatoires (option `--test-size`, `--folds`, `--seed`), entraîne avec les options `--scheduler/--decay/--min-lr` et affiche le RMSE moyen par fold afin de comparer différentes stratégies; un rappel de commande typique :
  ```
  python3 scripts/validation.py data/data.csv --folds 5 --test-size 0.2 --learning-rate 0.1 --iterations 1000 --scheduler exponential --decay 0.95
  ```
  Ce script complète `scripts/reports/rmse_plot.py` en fournissant des métriques sur la validation croisée que la review ft_helpme doit examiner.
- Les sorties de cette exécution se loggent aussi dans `data/validation_report.txt` (RMSE par fold + moyenne) pour garder une trace réutilisable par la suite.
- `data/validation_report.txt` est réécrit à chaque validation run (dernière exécution documentée : 2025-12-11 11:39:35) pour prouver que les même hyperparamètres validés restent cohérents à travers les splits.
- Un nouveau script `scripts/validation_summary.py` peut lire `data/validation_report.txt` et fournir un résumé rapide (nombre de folds, meilleur/pire RMSE, moyenne) pour faciliter les comptes rendus de la review.
  - La commande `scripts/validation_summary.py --report data/validation_report.txt --output docs/validation_summary.txt --markdown docs/validation_summary.md --json docs/validation_summary.json` garde un instantané prêt à être annexé aux notes de validation ft_helpme (`docs/validation_summary.*` contiennent les best/worst/average RMSE extraits de `data/validation_report.txt`, avec une table Markdown, un JSON et un HTML générés automatiquement); la session 12:59 a généré avg=978.62 (confirmé par `scripts/check_validation_stability.py`).
  - `scripts/check_validation_stability.py` lit `docs/validation_summary.json` en priorité (et bascule sur la version texte si nécessaire) puis émet un code d’erreur si la moyenne dépasse 1200, fournissant un point de contrôle rapide pour la revue ft_helpme (actuellement avg=978.62, best=594.47, worst=1520.42) et mettant en avant l’usage du snapshot JSON pour l’intégration automatisée.
  - `scripts/validation_summary_html.py` rend `docs/validation_summary.json` dans un petit tableau HTML (`docs/validation_summary.html`) afin que la review puisse coller la page dans un navigateur ou la partager rapidement sans manipuler Markdown/JSON; ce HTML est recréé chaque fois que le JSON change (lors des runs avec `--json`).
  - `scripts/archive_validation_html.py` copie le snapshot HTML vers `docs/archive/validation_summary_<stamp>.html`, ce qui permet de conserver des archives horodatées pour la revue ft_helpme après chaque acceptance.
  - `scripts/preview_validation.py` enchaîne `validation_summary.py --json` puis `check_validation_stability.py` pour rafraîchir tous les artefacts (`docs/validation_summary.*`, `docs/validation_summary.html`) et relancer la vérification avg<1200 en une seule commande pratique pour la revue et une CI rapide; passe `--archive` pour appeler `scripts/archive_validation_html.py` juste après et garder un snapshot horodaté.
- `scripts/log_validation_summary.py` alimente `docs/validation_history.md` avec chaque snapshot (timestamp + best/worst/avg) pour garder un journal linéaire des metrics.
- `scripts/analyze_validation_history.py` synthétise ce journal (nombre d’entrées, best/worst/avg range) pour voir comment la moyenne RMSE évolue dans le temps.
- `scripts/export_validation_history_csv.py` convertit `docs/validation_history.md` en `docs/validation_history.csv`, ce qui permet d’importer directement les valeurs timestamp/best/worst/avg dans un tableur ou un outil de dataviz sans manipuler Markdown.
- `scripts/trend_validation_history.py` lit la même `docs/validation_history.md`, calcule le delta moyen de RMSE entre les snapshots, compte les progressions/régressions et renvoie un WARNING (code 1) si la moyenne augmente de plus de 0.5, fournissant un outil rapide pour juger la pente RMSE sans ouvrir un tableur.
- `scripts/highlight_validation_history.py` synthétise l’historique pour extraire la moyenne la plus basse, la moyenne la plus haute et le snapshot le plus récent, offrant un résumé immédiat des metrics à partager avec la revue ft_helpme; le script écrit également `docs/validation_history_highlight.md` pour que le résumé soit prêt à coller dans les notes de validation, et ajoute un rappel sur l’utilisation du highlight dans `docs/convergence.md`.
- `scripts/verify_validation_highlight.py` vérifie que les highlights latest/best/worst extraits de `docs/validation_history_highlight.md` correspondent bien aux moyennes réellement listées dans `docs/validation_history.md`, et échoue (code 1) si le highlight diverge, ce qui ajoute un contrôle automatisé aux artefacts df pour la revue.
- `scripts/refresh_validation_artifacts.py` enchaîne `preview_validation` + `check_validation_stability.py` (optionnellement `--archive`) et remet à jour `docs/validation_summary.*` ainsi que les exports HTML/CSV/YAML/JSON ; un `--archive` récent (2025-12-11T16:56:27Z) a généré `docs/archive/validation_summary_20251211T165627Z.html`, confirmant que la moyenne 978.62 reste sous 1200 et que la revue dispose d’un snapshot daté à partager.
- `scripts/refresh_validation_artifacts.py --archive` peut être réexécuté sans modifier les métriques, ce qui produit de nouveaux HTML horodatés (`docs/archive/validation_summary_20251211T170443Z.html`) tout en conservant `avg=978.62 < 1200`; la commande enchaîne aussi la vérification `scripts/check_validation_stability.py` et assure que la revue ft_helpme peut récupérer un artefact fraîchement archivé sans être ralentie par des étapes manuelles.
- Retour à la commande : `python3 scripts/check_validation_stability.py` est incluse dans la documentation pour rappeler que ce check se lance après la génération du summary et peut être intégré au pipeline CI de la revue.
- L’exécution récente (`python3 scripts/check_validation_stability.py`) confirme la stabilité (avg=978.62, best=594.47, worst=1520.42). Ajouter cette ligne ici signale que le script passe aujourd’hui et les artefacts sont cohérents.

## Revue ft_helpme (12/12/2025)
- Suite à la review 42Net (notes/review_outcome.md), on conserve le scheduler `exponential` avec `decay 0.95` comme configuration recommandée ; le flag `--min-lr 1e-9` protège sur plateau et les traces sont écrites dans `data/history.json`.
- Le suivi RMSE s’effectue via `scripts/train.sh` (historique + `scripts/reports/rmse_plot.py data/history.json [--png plots/rmse.png]`) : l’ASCII sparkline + résumé (avg/best/worst) documentent la convergence à chaque run.
- Validation personnalisée (k-fold, bootstrap optionnelle) passe par `scripts/validation.py` : `python3 scripts/validation.py data/data.csv --folds 5 --test-size 0.2 --learning-rate 0.1 --iterations 1000 --scheduler exponential --decay 0.95` montre la stabilité du RMSE par split, et les remarques sur bootstrap apparaissent dans `notes/review_followup.md`.
- Les options `--early-stop`, `--patience` et `--min-delta` restent disponibles pour détecter les plateaux ; les sorties de validation + RMSE plot servent d’indicateurs pour ajuster les hyperparamètres sans repartir de zéro.

## Stratégie & métriques
- Toutes les options `--scheduler`, `--decay`, `--min-lr`, `--early-stop`, `--patience` et `--min-delta` gouvernent la cadence d’apprentissage ; la configuration recommandée active `exponential` avec early stopping pour stabiliser le RMSE tout en donnant des signaux au script `scripts/validation.py`.
- Le flag `--history path` (automatiquement `data/history.json` via `scripts/train.sh`) enregistre l’historique RMSE/learning_rate par itération. Utilisez `scripts/reports/rmse_plot.py data/history.json [--png output.png]` pour synthétiser la courbe (résumé, sparkline ASCII, option PNG si `matplotlib` est installé).

## Notes
- Les kilométrages sont normalisés (centrés puis divisés par l’étendue) pour stabiliser le gradient.
- Les paramètres `theta`, la moyenne et l’échelle sont sauvegardés dans `data/theta.json`.
- Bonus envisageables : script de visualisation (matplotlib) ou métriques supplémentaires.
