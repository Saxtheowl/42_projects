# Quickstart local

```bash
docker compose up -d
./scripts/check_rabbitmq.sh
./scripts/bootstrap_rabbitmq.sh
./scripts/validate_rabbitmq.sh
./scripts/publish_test_message_with_check.sh --dry-run
./scripts/test_publish_test_message.sh
```
Note: CONTENT_TYPE/MESSAGE_ID vides utilisent les valeurs par defaut; CONTENT_TYPE ne doit pas etre blanc (espaces/tabs/newlines) et MESSAGE_ID ne doit pas contenir d'espaces/tabs/newlines.
Note: si le payload n'est pas un JSON valide, publish_test_message echoue.
Note: en mode --json, les erreurs de validation retournent status=error.
Note: en mode --json, payload manquant/illisible/dossier retourne status=error + message explicite.
Note: PDFs generes par les consumers sont dans `shared/pdfs/` (override via `PDF_OUTPUT_DIR`). Lisez `README`/docs pour préférer `publish_test_message_with_check.sh` et assurer que `PDF_OUTPUT_DIR` est prêt avant chaque run.
Note: `publish_test_message --json` renvoie `pdf_output_dir` et `pdf_output_dir_missing` even on success; utilisez la nouvelle `scripts/verify_publish_pdf_metadata.sh` helper (ou `jq '.pdf_output_dir,.pdf_output_dir_missing'`) pour vérifier that the metadata contains `pdf_output_dir_missing=0`.
Ajoutez `./scripts/cleanup_pdf_output_dir.sh` pour effacer les artefacts PDF avant de relancer un test complet.
Consultez `./scripts/inspect_pdf_output_dir.sh` pour compter les PDF encore présents avant un run critique.
Utilisez `./scripts/ensure_pdf_output_dir_has_file.sh` pour confirmer qu’au moins un PDF est bien généré dans `PDF_OUTPUT_DIR` après un publish_test_message.
Avant chaque simulation, exécutez `./scripts/prepare_pdf_output_dir.sh` : il enchaîne `verify_pdf_output_dir.sh`, `cleanup_pdf_output_dir.sh` et `ensure_pdf_output_dir_has_file.sh` pour valider l’accès, vider les PDF précédents, puis vérifier qu’un artefact figure après la prochaine publication.
Pour automatiser la préparation, lancez `./scripts/prepare_pdf_output_dir.sh` pour vérifier et nettoyer le dossier avant d’exécuter un `publish_test_message`.

Option tout-en-un :
```bash
./scripts/bootstrap_and_validate.sh
```

Nettoyage des PDFs de test :
```bash
rm -f shared/pdfs/*
```
Vous pouvez aussi lancer `./scripts/cleanup_pdf_output_dir.sh` pour cibler le répertoire `PDF_OUTPUT_DIR` configuré, ce qui supprime les PDF avant d'exécuter un scénario complet.
