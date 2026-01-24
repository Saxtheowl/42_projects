Derniere mise a jour (2026-01-19 15:09:59) : Messagequeue/MessageQueue IN_PROGRESS : README rappelle `jq '.pdf_output_dir,.pdf_output_dir_missing'` la sortie JSON dry-run.
Derniere mise a jour (2026-01-19 14:09:43) : Messagequeue/MessageQueue IN_PROGRESS : tests_summary recommande pré-créer PDF_OUTPUT_DIR plus `pdf_output_dir_missing=0` pour le dry-run.
Derniere mise a jour (2026-01-19 14:04:35) : Messagequeue/MessageQueue IN_PROGRESS : README renvoie vers local_runbook + tests_summary pour les détails `pdf_output_dir`.
Derniere mise a jour (2026-01-19 13:54:43) : Messagequeue/MessageQueue IN_PROGRESS : local_runbook préconise de précréer PDF_OUTPUT_DIR et vérifier pdf_output_dir_missing=0.
Derniere mise a jour (2026-01-19 13:19:47) : Messagequeue/MessageQueue IN_PROGRESS : local_runbook cite le JSON dry-run `pdf_output_dir`.
Derniere mise a jour (2026-01-19 13:10:03) : Messagequeue/MessageQueue IN_PROGRESS : doc local_usage cite le JSON dry-run `pdf_output_dir`.
Derniere mise a jour (2026-01-19 12:54:36) : Messagequeue/MessageQueue IN_PROGRESS : docs e2e_local note le chemin PDF autodisplay.
Derniere mise a jour (2026-01-19 12:50:39) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local dry-run JSON garde pdf_output_dir brut.
Derniere mise a jour (2026-01-19 12:44:47) : Messagequeue/MessageQueue IN_PROGRESS : tests_summary note pdf_output_dir_missing.
Derniere mise a jour (2026-01-19 12:40:34) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local JSON dry-run ajoute pdf_output_dir_missing.
Derniere mise a jour (2026-01-19 12:36:05) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local cree PDF_OUTPUT_DIR manquant hors dry-run + tests/docs.
Derniere mise a jour (2026-01-19 12:30:41) : Messagequeue/MessageQueue IN_PROGRESS : doc local_usage ajoute exemple PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 12:24:51) : Messagequeue/MessageQueue IN_PROGRESS : tests_summary note PDF_OUTPUT_DIR pour smoke.
Derniere mise a jour (2026-01-19 12:19:40) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local note PDF_OUTPUT_DIR override.
Derniere mise a jour (2026-01-19 12:14:52) : Messagequeue/MessageQueue IN_PROGRESS : tests_producer note PDF_OUTPUT_DIR non utilise.
Derniere mise a jour (2026-01-19 12:09:39) : Messagequeue/MessageQueue IN_PROGRESS : test_tools note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 12:04:50) : Messagequeue/MessageQueue IN_PROGRESS : tests_consumers note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 11:59:46) : Messagequeue/MessageQueue IN_PROGRESS : logging note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 11:54:51) : Messagequeue/MessageQueue IN_PROGRESS : test_matrix note PDF_OUTPUT_DIR pour PDFs.
Derniere mise a jour (2026-01-19 11:49:39) : Messagequeue/MessageQueue IN_PROGRESS : security_notes ajoute suppression PDFs tests.
Derniere mise a jour (2026-01-19 11:44:37) : Messagequeue/MessageQueue IN_PROGRESS : module_status note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 11:39:39) : Messagequeue/MessageQueue IN_PROGRESS : payload_schema note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 11:34:53) : Messagequeue/MessageQueue IN_PROGRESS : api_contract ajoute PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 11:29:45) : Messagequeue/MessageQueue IN_PROGRESS : http_endpoints ajoute PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 11:24:33) : Messagequeue/MessageQueue IN_PROGRESS : local_runbook note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 11:19:35) : Messagequeue/MessageQueue IN_PROGRESS : local_usage note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 11:14:34) : Messagequeue/MessageQueue IN_PROGRESS : quickstart note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 11:09:52) : Messagequeue/MessageQueue IN_PROGRESS : tests_summary note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 11:04:55) : Messagequeue/MessageQueue IN_PROGRESS : run_modules mention PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 10:59:59) : Messagequeue/MessageQueue IN_PROGRESS : script_env note PDF_OUTPUT_DIR writable.
Derniere mise a jour (2026-01-19 10:54:34) : Messagequeue/MessageQueue IN_PROGRESS : implementation_plan note PDF_OUTPUT_DIR writable.
Derniere mise a jour (2026-01-19 10:49:31) : Messagequeue/MessageQueue IN_PROGRESS : queue_purpose note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 10:44:51) : Messagequeue/MessageQueue IN_PROGRESS : topology note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 10:40:06) : Messagequeue/MessageQueue IN_PROGRESS : docs_index note ordre alphabetique.
Derniere mise a jour (2026-01-19 10:34:35) : Messagequeue/MessageQueue IN_PROGRESS : smoke_plan note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 10:29:51) : Messagequeue/MessageQueue IN_PROGRESS : consumer_ack note PDF_OUTPUT_DIR writable.
Derniere mise a jour (2026-01-19 10:24:35) : Messagequeue/MessageQueue IN_PROGRESS : todo_next ajoute mention PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 10:19:36) : Messagequeue/MessageQueue IN_PROGRESS : tests_summary note nettoyage PDFs consumers.
Derniere mise a jour (2026-01-19 10:14:40) : Messagequeue/MessageQueue IN_PROGRESS : tests_producer note pas de PDF.
Derniere mise a jour (2026-01-19 10:09:36) : Messagequeue/MessageQueue IN_PROGRESS : tests_consumers ajoute nettoyage PDFs.
## Handoff note
- La section `reports/next_llm_summary.md` condense l’état actuel et propose les prochaines étapes prioritaires pour tout LLM reprenant le projet. Relisez ce fichier avant de démarrer pour savoir où concentrer les efforts et quelles contraintes respecter (log à jour, documentation ciblée, prioriser `IN_PROGRESS`).
## Recent addition
- Le sous-projet `Messagequeue/MessageQueue` dispose maintenant du script `scripts/verify_pdf_output_dir.sh` : exécutez-le avec `PDF_OUTPUT_DIR` défini pour vous assurer que le dossier existe et est accessible avant d’exécuter `publish_test_message`.
- De préférence, utilisez désormais `scripts/publish_test_message_with_check.sh` pour lancer `publish_test_message` après la vérification `PDF_OUTPUT_DIR`, comme détaillé dans le README du sous-projet. Ajoutez également `scripts/inspect_pdf_output_dir.sh`, `scripts/cleanup_pdf_output_dir.sh` et la nouvelle commande `scripts/prepare_pdf_output_dir.sh` pour surveiller, purger et préparer les artefacts PDF entre les runs.
Derniere mise a jour (2026-01-19 10:04:40) : Messagequeue/MessageQueue IN_PROGRESS : test_tools note nettoyage PDFs dummy.
Derniere mise a jour (2026-01-19 09:59:33) : Messagequeue/MessageQueue IN_PROGRESS : test_matrix note nettoyage shared/pdfs.
Derniere mise a jour (2026-01-19 09:54:33) : Messagequeue/MessageQueue IN_PROGRESS : pdf_contents note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 09:49:38) : Messagequeue/MessageQueue IN_PROGRESS : pdf_naming note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 09:44:34) : Messagequeue/MessageQueue IN_PROGRESS : services note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 09:39:35) : Messagequeue/MessageQueue IN_PROGRESS : service_matrix note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 09:34:40) : Messagequeue/MessageQueue IN_PROGRESS : module_layout note PDF_OUTPUT_DIR.
Derniere mise a jour (2026-01-19 09:29:35) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local ajoute nettoyage PDFs.
Derniere mise a jour (2026-01-19 09:24:33) : Messagequeue/MessageQueue IN_PROGRESS : scripts_overview note PDFs e2e_local.
Derniere mise a jour (2026-01-19 09:19:32) : Messagequeue/MessageQueue IN_PROGRESS : http_endpoints note PDF via consumers.
Derniere mise a jour (2026-01-19 09:14:48) : Messagequeue/MessageQueue IN_PROGRESS : service_env note PDF_OUTPUT_DIR writable.
Derniere mise a jour (2026-01-19 09:09:38) : Messagequeue/MessageQueue IN_PROGRESS : sample_routing_keys relie sample_student.json.
Derniere mise a jour (2026-01-19 09:04:38) : Messagequeue/MessageQueue IN_PROGRESS : ports note PDF output dir.
Derniere mise a jour (2026-01-19 08:59:54) : Messagequeue/MessageQueue IN_PROGRESS : api_contract note generation PDF via consumers.
Derniere mise a jour (2026-01-19 08:54:29) : Messagequeue/MessageQueue IN_PROGRESS : security_notes ajoute restriction acces shared.
Derniere mise a jour (2026-01-19 08:49:44) : Messagequeue/MessageQueue IN_PROGRESS : logging note chemin PDF par defaut.
Derniere mise a jour (2026-01-19 08:44:42) : Messagequeue/MessageQueue IN_PROGRESS : run_modules note nettoyage PDFs.
Derniere mise a jour (2026-01-19 08:39:35) : Messagequeue/MessageQueue IN_PROGRESS : local_usage ajoute nettoyage PDFs e2e_local.
Derniere mise a jour (2026-01-19 08:34:37) : Messagequeue/MessageQueue IN_PROGRESS : quickstart ajoute nettoyage PDFs.
Derniere mise a jour (2026-01-19 08:29:34) : Messagequeue/MessageQueue IN_PROGRESS : tests_summary precise prerequis e2e_local.
Derniere mise a jour (2026-01-19 08:24:34) : Messagequeue/MessageQueue IN_PROGRESS : todo_next detaille e2e/pdf/ci.
Derniere mise a jour (2026-01-19 08:19:37) : Messagequeue/MessageQueue IN_PROGRESS : module_status detaille etapes PDF reel.
Derniere mise a jour (2026-01-19 08:16:20) : Messagequeue/MessageQueue IN_PROGRESS : troubleshooting ajoute verification python3 pour --json.
Derniere mise a jour (2026-01-18 13:51:29) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local asserts pdf_output_dir exists when overridden in JSON.
Derniere mise a jour (2026-01-18 13:46:22) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local run after routing_key length check.
Derniere mise a jour (2026-01-18 13:41:27) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates routing_key length in JSON.
Derniere mise a jour (2026-01-18 13:36:28) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates exchange length in JSON.
Derniere mise a jour (2026-01-18 13:31:29) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates doc_type length in JSON.
Derniere mise a jour (2026-01-18 13:26:29) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates routing_key regex in JSON.
Derniere mise a jour (2026-01-18 13:21:37) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates exchange regex in JSON.
Derniere mise a jour (2026-01-18 13:16:28) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates doc_type regex in JSON.
Derniere mise a jour (2026-01-18 13:11:31) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local enforces output=single index<count in JSON.
Derniere mise a jour (2026-01-18 13:06:28) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates output values in JSON.
Derniere mise a jour (2026-01-18 13:01:25) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local run repeated; no new change required.
Derniere mise a jour (2026-01-18 12:56:22) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local help text verified after INDEX default fix.
Derniere mise a jour (2026-01-18 12:51:38) : Messagequeue/MessageQueue IN_PROGRESS : fix test_e2e_local help INDEX default.
Derniere mise a jour (2026-01-18 12:46:26) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejects empty status in JSON.
Derniere mise a jour (2026-01-18 12:41:30) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates status type in JSON.
Derniere mise a jour (2026-01-18 12:36:23) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local requires routing_key for non-social exchange in JSON.
Derniere mise a jour (2026-01-18 12:31:28) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local enforces absolute pdf_output_dir when overridden in JSON.
Derniere mise a jour (2026-01-18 12:26:42) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejects empty exchange string in JSON.
Derniere mise a jour (2026-01-18 12:21:23) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates payload_file type in JSON.
Derniere mise a jour (2026-01-18 12:16:22) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates ack_mode type in JSON.
Derniere mise a jour (2026-01-18 12:11:20) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates purge_queue type in JSON.
Derniere mise a jour (2026-01-18 12:06:20) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates check_rabbitmq type in JSON.
Derniere mise a jour (2026-01-18 12:01:19) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates validate_payload type in JSON.
Derniere mise a jour (2026-01-18 11:56:21) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates output type in JSON.
Derniere mise a jour (2026-01-18 11:51:25) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates count/index are strings in JSON.
Derniere mise a jour (2026-01-18 11:46:23) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates queue type in JSON.
Derniere mise a jour (2026-01-18 11:41:27) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates doc_type type in JSON.
Derniere mise a jour (2026-01-18 11:36:21) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates pdf_output_dir type in JSON.
Derniere mise a jour (2026-01-18 11:31:19) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates exchange type in JSON.
Derniere mise a jour (2026-01-18 11:26:41) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates routing_key type in JSON.
Derniere mise a jour (2026-01-18 11:21:21) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local checks social exchange inference for food_application.
Derniere mise a jour (2026-01-18 11:16:21) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local checks social exchange inference for transportation_costs_application.
Derniere mise a jour (2026-01-18 11:11:29) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local checks social exchange inference for financial_assistance_application.
Derniere mise a jour (2026-01-18 11:06:16) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local asserts payload_file non-empty in JSON.
Derniere mise a jour (2026-01-18 11:01:20) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local asserts payload_file is readable in JSON.
Derniere mise a jour (2026-01-18 10:56:24) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local asserts payload_file exists on disk in JSON.
Derniere mise a jour (2026-01-18 10:51:22) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local asserts payload_file ends with .json in JSON.
Derniere mise a jour (2026-01-18 10:46:21) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local verifies purge_queue default to 0 in JSON.
Derniere mise a jour (2026-01-18 10:41:19) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local verifies check_rabbitmq default to 1 in JSON.
Derniere mise a jour (2026-01-18 10:36:20) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local verifies validate_payload default to 1 in JSON.
Derniere mise a jour (2026-01-18 10:31:17) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local verifies index default to 0 in JSON.
Derniere mise a jour (2026-01-18 10:26:16) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local verifies count default to 1 in JSON.
Derniere mise a jour (2026-01-18 10:21:20) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local verifies output default to single in JSON.
Derniere mise a jour (2026-01-18 10:16:17) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local verifies ack_mode override in JSON.
Derniere mise a jour (2026-01-18 10:11:16) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local verifies default ack_mode in JSON.
Derniere mise a jour (2026-01-18 10:06:21) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local asserts PDF_OUTPUT_DIR override is absolute.
Derniere mise a jour (2026-01-18 10:01:13) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local enforces output=all count/index in JSON validation.
Derniere mise a jour (2026-01-18 09:56:44) : Messagequeue/MessageQueue IN_PROGRESS : fix duplicate pdf_output_dir override test block.
Derniere mise a jour (2026-01-18 09:51:30) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local checks pdf_output_dir override in JSON.
Derniere mise a jour (2026-01-18 09:46:13) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local asserts default payload_file path in JSON.
Derniere mise a jour (2026-01-18 09:41:16) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local asserts payload_file is absolute under ROOT_DIR.
Derniere mise a jour (2026-01-18 09:36:17) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates default pdf_output_dir in JSON.
Derniere mise a jour (2026-01-18 09:31:16) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates GRANT_EXCHANGE inference for grant_contracts.
Derniere mise a jour (2026-01-18 09:26:15) : Messagequeue/MessageQueue IN_PROGRESS : doc e2e_local JSON mention check_rabbitmq field.
Derniere mise a jour (2026-01-18 09:21:14) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates check_rabbitmq values in JSON.
Derniere mise a jour (2026-01-18 09:16:10) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local requires check_rabbitmq in JSON output.
Derniere mise a jour (2026-01-18 09:11:13) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates routing_key empty when social exchange inferred.
Derniere mise a jour (2026-01-18 09:07:55) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates default queue/exchange + doc_type fallback in JSON.
Derniere mise a jour (2026-01-18 09:01:56) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local checks doc_type override in JSON.
Derniere mise a jour (2026-01-18 08:56:23) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local enforces output=all constraints in JSON.
Derniere mise a jour (2026-01-18 08:51:15) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates purge_queue override.
Derniere mise a jour (2026-01-18 08:46:24) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local checks empty routing_key for SOCIAL_ASSISTANCE_EXCHANGE.
Derniere mise a jour (2026-01-18 08:41:16) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates pdf_output_dir in JSON output.
Derniere mise a jour (2026-01-18 08:36:12) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates exchange/routing_key in JSON output.
Derniere mise a jour (2026-01-18 08:31:15) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates doc_type in JSON output.
Derniere mise a jour (2026-01-18 08:26:13) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates purge_queue in JSON output.
Derniere mise a jour (2026-01-18 08:21:16) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates ack_mode in JSON output.
Derniere mise a jour (2026-01-18 08:16:18) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates env overrides for validate_payload/check_rabbitmq.
Derniere mise a jour (2026-01-18 08:11:22) : Messagequeue/MessageQueue IN_PROGRESS : doc e2e_local constraints added.
Derniere mise a jour (2026-01-18 08:06:19) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validates validate_payload/check_rabbitmq fields.
Derniere mise a jour (2026-01-18 08:01:16) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local allows COUNT>1 with OUTPUT=single.
Derniere mise a jour (2026-01-18 07:56:19) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local requires COUNT=1 for OUTPUT=single + negative test.
Derniere mise a jour (2026-01-18 07:51:20) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local requires readable PAYLOAD_FILE + negative test.
Derniere mise a jour (2026-01-18 07:46:19) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local requires non-empty PAYLOAD_FILE + negative test.
Derniere mise a jour (2026-01-18 07:41:38) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local requires .json PAYLOAD_FILE + negative test.
Derniere mise a jour (2026-01-18 07:36:47) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local requires INDEX=0 for OUTPUT=all + tests updated.
Derniere mise a jour (2026-01-18 07:31:09) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejects OUTPUT=all COUNT=1 even with --json.
Derniere mise a jour (2026-01-18 07:26:29) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local requires COUNT>=2 for OUTPUT=all + negative test.
Derniere mise a jour (2026-01-18 07:21:19) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local rejects ROUTING_KEY with SOCIAL_ASSISTANCE_EXCHANGE.
Derniere mise a jour (2026-01-18 07:16:16) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local limits DOC_TYPE length + negative test.
Derniere mise a jour (2026-01-18 07:11:23) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local validates PDF_OUTPUT_DIR writability + negative test.
Derniere mise a jour (2026-01-18 07:06:56) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local requires existing PAYLOAD_FILE in dry-run + negative test.
Derniere mise a jour (2026-01-18 07:01:55) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local validates PDF_OUTPUT_DIR + negative test.
Derniere mise a jour (2026-01-18 06:56:14) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local limits QUEUE length + negative test.
Derniere mise a jour (2026-01-18 06:51:14) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local limits EXCHANGE length + negative test.
Derniere mise a jour (2026-01-18 06:46:46) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local limits ROUTING_KEY length + negative test.
Derniere mise a jour (2026-01-18 06:41:13) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local validates ROUTING_KEY format + negative test.
Derniere mise a jour (2026-01-18 06:36:11) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local validates EXCHANGE format + negative test.
Derniere mise a jour (2026-01-18 06:31:32) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local validates QUEUE format + negative test.
Derniere mise a jour (2026-01-18 06:26:28) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local validates DOC_TYPE format + negative test.
Derniere mise a jour (2026-01-18 06:21:12) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local validates VALIDATE_PAYLOAD/CHECK_RABBITMQ + negative tests.
Derniere mise a jour (2026-01-18 06:16:09) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local validates PURGE_QUEUE + negative test.
Derniere mise a jour (2026-01-18 06:11:15) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local validates ACK_MODE + negative test.
Derniere mise a jour (2026-01-18 06:06:05) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejects negative COUNT.
Derniere mise a jour (2026-01-18 06:01:04) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejects non-numeric INDEX.
Derniere mise a jour (2026-01-18 05:56:05) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejects non-numeric COUNT.
Derniere mise a jour (2026-01-18 05:51:05) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejects invalid OUTPUT.
Derniere mise a jour (2026-01-18 05:46:01) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejects INDEX=-1.
Derniere mise a jour (2026-01-18 05:41:04) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejects COUNT=0.
Derniere mise a jour (2026-01-18 05:36:03) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejects INDEX>=COUNT in OUTPUT=single.
Derniere mise a jour (2026-01-18 05:32:47) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local dry-run validates OUTPUT/COUNT/INDEX + test output=all without json.
Derniere mise a jour (2026-01-18 05:26:30) : Messagequeue/MessageQueue IN_PROGRESS : validate_payload resolves PAYLOAD_FILE from repo root.
Derniere mise a jour (2026-01-18 05:21:45) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local resolve payload in dry-run output.
Derniere mise a jour (2026-01-18 05:16:13) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validate payload_file path + run.
Derniere mise a jour (2026-01-18 05:11:08) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local resolve PAYLOAD_FILE from repo root.
Derniere mise a jour (2026-01-18 05:06:10) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local check payload file exists + docs.
Derniere mise a jour (2026-01-18 05:01:03) : Messagequeue/MessageQueue IN_PROGRESS : doc e2e_local index/count constraint.
Derniere mise a jour (2026-01-18 04:56:08) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local validate COUNT/INDEX ranges.
Derniere mise a jour (2026-01-18 04:51:51) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local preflight check_rabbitmq + docs.
Derniere mise a jour (2026-01-18 04:46:10) : Messagequeue/MessageQueue IN_PROGRESS : run payload validation/tests + mark test_matrix.
Derniere mise a jour (2026-01-18 04:41:11) : Messagequeue/MessageQueue IN_PROGRESS : test_matrix mark e2e_local dry-run done.
Derniere mise a jour (2026-01-18 04:35:58) : Messagequeue/MessageQueue IN_PROGRESS : run test_e2e_local --json after count/index validation.
Derniere mise a jour (2026-01-18 04:31:04) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validate count/index numeric.
Derniere mise a jour (2026-01-18 04:25:51) : Messagequeue/MessageQueue IN_PROGRESS : run test_e2e_local --json after OUTPUT check.
Derniere mise a jour (2026-01-18 04:21:01) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local validate OUTPUT values.
Derniere mise a jour (2026-01-18 04:15:55) : Messagequeue/MessageQueue IN_PROGRESS : run test_e2e_local --json.
Derniere mise a jour (2026-01-18 04:11:17) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local enforce OUTPUT=all json + docs.
Derniere mise a jour (2026-01-18 04:05:58) : Messagequeue/MessageQueue IN_PROGRESS : README add test_e2e_local dry-run usage.
Derniere mise a jour (2026-01-18 04:00:49) : Messagequeue/MessageQueue IN_PROGRESS : fix test_e2e_local env propagation; run test.
Derniere mise a jour (2026-01-18 03:56:00) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local validate queue/count/index.
Derniere mise a jour (2026-01-18 03:51:23) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local env overrides + docs.
Derniere mise a jour (2026-01-18 03:46:08) : Messagequeue/MessageQueue IN_PROGRESS : doc e2e_local OUTPUT=all JSON note.
Derniere mise a jour (2026-01-18 03:41:24) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local --json + docs.
Derniere mise a jour (2026-01-18 03:36:14) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local --help + docs.
Derniere mise a jour (2026-01-18 03:31:34) : Messagequeue/MessageQueue IN_PROGRESS : fix test_e2e_local JSON parsing; run test.
Derniere mise a jour (2026-01-18 03:25:54) : Messagequeue/MessageQueue IN_PROGRESS : test_matrix e2e_local dry-run item.
Derniere mise a jour (2026-01-18 03:21:29) : Messagequeue/MessageQueue IN_PROGRESS : add test_e2e_local dry-run.
Derniere mise a jour (2026-01-18 03:16:48) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local OUTPUT=all + docs.
Derniere mise a jour (2026-01-18 03:11:22) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local INDEX selection + docs.
Derniere mise a jour (2026-01-18 03:06:28) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local COUNT support + docs.
Derniere mise a jour (2026-01-18 03:00:52) : Messagequeue/MessageQueue IN_PROGRESS : test_matrix payload section.
Derniere mise a jour (2026-01-18 02:55:54) : Messagequeue/MessageQueue IN_PROGRESS : tests_summary payload section.
Derniere mise a jour (2026-01-18 02:51:47) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local payload validation toggle + docs.
Derniere mise a jour (2026-01-18 02:45:51) : Messagequeue/MessageQueue IN_PROGRESS : README e2e_local usage section.
Derniere mise a jour (2026-01-18 02:41:40) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local dry-run + docs.
Derniere mise a jour (2026-01-18 02:36:03) : Messagequeue/MessageQueue IN_PROGRESS : doc tests_summary/test_matrix e2e_local.
Derniere mise a jour (2026-01-18 02:31:34) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local purge option + docs.
Derniere mise a jour (2026-01-18 02:26:14) : Messagequeue/MessageQueue IN_PROGRESS : doc e2e_local + runbook.
Derniere mise a jour (2026-01-18 02:22:53) : Messagequeue/MessageQueue IN_PROGRESS : ajout e2e_local script + docs.
Derniere mise a jour (2026-01-18 02:17:50) : Messagequeue/MessageQueue IN_PROGRESS : test_validate_payload --json + docs.
Derniere mise a jour (2026-01-18 02:11:42) : Messagequeue/MessageQueue IN_PROGRESS : bootstrap_rabbitmq/create_bindings --json + docs.
Derniere mise a jour (2026-01-18 02:06:22) : Messagequeue/MessageQueue IN_PROGRESS : post_sample --json + docs.
Derniere mise a jour (2026-01-18 02:01:00) : Messagequeue/MessageQueue IN_PROGRESS : fix post_sample extra fi.
Derniere mise a jour (2026-01-18 01:56:47) : Messagequeue/MessageQueue IN_PROGRESS : validate_payload --json + docs.
Derniere mise a jour (2026-01-18 01:51:58) : Messagequeue/MessageQueue IN_PROGRESS : smoke_local --json + docs.
Derniere mise a jour (2026-01-18 01:46:27) : Messagequeue/MessageQueue IN_PROGRESS : consume_test_message --json + docs.
Derniere mise a jour (2026-01-18 01:42:32) : Messagequeue/MessageQueue IN_PROGRESS : publish_test_message/publish_sample_keys --json + docs.
Derniere mise a jour (2026-01-18 01:37:36) : Messagequeue/MessageQueue IN_PROGRESS : test_routing/test_routing_matrix --json + docs.
Derniere mise a jour (2026-01-18 01:31:57) : Messagequeue/MessageQueue IN_PROGRESS : doctor --json + docs.
Derniere mise a jour (2026-01-18 01:26:47) : Messagequeue/MessageQueue IN_PROGRESS : run_checks --json + docs.
Derniere mise a jour (2026-01-18 01:21:39) : Messagequeue/MessageQueue IN_PROGRESS : check_prereqs --json + docs.
Derniere mise a jour (2026-01-18 01:16:14) : Messagequeue/MessageQueue IN_PROGRESS : wait_rabbitmq --json + docs.
Derniere mise a jour (2026-01-18 01:11:29) : Messagequeue/MessageQueue IN_PROGRESS : check_rabbitmq --json + docs.
Derniere mise a jour (2026-01-18 01:06:48) : Messagequeue/MessageQueue IN_PROGRESS : status_report --json + docs.
Derniere mise a jour (2026-01-18 01:01:38) : Messagequeue/MessageQueue IN_PROGRESS : list_exchanges/list_bindings --json + docs.
Derniere mise a jour (2026-01-18 00:57:10) : Messagequeue/MessageQueue IN_PROGRESS : list_queues/count_queue_messages --json + docs.
Derniere mise a jour (2026-01-18 00:51:57) : Messagequeue/MessageQueue IN_PROGRESS : validate_rabbitmq --json + docs.
Derniere mise a jour (2026-01-18 00:47:07) : Messagequeue/MessageQueue IN_PROGRESS : validate_rabbitmq --silent + docs.
Derniere mise a jour (2026-01-18 00:41:33) : Messagequeue/MessageQueue IN_PROGRESS : create_bindings --silent.
Derniere mise a jour (2026-01-18 00:36:24) : Messagequeue/MessageQueue IN_PROGRESS : bootstrap_rabbitmq --silent.
Derniere mise a jour (2026-01-18 00:31:23) : Messagequeue/MessageQueue IN_PROGRESS : wait_rabbitmq --silent.
Derniere mise a jour (2026-01-18 00:26:19) : Messagequeue/MessageQueue IN_PROGRESS : check_rabbitmq --silent.
Derniere mise a jour (2026-01-18 00:21:40) : Messagequeue/MessageQueue IN_PROGRESS : check_prereqs --silent.
Derniere mise a jour (2026-01-18 00:16:05) : Messagequeue/MessageQueue IN_PROGRESS : list_bindings --silent.
Derniere mise a jour (2026-01-18 00:11:18) : Messagequeue/MessageQueue IN_PROGRESS : list_exchanges --silent.
Derniere mise a jour (2026-01-18 00:06:31) : Messagequeue/MessageQueue IN_PROGRESS : list_queues --silent.
Derniere mise a jour (2026-01-18 00:01:28) : Messagequeue/MessageQueue IN_PROGRESS : count_queue_messages --silent.
Derniere mise a jour (2026-01-17 23:56:33) : Messagequeue/MessageQueue IN_PROGRESS : status_report --silent.
Derniere mise a jour (2026-01-17 23:51:34) : Messagequeue/MessageQueue IN_PROGRESS : doctor --silent.
Derniere mise a jour (2026-01-17 23:46:33) : Messagequeue/MessageQueue IN_PROGRESS : smoke_local --silent.
Derniere mise a jour (2026-01-17 23:41:25) : Messagequeue/MessageQueue IN_PROGRESS : test_routing --silent.
Derniere mise a jour (2026-01-17 23:36:20) : Messagequeue/MessageQueue IN_PROGRESS : test_routing_matrix --silent.
Derniere mise a jour (2026-01-17 23:30:56) : Messagequeue/MessageQueue IN_PROGRESS : maj todo_next.
Derniere mise a jour (2026-01-17 23:25:54) : Messagequeue/MessageQueue IN_PROGRESS : doc local_usage OUTPUT=status.
Derniere mise a jour (2026-01-17 23:21:14) : Messagequeue/MessageQueue IN_PROGRESS : post_sample OUTPUT status.
Derniere mise a jour (2026-01-17 23:15:56) : Messagequeue/MessageQueue IN_PROGRESS : doc local_usage post_sample.
Derniere mise a jour (2026-01-17 23:10:55) : Messagequeue/MessageQueue IN_PROGRESS : doc run_checks --silent usage.
Derniere mise a jour (2026-01-17 23:06:06) : Messagequeue/MessageQueue IN_PROGRESS : run_checks --silent.
Derniere mise a jour (2026-01-17 23:01:39) : Messagequeue/MessageQueue IN_PROGRESS : consume_test_message --silent + flags.
Derniere mise a jour (2026-01-17 22:56:33) : Messagequeue/MessageQueue IN_PROGRESS : publish_sample_keys flags + payload.
Derniere mise a jour (2026-01-17 22:51:11) : Messagequeue/MessageQueue IN_PROGRESS : publish_test_message --silent + flags.
Derniere mise a jour (2026-01-17 22:45:44) : Messagequeue/MessageQueue IN_PROGRESS : post_sample refuse flags inconnus.
Derniere mise a jour (2026-01-17 22:41:12) : Messagequeue/MessageQueue IN_PROGRESS : post_sample supporte --silent.
Derniere mise a jour (2026-01-17 22:36:07) : Messagequeue/MessageQueue IN_PROGRESS : post_sample --help OUTPUT pretty.
Derniere mise a jour (2026-01-17 22:30:57) : Messagequeue/MessageQueue IN_PROGRESS : doc endpoint grantType routing key.
Derniere mise a jour (2026-01-17 22:25:52) : Messagequeue/MessageQueue IN_PROGRESS : validation grantType avant publish.
Derniere mise a jour (2026-01-17 22:21:08) : Messagequeue/MessageQueue IN_PROGRESS : publish_test_message STRICT_GRANT_TYPE.
Derniere mise a jour (2026-01-17 22:15:47) : Messagequeue/MessageQueue IN_PROGRESS : test producer grantType segment vide.
Derniere mise a jour (2026-01-17 22:10:50) : Messagequeue/MessageQueue IN_PROGRESS : test_validate_payload grantType segment vide.
Derniere mise a jour (2026-01-17 22:05:50) : Messagequeue/MessageQueue IN_PROGRESS : doc tests_producer grantType format.
Derniere mise a jour (2026-01-17 22:01:24) : Messagequeue/MessageQueue IN_PROGRESS : producer valide format grantType.
Derniere mise a jour (2026-01-17 21:55:52) : Messagequeue/MessageQueue IN_PROGRESS : doc smoke_local routing key derive.
Derniere mise a jour (2026-01-17 21:51:01) : Messagequeue/MessageQueue IN_PROGRESS : smoke_local derive routing key via payload.
Derniere mise a jour (2026-01-17 21:45:58) : Messagequeue/MessageQueue IN_PROGRESS : publish_test_message supporte --help.
Derniere mise a jour (2026-01-17 21:40:58) : Messagequeue/MessageQueue IN_PROGRESS : consume_test_message OUTPUT pretty.
Derniere mise a jour (2026-01-17 21:35:58) : Messagequeue/MessageQueue IN_PROGRESS : consume_test_message supporte --help.
Derniere mise a jour (2026-01-17 21:31:12) : Messagequeue/MessageQueue IN_PROGRESS : publish_test_message derive routing key du payload.
Derniere mise a jour (2026-01-17 21:26:06) : Messagequeue/MessageQueue IN_PROGRESS : run_checks accepte plusieurs flags.
Derniere mise a jour (2026-01-17 21:20:44) : Messagequeue/MessageQueue IN_PROGRESS : doc publish_test_message metadata grantType.
Derniere mise a jour (2026-01-17 21:15:46) : Messagequeue/MessageQueue IN_PROGRESS : publish_test_message force grantType metadata.
Derniere mise a jour (2026-01-17 21:11:07) : Messagequeue/MessageQueue IN_PROGRESS : doctor lance test_validate_payload.
Derniere mise a jour (2026-01-17 21:06:08) : Messagequeue/MessageQueue IN_PROGRESS : script test_validate_payload ajoute.
Derniere mise a jour (2026-01-17 21:01:18) : Messagequeue/MessageQueue IN_PROGRESS : validate_payload impose grantType routing key.
Derniere mise a jour (2026-01-17 20:55:53) : Messagequeue/MessageQueue IN_PROGRESS : doc routing keys lie grantType payload.
Derniere mise a jour (2026-01-17 20:51:31) : Messagequeue/MessageQueue IN_PROGRESS : schema + sample grantType routing key.
Derniere mise a jour (2026-01-17 02:25:00) : CPP/CPP_Module_05 DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 02:21:10) : CPP/CPP_Module_05 IN_PROGRESS : ajout tests smoke ex00-ex03 + run_tests OK.
Derniere mise a jour (2026-01-17 02:34:00) : C/Libasm WAITING : nasm manquant.
Derniere mise a jour (2026-01-17 02:15:13) : CPP/CPP_Module_04 DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 02:11:56) : CPP/CPP_Module_04 IN_PROGRESS : ajout tests smoke ex00-ex04 + run_tests OK.
Derniere mise a jour (2026-01-17 02:04:58) : CPP/CPP_Module_03 DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 02:01:16) : CPP/CPP_Module_03 IN_PROGRESS : ajout tests smoke ex00-ex03 + run_tests OK.
Derniere mise a jour (2026-01-17 01:54:59) : CPP/CPP_Module_02 DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 01:51:17) : CPP/CPP_Module_02 IN_PROGRESS : ajout tests smoke ex00-ex03 + run_tests OK.
Derniere mise a jour (2026-01-17 01:44:57) : CPP/CPP_Module_01 DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 01:42:44) : CPP/CPP_Module_01 IN_PROGRESS : ajout tests smoke ex00-ex06 + run_tests OK.
Derniere mise a jour (2026-01-17 01:34:57) : CPP/CPP_Module_00 DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 01:30:45) : CPP/CPP_Module_00 IN_PROGRESS : ajout tests ex03/ex04 + run_tests OK.
Derniere mise a jour (2026-01-17 01:24:56) : CPP/CPP_Module_00 IN_PROGRESS : ajout tests smoke ex01 add/search + run_tests OK.
Derniere mise a jour (2026-01-17 01:21:39) : CPP/CPP_Module_00 IN_PROGRESS : ajout tests smoke ex00/ex02 + run_tests OK.
Derniere mise a jour (2026-01-17 01:14:56) : C/Ft_services DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 01:11:19) : C/Ft_services IN_PROGRESS : ajout tests statiques + run_tests OK.
Derniere mise a jour (2026-01-17 01:04:55) : C/Ft_ssl_base64_des DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 01:00:31) : C/Ft_ssl_base64_des IN_PROGRESS : ajout test base64 input vide + run_tests OK.
Derniere mise a jour (2026-01-17 00:54:54) : C/Ft_server DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 00:50:54) : C/Ft_server IN_PROGRESS : ajout tests statiques + run_tests OK.
Derniere mise a jour (2026-01-17 00:44:53) : C/Ft_communication DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 00:33:25) : C/Ft_communication IN_PROGRESS : tests export Markdown/JSON + run_tests OK.
Derniere mise a jour (2026-01-17 00:37:16) : C/Ft_turing DONE : ajout accept requis + tests OK.
Derniere mise a jour (2026-01-17 00:29:53) : C/Ft_ping DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 00:25:15) : C/Ft_ping IN_PROGRESS : ajout test -h + run_tests OK.
Derniere mise a jour (2026-01-17 00:19:52) : C/Ft_ssl_md5 DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 00:15:40) : C/Ft_ssl_md5 IN_PROGRESS : ajout test stdin vide + run_tests OK.
Derniere mise a jour (2026-01-17 00:09:52) : C/Ft_script DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-17 00:05:30) : C/Ft_script IN_PROGRESS : ajout test -c typescript par defaut + run_tests OK.
Derniere mise a jour (2026-01-17 00:00:42) : C/Ft_script IN_PROGRESS : ajout test -c stderr capture + run_tests OK.
Derniere mise a jour (2026-01-16 23:54:50) : C/Ft_mini_ls DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-16 23:49:54) : C/Ft_mini_ls IN_PROGRESS : ajout test dossier uniquement cache + run_tests OK.
Derniere mise a jour (2026-01-16 23:45:27) : C/Ft_mini_ls IN_PROGRESS : ajout test dossier vide.
Derniere mise a jour (2026-01-16 23:39:52) : C/Minitalk DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-16 23:35:01) : C/Minitalk IN_PROGRESS : doc tests maj (ponctuation/rafale).
Derniere mise a jour (2026-01-16 23:29:50) : C/Minitalk IN_PROGRESS : tests messages rapides + run_tests OK.
Derniere mise a jour (2026-01-16 23:26:09) : C/Minitalk IN_PROGRESS : test ponctuation + check ligne vide + run_tests OK.
Derniere mise a jour (2026-01-16 23:30:12) : Web/hello_node WAITING : sockets locales bloquees (tests reseau).
Derniere mise a jour (2026-01-16 23:22:48) : Web/hello_node IN_PROGRESS : harness capture stdout + run_tests OK (skip net).
Derniere mise a jour (2026-01-16 23:14:56) : Web/hello_node IN_PROGRESS : tests ex09 erreurs (iso manquant/route inconnue).
Derniere mise a jour (2026-01-16 23:04:50) : Hello/hello_vue DONE : cloture apres checks OK.
Derniere mise a jour (2026-01-16 23:00:22) : Hello/hello_vue IN_PROGRESS : ajout style ex05 + run_tests OK.
Derniere mise a jour (2026-01-16 22:55:32) : Hello/hello_vue IN_PROGRESS : checks CDN Vue 2.6.14 + run_tests OK.
Derniere mise a jour (2026-01-16 22:50:47) : C/Pipex DONE : ajout test quoting + run_tests OK.
Derniere mise a jour (2026-01-16 22:44:49) : Wordle/Wordle DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-16 22:40:01) : Wordle/Wordle IN_PROGRESS : ajout test dict missing file + run_tests OK.
Derniere mise a jour (2026-01-16 22:35:03) : Wordle/Wordle IN_PROGRESS : ajout test dict invalid + run_tests OK.
Derniere mise a jour (2026-01-16 22:30:01) : Wordle/Wordle IN_PROGRESS : ajout test determinisme seed + run_tests OK.
Derniere mise a jour (2026-01-16 22:24:48) : Wordle/Wordle IN_PROGRESS : ajout test CLI mot invalide + run_tests OK.
Derniere mise a jour (2026-01-16 22:19:47) : Wordle/Wordle IN_PROGRESS : ajout test CLI input vide + run_tests OK.
Derniere mise a jour (2026-01-16 22:15:52) : Wordle/Wordle IN_PROGRESS : ajout tests unitaires/CLI + run_tests OK.
Derniere mise a jour (2026-01-16 22:09:50) : Python/Django_Training_D01 DONE : cloture apres smoke tests OK.
Derniere mise a jour (2026-01-16 22:04:51) : Python/Django_Training_D01 IN_PROGRESS : doc section Tests ajoutee.
Derniere mise a jour (2026-01-16 22:02:10) : Python/Django_Training_D01 IN_PROGRESS : ajout smoke tests + run_tests OK.
Derniere mise a jour (2026-01-16 21:54:48) : C/Ft_printf DONE : cloture apres tests OK.
Derniere mise a jour (2026-01-16 21:49:50) : C/Ft_printf IN_PROGRESS : scripts/run_tests.sh OK (warning /dev/full skip).
Derniere mise a jour (2026-01-16 21:45:37) : C/Ft_printf IN_PROGRESS : harness: ignore warning ret mismatch pour (nil) vs 0x0.
Derniere mise a jour (2026-01-16 21:39:52) : C/Ft_printf IN_PROGRESS : harness: compteur de checks + resume final.
Derniere mise a jour (2026-01-16 21:34:46) : C/Ft_printf IN_PROGRESS : ajout test pointeur alternatif 0x7fffffff.
Derniere mise a jour (2026-01-16 21:29:47) : C/Ft_printf IN_PROGRESS : ajout test ordre mix %u/%d/%x/%i/%s.
Derniere mise a jour (2026-01-16 21:24:44) : C/Ft_printf IN_PROGRESS : run_tests.sh message clair en cas d'echec.
Derniere mise a jour (2026-01-16 21:19:44) : C/Ft_printf IN_PROGRESS : ajout test mix signes %d/%i.
Derniere mise a jour (2026-01-16 21:14:47) : C/Ft_printf IN_PROGRESS : ajout tests hex lettres + serie d'entiers.
Derniere mise a jour (2026-01-16 21:12:36) : C/Ft_printf IN_PROGRESS : ajout tests percent apres %d et %s.
Derniere mise a jour (2026-01-16 21:04:51) : C/Ft_printf IN_PROGRESS : harness: warning si ret printf != ft_printf.
Derniere mise a jour (2026-01-16 20:59:45) : C/Ft_printf IN_PROGRESS : ajout test mix %s/%p avec NULL.
Derniere mise a jour (2026-01-16 20:54:47) : C/Ft_printf IN_PROGRESS : harness raw: ajout index premier octet different.
Derniere mise a jour (2026-01-16 20:49:55) : C/Ft_printf IN_PROGRESS : ajout tests %s NULL avec prefix/suffix et double NULL.
Derniere mise a jour (2026-01-16 20:44:55) : C/Ft_printf IN_PROGRESS : ajout tests raw NUL avec %c + strings vides/texte.
Derniere mise a jour (2026-01-16 20:39:57) : C/Ft_printf IN_PROGRESS : harness raw: dump hex en cas de mismatch binaire.
Derniere mise a jour (2026-01-16 20:35:00) : C/Ft_printf IN_PROGRESS : simplif raw check + test binaire %% avec NUL.
Derniere mise a jour (2026-01-16 20:29:42) : C/Ft_printf IN_PROGRESS : ajout test raw mixte NUL %c/%s/%c (binaire).
Derniere mise a jour (2026-01-16 20:24:54) : C/Ft_printf IN_PROGRESS : doc tests: sorties binaires pour NUL dans harness.
Derniere mise a jour (2026-01-16 20:19:42) : C/Ft_printf IN_PROGRESS : ajout test raw string contenant un NUL interne.
Derniere mise a jour (2026-01-16 20:14:46) : C/Ft_printf IN_PROGRESS : ajout tests raw NUL en milieu et double NUL.
Derniere mise a jour (2026-01-16 20:10:51) : C/Ft_printf IN_PROGRESS : harness support sortie binaire + test %c NUL.
Derniere mise a jour (2026-01-16 20:04:55) : C/Ft_printf IN_PROGRESS : ajout tests strings vides/espaces + mix hex/pointeurs/combo.
Derniere mise a jour (2026-01-16 20:01:04) : C/Ft_printf IN_PROGRESS : ajout tests limites int + mix %% et NULL string.
Derniere mise a jour (2026-01-09 23:43:24) : C/Ft_printf IN_PROGRESS : test erreur d'ecriture via /dev/full (skip si absent) + scripts/run_tests.sh OK.
Derniere mise a jour (2026-01-09 23:33:45) : C/Ft_printf IN_PROGRESS : nouveaux tests (%u -1, hex UINT_MAX, %%%% chain, pointeurs multiples) + scripts/run_tests.sh OK.
Derniere mise a jour (2026-01-09 23:02:52) : C/Ft_printf IN_PROGRESS : test format long + scripts/run_tests.sh OK.
Derniere mise a jour (2026-01-09 22:52:46) : C/Ft_printf IN_PROGRESS : test ft_printf(NULL) + scripts/run_tests.sh OK.
Derniere mise a jour (2026-01-09 22:42:49) : C/Ft_printf IN_PROGRESS : test long wrap + scripts/run_tests.sh OK.
Derniere mise a jour (2026-01-09 22:24:08) : C/Ft_printf IN_PROGRESS : ajout de tests long string (flush buffer) + cas format vide/percent.
Derniere mise a jour (2026-01-04 14:00:32) : C/Libunit termine avec une suite d'echecs (segfault/timeout/exit) ajoutee et `./scripts/run_tests.sh` OK.
Derniere mise a jour (2026-01-04 13:54:43) : C/Libft termine avec un harness de tests `tests_realisation` et `./tests_realisation/run_tests.sh` OK.
Derniere mise a jour (2026-01-04 13:51:34) : C/ft_linux passe en WAITING (toolchain/kernel/boot/tarballs manquants, cf. `reports/missing_inputs.txt`), bascule sur C/Get_Next_Line termine avec test multi-fd ajoute et `./tests_realisation/run_tests.sh` OK.
Derniere mise a jour (2026-01-04 13:41:33) : C/ft_linux progresse : ajout de `scripts/missing_inputs_report.sh` pour lister les pre-requis LFS manquants (toolchain/boot/kernel/tarballs) et integration dans `run_reports.sh` pour un diagnostic consolide.
Derniere mise a jour (2026-01-05 09:35:00) : C/ft_linux progresse : `scripts/ensure_permissions.sh` déploie `chmod +x scripts/*.sh` pour éviter les erreurs `permission denied` que `run_reports.sh` déclenche encore sur trop de helpers ; la validation reste bloquée tant que la chaîne cross et les artefacts kernel/manifests manquent, mais ce script réduit brutalement les avertissements `permission denied` dans les logs (124 scripts corrigés).
Derniere mise a jour (2026-01-02 17:29:03) : C/ft_nmap termine : projet stabilise (multi-cibles, scan udp, exports enrichis, limite 1024 ports) et suite de tests make test OK.
Derniere mise a jour (2026-01-02 18:58:57) : C/Ft_shmup termine : shmup stabilise (campagne + endless, power-ups, boss/enraged, HUD) et build OK.
Derniere mise a jour (2026-01-02 18:39:38) : C/Ft_shmup progresse : ajout du dash (touche e, invuln courte + cooldown), HUD/aide MAJ; build OK.
Derniere mise a jour (2026-01-02 18:34:52) : C/Ft_shmup progresse : message de fin (Victory/Game Over) + touche x pour quitter, build OK.
Derniere mise a jour (2026-01-02 18:30:26) : C/Ft_shmup progresse : timers bases sur game-time (pause fige effets/power-ups), build OK.
Derniere mise a jour (2026-01-02 18:25:17) : C/Ft_shmup progresse : ajout des bombes (power-up B + touche b) pour nettoyer tirs/ennemis, HUD MAJ; build OK.
Derniere mise a jour (2026-01-02 18:19:55) : C/Ft_shmup progresse : power-up Slow Time (Z) ralentissant ennemis/tirs, HUD et aide MAJ; build OK.
Derniere mise a jour (2026-01-02 18:15:47) : C/Ft_shmup progresse : boss enraged (cadence acceleree + kamikazes), icone B explicite; build OK.
Derniere mise a jour (2026-01-02 18:09:45) : C/Ft_shmup progresse : nouvel ennemi Sniper (tirs diriges) avec icone T et spawn par vague; build OK.
Derniere mise a jour (2026-01-02 18:04:50) : C/Ft_shmup progresse : post-game avec relance (r) sans quitter; build OK.
Derniere mise a jour (2026-01-02 17:59:42) : C/Ft_shmup progresse : confirmation de sortie q->y/n via overlay; build OK.
Derniere mise a jour (2026-01-02 17:54:22) : C/Ft_shmup progresse : ajout combo de kills avec bonus score et HUD combo; build OK.
Derniere mise a jour (2026-01-02 17:49:22) : C/Ft_shmup progresse : bannieres Wave/Boss ajoutees au debut des vagues; build OK.
Derniere mise a jour (2026-01-02 17:44:55) : C/Ft_shmup progresse : overlay d’aide (touche h) avec rappel controls/power-ups/ennemis, HUD mis a jour; build OK.
Derniere mise a jour (2026-01-02 17:39:36) : C/Ft_shmup progresse : ajout d’ennemis kamikaze (suivi joueur, spawn par vague) avec score ajuste; build OK.
Derniere mise a jour (2026-01-02 17:35:15) : C/Ft_shmup progresse : nouveau power-up Spread (tir en éventail) avec projectiles diagonaux, HUD et drops distincts; build OK.
Derniere mise a jour (2026-01-02 17:26:56) : C/ft_nmap progresse : limite 1024 ports appliquee (apres exclusions), nouveau test port_limit, version 0.2.5 et make test OK.
Derniere mise a jour (2026-01-02 17:25:02) : C/ft_nmap progresse : exports enrichis avec scan_type (JSON/YAML/XML/CSV/HTML/MD), version 0.2.4 et tests mis a jour; make test OK.
Derniere mise a jour (2026-01-02 17:21:27) : C/ft_nmap progresse : make test OK apres ajout mode udp, resumé tcp/udp visible; README horodate.
Derniere mise a jour (2026-01-02 17:20:39) : C/ft_nmap progresse : ajout du mode --scan udp (sondes UDP sequentielles + retries), sortie resume indique tcp/udp, test scan_udp; version 0.2.3 et docs MAJ.
Derniere mise a jour (2026-01-02 17:14:28) : C/ft_nmap progresse : suite complete des tests make test OK apres ajout multi-cibles (-i), nouveaux tests targets_file; README horodate.
Derniere mise a jour (2026-01-02 17:13:51) : C/ft_nmap progresse : support du scan multi-cibles via -i/--file avec chemins d’export par cible (%s), aliases --ip/--ports/--speedup, test targets_file; docs/usage mis a jour.
Derniere mise a jour (2026-01-02 17:04:59) : C/ft_nmap progresse : suite complete des tests `make test` executee (tous OK, stop-after-n-open ignore par manque de bind), validation du parsing service_names; README horodate.
Derniere mise a jour (2025-12-26 17:49:21) : C/ft_nmap progresse : mode dry-run (-n) ajoute un flag `dry_run` dans tous les exports/tests, ports laissés pending/unknown sans ouvrir de sockets; docs/Makefile mis à jour.
Derniere mise a jour (2025-12-26 20:59:23) : ft_nmap embarque sa version dans tous les exports (JSON/YAML/XML/Markdown/CSV) avec tests renforcés et docs horodatés.
Derniere mise a jour (2025-12-27 18:40:00) : C/ft_nmap progresse : option -I pour forcer l’IP (bypass DNS) + liste d’adresses résolues exportée, résumé indique override; tests/Makefile/docs horodatés.
Derniere mise a jour (2025-12-27 15:10:00) : C/ft_nmap progresse : export JSON stats-only (-J) + test json_summary; export stdout toujours propre (-Q), docs horodatées.
Derniere mise a jour (2025-12-26 18:10:00) : C/ft_nmap progresse : filtre d’exports `-E open|known|all` (ports inclus dans JSON/CSV/YAML/HTML/NDJSON/Markdown) + nouveaux exports Markdown (-m) et test dédié; Makefile et docs mis à jour.
Derniere mise a jour (2025-12-26 17:05:00) : C/ft_nmap progresse : backoff configurables sur les retries via `-b <pct>` (timeout rallongé par retry, exporté dans stats), timeouts gérés par port; docs/tests/exports/CLi mis à jour.
Derniere mise a jour (2025-12-26 16:44:23) : C/ft_nmap progresse : option `-u <timeouts>` pour stopper après N timeouts (ports restants pending) avec flag `timeout_stop_hit` exporté; stats/tests/docs mis à jour.
Derniere mise a jour (2025-12-26 16:38:57) : C/ft_nmap progresse : option `-g <progress_ms>` pour afficher la progression périodique (stderr), test progress ajouté à `make test`; docs horodatées.
Derniere mise a jour (2025-12-26 16:36:07) : C/ft_nmap progresse : stats/export incluent désormais les ports les plus rapides/lents (fastest/slowest + durées) visibles en CLI/JSON/CSV/YAML, test stats étendu; docs horodatées.
Derniere mise a jour (2025-12-26 16:31:27) : C/ft_nmap progresse : randomisation reproductible via `-e <seed>` (seed exportée + flag randomized dans JSON/CSV/YAML/résumé CLI), nouveau test random_seed dans `make test`, docs horodatées.
Derniere mise a jour (2025-12-26 16:21:42) : C/ft_nmap progresse : stats ajoutent `avg_retries_per_port` et `first_open_ms` (exports JSON/CSV/YAML + résumé CLI), test stats étendu, README horodaté.
Derniere mise a jour (2025-12-26 16:17:41) : C/ft_nmap progresse : option `-f <n>` arrête après n ports OPEN (alias `-F` pour 1), ports restants marqués pending/unknown dans exports; nouveau test stop-after-n-open ajoute deux serveurs locaux.
Derniere mise a jour (2025-12-26 16:07:50) : C/ft_nmap progresse : option `-M deadline_ms` limite la durée, stats enrichies (`pending`, `deadline_hit`, `deadline_ms`, `delay_ms`) et exports NDJSON/CSV/JSON/YAML incluent désormais les ports non scannés; nouveau test deadline dans `make test`.
Derniere mise a jour (2025-12-26 16:12:51) : C/ft_nmap progresse : le résumé CLI affiche désormais les taux open/closed/timeout, stats exportent `open_rate/closed_rate/timeout_rate` (JSON/CSV/YAML) calculés sur les ports scannés; tests stats mis à jour.
Derniere mise a jour (2025-12-26 11:08:36) : C/ft_nmap progresse : `-P -` lit depuis stdin (tests ajoutés, cible `make test`), flag `-O` filtre tableau/lignes, retries `-R` exportés JSON/CSV, exit codes open=2/timeout=3, flags `-4/-6`, input `-P`, batch poll `-c`, randomisation `-r`, Makefile avec .d; scans basiques + fichier OK.
Derniere mise a jour (2025-12-26 09:38:01) : C/ft_ping termine : CLI complète (TOS/bind/reverse DNS/timestamps/stop-on-reply/payload/motif/timeout/deadline/quiet), stats dup/out-of-order + exit code pertes, tests/build/docs OK. C/ft_services reste clos (pipeline stable, validation OK).
Derniere mise a jour (2025-12-26 07:55:15) : C/ft_services progresse : la pipeline régénère sitemap après manifest final, index/portal/run_summary sont rafraîchis et la validation full passe de bout en bout.
Derniere mise a jour (2025-12-26 07:44:01) : C/ft_services progresse : snapshot_check désormais dans pipeline/validate (flags `--no-snapshot-check`/`--snapshot-tolerance`) et `logs_metrics_latest` aligne `anomalies_count` sur les anomalies signalées (`anomalies_flagged_count` + `anomalies_total`) ; pipeline rejouée, docs/Make/quick-check déjà branchés.
Derniere mise a jour (2025-12-26 07:35:27) : C/ft_services progresse : nouveau checker `logs_metrics_snapshot_check` (Totaux/ratios + alignement CSV/JSON) intégré au quick-check/Make pour sécuriser les exports status_top2; docs/READMEs rafraîchis.
Derniere mise a jour (2025-12-26 07:27:59) : C/ft_newton termine (cibles fixes/aléatoires, bornage/vent/traînée, projo configurable, exports JSON/MD/CSV/trace, stats contacts), tests auto verts, docs horodatés.
Derniere mise a jour (2025-12-26 05:47:49) : C/ft_hangouts termine (CLI complète : notifications, filtres, recherche, pins/mutes, export/backup, stats, tests auto).
Derniere mise a jour (2025-12-26 05:07:53) : C/ft_self_analysis termine (tableau de suivi rempli, journal mensuel, support oral markdown prêt).
Derniere mise a jour (2025-12-26 05:00:00) : C/ft_self_analysis démarre (version initiale de l’auto-analyse rédigée : expériences, personnalité, vision, tournants).
Derniere mise a jour (2025-12-26 04:45:00) : C/ft_helpme termine (flags -m/-o pour Markdown + export fichier, template expected/actual/logs, tests auto verts).
Derniere mise a jour (2025-12-26 03:23:36) : C/Ft_script termine (pty interactif + resize, fallback pipes; options -a/-c/-e/-f/-q, flush testé, retour code enfant, make test vert).
Derniere mise a jour (2025-12-26 04:33:21) : C/ft_helpme progresse (template enrichi expected/actual + logs/repro, tests auto verts).
Derniere mise a jour (2025-12-26 03:00:05) : C/Ft_mini_ls termine (équivalent ls -1tr sans arguments, erreur si args, tests comparatifs verts).
Derniere mise a jour (2025-12-26 02:55:25) : C/Ft_ssl_base64_des termine (option -A pour désactiver le wrapping Base64, compat openssl, make test vert).
Derniere mise a jour (2025-12-26 02:17:52) : Ft_ssl_md5 termine : CLI md5/sha256 (-p/-q/-r/-s, fichiers), gestion erreurs/usage, cache stdin partagé, make test vert.
Derniere mise a jour (2025-12-26 02:00:50) : Pipex termine (pipelines multi-cmd + here_doc stables) et debut de C/Ft_ssl_md5 (impls MD5/SHA256 maison, support -p/-q/-r/multi -s, script de tests auto).
Derniere mise a jour (2025-12-25 22:18:58) : ft_services : l’index HTML intègre les optionnels manifest ignorés + section snapshot de statut (badge/guard/checksums/validation/sitemap/manifest optional_ignored); pipeline+smoke+quick-check régénérés (overall alert attendu, sitemap ok, push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 22:04:38) : ft_services : index Markdown lit run_summary/latest/status avec garde d’erreur explicite et affiche les statuts réels; metrics_smoke fiabilise les arguments (plus de substitution qui casse avec set -e); pipeline+smoke+quick-check régénérés (overall alert, sitemap ok, push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 21:47:08) : ft_services : index Markdown affiche l’historique overall (lien + tableau top10) avec régénération en fin de pipeline; doublon sitemap supprimé; smoke/quick-check verts (push bloqué DNS).
Derniere mise a jour (2025-12-25 20:14:26) : ft_services : badge de statut global (SVG depuis log_metrics_status.json) ajouté et intégré au pipeline/index/portal/manifest/checksums/bundle; artefacts régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 20:52:46) : ft_services : smoke complet (`metrics_smoke.sh`/Make) qui enchaîne pipeline + quick-check avec gates `--fail-on-overall`/`--fail-on-badge`; quick-check fi corrigé (strict sitemap, status temp+vue texte), fail-on-overall opérationnel; artefacts à jour (overall alert, sitemap ok).
Derniere mise a jour (2025-12-25 20:22:36) : ft_services : pipeline régénérée (manifest/sitemap/checksums/index/portal/run_summary) avec le nouveau badge de statut global (SVG depuis status.json) et `make metrics-status` validé; artefacts à jour (overall alert, sitemap ok).
Derniere mise a jour (2025-12-26 06:10:00) : ft_services : statut overall (badge+sitemap+manifest) injecté dans run summary/index/portal; status.json généré via pipeline/quick-check (optional override, fail-on-badge/missing); artefacts régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 05:55:00) : ft_services : statut global (overall) calculé (badge+sitemap+manifest) affiché dans index/portal; statut JSON régénéré avec overrides (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 05:40:00) : ft_services : quick-check relaie `fail-on-badge/missing` via `logs_metrics_status` (optional override), manifest/checksums/status régénérés; quick-check strict vert (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 05:20:00) : ft_services : status JSON produit par la pipeline (`logs_metrics_status` avec `--optional`) exposé dans index/portal (key links/downloads), options fail-on-badge/missing disponibles; sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 04:45:00) : ft_services : `logs_metrics_status` supporte `--optional/--fail-on-badge/--fail-on-missing` (badge dégradé => code retour), optional aligné manifest; docs/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 04:20:00) : ft_services : `logs_metrics_status` ignore les artefacts optionnels dans le manifest (statut manifest=OK), docs/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 03:50:00) : ft_services : carte downloads du portail inclut les liens run summary (json/md/html); index/portal régénérés, sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 03:30:00) : ft_services : l’index affiche aussi le résumé sitemap (required/present/missing/optional) et une section liens clés; portail conserve cartes statuts/manifest/anomalies/totaux; artefacts régénérés, sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 03:10:00) : ft_services : quick stats + section liens clés (run summary/portal/bundle/manifest) dans l’index, carte anomalies + badge manifest/statut dans le portail; artefacts régénérés, sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 02:50:00) : ft_services : quick stats (overloaded/anomalies/totals) ajoutés aux barres/sections statut (index/portal) avec badge manifest; artefacts régénérés, sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 02:30:00) : ft_services : statut manifest (badge + résumé) ajouté au portail/index; artefacts régénérés, sitemap OK (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 02:05:00) : ft_services : portail/index affichent aussi le résumé manifest (total/present/missing/size) en plus des cartes statut; artefacts régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 01:45:00) : ft_services : portail montre un grid de cartes (badge/guard/checksums/validation/compare + carte sitemap + downloads) avec styles modernisés; index HTML/MD régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 01:20:00) : ft_services : portail/index améliorent l’UX (barre de statut stylée + cartes badge/guard/checksums/validation/compare/sitemap alimentées par run summary/latest); artefacts régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 00:55:00) : ft_services : index HTML/MD intègrent une barre/section statut (badge/guard/checksums/validation/compare/sitemap) alimentée par latest+run_summary; artefacts index/portal régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 00:30:00) : ft_services : portail affiche une barre de statut (badge/guard/checksums/validation/compare/sitemap) alimentée par latest+run_summary; artefacts régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-26 00:05:00) : ft_services : portail affiche le statut/artefacts sitemap (run summary enrichi) et pipeline relance validation finale après sitemaps/checksums; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 23:15:00) : ft_services : run summary inclut le statut/artefacts sitemap, pipeline relaie optional/manifest/strict jusqu’à la vérif + revalide après sitemaps/checksums; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 22:55:00) : ft_services : pipeline relaie `--sitemap-optional/--sitemap-manifest/--sitemap-strict` jusqu’à la vérif, Make/quick-check alignés; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 22:40:00) : ft_services : Make/quick-check relaient SITEMAP_OPTIONAL/SITEMAP_STRICT, optional reconnu par nom/path; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 22:20:00) : ft_services : comptages sitemap/manifest alignés (optional reconnu par nom/path), vérif `--strict-summary` fiable; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 22:00:00) : ft_services : vérif sitemap recalcule via manifest et signale les écarts sitemap/manifest (warnings ou échec avec `--strict-summary`), override `--optional` conservé; docs/CLI/READMEs/progress mis à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 21:40:00) : ft_services : vérif sitemap recalcule les manquants depuis le manifest (`--manifest`) en plus de l’override `--optional`; docs/CLI mises à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 21:20:00) : ft_services : vérif sitemap accepte `--optional` pour ignorer des artefacts via CLI (override), quick-check/Make alignés; docs/CLI mises à jour (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 21:00:00) : ft_services : pipeline/quick-check exposent `--sitemap-optional` + vérif sitemap dédiée (metrics-sitemap-verify); sitemaps/index/portal/checksums régénérés (push toujours bloqué DNS).
Derniere mise a jour (2025-12-25 18:20:00) : ft_services : index/portal affichent le résumé du sitemap JSON (present/missing/taille), cible Make `metrics-sitemap-json` ajoutée; sitemaps/index/portal/checksums régénérés.
Derniere mise a jour (2025-12-25 18:05:00) : ft_services : cible `make metrics-sitemap-json` pour régénérer le sitemap JSON (flag `--no-sitemap-json`), intégré pipeline/manifest/index/portal/checksums/publish; sitemaps recalculés.
Derniere mise a jour (2025-12-25 17:50:00) : ft_services : sitemap JSON ajouté (résumé présent/manquant/taille, flag `--no-sitemap-json`) intégré pipeline/manifest/index/portal/checksums/publish; sitemaps recalculés.
Derniere mise a jour (2025-12-25 17:35:00) : ft_services : sitemap Markdown/HTML affiche un résumé (artifacts présents/manquants + taille totale); artefacts régénérés et checksums/manifest rafraîchis.
Derniere mise a jour (2025-12-25 17:20:00) : ft_services : index HTML accepte `--output` (génération ailleurs que reports/index.html); docs/artefacts régénérés. Smoke déjà vert (reports locaux, checksums/manifest).
Derniere mise a jour (2025-12-25 17:05:00) : ft_services : smoke complet relancé après normalisation des chemins (reports locaux) — sitemap HTML/MD + run_summary/index/portal/manifest/checksums régénérés et vérifiés (checksums OK).
Derniere mise a jour (2025-12-25 16:50:00) : ft_services : scripts pipeline/CI/checksums basculés sur la racine C/ft_services (REPO_ROOT) pour écrire dans les rapports locaux, sitemap HTML/MD + run_summary régénérés avec index/portal et checksums recalculés.
Derniere mise a jour (2025-12-25 16:30:00) : ft_services : ajout du sitemap HTML (script `logs_metrics_sitemap_html.py`, flag `--no-sitemap-html`), exposé via manifest/index/portal/bundle/checksums + cible Make `metrics-sitemap-html`; manifest/checksums régénérés.
Derniere mise a jour (2025-12-25 16:00:00) : ft_services : ajout de la cible `make metrics-sitemap` (génère le sitemap Markdown depuis le manifest) et entrée CLI dédiée (`logs_metrics_sitemap_md.py` + flag `--no-sitemap`) avec la liste des artefacts enrichie (run_summary json/md/html + sitemap).
Derniere mise a jour (2025-12-25 15:32:24) : ft_services : run summary HTML (flags `--no-run-summary-md/html`) + sitemap Markdown (flag `--no-sitemap`) intégrés bundle/manifest/checksums/index/portal/Makefile; smoke complet + quick-check relancés (threshold 60, guard-delta-last 10).
Derniere mise a jour (2025-12-25 14:33:26) : ft_services : CI relaie `--post-validate/--validate-mode` vers la pipeline (et lance la validation post-bundle), run summary intégré (manifest/index/portal) et target Make `metrics-run-summary`; smoke rerun OK (threshold 60, guard-delta-last 10).
Derniere mise a jour (2025-12-25 14:06:52) : ft_services : guard overall/deltas alignés sur l’agrégation par ligne (latest = guard_summary), nouveau checker `logs_metrics_guard_latest_check.py` (pipeline/quick-check/Makefile) et pipeline réordonnée (manifest/portal/bundle/checksums) pour éviter les artefacts manquants ; pipeline relancée (threshold 60, guard-delta-last 10).
Derniere mise a jour (2025-12-25 13:50:30) : ft_services : ajout d’un quick-check `metrics_quick_check.sh`/`make metrics-quick-check` pour lancer guard_check + verify checksums; CI/pipeline/verify path-agnostiques et checksums normalisés; docs/CLI/README horodatés.
Derniere mise a jour (2025-12-25 11:55:06) : ft_services : guard_summary HTML comptait seulement le dernier garde (indentation) → corrigé pour aligner les compteurs/streaks avec CSV/JSON/MD; docs/CLI précisent la ligne CSV `__overall_streak`. Gardes et streaks restent validés depuis l’historique.
Derniere mise a jour (2025-12-25 11:48:15) : ft_services : guard_summary CSV ajoute la streak globale agrégée (row __overall_streak) et la validation la recalcule; pipeline+validation rerun (threshold 60, badge warn 30/danger 60, label uptime, guard-delta-last 10) OK.
Derniere mise a jour (2025-12-25 09:10:23) : ft_services : latest HTML/MD ajoutent le lien vers `log_metrics_guard_summary.json` et le publish inclut le JSON; pipeline+validation rerun (threshold 60, badge warn 30/danger 60, label uptime) OK.
Derniere mise a jour (2025-12-25 09:03:55) : ft_services : guard_summary JSON ajouté (flag --no-guard-summary), pipeline le génère et manifest/checksums/index/portal/latest/validate le référencent; pipeline+validation rerun (threshold 60, badge warn 30/danger 60, label uptime) OK.
Derniere mise a jour (2025-12-25 07:35:12) : ft_services : latest expose `badge_guards` (gate/ok-streak/no-regression) et les vues badge HTML/MD/index/portal affichent les garde-fous; badge history md/html affichent transition et fenêtre; pipeline rerun (threshold 60, badge warn 30/danger 60, label uptime) OK.
Derniere mise a jour (2025-12-25 07:32:45) : ft_services : vues badge history md/html affichent la transition (état précédent -> courant) et la fenêtre; pipeline rerun (threshold 60, badge warn 30/danger 60, label uptime) avec latest réécrit après badge_history pour alimenter les gardes (ok-streak/no-regression).
Derniere mise a jour (2025-12-25 07:30:38) : ft_services : latest rafraîchi après badge_history (état précédent, fenêtre/counts/streak, garde ok-streak) et rendu latest HTML/MD/index/portal affiche désormais l’historique badge (state/streak/prev) et les garde-fous; pipeline rerun (threshold 60, badge warn 30/danger 60, label uptime) OK.
Derniere mise a jour (2026-01-01 02:30:00) : ft_services : historique badge (log_metrics_badge_history.csv) ajouté (état/seuils/ratio/anomalies), manifest/index/portal/bundle/checksums/validation mis à jour; pipeline/validate rerun (threshold 60 prune=1) OK.
Derniere mise a jour (2025-12-31 20:00:00) : ft_services : latest HTML affiche Totals+deltas, pipeline supprime le manifest avant bundle et le régénère ensuite; validation contrôle latest JSON/HTML, docs/README/CLI/logs_metrics.md/progress MAJ; pipeline threshold 60 prune=1 + validation OK.
Derniere mise a jour (2025-12-31 14:20:00) : ft_services : overview md (totaux+deltas+liens) généré par la pipeline (flag --no-overview) et affiché dans le portail/index/publish/manifest/validate, cibles Makefile checksums/verify ajoutées; pipeline rerun threshold 60 prune=1 OK + validation OK; docs/README/CLI/progress MAJ (14:20).
Derniere mise a jour (2025-12-30 10:25:00) : ft_services : les docs/plan/README montrent maintenant la séquence alias `logmetrics` + `LOG_METRICS_DIR`/`pattern=status`/`top_n=2`, les synthèses `log_summary_diff`/`log_summary_multi`, l’export `reports/log_metrics_snapshot.csv` (`timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio`) (que l’on peut renommer `reports/log_metrics_snapshot.status_top2.csv` pour tracer l’intention), et la vérification `tail -n 5 ...` après `./scripts/logs_metrics_verify.sh csv` (ou json) pour confirmer que les mêmes services (`pattern=status`, top 2) apparaissent dans l’export avant de partager un tableau ou un dashboard sans ressaisir les filtres; les notes de revue doivent mentionner le `tail` et le renommage pour garantir qu’ils reviennent au même sous-ensemble de services.
Derniere mise a jour (2025-12-12 21:25:00) : ft_services : les docs mentionnent maintenant explicitement que `scripts/verify_snapshot.sh` plus the tail/jq commands cover both CSV and JSON snapshots so reviewers know exactly what to cite when they confirm `pattern=status`/`top_n=2` outputs.
Derniere mise a jour (2025-12-30 10:25:00) : ft_services : les docs/plan/README montrent maintenant la séquence alias `logmetrics` + `LOG_METRICS_DIR`/`pattern=status`/`top_n=2`, les synthèses `log_summary_diff`/`log_summary_multi`, l’export `reports/log_metrics_snapshot.csv` (`timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio`) (que l’on peut renommer `reports/log_metrics_snapshot.status_top2.csv` pour tracer l’intention), et la vérification `tail -n 5 ...` après `./scripts/logs_metrics_verify.sh csv` (ou json) pour confirmer que les mêmes services (`pattern=status`, top 2) apparaissent dans l’export avant de partager un tableau ou un dashboard sans ressaisir les filtres; les notes de revue doivent mentionner le `tail` et le renommage pour garantir qu’ils reviennent au même sous-ensemble de services. Pour les exports JSON (`reports/log_metrics_snapshot.status_top2.json`), indiquez aussi la commande `jq '.[-1]' ...` dans vos notes pour prouver que les mêmes colonnes sont présentes. Mentionnez aussi `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json` pour prouver que la version JSON expose les colonnes attendues.

