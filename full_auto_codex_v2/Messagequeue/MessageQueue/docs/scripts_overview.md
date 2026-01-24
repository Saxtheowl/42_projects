# Scripts overview

Ce dossier regroupe les scripts d'aide pour demarrer, configurer et valider RabbitMQ en local.

- check_prereqs.sh : verifie les prerequis locaux (SKIP_DOCKER/SKIP_MVN, --silent, --json).
- wait_rabbitmq.sh : attend que l'API management reponde (--silent, --json).
- check_rabbitmq.sh : verifie l'acces a l'API management (--silent, --json).
- bootstrap_rabbitmq.sh : cree exchanges/queues/bindings (--silent, --json).
- create_bindings.sh : cree exchanges/queues/bindings (sans docker, --silent, --json).
- validate_rabbitmq.sh : valide la topologie attendue (--silent, --json).
- bootstrap_and_validate.sh : bootstrap + validation en une commande.
- bootstrap_all.sh : docker compose + bootstrap + test de routage.
- smoke_local.sh : smoke test local de bout en bout (--silent, --json).
- publish_test_message.sh : publie un message JSON de test (copie grantType dans metadata, routing key derivee, valide exchange/routing/content_type/message_id, refuse content_type blanc (espaces/tabs/newlines) et message_id avec espaces/tabs/newlines, content_type/message_id vides -> defaults, refuse payload JSON invalide, sortie JSON d'erreur en --json si python3 dispo, --help, --silent, --json, --dry-run, STRICT_GRANT_TYPE).
- publish_sample_keys.sh : publie un lot de routing keys (ROUTING_KEYS, --silent, --json, PAYLOAD_FILE).
- verify_pdf_output_dir.sh : verifie que `PDF_OUTPUT_DIR` est defini, accessible et modifiable avant d'invoquer publish_test_message ou les consumers qui ecrivent des PDF.
- post_sample.sh : envoie un payload JSON au producer HTTP (--help, --silent, --json, OUTPUT=pretty|status).
- validate_payload.py : valide un payload JSON localement (champ requis + grantType routing key, --json).
- test_validate_payload.sh : tests simples du validateur (ok/ko, --json).
- test_publish_test_message.sh : tests dry-run pour publish_test_message (payload JSON invalide, CONTENT_TYPE blanc (espaces/tabs/newlines), CONTENT_TYPE vide -> default, MESSAGE_ID vide -> default, MESSAGE_ID avec espaces/tabs/newlines, --help, --json avec empty_message_id/whitespace_content_type).
- test_e2e_local.sh : test dry-run JSON du e2e_local (--help, --json).
- doctor.sh : verifie prerequis, payload, tests validate_payload/publish_test_message et topologie si disponible (--silent, --json).
- generate_dummy_pdf.py : genere un PDF minimal dans shared/pdfs.
- simulate_consumer.py : simule un consumer et genere un PDF.
- run_checks.sh : enchaine doctor + routing matrix (ou --skip-doctor/--skip-routing/--silent/--json).
- build_modules.sh : build maven des modules (skip tests, MODULES/--list).
- test_producer.sh : lance les tests Maven du producer (ou `--list`).
- tail_rabbitmq_logs.sh : suit les logs docker compose du broker.
- test_consumers.sh : execute les tests Maven des consumers (MODULES/--list).
- readme_toc.sh : genere un sommaire des sections du README (FILE).
- append_log.sh : ajoute une ligne dans progress.md et README racine.
- run_producer.sh : lance le producer (mvn spring-boot:run).
- run_consumer.sh : lance un consumer specifie (ou `--list`).
- consume_test_message.sh : recupere des messages depuis une queue (--help, --silent, --json, OUTPUT=pretty).
- count_queue_messages.sh : compte les messages par queue (filtre via QUEUES, --silent, --json).
- list_queues.sh / list_exchanges.sh / list_bindings.sh : inventaire topologie (filtres CSV via env, --silent, --json).
- purge_queues.sh : purge des queues ciblees.
- cleanup_pdf_output_dir.sh : supprime les PDF dans `PDF_OUTPUT_DIR` (ou `shared/pdfs` par défaut) avant les runs pour garder le dossier propre.
- inspect_pdf_output_dir.sh : affiche le nombre de PDF présents dans `PDF_OUTPUT_DIR` (ou `shared/pdfs` par défaut) pour contrôler ce qui reste après les tests.
- prepare_pdf_output_dir.sh : enchaîne `verify_pdf_output_dir.sh` et `cleanup_pdf_output_dir.sh` pour préparer le répertoire avant une publication ou un test complet.
- ensure_pdf_output_dir_has_file.sh : vérifie qu’au moins un PDF existe dans `PDF_OUTPUT_DIR` avant une démonstration ou un test de bout en bout, signalant l’absence d’artefacts.
- test_routing.sh : verifie le routage (grant.1.contract, --silent, --json).
- test_routing_matrix.sh : publie plusieurs routing keys (ROUTING_KEYS, --silent, --json) et verifie les comptes.
- status_report.sh : resume l'etat (queues/exchanges/bindings, filtres via env, --silent, --json).
- e2e_local.sh : publish -> consume -> PDF dummy (QUEUE/EXCHANGE/ROUTING_KEY, --silent, --json, --dry-run). PDFs ecrits dans shared/pdfs.
- publish_test_message_with_check.sh : run `verify_pdf_output_dir.sh` before invoking `publish_test_message.sh`, ensuring PDF_OUTPUT_DIR exists/writable for real artifact generation.
- reset_local.sh : nettoie PDFs et arrete docker compose (options).
- run_local_flow.sh : enchaine setup, smoke test et status report.

Utiliser `./scripts/check_prereqs.sh` puis `./scripts/smoke_local.sh` pour une validation rapide.
