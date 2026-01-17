# Variables d'environnement (scripts)

## Globals
- `RABBITMQ_HOST` (defaut: localhost)
- `RABBITMQ_PORT` (defaut: 15672 pour l'API management)
- `RABBITMQ_USER` / `RABBITMQ_PASS` (defaut: guest/guest)
- `RABBITMQ_VHOST` (defaut: /)

## publish_test_message.sh
- `EXCHANGE` (defaut: GRANT_EXCHANGE)
- `ROUTING_KEY` (defaut: grant.1.contract)
- `PAYLOAD_FILE` (defaut: docs/sample_student.json)

## consume_test_message.sh
- `QUEUE` (defaut: food_application)
- `COUNT` (defaut: 1)
- `ACK_MODE` (defaut: ack_requeue_false)
- `TRUNCATE` (defaut: 50000)

## purge_queues.sh
- `QUEUES` (CSV, defaut: food_application,financial_assistance_application,transportation_costs_application,grant_contracts,grant_other_documents)

## post_sample.sh
- `PRODUCER_URL` (defaut: http://localhost:8080/students)
- `PAYLOAD_FILE` (defaut: docs/sample_student.json)

## generate_dummy_pdf.py
- `PDF_OUTPUT_DIR` (defaut: shared/pdfs)
- `PDF_NAME` (defaut: dummy_YYYYMMDD_HHMMSS.pdf)
- `PDF_TEXT` (defaut: MessageQueue dummy PDF)

## simulate_consumer.py
- `PAYLOAD_FILE` (defaut: docs/sample_student.json)
- `DOC_TYPE` (defaut: food_application)

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

## test_routing_matrix.sh
- utilise `GRANT_EXCHANGE` et publie plusieurs keys
