# Tests ft_linear_regression

## Pré-requis
```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt  # à créer si besoin (pytest)
```

## Jeux de tests
- `./scripts/run_tests.sh` — exécute la suite Pytest (`tests_realisation`).
- `./scripts/train.sh --learning-rate 0.1 --iterations 1000` — entraîne le modèle sur `data/data.csv`.
- `./scripts/evaluate.py data/data.csv` — calcule la RMSE du modèle sur le dataset.
- `./scripts/predict.sh --mileage 65000` — prédit le prix pour un kilométrage donné.

## Dataset
- `data/data.csv` : colonnes `mileage,price` (kilométrage en km, prix en €).

Les fichiers `data/theta.json` sont générés par `train.sh` et utilisés par `predict.sh`.
