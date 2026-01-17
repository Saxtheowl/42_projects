# Scripts overview

Ce dossier regroupe les scripts d'aide pour demarrer, configurer et valider RabbitMQ en local.

- check_prereqs.sh : verifie les prerequis locaux (curl, python3, docker).
- wait_rabbitmq.sh : attend que l'API management reponde.
- check_rabbitmq.sh : verifie l'acces a l'API management.
- bootstrap_rabbitmq.sh : cree exchanges/queues/bindings.
- validate_rabbitmq.sh : valide la topologie attendue.
- bootstrap_and_validate.sh : bootstrap + validation en une commande.
- bootstrap_all.sh : docker compose + bootstrap + test de routage.
- smoke_local.sh : smoke test local de bout en bout.
- publish_test_message.sh : publie un message JSON de test.
- publish_sample_keys.sh : publie un lot de routing keys d'exemple.
- post_sample.sh : envoie un payload JSON au producer HTTP.
- validate_payload.py : valide un payload JSON localement.
- doctor.sh : verifie prerequis, payload et topologie si disponible.
- generate_dummy_pdf.py : genere un PDF minimal dans shared/pdfs.
- simulate_consumer.py : simule un consumer et genere un PDF.
- run_checks.sh : enchaine doctor + routing matrix.
- build_modules.sh : build maven des modules (skip tests).
- test_producer.sh : lance les tests Maven du producer.
- tail_rabbitmq_logs.sh : suit les logs docker compose du broker.
- test_consumers.sh : execute les tests Maven des consumers.
- readme_toc.sh : genere un sommaire des sections du README.
- consume_test_message.sh : recupere des messages depuis une queue.
- count_queue_messages.sh : compte les messages par queue.
- list_queues.sh / list_exchanges.sh / list_bindings.sh : inventaire topologie.
- purge_queues.sh : purge des queues ciblees.
- test_routing.sh : verifie le routage (grant.1.contract).
- test_routing_matrix.sh : publie plusieurs routing keys et verifie les comptes.
- status_report.sh : resume l'etat (queues/exchanges/bindings).
- reset_local.sh : nettoie PDFs et arrete docker compose (options).
- run_local_flow.sh : enchaine setup, smoke test et status report.

Utiliser `./scripts/check_prereqs.sh` puis `./scripts/smoke_local.sh` pour une validation rapide.