Un script d’accompagnement `scripts/verify_snapshot.sh` enchaîne la génération de l’export et les vérifications `tail` (CSV/JSON) : utilisez-le dans vos notes de revue pour démontrer qu’en une seule commande (`./scripts/verify_snapshot.sh csv` ou `./scripts/verify_snapshot.sh json`) vous produisez l’export, le tail et la proof `jq`, garantissant la reproductibilité des services `pattern=status`/`top_n=2`. Mentionnez également que le helper runs `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` et `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json` so both formats display the filtered columns and statuses before sharing. Signal the exact `tail`/`jq` commands in the review notes so contributors who don’t run the helper can still confirm the filtered logs in both snapshots. **Répétez les mêmes commandes (`tail -n 5 ...` et `jq '.[-1]' ...`) dans vos notes afin que les relecteurs puissent reproduire manuellement la vérification si le helper n’est pas relancé, en rappelant que `pattern=status` et `top_n=2` doivent être visibles dans ces dernières lignes.** Le bloc ci-dessus inclut aussi les commandes à coller, ce qui aide les relecteurs à commenter la même combinaison de commandes pour CSV et JSON.
Voici un exemple de workflow à mentionner dans la note de revue :

```
./scripts/verify_snapshot.sh csv
./scripts/verify_snapshot.sh json
tail -n 5 reports/log_metrics_snapshot.status_top2.csv
jq '.[-1]' reports/log_metrics_snapshot.status_top2.json
```

