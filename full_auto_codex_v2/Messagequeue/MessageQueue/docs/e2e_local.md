# E2E local (script)

Ce script execute un flux local simplifie :
1) publie un message de test via l'API RabbitMQ,
2) consomme un message depuis une queue,
3) genere un PDF dummy a partir du payload.

Commande :
```bash
./scripts/e2e_local.sh
```

Options :
- `--silent` : pas d'output.
- `--json` : sortie JSON (inclut `check_rabbitmq` et `pdf_output_dir_missing` en dry-run).
- `--dry-run` : affiche la configuration resolue et sort.
Note: `OUTPUT=all` requiert `--json`.
Note: `PDF_OUTPUT_DIR` peut etre different de `shared/pdfs/` si override et le dry-run JSON affiche le chemin exact sans suffixes.

Variables utiles :
- `QUEUE` (defaut: food_application)
- `EXCHANGE` (defaut: derive de QUEUE)
- `ROUTING_KEY` (defaut: derive par publish_test_message)
- `PAYLOAD_FILE` (defaut: docs/sample_student.json, resolu depuis la racine du repo si besoin)
- `DOC_TYPE` (defaut: QUEUE)
- `PDF_OUTPUT_DIR` (defaut: temp dir)
- `ACK_MODE` (defaut: ack_requeue_false)
- `PURGE_QUEUE` (defaut: 0)
- `VALIDATE_PAYLOAD` (defaut: 1)
- `COUNT` (defaut: 1)
- `INDEX` (defaut: 0)
- `OUTPUT` (defaut: single; single|all)
- `CHECK_RABBITMQ` (defaut: 1)
Note: `INDEX` doit etre < `COUNT` si `OUTPUT=single`.
Contraintes:
- `OUTPUT=all` -> `COUNT >= 2` et `INDEX=0`.
- `QUEUE`, `EXCHANGE`, `ROUTING_KEY` et `DOC_TYPE` doivent etre alphanum, `.` `_` `-` (longueur <= 255).
- `ROUTING_KEY` doit etre vide si `EXCHANGE=SOCIAL_ASSISTANCE_EXCHANGE`.
- `CONTENT_TYPE` et `MESSAGE_ID` proviennent de publish_test_message (vides -> defaults); CONTENT_TYPE ne doit pas etre blanc (espaces/tabs/newlines) et MESSAGE_ID ne doit pas contenir d'espaces/tabs/newlines (<=255).
- `PAYLOAD_FILE` doit etre un `.json` existant, lisible, non vide et valide.
- `PDF_OUTPUT_DIR` doit etre un dossier writable (cree si absent hors `--dry-run`).
- `ACK_MODE` : `ack_requeue_false` ou `ack_requeue_true`.
- `PURGE_QUEUE`, `VALIDATE_PAYLOAD`, `CHECK_RABBITMQ` : `0` ou `1`.

Exemples :
```bash
QUEUE=grant_contracts ./scripts/e2e_local.sh
```
```bash
./scripts/e2e_local.sh --json
```
```bash
PURGE_QUEUE=1 ./scripts/e2e_local.sh
```
```bash
VALIDATE_PAYLOAD=0 ./scripts/e2e_local.sh
```
```bash
COUNT=2 ./scripts/e2e_local.sh
```
```bash
COUNT=2 INDEX=1 ./scripts/e2e_local.sh
```
```bash
COUNT=2 OUTPUT=all ./scripts/e2e_local.sh --json
```
```bash
CHECK_RABBITMQ=0 ./scripts/e2e_local.sh --json
```
```bash
./scripts/e2e_local.sh --dry-run
```

Nettoyage des PDFs de test :
```bash
rm -f shared/pdfs/*
```
