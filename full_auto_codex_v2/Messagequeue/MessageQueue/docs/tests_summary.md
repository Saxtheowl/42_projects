# Tests summary

## Producer
- Validation champs requis (email manquant/vide)
- Routing key (default/custom)
- Health endpoint

## Payload
- Validation payload (schema + grantType) via `./scripts/validate_payload.py`
- Tests payload (cas ok/ko) via `./scripts/test_validate_payload.sh`
- Tests publish_test_message (help detaille, dry-run, routing key, payload JSON invalide + message d'erreur + status=error en --json, payload manquant/illisible/dossier + status=error en --json, erreurs JSON en --json pour exchange/routing_key/message_id/content_type invalides + longueurs, payload illisible/dossier, longueurs invalides, content_type blanc (espaces/tabs/newlines), content_type vide -> default, message_id vide -> default, message_id avec espaces/tabs/newlines) via `./scripts/test_publish_test_message.sh`
- Sortie `--json` publish_test_message: champs `empty_message_id` et `whitespace_content_type` exposes.

## Consumers
- Dummy PDF generator basic test (one per consumer)
  - Nettoyage: `rm -f shared/pdfs/*` apres les tests.
  - Note: `PDF_OUTPUT_DIR` permet d'override le dossier de sortie.

## Smoke
- E2E local (publish -> consume -> PDF dummy) via `./scripts/e2e_local.sh`
- Test e2e_local dry-run via `./scripts/test_e2e_local.sh`
  - Prerequis: RabbitMQ local demarre (docker compose) et dossier PDF accessible en ecriture.
  - Nettoyage: supprimer les PDFs generes apres verification manuelle.
  - Note: verifier `PDF_OUTPUT_DIR` si le dossier de sortie differe.
  - Note: préparez `PDF_OUTPUT_DIR` avec `./scripts/prepare_pdf_output_dir.sh` (qui combine verify/cleanup/ensure) avant d’appeler les suites pour éviter les erreurs de droit ou les PDF résiduels.
  - Note: executer `PDF_OUTPUT_DIR=/tmp/mq-pdfs ./scripts/test_e2e_local.sh --json` pour voir `pdf_OUTPUT_DIR` et verifiez `pdf_output_dir_missing=0`.
  - Note: le dry-run JSON expose `pdf_output_dir_missing` quand le dossier n'existe pas encore.

Executer les tests :
- Producer: `./scripts/test_producer.sh`
- Consumers: `./scripts/test_consumers.sh`
- Publish (dry-run): `./scripts/test_publish_test_message.sh`
  - Avant/après publication, utiliser `./scripts/cleanup_pdf_output_dir.sh` pour assurer un dossier propre et `./scripts/inspect_pdf_output_dir.sh` pour vérifier les artefacts PDF générés.
- Smoke: `./scripts/e2e_local.sh`
- Smoke (dry-run): `./scripts/test_e2e_local.sh`

Note: Maven doit etre installe (`mvn` disponible).
