# Outils de test (local)

## Scripts RabbitMQ
- `scripts/check_rabbitmq.sh` : verifie l'API management.
- `scripts/wait_rabbitmq.sh` : attend que l'API soit prete.
- `scripts/bootstrap_rabbitmq.sh` : cree exchanges/queues/bindings.
- `scripts/validate_rabbitmq.sh` : verifie la topologie.
- `scripts/check_prereqs.sh` : verifie les prerequis locaux.
- `scripts/load_env.sh` : charge un `.env` et affiche les variables utiles.
- `scripts/smoke_local.sh` : smoke test complet en local.
- `scripts/list_queues.sh` / `scripts/list_exchanges.sh` / `scripts/list_bindings.sh`
- `scripts/publish_test_message.sh` / `scripts/consume_test_message.sh`
- `scripts/publish_sample_keys.sh` : publie plusieurs routing keys d'exemple.
- `scripts/post_sample.sh` : envoie un payload HTTP au producer.
- `scripts/validate_payload.py` : valide un JSON localement.
- `scripts/doctor.sh` : check global prerequis + payload + topologie.
- `scripts/generate_dummy_pdf.py` : genere un PDF minimal dans shared/pdfs.
- `scripts/simulate_consumer.py` : simule un consumer et genere un PDF.
- `scripts/run_checks.sh` : lance un check global + routing matrix.
- `scripts/build_modules.sh` : build les modules Maven (skip tests).
- `scripts/test_producer.sh` : execute les tests du producer.
- `scripts/tail_rabbitmq_logs.sh` : suit les logs RabbitMQ (docker compose).
- `scripts/test_consumers.sh` : execute les tests des consumers.
- `scripts/readme_toc.sh` : genere un sommaire du README.
- `scripts/test_routing.sh` : verifie `grant.1.contract`.
- `scripts/test_routing_matrix.sh` : verifie plusieurs routing keys.
