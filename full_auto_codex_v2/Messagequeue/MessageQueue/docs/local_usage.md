# Usage local (recap)

Commandes rapides :

1) Initialiser .env (optionnel) :
```bash
./scripts/setup_env.sh
./scripts/load_env.sh
```
Check prerequis en mode silencieux :
```bash
./scripts/check_prereqs.sh --silent
```

2) Creer les exchanges/queues/bindings (sans docker) :
```bash
./scripts/create_bindings.sh
```

3) Lancer un check global :
```bash
./scripts/doctor.sh
```
Ou en mode silencieux :
```bash
./scripts/run_checks.sh --silent
```
Ou en JSON :
```bash
./scripts/run_checks.sh --json
```
Mode silencieux doctor :
```bash
./scripts/doctor.sh --silent
```
Mode JSON doctor :
```bash
./scripts/doctor.sh --json
```
Validation payload en JSON :
```bash
./scripts/validate_payload.py --json
```
Tests payload en JSON :
```bash
./scripts/test_validate_payload.sh --json
```

4) Smoke test complet :
```bash
./scripts/smoke_local.sh
```
Note: publish derive la routing key depuis `grantType` du payload si `ROUTING_KEY` est vide.
Mode silencieux :
```bash
./scripts/smoke_local.sh --silent
```
Mode JSON :
```bash
./scripts/smoke_local.sh --json
```

5) Test routing matrix :
```bash
./scripts/test_routing_matrix.sh
```
Override CSV :
```bash
ROUTING_KEYS="grant.foo,grant.2.contract" ./scripts/test_routing_matrix.sh
```
Mode JSON :
```bash
./scripts/test_routing_matrix.sh --json
```

5b) Test e2e (publish -> consume -> PDF dummy) :
```bash
./scripts/e2e_local.sh
```
Mode JSON :
```bash
./scripts/e2e_local.sh --json
```
Option purge queue :
```bash
PURGE_QUEUE=1 ./scripts/e2e_local.sh
```
Option skip validation payload :
```bash
VALIDATE_PAYLOAD=0 ./scripts/e2e_local.sh
```
Option count > 1 :
```bash
COUNT=2 ./scripts/e2e_local.sh
```
Option index du message :
```bash
COUNT=2 INDEX=1 ./scripts/e2e_local.sh
```
Note: `OUTPUT=single` requiert `INDEX < COUNT`.
Option output all (JSON requis) :
```bash
COUNT=2 OUTPUT=all ./scripts/e2e_local.sh --json
```
Option skip check RabbitMQ :
```bash
CHECK_RABBITMQ=0 ./scripts/e2e_local.sh --json
```
Option dry-run :
```bash
./scripts/e2e_local.sh --dry-run
```
Override dossier PDF :
```bash
PDF_OUTPUT_DIR="/tmp/mq-pdfs" ./scripts/e2e_local.sh
```
Nettoyage des PDFs de test :
```bash
rm -f shared/pdfs/*
```

6) Generation PDF dummy :
```bash
./scripts/generate_dummy_pdf.py
```

6b) Poster un payload exemple :
```bash
./scripts/post_sample.sh
```
Sortie status uniquement :
```bash
OUTPUT=status ./scripts/post_sample.sh
```
Sortie JSON brute :
```bash
./scripts/post_sample.sh --json
```
Publier une routing key en JSON :
```bash
ROUTING_KEY="grant.1.contract" ./scripts/publish_test_message.sh --json
```
Override content_type et message_id (sans espaces/tabs/newlines) :
```bash
CONTENT_TYPE="application/json" MESSAGE_ID="mq-test-123" ./scripts/publish_test_message.sh --dry-run --json
```
Note: MESSAGE_ID/CONTENT_TYPE vides utilisent les valeurs par defaut; MESSAGE_ID ne doit pas contenir d'espaces/tabs/newlines, CONTENT_TYPE ne doit pas etre blanc (espaces/tabs/newlines).
Note: si le payload n'est pas un JSON valide, publish_test_message affiche "Payload file is not valid JSON".
Note: PDFs generes par les consumers sont dans `shared/pdfs/` (override via `PDF_OUTPUT_DIR`, cree si absent hors --dry-run).
Note: en mode --json, les erreurs de validation retournent status=error.
Note: en mode --json, payload manquant/illisible/dossier retourne status=error + message explicite.
Note: la sortie JSON du dry-run e2e_local expose `pdf_output_dir` et `pdf_output_dir_missing`.
Dry-run publication (sans appel HTTP) :
```bash
./scripts/publish_test_message.sh --dry-run
```
Test dry-run publication :
```bash
./scripts/test_publish_test_message.sh
```
Sortie JSON :
```bash
./scripts/test_publish_test_message.sh --json
```

7) Sommaire README :
```bash
./scripts/readme_toc.sh
```

8) Log automatique :
```bash
./scripts/append_log.sh "YYYY-MM-DD HH:MM:SS" "Messagequeue/MessageQueue" "IN_PROGRESS" "action"
```

9) Test e2e_local dry-run :
```bash
./scripts/test_e2e_local.sh
```
Sortie JSON :
```bash
./scripts/test_e2e_local.sh --json
```
Override env :
```bash
QUEUE=grant_contracts COUNT=1 INDEX=0 OUTPUT=single ./scripts/test_e2e_local.sh --json
```

Option: rapport filtre (queues) :
```bash
QUEUE_FILTER="grant_contracts,grant_other_documents" ./scripts/status_report.sh
```
Option: rapport filtre en mode silencieux :
```bash
QUEUE_FILTER="grant_contracts,grant_other_documents" ./scripts/status_report.sh --silent
```
Option: rapport JSON (filtre queues) :
```bash
QUEUE_FILTER="grant_contracts,grant_other_documents" ./scripts/status_report.sh --json
```
Option: compteur queues en mode silencieux :
```bash
QUEUES="grant_contracts,grant_other_documents" ./scripts/count_queue_messages.sh --silent
```
Option: consommation JSON brute :
```bash
QUEUE="grant_contracts" COUNT=1 ./scripts/consume_test_message.sh --json
```
