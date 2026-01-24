# Variables d'environnement (scripts)

## Globals
- `RABBITMQ_HOST` (defaut: localhost)
- `RABBITMQ_PORT` (defaut: 15672 pour l'API management)
- `RABBITMQ_USER` / `RABBITMQ_PASS` (defaut: guest/guest)
- `RABBITMQ_VHOST` (defaut: /)
- `SKIP_DOCKER` (defaut: 0, ignore docker dans check_prereqs)
- `SKIP_MVN` (defaut: 0, ignore mvn dans check_prereqs)

## check_prereqs.sh
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## check_rabbitmq.sh
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## wait_rabbitmq.sh
- `TIMEOUT` (defaut: 30)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## publish_test_message.sh
- `EXCHANGE` (defaut: GRANT_EXCHANGE)
- `ROUTING_KEY` (defaut: grantType du payload, sinon grant.1.contract)
- `PAYLOAD_FILE` (defaut: docs/sample_student.json, resolu depuis la racine du repo si besoin)
- `STRICT_GRANT_TYPE` (defaut: 0; si 1, echec si grantType != ROUTING_KEY)
- `EXCHANGE`/`ROUTING_KEY` acceptent uniquement lettres, chiffres, point, underscore, hyphen (<=255 chars).
- Le `PAYLOAD_FILE` doit etre un fichier lisible (pas un dossier).
- Le payload doit etre un JSON valide, sinon publish_test_message echoue.
- `CONTENT_TYPE` vide prend la valeur par defaut, mais ne doit pas etre uniquement des espaces/tabs/newlines, et <=255 chars.
- `MESSAGE_ID` vide prend la valeur par defaut, sans espaces/tabs/newlines, et <=255 chars.
- En mode `--json`, les erreurs de validation retournent `{status:"error", error:"..."}`.
- `--silent` (pas d'output)
- `--json` (sortie JSON)
- `--dry-run` (validation + sortie, sans appel HTTP)

## consume_test_message.sh
- `QUEUE` (defaut: food_application)
- `COUNT` (defaut: 1)
- `ACK_MODE` (defaut: ack_requeue_false)
- `TRUNCATE` (defaut: 50000)
- `OUTPUT` (defaut: raw; raw|pretty)
- `--silent` (pas d'output)
- `--json` (sortie JSON brute)

## validate_payload.py
- `PAYLOAD_FILE` (defaut: docs/sample_student.json, resolu depuis la racine du repo si besoin)
- `--json` (sortie JSON)

## test_validate_payload.sh
- `--json` (sortie JSON)

## count_queue_messages.sh
- `QUEUES` (CSV, defaut: toutes les queues)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## purge_queues.sh
- `QUEUES` (CSV, defaut: food_application,financial_assistance_application,transportation_costs_application,grant_contracts,grant_other_documents)

## bootstrap_rabbitmq.sh
- `SOCIAL_EXCHANGE` (defaut: SOCIAL_ASSISTANCE_EXCHANGE)
- `GRANT_EXCHANGE` (defaut: GRANT_EXCHANGE)
- `FOOD_QUEUE` (defaut: food_application)
- `FINANCIAL_QUEUE` (defaut: financial_assistance_application)
- `TRANSPORT_QUEUE` (defaut: transportation_costs_application)
- `CONTRACTS_QUEUE` (defaut: grant_contracts)
- `OTHER_QUEUE` (defaut: grant_other_documents)
- `CONTRACTS_ROUTING_KEY` (defaut: grant.*.contract)
- `OTHER_ROUTING_KEY` (defaut: grant.*)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## validate_rabbitmq.sh
- `SOCIAL_EXCHANGE` (defaut: SOCIAL_ASSISTANCE_EXCHANGE)
- `GRANT_EXCHANGE` (defaut: GRANT_EXCHANGE)
- `FOOD_QUEUE` (defaut: food_application)
- `FINANCIAL_QUEUE` (defaut: financial_assistance_application)
- `TRANSPORT_QUEUE` (defaut: transportation_costs_application)
- `CONTRACTS_QUEUE` (defaut: grant_contracts)
- `OTHER_QUEUE` (defaut: grant_other_documents)
- `CONTRACTS_ROUTING_KEY` (defaut: grant.*.contract)
- `OTHER_ROUTING_KEY` (defaut: grant.*)
- `--silent` (pas d'output)

## post_sample.sh
- `PRODUCER_URL` (defaut: http://localhost:8080/students)
- `PAYLOAD_FILE` (defaut: docs/sample_student.json)
- `OUTPUT` (defaut: raw; raw|pretty|status)
- `--silent` (pas d'output)
- `--json` (sortie JSON brute)

## generate_dummy_pdf.py
- `PDF_OUTPUT_DIR` (defaut: shared/pdfs)
- `PDF_NAME` (defaut: dummy_YYYYMMDD_HHMMSS.pdf)
- `PDF_TEXT` (defaut: MessageQueue dummy PDF)
Note: `PDF_OUTPUT_DIR` doit etre writable.

## simulate_consumer.py
- `PAYLOAD_FILE` (defaut: docs/sample_student.json)
- `DOC_TYPE` (defaut: food_application)

## build_modules.sh
- `MODULES` (CSV, defaut: tous les modules; accepte nom ou chemin)

## list_exchanges.sh
- `EXCHANGES` (CSV, defaut: toutes les exchanges)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## list_queues.sh
- `QUEUES` (CSV, defaut: toutes les queues)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## list_bindings.sh
- `SOURCES` (CSV, defaut: toutes les sources)
- `DESTINATIONS` (CSV, defaut: toutes les destinations)
- `ROUTING_KEYS` (CSV, defaut: toutes les routing keys)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## load_env.sh
- `ENV_FILE` (defaut: .env)

## setup_env.sh
- `SRC` (defaut: .env.example)
- `DST` (defaut: .env)

## reset_local.sh
- `CLEAN_PDFS` (defaut: 1)
- `PURGE_QUEUES` (defaut: 0)
- `STOP_DOCKER` (defaut: 1)

## publish_sample_keys.sh
- utilise `GRANT_EXCHANGE` et les keys d'exemple
- `ROUTING_KEYS` (CSV, defaut: grant.application,grant.guarantee,grant.1.contract,grant.2.contract)
- `PAYLOAD_FILE` (defaut: docs/sample_student.json)
- `STRICT_GRANT_TYPE` (defaut: 0)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## create_bindings.sh
- `SOCIAL_EXCHANGE` (defaut: SOCIAL_ASSISTANCE_EXCHANGE)
- `GRANT_EXCHANGE` (defaut: GRANT_EXCHANGE)
- `FOOD_QUEUE` (defaut: food_application)
- `FINANCIAL_QUEUE` (defaut: financial_assistance_application)
- `TRANSPORT_QUEUE` (defaut: transportation_costs_application)
- `CONTRACTS_QUEUE` (defaut: grant_contracts)
- `OTHER_QUEUE` (defaut: grant_other_documents)
- `CONTRACTS_ROUTING_KEY` (defaut: grant.*.contract)
- `OTHER_ROUTING_KEY` (defaut: grant.*)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## run_checks.sh
- `--skip-routing` (skip test_routing_matrix, combinable)
- `--skip-doctor` (skip doctor, combinable)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## doctor.sh
- `--silent` (pas d'output)
- `--json` (sortie JSON, champs: status, prereqs, rabbitmq, topology, payload, payload_tests, publish_tests)

## test_routing.sh
- `GRANT_EXCHANGE` (defaut: GRANT_EXCHANGE)
- `CONTRACTS_QUEUE` (defaut: grant_contracts)
- `OTHER_QUEUE` (defaut: grant_other_documents)
- `CONTRACTS_ROUTING_KEY` (defaut: grant.*.contract)
- `OTHER_ROUTING_KEY` (defaut: grant.*)
- `ROUTING_KEY` (defaut: grant.1.contract)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## test_routing_matrix.sh
- `GRANT_EXCHANGE` (defaut: GRANT_EXCHANGE)
- `CONTRACTS_QUEUE` (defaut: grant_contracts)
- `OTHER_QUEUE` (defaut: grant_other_documents)
- `CONTRACTS_ROUTING_KEY` (defaut: grant.*.contract)
- `OTHER_ROUTING_KEY` (defaut: grant.*)
- `ROUTING_KEYS` (CSV, defaut: grant.application,grant.guarantee,grant.1.contract,grant.2.contract)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## test_consumers.sh
- `MODULES` (CSV, defaut: tous les consumers; accepte nom ou chemin)

## test_e2e_local.sh
- `--help` (affiche l'usage)
- `--json` (sortie JSON)
- `QUEUE` (defaut: food_application)
- `COUNT` (defaut: 2)
- `INDEX` (defaut: 1)
- `OUTPUT` (defaut: all; single|all)

## smoke_local.sh
- `GRANT_EXCHANGE` (defaut: GRANT_EXCHANGE)
- `CONTRACTS_QUEUE` (defaut: grant_contracts)
- `OTHER_QUEUE` (defaut: grant_other_documents)
- `ROUTING_KEY` (defaut: vide; publish derive du payload, test_routing force grant.1.contract)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## status_report.sh
- `QUEUE_FILTER` (CSV, defaut: toutes les queues)
- `EXCHANGE_FILTER` (CSV, defaut: toutes les exchanges)
- `SOURCE_FILTER` (CSV, defaut: toutes les sources)
- `DESTINATION_FILTER` (CSV, defaut: toutes les destinations)
- `ROUTING_KEY_FILTER` (CSV, defaut: toutes les routing keys)
- `--silent` (pas d'output)
- `--json` (sortie JSON)

## e2e_local.sh
- `QUEUE` (defaut: food_application)
- `EXCHANGE` (defaut: derive de QUEUE)
- `ROUTING_KEY` (defaut: derive par publish_test_message)
- `PAYLOAD_FILE` (defaut: docs/sample_student.json)
- `DOC_TYPE` (defaut: QUEUE)
- `PDF_OUTPUT_DIR` (defaut: temp dir)
- `ACK_MODE` (defaut: ack_requeue_false)
- `PURGE_QUEUE` (defaut: 0)
- `VALIDATE_PAYLOAD` (defaut: 1)
- `COUNT` (defaut: 1)
- `INDEX` (defaut: 0)
- `OUTPUT` (defaut: single; single|all)
- `CHECK_RABBITMQ` (defaut: 1)
- `--silent` (pas d'output)
- `--json` (sortie JSON)
- `--dry-run` (sortie config sans execution)

## readme_toc.sh
- `FILE` (defaut: Messagequeue/MessageQueue/README.md)
