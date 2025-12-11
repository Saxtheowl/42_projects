# Validation history

| Timestamp | Best RMSE | Worst RMSE | Average RMSE |
| --- | --- | --- | --- |
- [2025-12-11T17:04:43.000000Z](./archive/validation_summary_20251211T170443Z.html) | best=594.47 | worst=1520.42 | avg=978.62
- [2025-12-11T16:56:27.000000Z](./archive/validation_summary_20251211T165627Z.html) | best=594.47 | worst=1520.42 | avg=978.62
- [2025-12-11T11:39:31.542313+00:00Z](./validation_summary.html) | best=594.47 | worst=1520.42 | avg=978.62
> `scripts/highlight_validation_history.py` lit cette table et expose en une ligne les moyennes latest/best/worst au reviewer, générant aussi `docs/validation_history_highlight.md` pour fournir un snippet prêt à copier; couplé à `export_validation_history_csv.py` et `trend_validation_history.py`, il complète l’historique avec des sorties CSV et des alertes de dérive.
