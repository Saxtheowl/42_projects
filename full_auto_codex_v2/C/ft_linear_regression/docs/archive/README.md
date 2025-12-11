# Archive des snapshots HTML

Chaque exécution de `scripts/preview_validation.py --archive` génère :

- les artefacts `docs/validation_summary.txt`, `.md`, `.json`, `.html`,
- et enfin `scripts/archive_validation_html.py` copie le HTML vers `docs/archive/validation_summary_<timestamp>.html`.

Ce dossier contient donc une trace figée de chaque summary validé (timestamp UTC dans le nom). Pour partager une version approuvée avec la revue ou pour revenir à une référence précédente, ouvrez simplement le fichier HTML correspondant.

Si vous voulez rebâtir un snapshot et en archiver un nouveau, lancez :

```
python3 scripts/preview_validation.py --archive
```

La commande met à jour les artefacts et crée un nouvel `validation_summary_<timestamp>.html` dans ce dossier.

Pour visualiser rapidement les archives disponibles, utilisez `python3 scripts/list_validation_archives.py`.

Pour supprimer les snapshots vieillissants, lancez `python3 scripts/prune_validation_archives.py --days N` (par défaut 30 jours) et gardez uniquement les archives utiles pour la revue.

Après avoir archivé un snapshot avec `scripts/preview_validation.py --archive`, lancez `python3 scripts/verify_archive_summary.py` pour confirmer que la dernière archive reflète les métriques `docs/validation_summary.json` (best/worst/average RMSE).

Si vous voulez tout automatiser (preview + archive + prune + verify + CSV export), exécutez `python3 scripts/refresh_validation_artifacts.py`.

Pour comparer deux archives HTML, lancez `python3 scripts/diff_validation_archives.py validation_summary_<stamp1>.html validation_summary_<stamp2>.html`.