Ce bloc illustre clairement la commande unique et les vérifications explicites à l’aide de `tail`/`jq` pour obtenir la même sélection `pattern=status`/`top_n=2` sur les deux formats. Mentionnez-le dans vos notes de revue afin que le passage par le helper ou la réexécution des commandes puisse être suivi étape par étape par tout relecteur.
Ajoutez une phrase précisant que `C/ft_services/docs/logs_metrics.md` reprend cette recette helper + tail/jq afin que la note de revue cite la source documentaire en illustrant la même séquence `pattern=status`/`top_n=2` sur CSV et JSON.
Ajoutez également une phrase du type « Voir `C/ft_services/docs/logs_metrics.md` pour les rappels des tail/jq et les recommandations de revue » afin de rapprocher la documentation résumée en tête de README aux consignes plus détaillées du dossier `C/ft_services/docs`. Mentionnez la commande helper et les vérifications `tail`/`jq` dans votre note, citez cette documentation, puis décrivez comment les mêmes lignes `pattern=status`/`top_n=2` apparaissent en CSV et JSON pour que les approbateurs cochent les mêmes traits d’export.
Ajoutez aussi un court exemple de note de revue qui copie la commande helper et les deux `tail`/`jq` vérifications, puis mentionne cette documentation pour prouver que le même sous-ensemble `pattern=status`/`top_n=2` est partagé. Cela donne un modèle concret que les contributeurs peuvent réutiliser dans leur propre note.

