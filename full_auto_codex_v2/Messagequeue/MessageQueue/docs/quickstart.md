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
Ajoutez `./scripts/cleanup_pdf_output_dir.sh` pour effacer les artefacts PDF avant de relancer un test complet.
Consultez `./scripts/inspect_pdf_output_dir.sh` pour compter les PDF encore présents avant un run critique.
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
