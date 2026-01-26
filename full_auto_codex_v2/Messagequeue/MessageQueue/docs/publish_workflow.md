# Workflow publish_test_message

1. Mise en place du payload
   - Duplicate `docs/sample_publish_payload.json` et ajustez `exchange`, `routing_key`, `doc_type`, `content_type`, `message_id`.
   - Le champ `payload` doit pointer vers un dossier existant (par défaut `docs/`).

2. Validation locale (optionnelle mais recommandée)
   - Exécutez `./scripts/check_publish_payload.py --payload docs/sample_publish_payload.json --directory docs --json`.
   - Le script renvoie `status=error` si les champs sont invalides (longueur, regex, espaces, dossier illisible) et s’aligne sur les erreurs documentées (`test_publish_test_message`, `test_matrix`).

3. Publication
   - Avant la publication, lancez `./scripts/prepare_pdf_output_dir.sh` (ou `verify_pdf_output_dir.sh` suivi de `cleanup_pdf_output_dir.sh`) pour créer/valider le répertoire `PDF_OUTPUT_DIR` et purger les PDF résiduels.
   - Lancez `./scripts/publish_test_message_with_check.sh docs/sample_publish_payload.json` ou utilisez directement `./scripts/publish_test_message_with_check --json docs/sample_publish_payload.json` pour combiner la vérification du répertoire et la publication.
   - En mode `--json`, vous obtenez `status=ok`/`status=error` avec les champs `pdf_output_dir`/`pdf_output_dir_missing`.

4. Vérification des artefacts et métadonnées
   - Si `status=ok`, vérifiez que `PDF_OUTPUT_DIR` contient les PDF attendus (les docs `run_modules`, `smoke_plan` détaillent les chemins).
   - Après chaque publication en mode JSON, exécutez `./scripts/verify_publish_pdf_metadata.sh <path-to-json>` (ou configure la variable `PAYLOAD_FILE` / `PDF_OUTPUT_DIR`) pour confirmer que `pdf_output_dir` est présent, `pdf_output_dir_missing=0` et les champs relatifs aux PDF répondent au contrat décrit dans `docs/api_contract.md`.
   - Utilisez `./scripts/inspect_pdf_output_dir.sh` pour compter les PDF générés et `jq '.pdf_output_dir,.pdf_output_dir_missing'` pour confirmer les chemins.
   - Nettoyez le dossier pour les runs suivants avec `./scripts/cleanup_pdf_output_dir.sh`, ou laissez `inspect`/`ensure_pdf_output_dir_has_file.sh` confirmer la présence d’un artefact pour les démonstrations.

5. Intégration continue
   - Les scripts `test_publish_test_message`, `test_matrix`, `test_e2e_local` héritent de ce workflow en validant les mêmes contraintes et en inspectant les exports JSON/CSV.
   - Les logs `tests_summary`/`logs_metrics` peuvent aider à reproduire un `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` confirmant les exports du run.
