# Runbook local

Sequence rapide pour valider RabbitMQ et les scripts sans code Java.

1) Preparer l'environnement :
```bash
./scripts/setup_env.sh
./scripts/load_env.sh
```

2) Verifier les prerequis :
```bash
./scripts/check_prereqs.sh
```

3) Demarrer RabbitMQ et initialiser la topologie :
```bash
docker compose up -d
./scripts/bootstrap_rabbitmq.sh
./scripts/validate_rabbitmq.sh
```
Alternative sans docker (API management deja disponible) :
```bash
./scripts/create_bindings.sh
./scripts/validate_rabbitmq.sh
```

4) Publier et consommer un message de test :
```bash
./scripts/publish_test_message.sh
QUEUE="grant_contracts" ./scripts/consume_test_message.sh
```
Dry-run publication (sans HTTP) + test rapide :
```bash
./scripts/publish_test_message.sh --dry-run
./scripts/test_publish_test_message.sh
```
Note: `MESSAGE_ID` ne doit pas contenir d'espaces/tabs/newlines (vide -> default) et `CONTENT_TYPE` ne doit pas etre blanc (espaces/tabs/newlines, vide -> default).
Note: si le payload n'est pas un JSON valide, publish_test_message echoue.
Note: en mode --json, les erreurs de validation retournent status=error.
Note: en mode --json, payload manquant/illisible/dossier retourne status=error + message explicite.

5) Test e2e (publish -> consume -> PDF dummy) :
```bash
./scripts/e2e_local.sh
```
Note: PDFs generes par les consumers sont dans `shared/pdfs/` (override via `PDF_OUTPUT_DIR`).
Note: le dry-run `./scripts/test_e2e_local.sh --json` retourne `pdf_output_dir` et un flag `pdf_output_dir_missing` quand le dossier n'existe pas encore.
Note: pour éviter les erreurs vous pouvez lancer `PDF_OUTPUT_DIR=/tmp/mq-pdfs ./scripts/test_e2e_local.sh --json`; le JSON retourné conserve `pdf_output_dir_missing=0`.
Note: pipez la sortie vers `jq '.pdf_output_dir,.pdf_output_dir_missing'` pour confirmer les valeurs.

6) Verifier le routage grant.1.contract :
```bash
./scripts/test_routing.sh
```

7) Rapport rapide :
```bash
./scripts/status_report.sh
```

8) (Optionnel) Lancer producer + consumer :
```bash
./scripts/run_producer.sh
./scripts/run_consumer.sh food_application
```

9) Nettoyage (PDFs locaux) :
```bash
rm -f shared/pdfs/*
```
## PDF workflow
- Avant de publier un message de test, lancez `scripts/publish_test_message_with_check.sh` pour que `verify_pdf_output_dir.sh` prépare `PDF_OUTPUT_DIR`.  
- Après les publications, utilisez `scripts/cleanup_pdf_output_dir.sh` pour purger les PDF résiduels et `scripts/inspect_pdf_output_dir.sh` pour compter les artefacts générés, afin de garder le dossier propre lors des démonstrations.
