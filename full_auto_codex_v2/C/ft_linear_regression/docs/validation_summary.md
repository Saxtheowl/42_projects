# Validation summary (2025-12-11T11:39:31.542313)

| Metric | Value |
| --- | --- |
| Fold count | 5 |
| Best fold RMSE | 594.47 |
| Worst fold RMSE | 1520.42 |
| Average RMSE | 978.62 |

Pour illustrer la disponibilité de ce snapshot :

- JSON snapshot : [`docs/validation_summary.json`](validation_summary.json)
- HTML snapshot : [`docs/validation_summary.html`](validation_summary.html)
- Archive folder : [`docs/archive/`](archive/) (via `scripts/archive_validation_html.py`)
- Archive index : [`docs/archive/index.md`](archive/index.md) (généré par `scripts/index_validation_archives.py`)
- Refresh pipeline : `scripts/refresh_validation_artifacts.py` régénère `docs/validation_summary.*`, archive le dernier HTML, nettoie les vieux archives et vérifie que la dernière archive reflète le JSON partagé, donnant un artefact prêt pour la revue ft_helpme.