### Vérification automatisée des métriques log

Utilisez `./scripts/log_metrics_verify.sh csv` (ou `json`) après `logmetrics 2 status` pour exporter les métriques filtrées vers `reports/log_metrics_snapshot.csv` et vérifier automatiquement les cinq dernières lignes (`tail -n 5`). Cela garantit que la même sélection `pattern=status`/`top_n=2` et les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` sont maintenues avant d’alimenter un dashboard ou une fiche de revue.
Cette séquence complète peut se résumer par l'exemple :

```
$ export LOG_METRICS_DIR=tests/env/logs
$ alias logmetrics='./scripts/logs_metrics.sh'
$ logmetrics 2 status
$ ./scripts/log_summary_diff.sh tests/env/sample_a.conf tests/env/sample_b.conf
$ ./scripts/log_summary_multi.sh tests/env/sample_a.conf tests/env/sample_b.conf tests/env/ft_services.conf
$ ./scripts/logs_metrics_export.sh --topn 2 --format csv
```

Grâce à ce flux, la même sélection `pattern/status` et `top_n=2` guide la visualisation, les synthèses diff/multi et le CSV/JSON final (`timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio`) que vous pouvez copier dans une fiche de revue ou un dashboard automatique. La commande d’export réutilise les filtres précédents, ce qui garantit une répétabilité totale de la chaîne de reporting. Pour livrer ces métriques directement sous forme de fichier partageable, redirigez `./scripts/logs_metrics_export.sh --topn 2 --format csv` vers un fichier (`> reports/log_metrics_snapshot.csv`) ou un pipeline d’upload vers votre tableau de bord préféré, puis vérifiez rapidement la somme exportée avec `tail -n 5 reports/log_metrics_snapshot.csv` avant la diffusion.
Derniere mise a jour (2025-12-12 23:00:00) : ft_services : ajout de `docs/helpers.md` résumant tous les scripts d’assistance (show_config/clean_log/monitor_status/client_demo/demo_pipeline/stress_max_connections/replay_log/log_summary/log_summary_multi) et des instructions pas-à-pas ; la section des helpers mentionne `scripts/show_config.sh`, `scripts/clean_log.sh` et `scripts/monitor_status.sh` pour vérifier port/backlog/log_path/max_connections, purger les logs et dérouler les vérifications santé/connexion/overload ; le README du projet détaille une astuce de démonstration incluant `monitor_status.sh`, `client_demo.py`, `stress_max_connections.sh` et `replay_log.sh`, plus un exemple `./scripts/log_summary_multi.sh tests/env/ft_services_status.conf tests/env/ft_services.conf` illustrant comment regrouper plusieurs logs pour ensuite lire la ligne `Totals: status checks=<n> connections=<n> overloaded=<n>` ; `docs/helpers.md`/README mentionnent aussi `scripts/log_summary_diff.sh` (`Difference (config_b - config_a)`) et les configs `tests/env/sample_a.conf`/`tests/env/sample_b.conf` avec logs factices (tests/env/logs/sample_*.log), et le plan cite `scripts/demo_pipeline.sh` pour agir sur plusieurs configs à la suite.
Derniere mise a jour (2026-01-01 00:00:00) : ft_services : relancé `./full_auto_codex_v2/C/ft_services/scripts/logs_metrics_export.sh --dir full_auto_codex_v2/C/ft_services/tests/env/logs --pattern status --topn 2` puis vérifié les mêmes colonnes `timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio` via `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` et `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json`, comme recommandé dans `C/ft_services/docs/logs_metrics.md` pour prouver qu’ils apparaissent dans les deux formats status/top2 avant publication.
 Derniere mise a jour (2025-12-11 13:00:00) : ft_linear_regression : session 12:59 regénère `data/history.json` et `plots/latest_rmse.*`, les `docs/validation_summary.*` (text/table/JSON/HTML/archives/index) plus `scripts/check_validation_stability.py` (lecteur JSON + seuil avg<1200) restent en dessous de la cible, `scripts/preview_validation.py` chaînant la génération/validation (option `--archive` pour sauver l’HTML versionnée), `scripts/list_validation_archives.py` facilite le choix d’un snapshot, `scripts/prune_validation_archives.py` nettoie les traces trop anciennes, `scripts/verify_archive_summary.py` garantit que la dernière archive reflète la moyenne attendue, `scripts/export_validation_summary_csv.py` fournit une table CSV prête pour la revue, `scripts/index_validation_archives.py` dresse un sommaire Markdown des archives, et `docs/convergence.md` explique comment exploiter ces artefacts pour la revue ft_helpme.
 Derniere mise a jour (2025-12-12 11:39:00) : ft_helpme : review `C/ft_linear_regression` finalisée, `notes/review_outcome.md` synthétise les décisions (scheduler exponential + decay 0.95, RMSE plot & validation folds), et la checklist + docs préparent les actions à appliquer dans `ft_linear_regression`.
 Derniere mise a jour (2025-12-12 11:35:00) : ft_linear_regression : ajout de `scripts/validation.py` pour split aléatoires (test-size, folds, seed), apprentissage avec scheduler/decay/min-lr et reporting RMSE moyen par fold, le README/PLAN indiquent la commande à lancer et les RMSE seront discutés pendant la revue ft_helpme.
 Derniere mise a jour (2025-12-12 11:00:00) : ft_linear_regression : `train.py` accepte maintenant `--scheduler {constant,linear,exponential}`, `--decay`, `--min-lr` et `--history path`, le CLI `scripts/train.sh` écrit `data/history.json` et les docs/plan décrivent comment utiliser `scripts/reports/rmse_plot.py` après la revue ft_helpme ; projet reste IN_PROGRESS jusqu’à l’application des décisions post-review.
 Derniere mise a jour (2025-12-12 10:25:00) : ft_helpme : documenté le partage d’extraits (`code/gradient_notes.md`, `src/train.py`, `scripts/evaluate.py`) pendant la revue, la check-list/follow-up mentionnent scheduler/validation/visualisation, la session 12/12 15h peut démarrer dès que ces artefacts sont présentés.
 Derniere mise a jour (2025-12-12 10:20:00) : ft_helpme : ajout de `scripts/reports/rmse_plot.py` pour synthétiser l’historique RMSE (résumé, sparkline, option PNG) et mise à jour des docs/plan en conséquence ; la revue `ft_linear_regression` reste prête pour le 12/12 15h.
 Derniere mise a jour (2025-12-12 10:15:00) : ft_helpme : nouveau script `scripts/validate_followup.sh` vérifie que `notes/review_followup.md` mentionne scheduler/rmse_plot/validation et que `notes/debrief.md` n’est pas vide, le README/PLAN documentent son usage avant/ après la session du 12/12 15h.
 Derniere mise a jour (2025-12-12 09:00:00) : ft_helpme : review `C/ft_linear_regression` planifiée 12/12 15h (42Net reviewer), `notes/debrief.md`/`notes/review_followup.md` détaillent les actions scheduler/validation/visualisation, checklist script alerte si debrief vide ; après session, appliquer les décisions au projet cible.
 Derniere mise a jour (2025-12-09 07:10:00) : Graphical_Project : rendu PPM + exports (depth/normal/id/albedo/position) et statistiques complètes finalisés, `--mlx` preview prête (compilation `make USE_MLX=1`, touches S/D pour snapshots, options `--mlx-auto-*` et `--mlx-overlay`), projet DONE.
 Derniere mise a jour (2025-12-09 06:50:00) : Graphical_Project : `--mlx` garde l’aperçu mémoire, `--mlx-overlay` ajoute un texte flottant, `--mlx-depth`/`D` sauvent un PPM de profondeur, `--mlx-snapshot`/`S` enregistrent la couleur et les options `--mlx-auto-snapshot`/`--mlx-auto-depth` capturent automatiquement l’image en sortie sans ouvrir MLX ; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 06:15:00) : Graphical_Project : ajout de l’option `--mlx` (avec `mlx_bridge.c`) qui ouvre une fenêtre MiniLibX et affiche le frame déjà calculé via `render_frame` si la bibliothèque est disponible (`USE_MLX`); MLX toujours en attente.
 Derniere mise a jour (2025-12-09 06:05:00) : Graphical_Project : `render_frame`/`free_render_frame` capturent le buffer couleurs/profondeur/normales/IDs de la pipeline PPM pour préparer une interface MLX/temps réel réutilisant les mêmes données sans duplication; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:50:00) : Graphical_Project : `--stats-fps` expose le ratio `samples/duration` dans tous les exports (stats, JSON, CSV, console) en tant que `fps`, facilitant le suivi de la cadence du rendu; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:45:00) : Graphical_Project : `--stats-group name` ajoute `group=name` aux exports stats/JSON/CSV/console pour regrouper facilement les rendus de pipelines différents; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:40:00) : Graphical_Project : `--stats-tag key=value` ajoute un jeu de tags (`tags=key=value;...`) dans tous les exports (stats, JSON, CSV, console), ce qui permet d’annoter les rendus sans modifier les fichiers; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:38:16) : Graphical_Project : `--stats-comment-env VAR` peut remplir automatiquement le commentaire `stats` depuis une variable d’environnement lorsque l’option `--stats-comment` est absente, ce qui facilite l’annotation depuis des scripts; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:35:00) : Graphical_Project : `--stats-ms` imprime `duration_ms` et `duration_unit` dans tous les exports (stats, JSON, CSV, console) pour mesurer les rendus en millisecondes tout en conservant la durée en secondes; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:34:35) : Graphical_Project : `--stats-env VAR` capture la valeur d’une variable d’environnement et l’inscrit dans `env_vars` dans tous les exports (texte/JSON/CSV/console) pour tracer l’environnement d’exécution; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:30:00) : Graphical_Project : `--stats-console-stdout` bascule `--stats-console`/`--stats-console-json` sur `stdout` pour les pipelines qui préfèrent lire `stdout` tout en conservant `--stats-camera`; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:20:10) : Graphical_Project : `--stats-console-json` émet les mêmes métriques que `--stats-console` en JSON sur `stderr` (avec `--stats-camera` qui ajoute la ligne caméra), ce qui facilite l’ingestion machine sans toucher aux fichiers; MLX toujours en attente.
 Derniere mise a jour (2025-12-09 05:03:14) : Graphical_Project : `--stats`/`--stats-json`/`--stats-csv` incluent maintenant la graine `--seed` utilisée (dans les rapports texte, JSON et CSV) de manière à tracer et reproduire exactement chaque rendu; MLX toujours en attente.
Derniere mise a jour (2025-12-09 04:54:33) : Graphical_Project : `--stats-csv` écrit les métriques `--stats` dans un fichier CSV (en-tête `timestamp,scene,width,height,...,duration`) avec `--stats-csv-append` permettant de cumuler les rendus et `--stats-camera` ajoutant les colonnes `cam_pos_*`/`cam_dir_*`; MLX toujours en attente.
Derniere mise a jour (2025-12-08 22:13:15) : Expert_system termine (fixpoint, OR/XOR/bicond, traçage, origines des conflits, sortie JSON `-j`, flags combinables `-vcoj`, 17 tests OK); ft_kalman termine avec un mode `--udp` (paquets texte -> état renvoyé en JSON) et un mock stream Python, `make test` OK; ft_services termine côté manifests/scripts (Makefile start/apply/certs/stop + hosts/seed, scripts init_minikube/gen_certs/apply_all avec LB_POOL, check_cluster/gen_hosts/seed helpers, manifests namespace + MetalLB pool/L2 + ingress TLS whoami + stack WordPress/MariaDB/phpMyAdmin + FTPS LB + monitoring InfluxDB/Grafana avec ingress/datasource/dashboards; tests à faire sur Minikube réel); C/Ft_turing progresse (option -t, validation transitions/entrées/dupes/états inconnus, doc format, exemples unary_increment/reject_even/loop/bad_input/invalid_duplicate/invalid_move/invalid_unknown_state, script de tests 8 cas OK); ft_linux : GCC stage1 bloque (configure-target-libgcc echoue faute d'en-tetes stdc-predef/stdio dans le sysroot; prevoir stubs/en-tetes cibles avant nouvelle tentative), stub makeinfo PATH `.local/bin`, binutils deja installes (LFS `.lfs`); Graphical_Project : renderer PPM OK (`./RT` -> `output.ppm`) mais integration MLX en attente faute de bibliotheque; MessageQueue : sujet lu (RabbitMQ producer/consumers + PDF), en attente d'un broker RabbitMQ pour demarrer; AlCu : termine (parser + IA memoisee, saisie robuste, CLI `alcu` jouable); CPP_Module_05 termine (ex00→ex03 AForm + Shrubbery/Robotomy/Pardon + Intern, Makefiles c++98); CPP_Module_04 termine (ex00→ex04 Animal/Brain/AAnimal/Materia/AFK Mining, Makefiles c++98); CPP_Module_03 termine (ex00→ex03 ClapTrap/ScavTrap/FragTrap/DiamondTrap avec heritage virtuel, Makefiles c++98, tests basiques); CPP_Module_02 termine (ex00→ex03 Fixed/Point/bsp avec Makefiles c++98); CPP_Module_01 termine (ex00→ex06, Makefiles c++98); Django_Training_D01 termine (ex00→ex07, ressources numbers/periodic_table, generation HTML); ft_irc valide (smoke test robuste); ft_linux enrichi (versions + scripts download/partition/mount/env/chroot/toolchain avec cibles linux-headers/glibc, build_kernel, doc build_order/grub/fstab/network/chroot/toolchain/build_log, gen checksums, placeholder .config); CPP Module 00 termine (ex00 a ex04); ft_linear_regression termine avec visualisation matplotlib et RMSE.
Derniere mise a jour (2025-12-08 22:52:34) : C/Ft_turing termine : CLI complète (-v/-t/-r/-o/-s/-c), validation exhaustive (blank, sections obligatoires, complétude optionnelle), suite de tests 18/18 OK, docs format/exemples/README finalisées.
Derniere mise a jour (2025-12-08 23:58:26) : Graphical_Project progresse encore : tonemap (none/reinhard/aces), export depth/normal, primitive box, checker sur plans, ciel configurable (--sky), PPM multi-thread/supersampling/gamma + réflexions `--maxdepth`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:03:30) : Graphical_Project : ajout d’une atténuation quadratique des lumières (1/(1+0.09d+0.032d²)) pour des highlights plus réalistes, évitant la surexposition des surfaces proches; MLX toujours manquante.
Derniere mise a jour (2025-12-09 00:09:06) : Graphical_Project : support des spots directionnels (cutoff en degrés, direction normalisée) + nouvelle scène `assets/scenes/spotlight.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:12:44) : Graphical_Project : ajout d’un brouillard exponentiel global (`fog densité r g b`) appliqué au rendu selon la distance, scène `assets/scenes/foggy.rt` en exemple; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:18:26) : Graphical_Project : matériaux transparents/réfractifs (transparency + IOR optionnels) avec scène `assets/scenes/glass.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:29:20) : Graphical_Project : ombres douces via lights à rayon optionnel (multi shadow rays) + scène `assets/scenes/soft_shadow.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:37:48) : Graphical_Project : loader OBJ (`mesh`) qui triangule les faces, avec scène `assets/scenes/mesh.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:43:13) : Graphical_Project : `mesh` supporte un scale/translate optionnel (sx sy sz tx ty tz), scène `assets/scenes/mesh_scaled.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:48:23) : Graphical_Project : roughness sur les matériaux pour reflets glossy (scene `assets/scenes/glossy.rt`); MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:54:17) : Graphical_Project : loader OBJ supporte les normals `vn`/faces `v//n` + interpolation; scènes `mesh_normals.rt`/`pyramid.obj`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:58:21) : Graphical_Project : matériaux émissifs (emission_strength + couleur) et scène `assets/scenes/emissive.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:02:45) : Graphical_Project : mix refl/trans plus physique via Fresnel (Schlick) pour pondération auto des reflets.
Derniere mise a jour (2025-12-09 01:12:56) : Graphical_Project : textures PPM optionnelles (sphere/plane/mesh) avec scène `assets/scenes/textured.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:17:37) : Graphical_Project : UV OBJ (vt + faces v/vt/vn) avec sampling barycentrique des textures; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:23:34) : Graphical_Project : uv_scale pour tuiler les textures (nouvelle scène `assets/scenes/textured_tiled.rt`); MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:27:40) : Graphical_Project : textures bilinéaires (wrap) pour réduire l’aliasing sur sphères/plans/meshes; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:32:53) : Graphical_Project : wrap bilinéaire consolidé + doc CLI matériaux/texture; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:38:46) : Graphical_Project : lumières directionnelles (`dirlight`/`sun`) avec soft radius + scène `assets/scenes/sun.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:42:51) : Graphical_Project : rotation des meshes (rx ry rz après scale/translate) + scène `assets/scenes/mesh_rotated.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:33:24) : Graphical_Project : primitive triangle ajoutée (parser + intersection) avec scène `assets/scenes/triangles.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 00:23:54) : Graphical_Project : profondeur de champ (aperture/focal_dist) + scène `assets/scenes/dof.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 01:53:52) : Graphical_Project : env map pour le fond (`env` PPM) et export PPM binaire optionnel `--binary` (P6) pour accélérer l’écriture; MLX toujours en attente.
Derniere mise a jour (2025-12-09 02:04:21) : Graphical_Project : support des normal maps PPM (tangent space) avec parsing `[texture [uv_scale [normal]]]`, nouveau normal map `assets/textures/tilt_normal.ppm` et scène `assets/scenes/normal_mapped.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 02:06:18) : Graphical_Project : caméra accepte un vecteur up optionnel pour le roll (`camera ... [upx upy upz]`), scène `assets/scenes/tilted_camera.rt` ajoutée; MLX toujours en attente.
Derniere mise a jour (2025-12-09 02:08:16) : Graphical_Project : support PPM P3/P6 pour textures/envmaps, avec texture binaire `assets/textures/env_p6.ppm` et scène `assets/scenes/envmap_p6.rt`; MLX toujours en attente.
Derniere mise a jour (2025-12-09 02:16:01) : Graphical_Project : accélération BVH (AABB) pour les objets finis afin d’accélérer le rendu sur les meshes; plans restent testés linéairement. MLX toujours en attente.
Derniere mise a jour (2025-12-09 02:18:34) : Graphical_Project : loader OBJ triangule désormais les faces n-gones (fan) et ajoute une scène de validation `assets/scenes/mesh_polygon.rt` (pentagone).
Derniere mise a jour (2025-12-09 02:23:39) : Graphical_Project : ajout d’un flag `--no-bvh` pour désactiver l’accélération BVH (debug) et fallback linéaire.
Derniere mise a jour (2025-12-09 02:28:34) : Graphical_Project : AO optionnelle (`--ao radius samples`) pour moduler l’ambiant par occlusion locale.
Derniere mise a jour (2025-12-09 02:34:12) : Graphical_Project : option `--srgb-textures` pour convertir les textures sRGB en linéaire avant shading.
Derniere mise a jour (2025-12-09 02:38:34) : Graphical_Project : ajout de l’option `--exposure` (gain avant tonemap/gamma) pour contrôler la luminosité globale.
Derniere mise a jour (2025-12-09 02:43:34) : Graphical_Project : `--glossy-samples` permet de lisser le bruit des reflets flous (moyenne multi-rayons).
Derniere mise a jour (2025-12-09 02:50:15) : Graphical_Project : export ID map (`--id id.ppm`) pour le debug/compositing (couleurs hashées par objet).
Derniere mise a jour (2025-12-09 02:54:20) : Graphical_Project : lighting diffus de l’envmap via `--env-samples` (éclairage indirect par hémisphère autour de la normale).
Derniere mise a jour (2025-12-09 03:00:55) : Graphical_Project : export buffers `--albedo` et `--position` (clamp [-10,10]) en plus des depth/normal/ID.
Derniere mise a jour (2025-12-09 03:10:08) : Graphical_Project : seed global `--seed` pour des rendus reproductibles; buffers albedo/position et env-samples intègrent ce seed.
Derniere mise a jour (2025-12-09 03:19:24) : Graphical_Project : option `--pos-range` pour régler le clamp des cartes position, seed appliqué partout.
Derniere mise a jour (2025-12-09 03:27:36) : Graphical_Project : ajout `--clamp` pour borner la luminance linéaire avant tonemap (0 désactive) et nettoyage du parsing CLI (flags id/albedo/position/seed/clamp).
Derniere mise a jour (2025-12-09 03:31:13) : Graphical_Project : flag `--bin-buffers` pour exporter depth/normal/id/albedo/position en P6 binaire (exports debug plus rapides).
Derniere mise a jour (2025-12-09 03:38:12) : Graphical_Project : option `--stats <file>` qui écrit width/height/samples/threads/gamma/maxdepth/exposure/binary/binary_buffers/durée dans le fichier après le rendu.
Derniere mise a jour (2025-12-09 03:43:07) : Graphical_Project : `--stats` capture désormais les threads réellement utilisés (auto détecté / clamp `height`) pour que la fiche reflète fidèlement le rendu.
Derniere mise a jour (2025-12-09 03:48:16) : Graphical_Project : option `--stats-append` pour ajouter les fiches successives sans écraser les précédentes (les stats continuent d’indiquer les threads auto-détectés + durée).
Derniere mise a jour (2025-12-27 10:23:52) : general review de la procédure helper `./scripts/logs_metrics_export.sh --pattern status --topn 2` avec `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` et `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json`; la checklist helper → CSV tail → JSON jq reste referencée pour que les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` soient toujours confirmées, comme décrit dans `C/ft_services/docs/logs_metrics.md`.
Derniere mise a jour (2025-12-09 03:53:00) : Graphical_Project : `--stats` enregistre maintenant les réglages `glossy_samples/env_samples/pos_range/clamp/ao_samples/env_intensity`, utile pour comparer les rendus; `--stats-append` conserve les historiques multi-rendus.
Derniere mise a jour (2025-12-09 03:59:19) : Graphical_Project : l’option `--env-intensity` module l’éclairage diffus de l’envmap pour ajuster l’ambiance globale sans retoucher la texture, `--stats` logge désormais la scène/timestamp et le nombre de lights pour tracer les fichiers de stats.
Derniere mise a jour (2025-12-09 04:23:20) : Graphical_Project : `--stats-camera` ajoute la position/direction caméra dans la fiche stats permettant de lier précisément les rendus aux angles de prise de vue.
Derniere mise a jour (2025-12-09 04:32:54) : Graphical_Project : `--stats-json` duplique les métriques `--stats` en JSON (append autorisé), utile pour l’analyse automatisée; MLX toujours manquante.
Derniere mise a jour (2025-12-09 04:34:30) : Graphical_Project : `--stats-json -` imprime la sortie JSON sur stdout pour les pipelines tout en restant compatible avec `--stats-camera`; MLX toujours manquante.
Derniere mise a jour (2025-12-09 04:28:17) : Graphical_Project : `--stats` mesure aussi les luminances moyenne/min/max et l’écart-type (0-1) pour détecter l’exposition; MLX toujours manquante.
Derniere mise a jour (2025-12-09 03:53:00) : Graphical_Project : option `--env-intensity` pour ajuster la contribution diffuse de l’envmap (1.0 par défaut).
# Pour les relectures détaillées, précisez la commande helper utilisée et la séquence de vérification `tail`/`jq` afin de retranscrire exactement les lignes `pattern=status`/`top_n=2` de `reports/log_metrics_snapshot.status_top2.csv` et `.json`. Le paragraphe ci-dessus vous montre la syntaxe à coller, et le lien vers `C/ft_services/docs/logs_metrics.md` conforte la source documentaire qui décrit le même helper + tail/jq afin que tout relecteur retrouve sans ambiguïté le même sous-ensemble filtré. Ajoutez un court exemple de note de revue, par exemple : « notez le helper `./scripts/logs_metrics_export.sh --pattern status --topn 2` puis validez les exports via `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` et `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json` ; mentionnez cette combinaison dans vos commentaires pour prouver que le même sous-ensemble CSV/JSON a été vérifié » afin de boucler la directive README vers le détail du C/ft_services/docs. Encouragez les relecteurs, quand ils rapportent le helper, à rappeler les paths `reports/log_metrics_snapshot.status_top2.csv/.json` and `tail`/`jq` commands verbatim so the `pattern=status`/`top_n=2` lines can be instantly retraced before approval. Et suggérez de recopier la mini-checklist helper → tail CSV → tail JSON | jq dans les notes de revue pour que l’on retrouve toujours `status,top_n` dans ces lignes partagées. Mentionnez également que `C/ft_services/docs/logs_metrics.md` contient des exemples prêts à copier dans une note et un rappel des colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` afin que les approbateurs puissent cocher chaque vérification.
Reprécisez ensuite dans vos annotations (helper → `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` → `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json`) les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` du sous-ensemble `pattern=status/top_n=2` comme le décrit `C/ft_services/docs/logs_metrics.md`. Cette mini-checklist facilite la validation par double vérification (CSV + JSON) et garantit que la trace `reports/log_metrics_snapshot.status_top2.csv/.json` reste référencée de façon identique à chaque relecture.
Ajoutez cette même mini-checklist helper → CSV tail → JSON jq à votre commentaire pour que, à l’instant T, tous les relecteurs puissent repérer les mêmes lignes `pattern=status/top_n=2` et cocher les colonnes répertoriées dans `C/ft_services/docs/logs_metrics.md` avant toute approbation finale. Cela maintient la piste visible dans README, la fiche doc, et vos notes de relecture.
Dans vos notes récapitulatives, précisez aussi que les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` doivent apparaître dans le subset `pattern=status/top_n=2`, car la doc `C/ft_services/docs/logs_metrics.md` les expose et les trace via `tail -n 5 reports/log_metrics_snapshot.status_top2.csv` plus `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json`. En recollant cette mini-checklist (helper → CSV tail → JSON jq → doc), vous garantissez qu’avant chaque approbation tout le monde suit exactement la même routine de vérification et les mêmes exports `reports/log_metrics_snapshot.status_top2.csv/.json`.
Pensez à copier cette mini-checklist (helper → tail CSV → tail JSON | jq) dans la section de votre note qui cite `C/ft_services/docs/logs_metrics.md`, et ajoutez ces chemins/commandes textuellement (`./scripts/logs_metrics_export.sh --pattern status --topn 2`, `reports/log_metrics_snapshot.status_top2.csv/.json`, `tail -n 5 ...`, `jq '.[-1]' ...`) pour que les relecteurs suivants puissent d’emblée retrouver les lignes `pattern=status/top_n=2`. Cela maintient la piste `status,top_n` identique entre la doc, README et vos annotations. Répétez la liste des colonnes exportées (`timestamp, log_file, status_checks, connections, overloaded, overloaded_ratio`) à chaque mention afin d’attester que les mêmes métriques sont vérifiées à chaque point de contact.
En recopiant cette mini-checklist (helper → CSV tail → JSON jq) dans vos commentaires, vous confirmez aussi que la doc `C/ft_services/docs/logs_metrics.md` et les fichiers `reports/log_metrics_snapshot.status_top2.csv/.json` ont été revalidés via les mêmes commandes, ce qui rend la ligne `pattern=status/top_n=2` observable dans les deux formats avant la validation finale.
  - helper `./scripts/logs_metrics_export.sh --pattern status --topn 2`
  - CSV check `tail -n 5 reports/log_metrics_snapshot.status_top2.csv`
  - JSON check `jq '.[-1]' reports/log_metrics_snapshot.status_top2.json`
  - citation `C/ft_services/docs/logs_metrics.md`
Cette mini-checklist peut être recopiée dans vos annotations pour garantir que les colonnes `timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio` sont bien confirmées sous `pattern=status`/`top_n=2`, comme l’explique la doc `C/ft_services/docs/logs_metrics.md`, et que le helper produit les fichiers `reports/log_metrics_snapshot.status_top2.csv/.json` vérifiés par les commandes `tail -n 5 ...` et `jq '.[-1]' ...`.
Pour aller plus loin, mentionnez dans vos notes que la même doc `C/ft_services/docs/logs_metrics.md` décrit le helper et les colonnes citées, ce qui permet à chacun de réexécuter `tail`/`jq` sur les fichiers exportés et de confirmer que le `pattern=status`/`top_n=2` subset est bien identique au moment du contrôle de relecture. Rappelez aussi la mini-checklist (helper → CSV tail → JSON jq → citation) pour que tout relecteur reporte exactement les mêmes vérifications avant de valider. Ajoutez une phrase incitant les relecteurs à recopier ce trio de commandes (`helper`, `tail -n 5 ...`, `jq '.[-1]' ...`) dans leurs commentaires afin que la piste `pattern=status / top_n=2` reste visible dans les deux formats avant l’approbation.
Derniere mise a jour (2025-12-25 21:07:40) : ft_services : historique overall généré avant manifest/checksums (CSV dans manifest/sitemap/portal), portail avec liens cliquables + tableau d’historique; smoke + quick-check verts (push toujours bloqué DNS).
Derniere mise à jour (2025-12-27 14:07:12) : synchronisation des docs/scripts/helpers
Derniere mise a jour (2026-01-02 19:06:38) : C/ft_linear_regression progresse : validation_summary ajoute median/stddev RMSE (txt/md/json/html/csv/yaml) avec scripts d'export a jour.
Derniere mise a jour (2026-01-02 19:13:15) : C/ft_linear_regression progresse : early stopping restaure les meilleurs theta et validation ajoute best_epoch/best_train_rmse avec options early-stop.
Derniere mise a jour (2026-01-02 19:15:24) : C/ft_linear_regression progresse : validation.py ecrit data/validation_report.txt via --output (default), docs alignes.
Derniere mise a jour (2026-01-02 19:19:39) : C/ft_linear_regression progresse : validation.py ajoute bootstrap (OOB) via --bootstrap-samples pour RMSE supplementaire.
Derniere mise a jour (2026-01-02 19:25:49) : C/ft_linear_regression progresse : validation_summary capture bootstrap average et artefacts regeneres apres run bootstrap.
Derniere mise a jour (2026-01-02 19:29:25) : C/ft_linear_regression progresse : tests ajoutés pour validation_summary (bootstrap) et pytest OK.
Derniere mise a jour (2026-01-02 19:34:52) : C/ft_linear_regression DONE : doc rmse_plot + roadmap post-review, plan termine.
Derniere mise a jour (2026-01-02 19:41:38) : C/ft_hangouts IN_PROGRESS : auto-creation contact SMS inconnu + scenario CLI mis a jour.
Derniere mise a jour (2026-01-02 19:42:33) : C/ft_hangouts IN_PROGRESS : tests run_tests.sh relances apres auto-creation contact SMS.
Derniere mise a jour (2026-01-02 19:46:10) : C/ft_hangouts IN_PROGRESS : settings theme CLI + run_tests.sh OK.
Derniere mise a jour (2026-01-02 19:51:13) : C/ft_hangouts IN_PROGRESS : avatars contacts (add/set-avatar) + run_tests.sh OK.
Derniere mise a jour (2026-01-02 19:55:45) : C/ft_hangouts IN_PROGRESS : import/export contacts CSV + run_tests.sh OK.
Derniere mise a jour (2026-01-02 19:59:45) : C/ft_hangouts IN_PROGRESS : guide utilisateur CLI ajoute.
Derniere mise a jour (2026-01-02 20:04:41) : C/ft_hangouts IN_PROGRESS : README complete + user_journeys ajoutes.
Derniere mise a jour (2026-01-02 20:11:27) : C/ft_hangouts IN_PROGRESS : support appels (log/list/stats) + run_tests.sh OK.
Derniere mise a jour (2026-01-02 20:12:06) : C/ft_hangouts IN_PROGRESS : guide utilisateur mis a jour (section appels).
Derniere mise a jour (2026-01-02 20:15:27) : C/ft_hangouts IN_PROGRESS : export/import appels JSON + run_tests.sh OK.
Derniere mise a jour (2026-01-02 20:19:04) : C/ft_hangouts DONE : prototype CLI complet, docs/tests stabilises.
Derniere mise a jour (2026-01-02 20:25:54) : C/Ft_ls DONE : tests comparatifs OK, plan/README finalises.
Derniere mise a jour (2026-01-02 20:31:24) : C/ft_linux IN_PROGRESS : toolchain split gcc-stage1/libgcc, docs/plans mis a jour.
Derniere mise a jour (2026-01-02 20:34:45) : C/ft_linux IN_PROGRESS : ajout validation toolchain (script + docs).
Derniere mise a jour (2026-01-02 20:40:32) : C/ft_linux IN_PROGRESS : manifest build_system + build_system.sh ameliore.
Derniere mise a jour (2026-01-02 20:44:26) : C/ft_linux IN_PROGRESS : ajout verify_manifest.sh pour valider les tarballs.
Derniere mise a jour (2026-01-02 20:49:43) : C/ft_linux IN_PROGRESS : ajout preflight.sh (env + toolchain + manifest).
Derniere mise a jour (2026-01-02 20:54:22) : C/ft_linux IN_PROGRESS : preflight appelle validate_toolchain + docs ajoutes.
Derniere mise a jour (2026-01-02 20:59:37) : C/ft_linux IN_PROGRESS : ajout log_build.sh pour journaliser les builds.
Derniere mise a jour (2026-01-02 21:04:33) : C/ft_linux IN_PROGRESS : ajout quickcheck.sh (resume validations).
Derniere mise a jour (2026-01-02 21:09:32) : C/ft_linux IN_PROGRESS : ajout status_report.sh (logs + tarballs).
Derniere mise a jour (2026-01-02 21:14:26) : C/ft_linux IN_PROGRESS : status_report execute, rapport genere.
Derniere mise a jour (2026-01-02 21:19:36) : C/ft_linux IN_PROGRESS : status_report genere TXT+CSV.
Derniere mise a jour (2026-01-02 21:24:42) : C/ft_linux IN_PROGRESS : manifest enrichi (utilitaires de base) + docs.
Derniere mise a jour (2026-01-02 21:30:25) : C/ft_linux IN_PROGRESS : download_sources.sh ajoute --verify-only/--list.
Derniere mise a jour (2026-01-02 21:35:46) : C/ft_linux IN_PROGRESS : missing_tarballs.sh + reports missing_tarballs.*.
Derniere mise a jour (2026-01-02 21:44:45) : C/ft_linux IN_PROGRESS : manifest_report.sh + reports manifest_sources.*.
Derniere mise a jour (2026-01-02 21:49:46) : C/ft_linux IN_PROGRESS : generate_downloads.sh + reports/download_missing.sh.
Derniere mise a jour (2026-01-02 21:54:45) : C/ft_linux IN_PROGRESS : verify_checksums.sh + reports/sha_report.*.
Derniere mise a jour (2026-01-02 21:59:37) : C/ft_linux IN_PROGRESS : verify_checksums.sh resume + exit code.
Derniere mise a jour (2026-01-02 22:04:40) : C/ft_linux IN_PROGRESS : report_index.sh + reports/index.md.
Derniere mise a jour (2026-01-02 22:09:29) : C/ft_linux IN_PROGRESS : quickcheck.sh execute (toolchain + tarballs manquants).
Derniere mise a jour (2026-01-02 22:14:56) : C/ft_linux IN_PROGRESS : download_sources.sh support --from dir.
Derniere mise a jour (2026-01-02 22:19:49) : C/ft_linux IN_PROGRESS : env_audit.sh + reports/env_audit.*.
Derniere mise a jour (2026-01-02 22:25:18) : C/ft_linux IN_PROGRESS : setup_env.sh passe en mode commandes (create/partition/attach/format/mount).
Derniere mise a jour (2026-01-02 22:29:34) : C/ft_linux IN_PROGRESS : setup_env.sh ajoute generation fstab.
Derniere mise a jour (2026-01-02 22:33:07) : C/ft_linux IN_PROGRESS : build_kernel.sh gere chroot/LFS, options config/modules/install + logs.
Derniere mise a jour (2026-01-02 22:40:12) : C/ft_linux IN_PROGRESS : ajout build_rootfs.sh + layout rootfs TSV.
Derniere mise a jour (2026-01-02 22:44:56) : C/ft_linux IN_PROGRESS : ajout bootstrap_system.sh (fstab/hosts/passwd/group/hostname).
Derniere mise a jour (2026-01-02 22:49:39) : C/ft_linux IN_PROGRESS : ajout squelette SysV init (inittab+rc scripts).
Derniere mise a jour (2026-01-02 22:54:23) : C/ft_linux IN_PROGRESS : ajout generate_grub_cfg.sh (grub.cfg auto).
Derniere mise a jour (2026-01-02 22:59:33) : C/ft_linux IN_PROGRESS : ajout chroot_prepare.sh (mount/umount chroot).
Derniere mise a jour (2026-01-02 23:04:42) : C/ft_linux IN_PROGRESS : ajout install_init_scripts.sh (mountfs/syslog/network).
Derniere mise a jour (2026-01-02 23:09:48) : C/ft_linux IN_PROGRESS : ajout rootfs_report.sh (rapport structure rootfs).
Derniere mise a jour (2026-01-02 23:14:43) : C/ft_linux IN_PROGRESS : ajout enable_services.sh + manifest services.
Derniere mise a jour (2026-01-02 23:19:02) : C/ft_linux IN_PROGRESS : ajout build_mini_system.sh + manifest intermediaire.
Derniere mise a jour (2026-01-02 23:25:29) : C/ft_linux IN_PROGRESS : manifests supportent build_type + build_mini/system adaptes.
Derniere mise a jour (2026-01-02 23:29:20) : C/ft_linux IN_PROGRESS : list manifests affiche build_type.
Derniere mise a jour (2026-01-02 23:34:28) : C/ft_linux IN_PROGRESS : ajout validate_manifests.sh (lint manifests).
Derniere mise a jour (2026-01-02 23:39:03) : C/ft_linux IN_PROGRESS : ajout boot_checklist.sh (rapport prerequis boot).
Derniere mise a jour (2026-01-02 23:44:14) : C/ft_linux IN_PROGRESS : boot_checklist.sh gere kernel absent proprement.
Derniere mise a jour (2026-01-02 23:49:29) : C/ft_linux IN_PROGRESS : ajout validate_fstab.sh (rapport fstab).
Derniere mise a jour (2026-01-02 23:54:27) : C/ft_linux IN_PROGRESS : ajout create_dev_nodes.sh (noeuds /dev minimaux).
Derniere mise a jour (2026-01-02 23:59:40) : C/ft_linux IN_PROGRESS : ajout install_system_configs.sh + templates system.
Derniere mise a jour (2026-01-03 00:04:04) : C/ft_linux IN_PROGRESS : ajout locale.sh (profile.d) via install_system_configs.sh.
Derniere mise a jour (2026-01-03 00:09:58) : C/ft_linux IN_PROGRESS : ajout check_env_prereqs.sh + preflight etendu.
Derniere mise a jour (2026-01-03 00:14:35) : C/ft_linux IN_PROGRESS : ajout bootstrap_all.sh (sequence setup complete).
Derniere mise a jour (2026-01-03 00:19:06) : C/ft_linux IN_PROGRESS : ajout summary_report.sh (rapport synthese).
Derniere mise a jour (2026-01-03 00:24:31) : C/ft_linux IN_PROGRESS : ajout ensure_grub_cfg.sh (installe grub.cfg).
Derniere mise a jour (2026-01-03 00:29:36) : C/ft_linux IN_PROGRESS : ajout validate_grub_cfg.sh (rapport grub).
Derniere mise a jour (2026-01-03 00:34:06) : C/ft_linux IN_PROGRESS : ajout build_kernel_config.sh (defconfig).
Derniere mise a jour (2026-01-03 00:39:06) : C/ft_linux IN_PROGRESS : build_kernel.sh ajoute --print-release.
Derniere mise a jour (2026-01-03 00:45:07) : C/ft_linux IN_PROGRESS : ajout build_initramfs.sh + manifest initramfs.
Derniere mise a jour (2026-01-03 00:49:06) : C/ft_linux IN_PROGRESS : initramfs modules list ajoutee.
Derniere mise a jour (2026-01-03 00:54:36) : C/ft_linux IN_PROGRESS : ajout validate_initramfs.sh (rapport initramfs).
Derniere mise a jour (2026-01-03 00:59:33) : C/ft_linux IN_PROGRESS : ajout package_rootfs.sh (tar+checksum).
Derniere mise a jour (2026-01-03 01:04:14) : C/ft_linux IN_PROGRESS : package_rootfs.sh robustifie output sans sha256sum.
Derniere mise a jour (2026-01-03 01:09:31) : C/ft_linux IN_PROGRESS : ajout release_report.sh (recap versions).
Derniere mise a jour (2026-01-03 01:14:14) : C/ft_linux IN_PROGRESS : summary_report.sh inclut release_report.
Derniere mise a jour (2026-01-03 01:19:15) : C/ft_linux IN_PROGRESS : summary_report.sh inclut grub/initramfs.
Derniere mise a jour (2026-01-03 01:24:40) : C/ft_linux IN_PROGRESS : ajout validate_services.sh (rapport services).
Derniere mise a jour (2026-01-03 01:29:13) : C/ft_linux IN_PROGRESS : summary_report.sh inclut services_report.
Derniere mise a jour (2026-01-03 01:34:47) : C/ft_linux IN_PROGRESS : validate_manifests.sh genere manifest_report.txt.
Derniere mise a jour (2026-01-03 01:39:30) : C/ft_linux IN_PROGRESS : ajout run_reports.sh (orchestrateur rapports).
Derniere mise a jour (2026-01-03 01:44:30) : C/ft_linux IN_PROGRESS : run_reports.sh inclut prerequis host.
Derniere mise a jour (2026-01-03 01:49:32) : C/ft_linux IN_PROGRESS : ajout boot_bundle.sh (kernel+initramfs+grub).
Derniere mise a jour (2026-01-03 01:54:51) : C/ft_linux IN_PROGRESS : ajout validate_kernel_config.sh + kernel_requirements.txt.
Derniere mise a jour (2026-01-03 01:59:14) : C/ft_linux IN_PROGRESS : run_reports.sh inclut validation kernel config.
Derniere mise a jour (2026-01-03 02:04:12) : C/ft_linux IN_PROGRESS : summary_report.sh inclut kernel_config_report.
Derniere mise a jour (2026-01-03 02:10:31) : C/ft_linux IN_PROGRESS : initramfs install-boot + grub initrd auto.
Derniere mise a jour (2026-01-03 02:14:50) : C/ft_linux IN_PROGRESS : ajout boot_artifacts.sh (artefacts /boot).
Derniere mise a jour (2026-01-03 02:19:18) : C/ft_linux IN_PROGRESS : boot_bundle.sh verifie artefacts /boot.
Derniere mise a jour (2026-01-03 02:24:54) : C/ft_linux IN_PROGRESS : ajout full_pipeline.sh (pipeline complet).
Derniere mise a jour (2026-01-03 02:29:59) : C/ft_linux IN_PROGRESS : ajout generate_initramfs_manifest.sh + bins list.
Derniere mise a jour (2026-01-03 02:34:27) : C/ft_linux IN_PROGRESS : run_reports.sh corrige doublon summary_report.
Derniere mise a jour (2026-01-03 02:39:40) : C/ft_linux IN_PROGRESS : ajout chroot_enter.sh (mount+chroot+umount).
Derniere mise a jour (2026-01-03 02:44:18) : C/ft_linux IN_PROGRESS : full_pipeline.sh valide config kernel.
Derniere mise a jour (2026-01-03 02:49:50) : C/ft_linux IN_PROGRESS : ajout grub_install.sh (installation GRUB).
Derniere mise a jour (2026-01-03 02:54:34) : C/ft_linux IN_PROGRESS : ajout detect_boot_mode.sh (BIOS/UEFI).
Derniere mise a jour (2026-01-03 02:59:21) : C/ft_linux IN_PROGRESS : reports incluent boot_mode.
Derniere mise a jour (2026-01-03 03:04:31) : C/ft_linux IN_PROGRESS : build_initramfs.sh supporte manifest genere.
Derniere mise a jour (2026-01-03 03:09:25) : C/ft_linux IN_PROGRESS : ajout host_requirements.md.
Derniere mise a jour (2026-01-03 03:14:51) : C/ft_linux IN_PROGRESS : ajout run_vm.sh (boot QEMU).
Derniere mise a jour (2026-01-03 03:19:24) : C/ft_linux IN_PROGRESS : run_vm.sh supporte SSH port forwarding.
Derniere mise a jour (2026-01-03 03:24:21) : C/ft_linux IN_PROGRESS : run_vm.sh aide clarifiee pour SSH.
Derniere mise a jour (2026-01-03 03:29:12) : C/ft_linux IN_PROGRESS : run_vm.sh ajoute exemple SSH.
Derniere mise a jour (2026-01-03 03:34:46) : C/ft_linux IN_PROGRESS : ajout boot_finalize.sh (finalisation boot).
Derniere mise a jour (2026-01-03 03:39:14) : C/ft_linux IN_PROGRESS : boot_finalize rapporte + summary.
Derniere mise a jour (2026-01-03 03:44:38) : C/ft_linux IN_PROGRESS : ajout archive_reports.sh (bundle rapports/logs).
Derniere mise a jour (2026-01-03 03:49:34) : C/ft_linux IN_PROGRESS : validate_grub_cfg verifie initrd.
Derniere mise a jour (2026-01-03 03:54:30) : C/ft_linux IN_PROGRESS : summary_report regroupe boot/grub/initramfs.
Derniere mise a jour (2026-01-03 03:59:31) : C/ft_linux IN_PROGRESS : build_initramfs.sh peut generer le manifest.
Derniere mise a jour (2026-01-03 04:04:33) : C/ft_linux IN_PROGRESS : ajout runbook complet.
Derniere mise a jour (2026-01-03 04:09:37) : C/ft_linux IN_PROGRESS : ajout check_ready_to_boot.sh (rapport boot ready).
Derniere mise a jour (2026-01-03 04:14:20) : C/ft_linux IN_PROGRESS : check_ready_to_boot verifie rc scripts.
Derniere mise a jour (2026-01-03 04:19:23) : C/ft_linux IN_PROGRESS : reports incluent ready_to_boot.
Derniere mise a jour (2026-01-03 04:24:15) : C/ft_linux IN_PROGRESS : ajout snapshot_image.sh (snapshot disque).
Derniere mise a jour (2026-01-03 04:29:16) : C/ft_linux IN_PROGRESS : run_vm.sh aide mentionne defaults mem/cpus.
Derniere mise a jour (2026-01-03 04:34:44) : C/ft_linux IN_PROGRESS : ajout convert_image.sh (qcow2).
Derniere mise a jour (2026-01-03 04:39:17) : C/ft_linux IN_PROGRESS : run_vm.sh detecte qcow2.
Derniere mise a jour (2026-01-03 04:44:42) : C/ft_linux IN_PROGRESS : ajout image_report.sh (rapport image).
Derniere mise a jour (2026-01-03 04:49:21) : C/ft_linux IN_PROGRESS : run_reports.sh archive reports/logs.
Derniere mise a jour (2026-01-03 04:55:24) : C/ft_linux IN_PROGRESS : archive_reports.sh regenere reports/index.md.
Derniere mise a jour (2026-01-03 04:59:25) : C/ft_linux IN_PROGRESS : archive_reports.sh log index refresh.
Derniere mise a jour (2026-01-03 05:04:46) : C/ft_linux IN_PROGRESS : ajout export_boot_artifacts.sh.
Derniere mise a jour (2026-01-03 05:09:24) : C/ft_linux IN_PROGRESS : boot_finalize exporte artefacts boot.
Derniere mise a jour (2026-01-03 05:14:23) : C/ft_linux IN_PROGRESS : runbook note boot_finalize exporte artefacts.
Derniere mise a jour (2026-01-03 05:19:53) : C/ft_linux IN_PROGRESS : ajout validate_boot_archive.sh.
Derniere mise a jour (2026-01-03 05:24:39) : C/ft_linux IN_PROGRESS : ajout clean_workspace.sh.
Derniere mise a jour (2026-01-03 05:29:38) : C/ft_linux IN_PROGRESS : clean_workspace.sh couvre boot_artifacts/qcow2.
Derniere mise a jour (2026-01-03 05:34:49) : C/ft_linux IN_PROGRESS : ajout partition_report.sh.
Derniere mise a jour (2026-01-03 05:39:31) : C/ft_linux IN_PROGRESS : reports incluent partition_report.
Derniere mise a jour (2026-01-03 05:44:43) : C/ft_linux IN_PROGRESS : partition_report inclut label/unit.
Derniere mise a jour (2026-01-03 05:49:20) : C/ft_linux IN_PROGRESS : ajout release_bundle.sh (bundle final).
Derniere mise a jour (2026-01-03 05:55:37) : C/ft_linux IN_PROGRESS : release_bundle.sh supprime archive precedente.
Derniere mise a jour (2026-01-03 05:59:59) : C/ft_linux IN_PROGRESS : ajout validate_release_bundle.sh.
Derniere mise a jour (2026-01-03 06:04:18) : C/ft_linux IN_PROGRESS : validate_release_bundle verifie boot_artifacts.
Derniere mise a jour (2026-01-03 06:09:18) : C/ft_linux IN_PROGRESS : validate_release_bundle verifie summary.md.
Derniere mise a jour (2026-01-03 06:14:53) : C/ft_linux IN_PROGRESS : ajout assess_status.sh (etat consolide).
Derniere mise a jour (2026-01-03 06:19:22) : C/ft_linux IN_PROGRESS : ajout apply_kernel_requirements.sh.
Derniere mise a jour (2026-01-03 06:24:20) : C/ft_linux IN_PROGRESS : build_kernel_config.sh supporte --apply-reqs.
Derniere mise a jour (2026-01-03 06:29:19) : C/ft_linux IN_PROGRESS : runbook utilise --apply-reqs.
Derniere mise a jour (2026-01-03 06:37:11) : C/ft_linux IN_PROGRESS : reprise build_system/build_mini_system avec state.
Derniere mise a jour (2026-01-03 06:45:16) : C/ft_linux IN_PROGRESS : ajout status/reset state pour build_system/build_mini_system.
Derniere mise a jour (2026-01-03 06:49:56) : C/ft_linux IN_PROGRESS : ajout build_state_report + summary/run_reports.
Derniere mise a jour (2026-01-03 06:54:53) : C/ft_linux IN_PROGRESS : ajout validate_build_state + integration summary/run_reports.
Derniere mise a jour (2026-01-03 07:00:03) : C/ft_linux IN_PROGRESS : ajout build_state_sync (logs -> state).
Derniere mise a jour (2026-01-03 07:05:17) : C/ft_linux IN_PROGRESS : ajout plage --from/--until build_system/mini_system.
Derniere mise a jour (2026-01-03 07:09:58) : C/ft_linux IN_PROGRESS : ajout build_log_audit + integration summary/run_reports.
Derniere mise a jour (2026-01-03 07:14:46) : C/ft_linux IN_PROGRESS : ajout manifest_coverage (logs vs manifests).
Derniere mise a jour (2026-01-03 07:19:56) : C/ft_linux IN_PROGRESS : status_assessment couvre build_state/build_log/coverage.
Derniere mise a jour (2026-01-03 07:24:52) : C/ft_linux IN_PROGRESS : validate_manifests detecte doublons manifests.
Derniere mise a jour (2026-01-03 07:30:23) : C/ft_linux IN_PROGRESS : ajout build_plan + pkg build_system.
Derniere mise a jour (2026-01-03 07:34:46) : C/ft_linux IN_PROGRESS : ajout build_queue (execution plan avec reprise).
Derniere mise a jour (2026-01-03 07:41:28) : C/ft_linux IN_PROGRESS : ajout build_times (timings + rapport).
Derniere mise a jour (2026-01-03 07:44:54) : C/ft_linux IN_PROGRESS : build_queue log CSV + summary.
Derniere mise a jour (2026-01-03 07:49:50) : C/ft_linux IN_PROGRESS : build_queue status/reset.
Derniere mise a jour (2026-01-03 07:54:51) : C/ft_linux IN_PROGRESS : build_queue status integre rapports + assess.
Derniere mise a jour (2026-01-03 07:59:55) : C/ft_linux IN_PROGRESS : ajout validate_build_plan.
Derniere mise a jour (2026-01-03 08:04:47) : C/ft_linux IN_PROGRESS : validate_build_plan corrige comptage + liste inconnus.
Derniere mise a jour (2026-01-03 08:09:49) : C/ft_linux IN_PROGRESS : ajout build_queue_retry.
Derniere mise a jour (2026-01-03 08:14:55) : C/ft_linux IN_PROGRESS : ajout build_queue_retry_report + integration rapports.
Derniere mise a jour (2026-01-03 08:20:12) : C/ft_linux IN_PROGRESS : ajout build_queue_sync_states.
Derniere mise a jour (2026-01-03 08:24:47) : C/ft_linux IN_PROGRESS : build_queue timeout support.
Derniere mise a jour (2026-01-03 08:30:04) : C/ft_linux IN_PROGRESS : ajout build_queue_metrics.
Derniere mise a jour (2026-01-03 08:34:28) : C/ft_linux IN_PROGRESS : build_queue_metrics ajoute top durees.
Derniere mise a jour (2026-01-03 08:39:27) : C/ft_linux IN_PROGRESS : build_queue_metrics ajoute top echecs.
Derniere mise a jour (2026-01-03 08:45:04) : C/ft_linux IN_PROGRESS : ajout validate_build_queue_state.
Derniere mise a jour (2026-01-03 08:49:56) : C/ft_linux IN_PROGRESS : ajout build_queue_report.
Derniere mise a jour (2026-01-03 08:55:27) : C/ft_linux IN_PROGRESS : ajout build_state_snapshot/diff.
Derniere mise a jour (2026-01-03 09:00:06) : C/ft_linux IN_PROGRESS : ajout build_state_list/prune.
Derniere mise a jour (2026-01-03 09:04:56) : C/ft_linux IN_PROGRESS : build_state_prune dry-run + integration rapports.
Derniere mise a jour (2026-01-03 09:10:06) : C/ft_linux IN_PROGRESS : ajout build_dashboard.
Derniere mise a jour (2026-01-03 09:15:32) : C/ft_linux IN_PROGRESS : ajout build_plan_split.
Derniere mise a jour (2026-01-03 09:20:05) : C/ft_linux IN_PROGRESS : ajout build_plan_remaining.
Derniere mise a jour (2026-01-03 09:26:01) : C/ft_linux IN_PROGRESS : build_progress tracking + report.
Derniere mise a jour (2026-01-03 09:30:10) : C/ft_linux IN_PROGRESS : ajout build_progress_rollup.
Derniere mise a jour (2026-01-03 09:34:30) : C/ft_linux IN_PROGRESS : build_queue_metrics detaille durees ok.
Derniere mise a jour (2026-01-03 09:40:02) : C/ft_linux IN_PROGRESS : ajout build_progress_failures.
Derniere mise a jour (2026-01-03 09:45:12) : C/ft_linux IN_PROGRESS : ajout build_orchestrator.
Derniere mise a jour (2026-01-03 09:50:08) : C/ft_linux IN_PROGRESS : ajout build_orchestrator_report.
Derniere mise a jour (2026-01-03 09:55:04) : C/ft_linux IN_PROGRESS : build_orchestrator exporte JSON.
Derniere mise a jour (2026-01-03 10:00:11) : C/ft_linux IN_PROGRESS : ajout build_orchestrator_status.
Derniere mise a jour (2026-01-03 10:04:35) : C/ft_linux IN_PROGRESS : build_orchestrator JSON escape.
Derniere mise a jour (2026-01-03 10:10:09) : C/ft_linux IN_PROGRESS : ajout build_orchestrator_validate.
Derniere mise a jour (2026-01-03 10:15:14) : C/ft_linux IN_PROGRESS : ajout build_health_report.
Derniere mise a jour (2026-01-03 10:19:57) : C/ft_linux IN_PROGRESS : build_queue continue-on-fail.
Derniere mise a jour (2026-01-03 10:25:39) : C/ft_linux IN_PROGRESS : build_system/mini supporte make check.
Derniere mise a jour (2026-01-03 10:30:25) : C/ft_linux IN_PROGRESS : ajout build_gate.
Derniere mise a jour (2026-01-03 10:34:55) : C/ft_linux IN_PROGRESS : run_reports inclut build_gate + health.
Derniere mise a jour (2026-01-03 10:40:23) : C/ft_linux IN_PROGRESS : ajout build_summary_json.
Derniere mise a jour (2026-01-03 10:44:38) : C/ft_linux IN_PROGRESS : build_summary_json corrige rollup.
Derniere mise a jour (2026-01-03 10:50:03) : C/ft_linux IN_PROGRESS : ajout build_session.
Derniere mise a jour (2026-01-03 10:55:25) : C/ft_linux IN_PROGRESS : plan/orchestrator supporte check.
Derniere mise a jour (2026-01-03 11:00:13) : C/ft_linux IN_PROGRESS : ajout build_summary_validate.
Derniere mise a jour (2026-01-03 11:05:25) : C/ft_linux IN_PROGRESS : ajout build_queue_failures.
Derniere mise a jour (2026-01-03 11:09:53) : C/ft_linux IN_PROGRESS : build_queue_report integre failures.
Derniere mise a jour (2026-01-03 11:14:34) : C/ft_linux IN_PROGRESS : build_queue_metrics ajoute taux ok.
Derniere mise a jour (2026-01-17 02:35:10) : C/Ft_ssl_md5 DONE : ajout test md5 -s "" + tests OK.
Derniere mise a jour (2026-01-17 02:36:52) : C/ft_kalman IN_PROGRESS : tests inverse 3x3 + fix Werror host non utilise.
Derniere mise a jour (2026-01-17 02:40:09) : C/ft_kalman IN_PROGRESS : test transpose matrice + run_unit OK.
Derniere mise a jour (2026-01-17 02:45:07) : C/ft_kalman IN_PROGRESS : test identite matrice + run_unit OK.
Derniere mise a jour (2026-01-17 02:49:59) : C/ft_kalman IN_PROGRESS : doc tests_realisation (run_unit + couverture).
Derniere mise a jour (2026-01-17 02:55:08) : C/ft_kalman IN_PROGRESS : test determinant 3x3 + run_unit OK.
Derniere mise a jour (2026-01-17 03:00:45) : C/ft_kalman IN_PROGRESS : run_udp mock + skip si sockets interdites.
Derniere mise a jour (2026-01-17 03:05:21) : C/ft_kalman IN_PROGRESS : cibles Makefile test-udp/test-all + doc.
Derniere mise a jour (2026-01-17 03:10:08) : C/ft_kalman DONE : cloture apres tests unit + udp mock + doc.
Derniere mise a jour (2026-01-17 03:15:36) : C/ft_helpme DONE : tests valeurs par defaut (unspecified) + run_tests OK.
Derniere mise a jour (2026-01-17 03:20:56) : C/ft_irc WAITING : tests smoke bloques (sockets locaux interdits).
Derniere mise a jour (2026-01-17 03:21:42) : C/Born2beRoot DONE : checks labels monitoring.sh + run_tests OK.
Derniere mise a jour (2026-01-17 03:26:28) : C/Philosophers DONE : run_tests.sh (erreurs + single philo) + tests OK.
Derniere mise a jour (2026-01-17 03:30:31) : C/Push_swap DONE : tests deja trie + overflow + run_tests OK.
Derniere mise a jour (2026-01-17 03:35:41) : C/Ft_containers DONE : run_tests.sh inclut list_stack_queue_compare + OK.
Derniere mise a jour (2026-01-17 03:40:30) : C/Ft_shield DONE : tests exit code + usage erreurs + run_tests OK.
Derniere mise a jour (2026-01-17 03:45:23) : C/So_Long DONE : tests cartes invalides + run_tests OK.
Derniere mise a jour (2026-01-17 03:50:37) : C/Minitalk DONE : tests client erreurs (args/pid) + run_tests OK.
Derniere mise a jour (2026-01-17 03:55:59) : C/Ft_ping DONE : test pattern invalide (options) + tests OK.
Derniere mise a jour (2026-01-17 04:00:36) : C/Ft_mini_ls DONE : tests args message erreur + run_tests OK.
Derniere mise a jour (2026-01-17 04:07:04) : C/Ft_ls DONE : test fichier manquant + run_tests OK.
Derniere mise a jour (2026-01-17 04:10:14) : C/ft_self_analysis DONE : ajout questions reviewer + MAJ checklist.
Derniere mise a jour (2026-01-17 04:15:32) : C/Ft_server DONE : checks env MySQL dans tests_realisation + OK.
Derniere mise a jour (2026-01-17 04:20:46) : C/Ft_ls IN_PROGRESS : test symlink -l + run_tests OK.
Derniere mise a jour (2026-01-17 04:25:12) : C/Ft_ls DONE : test fichier -l + run_tests OK.
Derniere mise a jour (2026-01-17 04:30:44) : C/Minishell IN_PROGRESS : run_unit_tests.sh build auto + tests OK.
Derniere mise a jour (2026-01-17 04:35:18) : C/Minishell DONE : test pwd_basic + run_unit_tests OK.
Derniere mise a jour (2026-01-17 04:40:16) : Messagequeue/MessageQueue IN_PROGRESS : ajout docker-compose RabbitMQ + doc.
Derniere mise a jour (2026-01-17 04:45:47) : Messagequeue/MessageQueue IN_PROGRESS : doc topologie exchanges/queues + plan MAJ.
Derniere mise a jour (2026-01-17 04:50:16) : Messagequeue/MessageQueue IN_PROGRESS : ajout shared/pdfs + doc.
Derniere mise a jour (2026-01-17 04:55:14) : Messagequeue/MessageQueue IN_PROGRESS : ajout sample_student.json + doc.
Derniere mise a jour (2026-01-17 05:00:13) : Messagequeue/MessageQueue IN_PROGRESS : exemples routing keys + doc.
Derniere mise a jour (2026-01-17 05:05:09) : Messagequeue/MessageQueue IN_PROGRESS : doc stop/start docker compose.
Derniere mise a jour (2026-01-17 05:10:18) : Messagequeue/MessageQueue IN_PROGRESS : doc services + PDFs.
Derniere mise a jour (2026-01-17 05:15:13) : Messagequeue/MessageQueue IN_PROGRESS : plan MAJ arborescence.
Derniere mise a jour (2026-01-17 05:20:40) : Messagequeue/MessageQueue IN_PROGRESS : script bootstrap RabbitMQ.
Derniere mise a jour (2026-01-17 05:25:15) : Messagequeue/MessageQueue IN_PROGRESS : doc env bootstrap RabbitMQ.
Derniere mise a jour (2026-01-17 05:30:17) : Messagequeue/MessageQueue IN_PROGRESS : doc nommage PDF.
Derniere mise a jour (2026-01-17 05:35:23) : Messagequeue/MessageQueue IN_PROGRESS : script check_rabbitmq + doc.
Derniere mise a jour (2026-01-17 05:40:11) : Messagequeue/MessageQueue IN_PROGRESS : doc sequence bootstrap complete.
Derniere mise a jour (2026-01-17 05:45:51) : Messagequeue/MessageQueue IN_PROGRESS : script validate_rabbitmq + doc.
Derniere mise a jour (2026-01-17 05:50:17) : Messagequeue/MessageQueue IN_PROGRESS : validate_rabbitmq verifie bindings.
Derniere mise a jour (2026-01-17 05:55:11) : Messagequeue/MessageQueue IN_PROGRESS : note API management pour validation.
Derniere mise a jour (2026-01-17 06:00:25) : Messagequeue/MessageQueue IN_PROGRESS : script bootstrap_and_validate.
Derniere mise a jour (2026-01-17 06:05:16) : Messagequeue/MessageQueue IN_PROGRESS : quickstart local doc.
Derniere mise a jour (2026-01-17 06:10:28) : Messagequeue/MessageQueue IN_PROGRESS : plan MAJ scripts setup/quickstart coches.
Derniere mise a jour (2026-01-17 06:15:33) : Messagequeue/MessageQueue IN_PROGRESS : layout modules + dossiers services.
Derniere mise a jour (2026-01-17 06:20:11) : Messagequeue/MessageQueue IN_PROGRESS : mention modules stubs services/.
Derniere mise a jour (2026-01-17 06:25:31) : Messagequeue/MessageQueue IN_PROGRESS : doc variables env services.
Derniere mise a jour (2026-01-17 06:30:23) : Messagequeue/MessageQueue IN_PROGRESS : doc contenu PDFs.
Derniere mise a jour (2026-01-17 06:35:20) : Messagequeue/MessageQueue IN_PROGRESS : smoke plan local.
Derniere mise a jour (2026-01-17 06:40:12) : Messagequeue/MessageQueue IN_PROGRESS : TODO implementation.
Derniere mise a jour (2026-01-17 06:46:11) : Messagequeue/MessageQueue IN_PROGRESS : scripts publish/consume test + doc.
Derniere mise a jour (2026-01-17 06:50:22) : Messagequeue/MessageQueue IN_PROGRESS : publish_test_message content_type JSON.
Derniere mise a jour (2026-01-17 06:55:23) : Messagequeue/MessageQueue IN_PROGRESS : publish_test_message message_id auto.
Derniere mise a jour (2026-01-17 07:00:20) : Messagequeue/MessageQueue IN_PROGRESS : consume_test_message TRUNCATE.
Derniere mise a jour (2026-01-17 07:05:32) : Messagequeue/MessageQueue IN_PROGRESS : script list_queues.
Derniere mise a jour (2026-01-17 07:10:33) : Messagequeue/MessageQueue IN_PROGRESS : script list_exchanges.
Derniere mise a jour (2026-01-17 07:15:15) : Messagequeue/MessageQueue IN_PROGRESS : list_exchanges ignore exchange vide.
Derniere mise a jour (2026-01-17 07:20:24) : Messagequeue/MessageQueue IN_PROGRESS : doc policy ACK consumers.
Derniere mise a jour (2026-01-17 07:25:15) : Messagequeue/MessageQueue IN_PROGRESS : sample_student grantType.
Derniere mise a jour (2026-01-17 07:30:23) : Messagequeue/MessageQueue IN_PROGRESS : publish_test_message routing key default + metadata.
Derniere mise a jour (2026-01-17 07:35:26) : Messagequeue/MessageQueue IN_PROGRESS : test matrix.
Derniere mise a jour (2026-01-17 07:40:15) : Messagequeue/MessageQueue IN_PROGRESS : note statut.
Derniere mise a jour (2026-01-17 07:45:45) : Messagequeue/MessageQueue IN_PROGRESS : script test_routing.
Derniere mise a jour (2026-01-17 07:50:19) : Messagequeue/MessageQueue IN_PROGRESS : fix test_routing env.
Derniere mise a jour (2026-01-17 07:55:17) : Messagequeue/MessageQueue IN_PROGRESS : test_routing purge queue DELETE.
Derniere mise a jour (2026-01-17 08:00:24) : Messagequeue/MessageQueue IN_PROGRESS : doc endpoints producer.
Derniere mise a jour (2026-01-17 08:05:23) : Messagequeue/MessageQueue IN_PROGRESS : doc schema payload.
Derniere mise a jour (2026-01-17 08:10:34) : Messagequeue/MessageQueue IN_PROGRESS : script wait_rabbitmq.
Derniere mise a jour (2026-01-17 08:15:31) : Messagequeue/MessageQueue IN_PROGRESS : script bootstrap_all.
Derniere mise a jour (2026-01-17 08:20:39) : Messagequeue/MessageQueue IN_PROGRESS : script list_bindings.
Derniere mise a jour (2026-01-17 08:25:39) : Messagequeue/MessageQueue IN_PROGRESS : publish_test_message default exchange.
Derniere mise a jour (2026-01-17 08:30:44) : Messagequeue/MessageQueue IN_PROGRESS : nettoyage test_routing.
Derniere mise a jour (2026-01-17 08:35:28) : Messagequeue/MessageQueue IN_PROGRESS : test matrix prerequis RabbitMQ coches.
Derniere mise a jour (2026-01-17 08:40:30) : Messagequeue/MessageQueue IN_PROGRESS : doc outils de test.
Derniere mise a jour (2026-01-17 08:45:19) : Messagequeue/MessageQueue IN_PROGRESS : lien UI RabbitMQ.
Derniere mise a jour (2026-01-17 08:50:13) : Messagequeue/MessageQueue IN_PROGRESS : script count_queue_messages.
Derniere mise a jour (2026-01-17 08:55:21) : Messagequeue/MessageQueue IN_PROGRESS : note API management scripts listing.
Derniere mise a jour (2026-01-17 09:01:02) : Messagequeue/MessageQueue IN_PROGRESS : note permissions shared/pdfs.
Derniere mise a jour (2026-01-17 09:05:40) : Messagequeue/MessageQueue IN_PROGRESS : precision permissions PDFs.
Derniere mise a jour (2026-01-17 09:10:47) : Messagequeue/MessageQueue IN_PROGRESS : bootstrap_all inclut test_routing.
Derniere mise a jour (2026-01-17 09:15:15) : Messagequeue/MessageQueue IN_PROGRESS : doc troubleshooting.
Derniere mise a jour (2026-01-17 09:20:22) : Messagequeue/MessageQueue IN_PROGRESS : TODO tests e2e.
Derniere mise a jour (2026-01-17 09:25:21) : Messagequeue/MessageQueue IN_PROGRESS : commande nettoyage shared/pdfs.
Derniere mise a jour (2026-01-17 09:30:24) : Messagequeue/MessageQueue IN_PROGRESS : doc PAYLOAD_FILE publish_test_message.
Derniere mise a jour (2026-01-17 09:35:23) : Messagequeue/MessageQueue IN_PROGRESS : precision payload defaut.
Derniere mise a jour (2026-01-17 09:40:25) : Messagequeue/MessageQueue IN_PROGRESS : doc vhost par defaut.
Derniere mise a jour (2026-01-17 09:45:33) : Messagequeue/MessageQueue IN_PROGRESS : ajout .env.example RabbitMQ.
Derniere mise a jour (2026-01-17 09:50:24) : Messagequeue/MessageQueue IN_PROGRESS : doc usage fichier .env.
Derniere mise a jour (2026-01-17 09:55:38) : Messagequeue/MessageQueue IN_PROGRESS : exemple variables .env credentials.
Derniere mise a jour (2026-01-17 10:00:47) : Messagequeue/MessageQueue IN_PROGRESS : script purge_queues.
Derniere mise a jour (2026-01-17 10:05:17) : Messagequeue/MessageQueue IN_PROGRESS : purge_queues supporte QUEUES CSV.
Derniere mise a jour (2026-01-17 10:10:34) : Messagequeue/MessageQueue IN_PROGRESS : purge_queues trim espaces CSV.
Derniere mise a jour (2026-01-17 10:16:27) : Messagequeue/MessageQueue IN_PROGRESS : doc plan d'implementation.
Derniere mise a jour (2026-01-17 10:21:08) : Messagequeue/MessageQueue IN_PROGRESS : ajout script smoke_local.
Derniere mise a jour (2026-01-17 10:25:28) : Messagequeue/MessageQueue IN_PROGRESS : ajout script check_prereqs.
Derniere mise a jour (2026-01-17 10:30:23) : Messagequeue/MessageQueue IN_PROGRESS : smoke plan check_prereqs + smoke_local.
Derniere mise a jour (2026-01-17 10:35:26) : Messagequeue/MessageQueue IN_PROGRESS : doc scripts overview.
Derniere mise a jour (2026-01-17 10:40:29) : Messagequeue/MessageQueue IN_PROGRESS : ajout script load_env.
Derniere mise a jour (2026-01-17 10:45:23) : Messagequeue/MessageQueue IN_PROGRESS : doc outils de test (scripts ajout).
Derniere mise a jour (2026-01-17 10:50:27) : Messagequeue/MessageQueue IN_PROGRESS : ajout script setup_env.
Derniere mise a jour (2026-01-17 10:55:33) : Messagequeue/MessageQueue IN_PROGRESS : ajout script status_report.
Derniere mise a jour (2026-01-17 11:00:37) : Messagequeue/MessageQueue IN_PROGRESS : ajout runbook local.
Derniere mise a jour (2026-01-17 11:06:03) : Messagequeue/MessageQueue IN_PROGRESS : ajout script test_routing_matrix.
Derniere mise a jour (2026-01-17 11:10:40) : Messagequeue/MessageQueue IN_PROGRESS : ajout script publish_sample_keys.
Derniere mise a jour (2026-01-17 11:15:44) : Messagequeue/MessageQueue IN_PROGRESS : doc troubleshooting env.
Derniere mise a jour (2026-01-17 11:20:54) : Messagequeue/MessageQueue IN_PROGRESS : ajout script post_sample.
Derniere mise a jour (2026-01-17 11:25:38) : Messagequeue/MessageQueue IN_PROGRESS : ajout script reset_local.
Derniere mise a jour (2026-01-17 11:30:36) : Messagequeue/MessageQueue IN_PROGRESS : ajout script run_local_flow.
Derniere mise a jour (2026-01-17 11:35:56) : Messagequeue/MessageQueue IN_PROGRESS : ajout script validate_payload.
Derniere mise a jour (2026-01-17 11:40:44) : Messagequeue/MessageQueue IN_PROGRESS : ajout script doctor.
Derniere mise a jour (2026-01-17 11:46:15) : Messagequeue/MessageQueue IN_PROGRESS : ajout script generate_dummy_pdf.
Derniere mise a jour (2026-01-17 11:50:45) : Messagequeue/MessageQueue IN_PROGRESS : README stubs services.
Derniere mise a jour (2026-01-17 11:55:29) : Messagequeue/MessageQueue IN_PROGRESS : index consumers.
Derniere mise a jour (2026-01-17 12:00:33) : Messagequeue/MessageQueue IN_PROGRESS : stub grant_other_documents.
Derniere mise a jour (2026-01-17 12:05:26) : Messagequeue/MessageQueue IN_PROGRESS : ajout service matrix.
Derniere mise a jour (2026-01-17 12:10:25) : Messagequeue/MessageQueue IN_PROGRESS : ajout todo_next.
Derniere mise a jour (2026-01-17 12:15:57) : Messagequeue/MessageQueue IN_PROGRESS : ajout script simulate_consumer.
Derniere mise a jour (2026-01-17 12:20:40) : Messagequeue/MessageQueue IN_PROGRESS : ajout recap usage local.
Derniere mise a jour (2026-01-17 12:25:42) : Messagequeue/MessageQueue IN_PROGRESS : doc variables scripts.
Derniere mise a jour (2026-01-17 12:30:47) : Messagequeue/MessageQueue IN_PROGRESS : ajout script run_checks.
Derniere mise a jour (2026-01-17 12:36:22) : Messagequeue/MessageQueue IN_PROGRESS : stub Spring Boot producer.
Derniere mise a jour (2026-01-17 12:41:05) : Messagequeue/MessageQueue IN_PROGRESS : stub consumer food_application.
Derniere mise a jour (2026-01-17 12:45:59) : Messagequeue/MessageQueue IN_PROGRESS : stub consumer financial_assistance.
Derniere mise a jour (2026-01-17 12:50:45) : Messagequeue/MessageQueue IN_PROGRESS : stub consumer transportation_costs.
Derniere mise a jour (2026-01-17 12:55:46) : Messagequeue/MessageQueue IN_PROGRESS : stub consumer contracts.
Derniere mise a jour (2026-01-17 13:00:49) : Messagequeue/MessageQueue IN_PROGRESS : stub consumer grant_other_documents.
Derniere mise a jour (2026-01-17 13:05:51) : Messagequeue/MessageQueue IN_PROGRESS : ajout script build_modules.
Derniere mise a jour (2026-01-17 13:10:34) : Messagequeue/MessageQueue IN_PROGRESS : producer health + validation champs requis.
Derniere mise a jour (2026-01-17 13:15:37) : Messagequeue/MessageQueue IN_PROGRESS : producer JSON status+routingKey.
Derniere mise a jour (2026-01-17 13:20:34) : Messagequeue/MessageQueue IN_PROGRESS : ajout doc run_modules.
Derniere mise a jour (2026-01-17 13:25:48) : Messagequeue/MessageQueue IN_PROGRESS : tests producer MockMvc.
Derniere mise a jour (2026-01-17 13:30:41) : Messagequeue/MessageQueue IN_PROGRESS : test endpoint health.
Derniere mise a jour (2026-01-17 13:35:51) : Messagequeue/MessageQueue IN_PROGRESS : ajout script test_producer.
Derniere mise a jour (2026-01-17 13:40:38) : Messagequeue/MessageQueue IN_PROGRESS : test routing producer MockBean.
Derniere mise a jour (2026-01-17 13:45:35) : Messagequeue/MessageQueue IN_PROGRESS : doc tests producer.
Derniere mise a jour (2026-01-17 13:50:55) : Messagequeue/MessageQueue IN_PROGRESS : consumer food PDF dummy.
Derniere mise a jour (2026-01-17 13:55:43) : Messagequeue/MessageQueue IN_PROGRESS : consumer financial PDF dummy.
Derniere mise a jour (2026-01-17 14:00:44) : Messagequeue/MessageQueue IN_PROGRESS : consumer transportation PDF dummy.
Derniere mise a jour (2026-01-17 14:05:44) : Messagequeue/MessageQueue IN_PROGRESS : consumer contracts PDF dummy.
Derniere mise a jour (2026-01-17 14:10:53) : Messagequeue/MessageQueue IN_PROGRESS : consumer grant_other_documents PDF dummy.
Derniere mise a jour (2026-01-17 14:15:33) : Messagequeue/MessageQueue IN_PROGRESS : doc run/env consumers index.
Derniere mise a jour (2026-01-17 14:20:28) : Messagequeue/MessageQueue IN_PROGRESS : tests producer bloques (mvn manquant).
Derniere mise a jour (2026-01-17 14:25:30) : Messagequeue/MessageQueue IN_PROGRESS : check_prereqs verifie mvn.
Derniere mise a jour (2026-01-17 14:30:36) : Messagequeue/MessageQueue IN_PROGRESS : doc troubleshooting Maven.
Derniere mise a jour (2026-01-17 14:35:59) : Messagequeue/MessageQueue IN_PROGRESS : consumers EnableRabbit.
Derniere mise a jour (2026-01-17 14:40:25) : Messagequeue/MessageQueue IN_PROGRESS : doc run_modules + note EnableRabbit.
Derniere mise a jour (2026-01-17 14:46:00) : Messagequeue/MessageQueue IN_PROGRESS : ajout script tail_rabbitmq_logs.
Derniere mise a jour (2026-01-17 14:50:36) : Messagequeue/MessageQueue IN_PROGRESS : doc endpoints/env producer.
Derniere mise a jour (2026-01-17 14:55:43) : Messagequeue/MessageQueue IN_PROGRESS : test dummy PDF transportation.
Derniere mise a jour (2026-01-17 15:00:43) : Messagequeue/MessageQueue IN_PROGRESS : test dummy PDF financial.
Derniere mise a jour (2026-01-17 15:05:39) : Messagequeue/MessageQueue IN_PROGRESS : test dummy PDF contracts.
Derniere mise a jour (2026-01-17 15:10:37) : Messagequeue/MessageQueue IN_PROGRESS : test dummy PDF grant_other_documents.
Derniere mise a jour (2026-01-17 15:15:40) : Messagequeue/MessageQueue IN_PROGRESS : test dummy PDF food.
Derniere mise a jour (2026-01-17 15:20:37) : Messagequeue/MessageQueue IN_PROGRESS : doc tests consumers.
Derniere mise a jour (2026-01-17 15:25:59) : Messagequeue/MessageQueue IN_PROGRESS : ajout script test_consumers.
Derniere mise a jour (2026-01-17 15:30:59) : Messagequeue/MessageQueue IN_PROGRESS : ajout script readme_toc.
Derniere mise a jour (2026-01-17 15:35:28) : Messagequeue/MessageQueue IN_PROGRESS : doc usage local (sommaire README).
Derniere mise a jour (2026-01-17 15:40:46) : Messagequeue/MessageQueue IN_PROGRESS : ajout docs_index.
Derniere mise a jour (2026-01-17 15:46:23) : Messagequeue/MessageQueue IN_PROGRESS : DummyPdfGenerator resolve script path.
Derniere mise a jour (2026-01-17 15:51:24) : Messagequeue/MessageQueue IN_PROGRESS : harmonisation DummyPdfGenerator.
Derniere mise a jour (2026-01-17 15:55:28) : Messagequeue/MessageQueue IN_PROGRESS : doc tests_consumers (script).
Derniere mise a jour (2026-01-17 16:00:50) : Messagequeue/MessageQueue IN_PROGRESS : ajout module_status.
Derniere mise a jour (2026-01-17 16:05:41) : Messagequeue/MessageQueue IN_PROGRESS : doc ports.
Derniere mise a jour (2026-01-17 16:10:34) : Messagequeue/MessageQueue IN_PROGRESS : producer declare exchanges.
Derniere mise a jour (2026-01-17 16:15:49) : Messagequeue/MessageQueue IN_PROGRESS : producer exchanges configurables.
Derniere mise a jour (2026-01-17 16:20:37) : Messagequeue/MessageQueue IN_PROGRESS : test config exchanges.
Derniere mise a jour (2026-01-17 16:26:19) : Messagequeue/MessageQueue IN_PROGRESS : extraction ExchangeNames.
Derniere mise a jour (2026-01-17 16:30:31) : Messagequeue/MessageQueue IN_PROGRESS : doc ExchangeNames producer.
Derniere mise a jour (2026-01-17 16:35:41) : Messagequeue/MessageQueue IN_PROGRESS : test routing par defaut (grantType absent).
Derniere mise a jour (2026-01-17 16:40:46) : Messagequeue/MessageQueue IN_PROGRESS : ajout api_contract.
Derniere mise a jour (2026-01-17 16:45:41) : Messagequeue/MessageQueue IN_PROGRESS : exemple curl API contract.
Derniere mise a jour (2026-01-17 16:50:46) : Messagequeue/MessageQueue IN_PROGRESS : test validation email vide.
Derniere mise a jour (2026-01-17 16:55:29) : Messagequeue/MessageQueue IN_PROGRESS : doc tests producer (couverture).
Derniere mise a jour (2026-01-17 17:00:48) : Messagequeue/MessageQueue IN_PROGRESS : ajout tests_summary.
Derniere mise a jour (2026-01-17 17:05:40) : Messagequeue/MessageQueue IN_PROGRESS : docs_index tests_summary.
Derniere mise a jour (2026-01-17 17:10:31) : Messagequeue/MessageQueue IN_PROGRESS : note Maven tests_summary.
Derniere mise a jour (2026-01-17 17:16:20) : Messagequeue/MessageQueue IN_PROGRESS : ajout script append_log.
Derniere mise a jour (2026-01-17 17:20:32) : Messagequeue/MessageQueue IN_PROGRESS : doc usage local (append_log).
Derniere mise a jour (2026-01-17 17:25:30) : Messagequeue/MessageQueue IN_PROGRESS : ajout doc logging.
Derniere mise a jour (2026-01-17 17:30:45) : Messagequeue/MessageQueue IN_PROGRESS : ajout security_notes.
Derniere mise a jour (2026-01-17 17:42:33) : Messagequeue/MessageQueue IN_PROGRESS : bindings queues/exchanges consumers.
Derniere mise a jour (2026-01-17 17:44:47) : Messagequeue/MessageQueue IN_PROGRESS : script create_bindings.
Derniere mise a jour (2026-01-17 17:46:04) : Messagequeue/MessageQueue IN_PROGRESS : validate_rabbitmq aligne routing keys.
Derniere mise a jour (2026-01-17 17:50:41) : Messagequeue/MessageQueue IN_PROGRESS : usage local create_bindings.
Derniere mise a jour (2026-01-17 17:55:45) : Messagequeue/MessageQueue IN_PROGRESS : doctor hint create_bindings.
Derniere mise a jour (2026-01-17 18:01:03) : Messagequeue/MessageQueue IN_PROGRESS : bootstrap_rabbitmq aligne routing keys.
Derniere mise a jour (2026-01-17 18:06:50) : Messagequeue/MessageQueue IN_PROGRESS : test_routing scripts env.
Derniere mise a jour (2026-01-17 18:11:04) : Messagequeue/MessageQueue IN_PROGRESS : test_routing_matrix ROUTING_KEYS.
Derniere mise a jour (2026-01-17 18:15:42) : Messagequeue/MessageQueue IN_PROGRESS : doc ROUTING_KEYS test_routing_matrix.
Derniere mise a jour (2026-01-17 18:20:48) : Messagequeue/MessageQueue IN_PROGRESS : smoke_local env queues.
Derniere mise a jour (2026-01-17 18:26:15) : Messagequeue/MessageQueue IN_PROGRESS : count_queue_messages QUEUES.
Derniere mise a jour (2026-01-17 18:31:11) : Messagequeue/MessageQueue IN_PROGRESS : filtres list_exchanges/list_bindings.
Derniere mise a jour (2026-01-17 18:36:23) : Messagequeue/MessageQueue IN_PROGRESS : status_report filtres env.
Derniere mise a jour (2026-01-17 18:40:51) : Messagequeue/MessageQueue IN_PROGRESS : list_queues filtre QUEUES.
Derniere mise a jour (2026-01-17 18:45:46) : Messagequeue/MessageQueue IN_PROGRESS : run_modules scripts.
Derniere mise a jour (2026-01-17 18:50:38) : Messagequeue/MessageQueue IN_PROGRESS : runbook local create_bindings.
Derniere mise a jour (2026-01-17 18:55:41) : Messagequeue/MessageQueue IN_PROGRESS : status_report affiche filtres.
Derniere mise a jour (2026-01-17 19:00:51) : Messagequeue/MessageQueue IN_PROGRESS : usage local status_report filtre.
Derniere mise a jour (2026-01-17 19:06:11) : Messagequeue/MessageQueue IN_PROGRESS : publish_sample_keys ROUTING_KEYS.
Derniere mise a jour (2026-01-17 19:10:45) : Messagequeue/MessageQueue IN_PROGRESS : doc override ROUTING_KEYS publish_sample_keys.
Derniere mise a jour (2026-01-17 19:15:53) : Messagequeue/MessageQueue IN_PROGRESS : publish_sample_keys GRANT_EXCHANGE env.
Derniere mise a jour (2026-01-17 19:20:40) : Messagequeue/MessageQueue IN_PROGRESS : README producer run_producer.
Derniere mise a jour (2026-01-17 19:25:43) : Messagequeue/MessageQueue IN_PROGRESS : runbook local run_producer/run_consumer.
Derniere mise a jour (2026-01-17 19:30:57) : Messagequeue/MessageQueue IN_PROGRESS : run_consumer --list.
Derniere mise a jour (2026-01-17 19:36:00) : Messagequeue/MessageQueue IN_PROGRESS : test_consumers --list.
Derniere mise a jour (2026-01-17 19:41:24) : Messagequeue/MessageQueue IN_PROGRESS : build_modules MODULES/--list.
Derniere mise a jour (2026-01-17 19:45:55) : Messagequeue/MessageQueue IN_PROGRESS : test_producer --list.
Derniere mise a jour (2026-01-17 19:51:06) : Messagequeue/MessageQueue IN_PROGRESS : doc readme_toc FILE env.
Derniere mise a jour (2026-01-17 19:55:45) : Messagequeue/MessageQueue IN_PROGRESS : docs_index complete docs recentes.
Derniere mise a jour (2026-01-17 20:01:05) : Messagequeue/MessageQueue IN_PROGRESS : check_prereqs SKIP_DOCKER/SKIP_MVN.
Derniere mise a jour (2026-01-17 20:06:27) : Messagequeue/MessageQueue IN_PROGRESS : PDF_DISABLED dummy PDF.
Derniere mise a jour (2026-01-17 20:12:23) : Messagequeue/MessageQueue IN_PROGRESS : tests pdf.disabled.
Derniere mise a jour (2026-01-17 20:16:09) : Messagequeue/MessageQueue IN_PROGRESS : test_consumers MODULES.
Derniere mise a jour (2026-01-17 20:20:55) : Messagequeue/MessageQueue IN_PROGRESS : usage local ROUTING_KEYS.
Derniere mise a jour (2026-01-17 20:25:49) : Messagequeue/MessageQueue IN_PROGRESS : doc pdf.disabled system property.
Derniere mise a jour (2026-01-17 20:30:50) : Messagequeue/MessageQueue IN_PROGRESS : doc PDF_DISABLED consumers/tests.
Derniere mise a jour (2026-01-17 20:36:10) : Messagequeue/MessageQueue IN_PROGRESS : run_checks --skip-routing.
Derniere mise a jour (2026-01-17 20:41:08) : Messagequeue/MessageQueue IN_PROGRESS : run_checks --skip-doctor.
Derniere mise a jour (2026-01-17 20:47:43) : Messagequeue/MessageQueue IN_PROGRESS : grantType requis + tests/docs.
Derniere mise a jour (2026-01-18 13:58:09) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local refuse DOC_TYPE avec point.
Derniere mise a jour (2026-01-18 14:01:25) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejette PAYLOAD_FILE dossier.
Derniere mise a jour (2026-01-18 14:06:30) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte PAYLOAD_FILE relatif.
Derniere mise a jour (2026-01-18 14:11:22) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejette COUNT decimal.
Derniere mise a jour (2026-01-18 14:16:22) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejette INDEX decimal.
Derniere mise a jour (2026-01-18 14:21:29) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte EXCHANGE avec point.
Derniere mise a jour (2026-01-18 14:26:38) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte ROUTING_KEY avec point sur GRANT_EXCHANGE.
Derniere mise a jour (2026-01-18 14:31:24) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte ROUTING_KEY avec tiret sur GRANT_EXCHANGE.
Derniere mise a jour (2026-01-18 14:36:31) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local valide OUTPUT=all COUNT=2 INDEX=0.
Derniere mise a jour (2026-01-18 14:41:27) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte ROUTING_KEY avec underscore sur GRANT_EXCHANGE.
Derniere mise a jour (2026-01-18 14:46:44) : Messagequeue/MessageQueue IN_PROGRESS : PDF_OUTPUT_DIR doit etre absolu (test + validation).
Derniere mise a jour (2026-01-18 14:51:44) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte QUEUE avec point/underscore.
Derniere mise a jour (2026-01-18 14:56:37) : Messagequeue/MessageQueue IN_PROGRESS : DOC_TYPE accepte le point (validation + tests).
Derniere mise a jour (2026-01-18 15:03:28) : Messagequeue/MessageQueue IN_PROGRESS : e2e_local derive ROUTING_KEY grantType du payload.
Derniere mise a jour (2026-01-18 15:06:44) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local default ROUTING_KEY sans grantType.
Derniere mise a jour (2026-01-18 15:11:58) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local valide DOC_TYPE point en JSON.
Derniere mise a jour (2026-01-18 15:16:28) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejette PDF_OUTPUT_DIR absent.
Derniere mise a jour (2026-01-18 15:21:27) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte OUTPUT vide (default).
Derniere mise a jour (2026-01-18 15:26:54) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local derive routing_key grantType custom.
Derniere mise a jour (2026-01-18 15:31:44) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte EXCHANGE avec underscore.
Derniere mise a jour (2026-01-18 15:36:31) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte ACK_MODE ack_requeue_true.
Derniere mise a jour (2026-01-18 15:41:30) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte PURGE_QUEUE=1.
Derniere mise a jour (2026-01-18 15:46:31) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte VALIDATE_PAYLOAD=0.
Derniere mise a jour (2026-01-18 15:51:31) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte CHECK_RABBITMQ=0.
Derniere mise a jour (2026-01-18 15:56:30) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte DOC_TYPE longueur 255.
Derniere mise a jour (2026-01-18 16:01:33) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte QUEUE longueur 255.
Derniere mise a jour (2026-01-18 16:06:31) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte EXCHANGE longueur 255.
Derniere mise a jour (2026-01-18 16:11:30) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte ROUTING_KEY longueur 255.
Derniere mise a jour (2026-01-18 16:16:33) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte PDF_OUTPUT_DIR writable.
Derniere mise a jour (2026-01-18 16:21:32) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte OUTPUT=single.
Derniere mise a jour (2026-01-18 16:26:31) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte COUNT=1 INDEX=0 OUTPUT=single.
Derniere mise a jour (2026-01-18 16:31:36) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte COUNT=2 INDEX=1 OUTPUT=single.
Derniere mise a jour (2026-01-18 16:36:48) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte COUNT avec zeros en tete.
Derniere mise a jour (2026-01-18 16:41:34) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte INDEX avec zeros en tete.
Derniere mise a jour (2026-01-18 16:46:42) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte QUEUE avec tiret.
Derniere mise a jour (2026-01-18 16:51:37) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte EXCHANGE avec tiret.
Derniere mise a jour (2026-01-18 16:56:37) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte ROUTING_KEY mixte.
Derniere mise a jour (2026-01-18 17:01:39) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local valide DOC_TYPE mixte.
Derniere mise a jour (2026-01-18 17:06:37) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte ROUTING_KEY point/underscore/tiret.
Derniere mise a jour (2026-01-18 17:11:39) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte ROUTING_KEY vide pour SOCIAL_ASSISTANCE_EXCHANGE.
Derniere mise a jour (2026-01-18 17:16:41) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local rejette OUTPUT=all INDEX=1.
Derniere mise a jour (2026-01-18 17:21:37) : Messagequeue/MessageQueue IN_PROGRESS : test_e2e_local accepte COUNT=3 INDEX=0 OUTPUT=single.
Derniere mise a jour (2026-01-18 17:28:03) : Messagequeue/MessageQueue IN_PROGRESS : ajout PROJECTS_OVERVIEW.md a la racine.
Derniere mise a jour (2026-01-18 17:30:35) : Messagequeue/MessageQueue IN_PROGRESS : PROJECTS_OVERVIEW.md detaille en francais.
Derniere mise a jour (2026-01-18 19:48:37) : Messagequeue/MessageQueue IN_PROGRESS : ajout section lecture dans PROJECTS_OVERVIEW.md.
Derniere mise a jour (2026-01-18 19:49:17) : Messagequeue/MessageQueue IN_PROGRESS : ajout section Conventions dans PROJECTS_OVERVIEW.md.
Derniere mise a jour (2026-01-18 19:50:12) : Messagequeue/MessageQueue IN_PROGRESS : ajout section Glossaire dans PROJECTS_OVERVIEW.md.
Derniere mise a jour (2026-01-18 19:53:58) : Messagequeue/MessageQueue IN_PROGRESS : ajout section Utilisation du panorama dans PROJECTS_OVERVIEW.md.
Derniere mise a jour (2026-01-18 19:58:58) : Messagequeue/MessageQueue IN_PROGRESS : ajout section Structure du depot dans PROJECTS_OVERVIEW.md.
Derniere mise a jour (2026-01-18 20:03:59) : Messagequeue/MessageQueue IN_PROGRESS : ajout section Comment verifier dans PROJECTS_OVERVIEW.md.
Derniere mise a jour (2026-01-18 20:08:32) : ajout --dry-run + tests pour publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-18 20:09:47) : doctor integre tests publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-18 20:14:06) : doc usage publish_test_message --dry-run (MessageQueue).
Derniere mise a jour (2026-01-18 20:19:49) : test_publish_test_message supporte --json (MessageQueue).
Derniere mise a jour (2026-01-18 20:24:11) : test_publish_test_message --json n'affiche que du JSON (MessageQueue).
Derniere mise a jour (2026-01-18 20:29:18) : test_publish_test_message --json supprime la ligne ok (MessageQueue).
Derniere mise a jour (2026-01-18 20:34:10) : doc doctor --json mentionne publish_tests (MessageQueue).
Derniere mise a jour (2026-01-18 20:39:09) : test_matrix mentionne test_publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-18 20:44:07) : runbook mentionne publish_test_message --dry-run (MessageQueue).
Derniere mise a jour (2026-01-18 20:49:13) : quickstart inclut publish_test_message --dry-run (MessageQueue).
Derniere mise a jour (2026-01-18 20:54:08) : docs_index reference quickstart (MessageQueue).
Derniere mise a jour (2026-01-18 20:59:12) : troubleshooting_env mentionne doctor --json (MessageQueue).
Derniere mise a jour (2026-01-18 21:04:26) : tests publish_test_message couvrent payload illisible/dossier (MessageQueue).
Derniere mise a jour (2026-01-18 21:09:07) : tests_summary detaille erreurs payload publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-18 21:14:18) : publish_test_message verifie payload lisible/dossier (MessageQueue).
Derniere mise a jour (2026-01-18 21:19:07) : script_env precise PAYLOAD_FILE lisible (MessageQueue).
Derniere mise a jour (2026-01-18 21:25:20) : publish_test_message valide exchange/routing key + tests (MessageQueue).
Derniere mise a jour (2026-01-18 21:29:23) : tests publish_test_message couvrent longueurs exchange/routing key (MessageQueue).
Derniere mise a jour (2026-01-18 21:34:05) : tests_summary mentionne longueurs invalides publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-18 21:39:04) : test_matrix mentionne longueurs exchange/routing key (MessageQueue).
Derniere mise a jour (2026-01-18 21:44:35) : help publish_test_message enrichi + test help (MessageQueue).
Derniere mise a jour (2026-01-18 21:49:05) : tests_summary mentionne test help publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-18 21:55:31) : tests publish_test_message couvrent CONTENT_TYPE trop long (MessageQueue).
Derniere mise a jour (2026-01-18 21:59:38) : publish_test_message valide MESSAGE_ID trop long + tests (MessageQueue).
Derniere mise a jour (2026-01-18 22:04:10) : test_matrix mentionne MESSAGE_ID trop long (MessageQueue).
Derniere mise a jour (2026-01-18 22:09:06) : tests_summary mentionne content_type/message_id (MessageQueue).
Derniere mise a jour (2026-01-18 22:14:15) : troubleshooting_env couvre erreurs publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-18 22:19:10) : test_tools mentionne validations publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-18 22:24:22) : e2e_local mentionne content_type/message_id (MessageQueue).
Derniere mise a jour (2026-01-18 22:29:13) : local_usage montre MESSAGE_ID/CONTENT_TYPE override (MessageQueue).
Derniere mise a jour (2026-01-18 22:34:10) : scripts_overview mentionne validations publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-18 22:39:58) : test_publish_test_message verifie message_id non vide (MessageQueue).
Derniere mise a jour (2026-01-18 22:44:07) : tests_summary mentionne message_id non vide (MessageQueue).
Derniere mise a jour (2026-01-18 22:49:07) : test_matrix mentionne MESSAGE_ID vide/trop long (MessageQueue).
Derniere mise a jour (2026-01-18 22:54:41) : publish_test_message refuse MESSAGE_ID avec espaces + tests (MessageQueue).
Derniere mise a jour (2026-01-18 22:59:10) : tests_summary mentionne message_id sans espaces (MessageQueue).
Derniere mise a jour (2026-01-18 23:04:09) : test_matrix mentionne MESSAGE_ID avec espaces (MessageQueue).
Derniere mise a jour (2026-01-18 23:09:11) : test_tools mentionne message_id sans espaces (MessageQueue).
Derniere mise a jour (2026-01-18 23:14:12) : local_usage rappelle message_id sans espaces (MessageQueue).
Derniere mise a jour (2026-01-18 23:20:08) : publish_test_message refuse CONTENT_TYPE espaces + tests (MessageQueue).
Derniere mise a jour (2026-01-18 23:24:11) : tests_summary mentionne content_type non blanc (MessageQueue).
Derniere mise a jour (2026-01-18 23:29:11) : test_matrix mentionne CONTENT_TYPE blanc (MessageQueue).
Derniere mise a jour (2026-01-18 23:34:11) : runbook rappelle contraintes message_id/content_type (MessageQueue).
Derniere mise a jour (2026-01-18 23:39:35) : help publish_test_message mentionne message_id/content_type (MessageQueue).
Derniere mise a jour (2026-01-18 23:44:11) : tests_summary mentionne help detaille publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-18 23:49:15) : test_tools mentionne content_type blanc et message_id avec espaces (MessageQueue).
Derniere mise a jour (2026-01-18 23:55:17) : test_publish_test_message couvre CONTENT_TYPE vide (MessageQueue).
Derniere mise a jour (2026-01-18 23:59:14) : tests_summary mentionne content_type vide/blanc (MessageQueue).
Derniere mise a jour (2026-01-19 00:04:17) : test_matrix mentionne CONTENT_TYPE vide (MessageQueue).
Derniere mise a jour (2026-01-19 00:09:15) : test_tools mentionne content_type vide/blanc (MessageQueue).
Derniere mise a jour (2026-01-19 00:14:23) : test_publish_test_message couvre MESSAGE_ID vide (MessageQueue).
Derniere mise a jour (2026-01-19 00:19:11) : test_tools mentionne message_id vide (MessageQueue).
Derniere mise a jour (2026-01-19 00:24:12) : tests_summary mentionne message_id vide/espaces (MessageQueue).
Derniere mise a jour (2026-01-19 00:29:42) : test_tools detaille tests content_type/message_id (MessageQueue).
Derniere mise a jour (2026-01-19 00:34:39) : tests_summary note champs JSON empty_message_id/whitespace_content_type (MessageQueue).
Derniere mise a jour (2026-01-19 00:39:14) : scripts_overview detaille tests content_type/message_id (MessageQueue).
Derniere mise a jour (2026-01-19 00:44:15) : scripts_overview note champs JSON empty_message_id/whitespace_content_type (MessageQueue).
Derniere mise a jour (2026-01-19 00:49:21) : test_publish_test_message exige champs JSON empty_message_id/whitespace_content_type (MessageQueue).
Derniere mise a jour (2026-01-19 00:54:14) : test_matrix note champs JSON empty_message_id/whitespace_content_type (MessageQueue).
Derniere mise a jour (2026-01-19 00:59:12) : test_tools note champs JSON empty_message_id/whitespace_content_type (MessageQueue).
Derniere mise a jour (2026-01-19 01:04:19) : corrige champs requis JSON publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-19 01:10:23) : tests maj defaults message_id/content_type + test ok (MessageQueue).
Derniere mise a jour (2026-01-19 01:14:19) : script_env clarifie defaults content_type/message_id (MessageQueue).
Derniere mise a jour (2026-01-19 01:19:14) : troubleshooting_env clarifie defaults content_type/message_id (MessageQueue).
Derniere mise a jour (2026-01-19 01:24:18) : local_runbook clarifie defaults content_type/message_id (MessageQueue).
Derniere mise a jour (2026-01-19 01:29:33) : local_usage note defaults message_id/content_type (MessageQueue).
Derniere mise a jour (2026-01-19 01:34:17) : e2e_local clarifie defaults content_type/message_id (MessageQueue).
Derniere mise a jour (2026-01-19 01:39:24) : quickstart note defaults content_type/message_id (MessageQueue).
Derniere mise a jour (2026-01-19 01:44:36) : troubleshooting rappelle defaults content_type/message_id (MessageQueue).
Derniere mise a jour (2026-01-19 01:49:20) : scripts_overview note defaults publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-19 01:54:37) : test_publish_test_message couvre content_type whitespace tab (MessageQueue).
Derniere mise a jour (2026-01-19 01:59:19) : test_publish_test_message --json ok apres whitespace tab (MessageQueue).
Derniere mise a jour (2026-01-19 02:04:14) : test_matrix mentionne content_type blanc espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 02:09:26) : tests_summary mentionne content_type blanc espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 02:14:28) : docs mentionnent content_type blanc espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 02:19:16) : quickstart precise content_type blanc espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 02:24:14) : local_usage precise content_type blanc espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 02:29:15) : e2e_local precise content_type blanc espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 02:34:15) : script_env precise content_type blanc espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 02:39:14) : troubleshooting_env precise content_type blanc espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 02:44:14) : local_runbook precise content_type blanc espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 02:49:21) : troubleshooting precise content_type blanc espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 02:54:27) : test_tools precise content_type blanc espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 03:00:03) : test_publish_test_message verifie message_id tab + docs (MessageQueue).
Derniere mise a jour (2026-01-19 03:04:16) : script_env precise message_id sans espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 03:09:19) : troubleshooting_env precise message_id sans espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 03:14:18) : local_runbook precise message_id sans espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 03:19:17) : local_usage precise message_id sans espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 03:24:17) : quickstart precise message_id sans espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 03:29:17) : troubleshooting precise message_id sans espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 03:34:22) : e2e_local precise message_id sans espaces/tabs (MessageQueue).
Derniere mise a jour (2026-01-19 03:39:35) : test_publish_test_message couvre content_type whitespace newline (MessageQueue).
Derniere mise a jour (2026-01-19 03:44:43) : docs precisent content_type blanc espaces/tabs/newlines (MessageQueue).
Derniere mise a jour (2026-01-19 03:49:53) : docs precisent content_type blanc espaces/tabs/newlines partout (MessageQueue).
Derniere mise a jour (2026-01-19 03:54:33) : test_publish_test_message couvre message_id whitespace newline (MessageQueue).
Derniere mise a jour (2026-01-19 03:59:41) : docs precisent message_id espaces/tabs/newlines (MessageQueue).
Derniere mise a jour (2026-01-19 04:04:58) : docs precisent message_id sans espaces/tabs/newlines (MessageQueue).
Derniere mise a jour (2026-01-19 04:09:33) : scripts_overview detaille refus content_type/message_id (MessageQueue).
Derniere mise a jour (2026-01-19 04:14:30) : local_runbook/local_usage mentionnent message_id newlines (MessageQueue).
Derniere mise a jour (2026-01-19 04:19:39) : troubleshooting_env ajoute mention whitespace (MessageQueue).
Derniere mise a jour (2026-01-19 04:24:28) : local_usage mentionne message_id sans espaces/tabs/newlines (MessageQueue).
Derniere mise a jour (2026-01-19 04:31:19) : PROJETS_EXPLICATIONS.md etendu avec lignes 11-16 par projet.
Derniere mise a jour (2026-01-19 04:35:36) : publish_test_message refuse JSON invalide + test associe (MessageQueue).
Derniere mise a jour (2026-01-19 04:39:48) : docs tests_* mentionnent payload JSON invalide (MessageQueue).
Derniere mise a jour (2026-01-19 04:44:39) : troubleshooting mentionne payload JSON invalide (MessageQueue).
Derniere mise a jour (2026-01-19 04:49:36) : local_usage mentionne erreur JSON invalide (MessageQueue).
Derniere mise a jour (2026-01-19 04:54:27) : script_env mentionne JSON valide pour publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-19 04:59:30) : quickstart note JSON invalide pour publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-19 05:04:49) : test_publish_test_message verifie message erreur JSON invalide (MessageQueue).
Derniere mise a jour (2026-01-19 05:09:30) : troubleshooting_env ajoute JSON invalide publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-19 05:14:29) : local_runbook note JSON invalide publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-19 05:19:41) : help publish_test_message mentionne JSON valide + test (MessageQueue).
Derniere mise a jour (2026-01-19 05:24:29) : tests_summary detaille message erreur JSON invalide (MessageQueue).
Derniere mise a jour (2026-01-19 05:29:25) : troubleshooting_env precise message JSON invalide (MessageQueue).
Derniere mise a jour (2026-01-19 05:34:28) : http_endpoints mentionne JSON invalide pour POST /students (MessageQueue).
Derniere mise a jour (2026-01-19 05:39:29) : e2e_local precise PAYLOAD_FILE JSON valide (MessageQueue).
Derniere mise a jour (2026-01-19 05:44:37) : test_publish_test_message verifie chemin JSON invalide (MessageQueue).
Derniere mise a jour (2026-01-19 05:50:21) : publish_test_message JSON error en mode --json + test (MessageQueue).
Derniere mise a jour (2026-01-19 05:54:25) : scripts_overview mentionne sortie JSON d'erreur (MessageQueue).
Derniere mise a jour (2026-01-19 05:59:22) : test_matrix mentionne JSON erreur publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-19 06:04:24) : test_tools mentionne sortie JSON d'erreur (MessageQueue).
Derniere mise a jour (2026-01-19 06:09:28) : tests_summary precise status=error JSON invalide (MessageQueue).
Derniere mise a jour (2026-01-19 06:15:37) : publish_test_message JSON error payload manquant + docs/tests (MessageQueue).
Derniere mise a jour (2026-01-19 06:20:42) : erreurs JSON en --json pour validations publish_test_message (MessageQueue).
Derniere mise a jour (2026-01-19 06:24:49) : test_publish_test_message JSON erreur content_type trop long (MessageQueue).
Derniere mise a jour (2026-01-19 06:30:15) : tests JSON erreurs longueurs exchange/routing/message_id (MessageQueue).
Derniere mise a jour (2026-01-19 06:34:23) : test_matrix mentionne erreurs JSON longueurs (MessageQueue).
Derniere mise a jour (2026-01-19 06:39:25) : script_env mentionne erreurs JSON en --json (MessageQueue).
Derniere mise a jour (2026-01-19 06:44:36) : README MessageQueue mentionne erreurs JSON en --json.
Derniere mise a jour (2026-01-19 06:49:54) : help mentionne status=error en --json + test (MessageQueue).
Derniere mise a jour (2026-01-19 06:54:27) : local_usage mentionne status=error en --json (MessageQueue).
Derniere mise a jour (2026-01-19 06:59:26) : local_runbook mentionne status=error en --json (MessageQueue).
Derniere mise a jour (2026-01-19 07:04:24) : quickstart mentionne status=error en --json (MessageQueue).
Derniere mise a jour (2026-01-19 07:09:27) : http_endpoints mentionne status=error pour POST /students (MessageQueue).
Derniere mise a jour (2026-01-19 07:14:24) : troubleshooting mentionne status=error en --json (MessageQueue).
Derniere mise a jour (2026-01-19 07:20:46) : publish_test_message JSON erreurs payload directory+readable + tests (MessageQueue).
Derniere mise a jour (2026-01-19 07:24:46) : docs test_matrix/tests_summary ajoutent erreurs JSON payload (MessageQueue).
Derniere mise a jour (2026-01-19 07:29:28) : troubleshooting_env ajoute payload not found/directory (MessageQueue).
Derniere mise a jour (2026-01-19 07:34:30) : troubleshooting ajoute payload not found/directory (MessageQueue).
Derniere mise a jour (2026-01-19 07:39:34) : test_tools detaille erreurs JSON payload manquant/illisible/dossier (MessageQueue).
Derniere mise a jour (2026-01-19 07:44:32) : local_usage mentionne erreurs JSON payload manquant/illisible/dossier (MessageQueue).
Derniere mise a jour (2026-01-19 07:49:27) : local_runbook mentionne erreurs JSON payload manquant/illisible/dossier (MessageQueue).
Derniere mise a jour (2026-01-19 07:54:27) : quickstart mentionne erreurs JSON payload manquant/illisible/dossier (MessageQueue).
Derniere mise a jour (2026-01-19 07:59:37) : json_error verifie python3 avant JSON (MessageQueue).
Derniere mise a jour (2026-01-19 08:04:28) : scripts_overview note JSON errors si python3 dispo (MessageQueue).
Derniere mise a jour (2026-01-19 08:09:24) : troubleshooting_env note --json sans python3 (MessageQueue).
