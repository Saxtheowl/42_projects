# Message Queue

Statut : IN_PROGRESS

Mise à jour (2026-01-25 03:15:00) : test_publish_test_message now checks that every JSON response from publish_test_message includes `pdf_output_dir` and `pdf_output_dir_missing`.
Mise à jour (2026-01-25 03:03:46) : publish_test_message JSON (dry-run ou succès) expose `pdf_output_dir` + `pdf_output_dir_missing` to align with the API contract and tests.
Mise à jour (2026-01-19 14:09:43) : tests_summary recommande précréer PDF_OUTPUT_DIR pour générer le JSON dry-run.
Mise à jour (2026-01-19 15:09:59) : README mentionne `jq '.pdf_output_dir,.pdf_output_dir_missing'` pour inspecter la sortie JSON dry-run.
Mise à jour (2026-01-19 13:54:43) : local_runbook préconise de précréer PDF_OUTPUT_DIR et vérifier pdf_output_dir_missing=0.
Mise à jour (2026-01-19 13:19:47) : local_runbook mentionne le JSON dry-run `pdf_output_dir`.
Mise à jour (2026-01-19 13:10:03) : local_usage mentionne le JSON dry-run `pdf_output_dir`.
Mise à jour (2026-01-19 12:54:36) : e2e_local doc note le chemin PDF dune dry-run.
Mise à jour (2026-01-19 12:44:47) : tests_summary mentionne pdf_output_dir_missing en dry-run.
Mise à jour (2026-01-19 12:40:34) : e2e_local ajoute pdf_output_dir_missing dans la sortie JSON dry-run.
Mise à jour (2026-01-19 12:36:05) : e2e_local accepte un PDF_OUTPUT_DIR absent en dry-run et le cree hors dry-run.
Mise à jour (2026-01-19 12:30:41) : local_usage ajoute un exemple PDF_OUTPUT_DIR pour le dossier de sortie.
Mise à jour (2026-01-19 12:24:51) : tests_summary note PDF_OUTPUT_DIR pour smoke.
Mise à jour (2026-01-19 12:19:40) : e2e_local note PDF_OUTPUT_DIR override.
Mise à jour (2026-01-19 12:14:52) : tests_producer note PDF_OUTPUT_DIR non utilise.
Mise à jour (2026-01-19 12:09:39) : test_tools note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 12:04:50) : tests_consumers note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 11:59:46) : logging note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 11:54:51) : test_matrix note PDF_OUTPUT_DIR pour PDFs.
Mise à jour (2026-01-19 11:49:39) : security_notes ajoute suppression PDFs tests.
Mise à jour (2026-01-19 11:44:37) : module_status note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 11:39:39) : payload_schema note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 11:34:53) : api_contract ajoute PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 11:29:45) : http_endpoints ajoute PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 11:24:33) : local_runbook note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 11:19:35) : local_usage note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 11:14:34) : quickstart note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 11:09:52) : tests_summary note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 11:04:55) : run_modules mention PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 10:59:59) : script_env note PDF_OUTPUT_DIR writable.
Mise à jour (2026-01-19 10:54:34) : implementation_plan note PDF_OUTPUT_DIR writable.
Mise à jour (2026-01-19 10:49:31) : queue_purpose note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 10:44:51) : topology note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 10:40:06) : docs_index note ordre alphabetique.
Mise à jour (2026-01-19 10:34:35) : smoke_plan note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 10:29:51) : consumer_ack note PDF_OUTPUT_DIR writable.
Mise à jour (2026-01-19 10:24:35) : todo_next ajoute mention PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 10:19:36) : tests_summary note nettoyage PDFs consumers.
Mise à jour (2026-01-19 10:14:40) : tests_producer note pas de PDF.
Mise à jour (2026-01-19 10:09:36) : tests_consumers ajoute nettoyage PDFs.
Mise à jour (2026-01-19 10:04:40) : test_tools note nettoyage PDFs dummy.
Mise à jour (2026-01-19 09:59:33) : test_matrix note nettoyage shared/pdfs.
Mise à jour (2026-01-19 09:54:33) : pdf_contents note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 09:49:38) : pdf_naming note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 09:44:34) : services note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 09:39:35) : service_matrix note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 09:34:40) : module_layout note PDF_OUTPUT_DIR.
Mise à jour (2026-01-19 09:29:35) : e2e_local ajoute nettoyage PDFs.
Mise à jour (2026-01-19 09:24:33) : scripts_overview note PDFs e2e_local.
Mise à jour (2026-01-19 09:19:32) : http_endpoints note PDF via consumers.
Mise à jour (2026-01-19 09:14:48) : service_env note PDF_OUTPUT_DIR writable.
Mise à jour (2026-01-19 09:09:38) : sample_routing_keys relie sample_student.json.
Mise à jour (2026-01-19 09:04:38) : ports note PDF output dir.
Mise à jour (2026-01-19 08:59:54) : api_contract note generation PDF via consumers.
Mise à jour (2026-01-19 08:54:29) : security_notes ajoute restriction acces shared.
Mise à jour (2026-01-19 08:49:44) : logging note chemin PDF par defaut.
Mise à jour (2026-01-19 08:44:42) : run_modules note nettoyage PDFs.
Mise à jour (2026-01-19 08:39:35) : local_usage ajoute nettoyage PDFs e2e_local.
Mise à jour (2026-01-24 15:30:00) : tests_consumers note le script scripts/verify_pdf_output_dir.sh (Bash) pour vérifier PDF_OUTPUT_DIR avant d'émettre un publish_test_message.
Mise à jour (2026-01-24 16:20:00) : README explique que `scripts/publish_test_message_with_check.sh` combine la vérification de `verify_pdf_output_dir.sh` avec `publish_test_message.sh`.
Mise à jour (2026-01-24 16:40:00) : README recommande d’appeler `publish_test_message_with_check.sh` plutôt que `publish_test_message.sh` pour les démos/CI afin d’éviter les erreurs PDF_OUTPUT_DIR.
Mise à jour (2026-01-25 03:45:00) : README cite `scripts/verify_publish_pdf_metadata.sh` when describing quickstart to show how the new helper asserts `pdf_output_dir`/`pdf_output_dir_missing`.
Mise à jour (2026-01-24 21:45:00) : README cite `docs/publish_workflow.md`/`docs/quickstart.md` pour montrer la séquence `prepare_pdf_output_dir.sh` → `publish_test_message_with_check.sh` → inspection/cleanup des PDFs et renvoie vers `docs/scripts_overview.md` pour trouver ces scripts.
Mise à jour (2026-01-24 21:10:00) : README encourage maintenant à suivre `docs/publish_workflow.md`/`docs/quickstart.md` qui décrivent la chaîne `prepare_pdf_output_dir.sh` → `publish_test_message_with_check.sh` → `inspect/cleanup_pdf_output_dir.sh` pour garantir un PDF_OUTPUT_DIR prêt et propre avant les runs.
Mise à jour (2026-01-19 08:34:37) : quickstart ajoute nettoyage PDFs.
Mise à jour (2026-01-19 08:29:34) : tests_summary precise prerequis e2e_local.
Mise à jour (2026-01-19 08:24:34) : todo_next detaille e2e/pdf/ci.
Mise à jour (2026-01-19 08:19:37) : module_status detaille etapes PDF reel.
Mise à jour (2026-01-19 08:16:20) : troubleshooting ajoute verification python3 pour --json.
Mise à jour (2026-01-18 13:51:29) : test_e2e_local asserts pdf_output_dir exists when overridden in JSON.

Mise à jour (2026-01-18 13:46:22) : test_e2e_local run after routing_key length check.

Mise à jour (2026-01-18 13:41:27) : test_e2e_local validates routing_key length in JSON.

Mise à jour (2026-01-18 13:36:28) : test_e2e_local validates exchange length in JSON.

Mise à jour (2026-01-18 13:31:29) : test_e2e_local validates doc_type length in JSON.

Mise à jour (2026-01-18 13:26:29) : test_e2e_local validates routing_key regex in JSON.

Mise à jour (2026-01-18 13:21:37) : test_e2e_local validates exchange regex in JSON.

Mise à jour (2026-01-18 13:16:28) : test_e2e_local validates doc_type regex in JSON.

Mise à jour (2026-01-18 13:11:31) : test_e2e_local enforces output=single index<count in JSON.

Mise à jour (2026-01-18 13:06:28) : test_e2e_local validates output values in JSON.

Mise à jour (2026-01-18 13:01:25) : test_e2e_local run repeated; no new change required.

Mise à jour (2026-01-18 12:56:22) : test_e2e_local help text verified after INDEX default fix.

Mise à jour (2026-01-18 12:51:38) : fix test_e2e_local help INDEX default.

Mise à jour (2026-01-18 12:46:26) : test_e2e_local rejects empty status in JSON.

Mise à jour (2026-01-18 12:41:30) : test_e2e_local validates status type in JSON.

Mise à jour (2026-01-18 12:36:23) : test_e2e_local requires routing_key for non-social exchange in JSON.

Mise à jour (2026-01-18 12:31:28) : test_e2e_local enforces absolute pdf_output_dir when overridden in JSON.

Mise à jour (2026-01-18 12:26:42) : test_e2e_local rejects empty exchange string in JSON.

Mise à jour (2026-01-18 12:21:23) : test_e2e_local validates payload_file type in JSON.

Mise à jour (2026-01-18 12:16:22) : test_e2e_local validates ack_mode type in JSON.

Mise à jour (2026-01-18 12:11:20) : test_e2e_local validates purge_queue type in JSON.

Mise à jour (2026-01-18 12:06:20) : test_e2e_local validates check_rabbitmq type in JSON.

Mise à jour (2026-01-18 12:01:19) : test_e2e_local validates validate_payload type in JSON.

Mise à jour (2026-01-18 11:56:21) : test_e2e_local validates output type in JSON.

Mise à jour (2026-01-18 11:51:25) : test_e2e_local validates count/index are strings in JSON.

Mise à jour (2026-01-18 11:46:23) : test_e2e_local validates queue type in JSON.

Mise à jour (2026-01-18 11:41:27) : test_e2e_local validates doc_type type in JSON.

Mise à jour (2026-01-18 11:36:21) : test_e2e_local validates pdf_output_dir type in JSON.

Mise à jour (2026-01-18 11:31:19) : test_e2e_local validates exchange type in JSON.

Mise à jour (2026-01-18 11:26:41) : test_e2e_local validates routing_key type in JSON.

Mise à jour (2026-01-18 11:21:21) : test_e2e_local checks social exchange inference for food_application.

Mise à jour (2026-01-18 11:16:21) : test_e2e_local checks social exchange inference for transportation_costs_application.

Mise à jour (2026-01-18 11:11:29) : test_e2e_local checks social exchange inference for financial_assistance_application.

Mise à jour (2026-01-18 11:06:16) : test_e2e_local asserts payload_file non-empty in JSON.

Mise à jour (2026-01-18 11:01:20) : test_e2e_local asserts payload_file is readable in JSON.

Mise à jour (2026-01-18 10:56:24) : test_e2e_local asserts payload_file exists on disk in JSON.

Mise à jour (2026-01-18 10:51:22) : test_e2e_local asserts payload_file ends with .json in JSON.

Mise à jour (2026-01-18 10:46:21) : test_e2e_local verifies purge_queue default to 0 in JSON.

Mise à jour (2026-01-18 10:41:19) : test_e2e_local verifies check_rabbitmq default to 1 in JSON.

Mise à jour (2026-01-18 10:36:20) : test_e2e_local verifies validate_payload default to 1 in JSON.

Mise à jour (2026-01-18 10:31:17) : test_e2e_local verifies index default to 0 in JSON.

Mise à jour (2026-01-18 10:26:16) : test_e2e_local verifies count default to 1 in JSON.

Mise à jour (2026-01-18 10:21:20) : test_e2e_local verifies output default to single in JSON.

Mise à jour (2026-01-18 10:16:17) : test_e2e_local verifies ack_mode override in JSON.

Mise à jour (2026-01-18 10:11:16) : test_e2e_local verifies default ack_mode in JSON.

Mise à jour (2026-01-18 10:06:21) : test_e2e_local asserts PDF_OUTPUT_DIR override is absolute.

Mise à jour (2026-01-18 10:01:13) : test_e2e_local enforces output=all count/index in JSON validation.

Mise à jour (2026-01-18 09:56:44) : fix duplicate pdf_output_dir override test block.

Mise à jour (2026-01-18 09:51:30) : test_e2e_local checks pdf_output_dir override in JSON.

Mise à jour (2026-01-18 09:46:13) : test_e2e_local asserts default payload_file path in JSON.

Mise à jour (2026-01-18 09:41:16) : test_e2e_local asserts payload_file is absolute under ROOT_DIR.

Mise à jour (2026-01-18 09:36:17) : test_e2e_local validates default pdf_output_dir in JSON.

Mise à jour (2026-01-18 09:31:16) : test_e2e_local validates GRANT_EXCHANGE inference for grant_contracts.

Mise à jour (2026-01-18 09:26:15) : doc e2e_local JSON mention check_rabbitmq field.

Mise à jour (2026-01-18 09:21:14) : test_e2e_local validates check_rabbitmq values in JSON.

Mise à jour (2026-01-18 09:16:10) : test_e2e_local requires check_rabbitmq in JSON output.

Mise à jour (2026-01-18 09:11:13) : test_e2e_local validates routing_key empty when social exchange inferred.

Mise à jour (2026-01-18 09:07:55) : test_e2e_local validates default queue/exchange + doc_type fallback in JSON.

Mise à jour (2026-01-18 09:01:56) : test_e2e_local checks doc_type override in JSON.

Mise à jour (2026-01-18 05:26:30) : validate_payload resolves PAYLOAD_FILE from repo root.

Mise à jour (2026-01-18 05:21:45) : e2e_local resolve payload in dry-run output.

Mise à jour (2026-01-18 05:16:13) : test_e2e_local validate payload_file path + run.

Mise à jour (2026-01-18 05:11:08) : e2e_local resolve PAYLOAD_FILE from repo root.

Mise à jour (2026-01-18 05:06:10) : e2e_local check payload file exists + docs.

Mise à jour (2026-01-18 05:01:03) : doc e2e_local index/count constraint.

Mise à jour (2026-01-18 04:56:08) : e2e_local validate COUNT/INDEX ranges.

Mise à jour (2026-01-18 04:51:51) : e2e_local preflight check_rabbitmq + docs.

Mise à jour (2026-01-18 04:46:10) : run payload validation/tests + mark test_matrix.

Mise à jour (2026-01-18 04:41:11) : test_matrix mark e2e_local dry-run done.

Mise à jour (2026-01-18 04:35:58) : run test_e2e_local --json after count/index validation.

Mise à jour (2026-01-18 04:31:04) : test_e2e_local validate count/index numeric.

Mise à jour (2026-01-18 04:25:51) : run test_e2e_local --json after OUTPUT check.

Mise à jour (2026-01-18 04:21:01) : e2e_local validate OUTPUT values.

Mise à jour (2026-01-18 04:15:55) : run test_e2e_local --json.

Mise à jour (2026-01-18 04:11:17) : e2e_local enforce OUTPUT=all json + docs.

Mise à jour (2026-01-18 04:05:58) : README add test_e2e_local dry-run usage.

Mise à jour (2026-01-18 04:00:49) : fix test_e2e_local env propagation; run test.

Mise à jour (2026-01-18 03:56:00) : test_e2e_local validate queue/count/index.

Mise à jour (2026-01-18 03:51:23) : test_e2e_local env overrides + docs.

Mise à jour (2026-01-18 03:46:08) : doc e2e_local OUTPUT=all JSON note.

Mise à jour (2026-01-18 03:41:24) : test_e2e_local --json + docs.

Mise à jour (2026-01-18 03:36:14) : test_e2e_local --help + docs.

Mise à jour (2026-01-18 03:31:34) : fix test_e2e_local JSON parsing; run test.

Mise à jour (2026-01-18 03:25:54) : test_matrix e2e_local dry-run item.

Mise à jour (2026-01-18 03:21:29) : add test_e2e_local dry-run.

Mise à jour (2026-01-18 03:16:48) : e2e_local OUTPUT=all + docs.

Mise à jour (2026-01-18 03:11:22) : e2e_local INDEX selection + docs.

Mise à jour (2026-01-18 03:06:28) : e2e_local COUNT support + docs.

Mise à jour (2026-01-18 03:00:52) : test_matrix payload section.

Mise à jour (2026-01-18 02:55:54) : tests_summary payload section.

Mise à jour (2026-01-18 02:51:47) : e2e_local payload validation toggle + docs.

Mise à jour (2026-01-18 02:45:51) : README e2e_local usage section.

## E2E local (script)
Pour un test rapide publish -> consume -> PDF dummy :
```bash
./scripts/e2e_local.sh
```
Options utiles :
```bash
./scripts/e2e_local.sh --json
PURGE_QUEUE=1 ./scripts/e2e_local.sh
./scripts/e2e_local.sh --dry-run
```
Dry-run test :
```bash
./scripts/test_e2e_local.sh --json
```

Mise à jour (2026-01-18 02:41:40) : e2e_local dry-run + docs.

Mise à jour (2026-01-18 02:36:03) : doc tests_summary/test_matrix e2e_local.

Mise à jour (2026-01-18 02:31:34) : e2e_local purge option + docs.

Mise à jour (2026-01-18 02:26:14) : doc e2e_local + runbook.

Mise à jour (2026-01-18 02:22:53) : ajout e2e_local script + docs.

Mise à jour (2026-01-18 02:17:50) : test_validate_payload --json + docs.

Mise à jour (2026-01-18 02:11:42) : bootstrap_rabbitmq/create_bindings --json + docs.

Mise à jour (2026-01-18 02:06:22) : post_sample --json + docs.

Mise à jour (2026-01-18 02:01:00) : fix post_sample extra fi.

Mise à jour (2026-01-18 01:56:47) : validate_payload --json + docs.

Mise à jour (2026-01-18 01:51:58) : smoke_local --json + docs.

Mise à jour (2026-01-18 01:46:27) : consume_test_message --json + docs.

Mise à jour (2026-01-18 01:42:32) : publish_test_message/publish_sample_keys --json + docs.

Mise à jour (2026-01-18 01:37:36) : test_routing/test_routing_matrix --json + docs.

Mise à jour (2026-01-18 01:31:57) : doctor --json + docs.

Mise à jour (2026-01-18 01:26:47) : run_checks --json + docs.

Mise à jour (2026-01-18 01:21:39) : check_prereqs --json + docs.

Mise à jour (2026-01-18 01:16:14) : wait_rabbitmq --json + docs.

Mise à jour (2026-01-18 01:11:29) : check_rabbitmq --json + docs.

Mise à jour (2026-01-18 01:06:48) : status_report --json + docs.

Mise à jour (2026-01-18 01:01:38) : list_exchanges/list_bindings --json + docs.

Mise à jour (2026-01-18 00:57:10) : list_queues/count_queue_messages --json + docs.

Mise à jour (2026-01-18 00:51:57) : validate_rabbitmq --json + docs.

Mise à jour (2026-01-18 00:47:07) : validate_rabbitmq --silent + docs.

Mise à jour (2026-01-18 00:41:33) : create_bindings supporte --silent.

Mise à jour (2026-01-18 00:36:24) : bootstrap_rabbitmq supporte --silent.

Mise à jour (2026-01-18 00:31:23) : wait_rabbitmq supporte --silent.

Mise à jour (2026-01-18 00:26:19) : check_rabbitmq supporte --silent.

Mise à jour (2026-01-18 00:21:40) : check_prereqs supporte --silent.

Mise à jour (2026-01-18 00:16:05) : list_bindings supporte --silent.

Mise à jour (2026-01-18 00:11:18) : list_exchanges supporte --silent.

Mise à jour (2026-01-18 00:06:31) : list_queues supporte --silent.

Mise à jour (2026-01-18 00:01:28) : count_queue_messages supporte --silent.

Mise à jour (2026-01-17 23:56:33) : status_report supporte --silent.

Mise à jour (2026-01-17 23:51:34) : doctor supporte --silent.

Mise à jour (2026-01-17 23:46:33) : smoke_local supporte --silent.

Mise à jour (2026-01-17 23:41:25) : test_routing supporte --silent.

Mise à jour (2026-01-17 23:36:20) : test_routing_matrix supporte --silent.

Mise à jour (2026-01-17 23:30:56) : maj todo_next.

Mise à jour (2026-01-17 23:25:54) : doc local_usage OUTPUT=status.

Mise à jour (2026-01-17 23:21:14) : post_sample OUTPUT status.

Mise à jour (2026-01-17 23:15:56) : doc local_usage post_sample.

Mise à jour (2026-01-17 23:10:55) : doc run_checks --silent usage.

Mise à jour (2026-01-17 23:06:06) : run_checks supporte --silent.

Mise à jour (2026-01-17 23:01:39) : consume_test_message --silent + flags.

Mise à jour (2026-01-17 22:56:33) : publish_sample_keys flags + payload.

Mise à jour (2026-01-17 22:51:11) : publish_test_message supporte --silent + flags.

Mise à jour (2026-01-17 22:45:44) : post_sample refuse flags inconnus.

Mise à jour (2026-01-17 22:41:12) : post_sample supporte --silent.

Mise à jour (2026-01-17 22:36:07) : post_sample supporte --help + OUTPUT pretty.

Mise à jour (2026-01-17 22:30:57) : doc endpoint grantType routing key.

Mise à jour (2026-01-17 22:25:52) : validation grantType avant publish.

Mise à jour (2026-01-17 22:21:08) : publish_test_message STRICT_GRANT_TYPE.

Mise à jour (2026-01-17 22:15:47) : test producer grantType segment vide.

Mise à jour (2026-01-17 22:10:50) : test_validate_payload cas grantType segment vide.

Mise à jour (2026-01-17 22:05:50) : doc tests_producer grantType format.

Mise à jour (2026-01-17 22:01:24) : producer valide format grantType.

Mise à jour (2026-01-17 21:55:52) : doc smoke_local routing key derive.

Mise à jour (2026-01-17 21:51:01) : smoke_local derive routing key via payload.

Mise à jour (2026-01-17 21:45:58) : publish_test_message supporte --help.

Mise à jour (2026-01-17 21:40:58) : consume_test_message OUTPUT pretty.

Mise à jour (2026-01-17 21:35:58) : consume_test_message supporte --help.

Mise à jour (2026-01-17 21:31:12) : publish_test_message derive routing key du payload.

Mise à jour (2026-01-17 21:26:06) : run_checks accepte plusieurs flags.

Mise à jour (2026-01-17 21:20:44) : doc publish_test_message metadata grantType.

Mise à jour (2026-01-17 21:15:46) : publish_test_message force grantType en metadata.

Mise à jour (2026-01-17 21:11:07) : doctor lance test_validate_payload.

Mise à jour (2026-01-17 21:06:08) : ajout test_validate_payload script.

Mise à jour (2026-01-17 21:01:18) : validate_payload exige grantType routing key.

Mise à jour (2026-01-17 20:55:53) : doc routing keys lie grantType payload.

Mise à jour (2026-01-17 20:51:31) : schema + sample grantType format routing key.

Mise à jour (2026-01-17 20:47:43) : grantType requis + tests/ docs maj.

Mise à jour (2026-01-17 20:41:08) : run_checks supporte --skip-doctor.

Mise à jour (2026-01-17 20:36:10) : run_checks supporte --skip-routing.

Mise à jour (2026-01-17 20:30:50) : doc PDF_DISABLED consumers + tests pdf.disabled.

Mise à jour (2026-01-17 20:25:49) : doc pdf.disabled system property.

Mise à jour (2026-01-17 20:20:55) : usage local mentionne ROUTING_KEYS test_routing_matrix.

Mise à jour (2026-01-17 20:16:09) : test_consumers supporte MODULES.

Mise à jour (2026-01-17 20:12:23) : tests PDF_DISABLED via pdf.disabled.

Mise à jour (2026-01-17 20:06:27) : PDF_DISABLED pour couper generation PDF dummy.

Mise à jour (2026-01-17 20:01:05) : check_prereqs supporte SKIP_DOCKER/SKIP_MVN.

Mise à jour (2026-01-17 19:55:45) : docs_index complete docs recentes.

Mise à jour (2026-01-17 19:51:06) : doc readme_toc FILE env.

Mise à jour (2026-01-17 19:45:55) : test_producer supporte --list.

Mise à jour (2026-01-17 19:41:24) : build_modules supporte MODULES/--list.

Mise à jour (2026-01-17 19:36:00) : test_consumers supporte --list.

Mise à jour (2026-01-17 19:30:57) : run_consumer supporte --list.

Mise à jour (2026-01-17 19:25:43) : runbook local mentionne run_producer/run_consumer.

Mise à jour (2026-01-17 19:20:40) : README producer clarifie run_producer.

Mise à jour (2026-01-17 19:15:53) : publish_sample_keys respecte GRANT_EXCHANGE env.

Mise à jour (2026-01-17 19:10:45) : doc override ROUTING_KEYS publish_sample_keys.

Mise à jour (2026-01-17 19:06:11) : publish_sample_keys supporte ROUTING_KEYS.

Mise à jour (2026-01-17 19:00:51) : usage local ajoute status_report filtre.

Mise à jour (2026-01-17 18:55:41) : status_report affiche filtres actifs.

Mise à jour (2026-01-17 18:50:38) : runbook local ajoute alternative create_bindings.

Mise à jour (2026-01-17 18:45:46) : run_modules mentionne run_producer/run_consumer.

Mise à jour (2026-01-17 18:40:51) : list_queues supporte filtre QUEUES.

Mise à jour (2026-01-17 18:36:23) : status_report filtres via env.

Mise à jour (2026-01-17 18:31:11) : list_exchanges/list_bindings supportent filtres CSV.

Mise à jour (2026-01-17 18:26:15) : count_queue_messages supporte QUEUES.

Mise à jour (2026-01-17 18:20:48) : smoke_local utilise GRANT_EXCHANGE/queues env.

Mise à jour (2026-01-17 18:15:42) : doc test_routing_matrix ROUTING_KEYS.

Mise à jour (2026-01-17 18:11:04) : test_routing_matrix accepte ROUTING_KEYS.

Mise à jour (2026-01-17 18:06:50) : test_routing scripts utilisent routing keys env.

Mise à jour (2026-01-17 18:01:03) : bootstrap_rabbitmq aligne routing keys/queues.

Mise à jour (2026-01-17 17:55:45) : doctor signale topology invalide + create_bindings.

Mise à jour (2026-01-17 17:50:41) : usage local inclut create_bindings.

Mise à jour (2026-01-17 17:46:04) : validate_rabbitmq aligne routing keys/queues.

Mise à jour (2026-01-17 17:44:47) : ajout script create_bindings (exchanges/queues/bindings).

Mise à jour (2026-01-17 17:42:33) : bindings exchanges/queues pour consumers.

Mise à jour (2026-01-17 17:30:45) : ajout security_notes.

Mise à jour (2026-01-17 17:25:30) : ajout doc logging.

Mise à jour (2026-01-17 17:20:32) : doc usage local (append_log).

Mise à jour (2026-01-17 17:16:20) : ajout script append_log.

Mise à jour (2026-01-17 17:10:31) : note Maven dans tests_summary.

Mise à jour (2026-01-17 17:05:40) : docs_index inclut tests_summary.

Mise à jour (2026-01-17 17:00:48) : ajout tests_summary.

Mise à jour (2026-01-17 16:55:29) : doc tests producer (couverture).

Mise à jour (2026-01-17 16:50:46) : test validation email vide.

Mise à jour (2026-01-17 16:45:41) : exemple curl API contract.

Mise à jour (2026-01-17 16:40:46) : ajout api_contract.

Mise à jour (2026-01-17 16:35:41) : test routing par defaut (grantType absent).

Mise à jour (2026-01-17 16:30:31) : doc ExchangeNames producer.

Mise à jour (2026-01-17 16:26:19) : extraction ExchangeNames pour producer.

Mise à jour (2026-01-17 16:20:37) : ajout test config exchanges.

Mise à jour (2026-01-17 16:15:49) : producer exchanges configurables.

Mise à jour (2026-01-17 16:10:34) : producer declare exchanges.

Mise à jour (2026-01-17 16:05:41) : doc ports.

Mise à jour (2026-01-17 16:00:50) : ajout module_status.

Mise à jour (2026-01-17 15:55:28) : doc tests_consumers (script).

Mise à jour (2026-01-17 15:51:24) : harmonisation DummyPdfGenerator.

Mise à jour (2026-01-17 15:46:23) : DummyPdfGenerator resolve script path.

Mise à jour (2026-01-17 15:40:46) : ajout docs_index.

Mise à jour (2026-01-17 15:35:28) : doc usage local (sommaire README).

Mise à jour (2026-01-17 15:30:59) : ajout script readme_toc.

Mise à jour (2026-01-17 15:25:59) : ajout script test_consumers.

Mise à jour (2026-01-17 15:20:37) : doc tests consumers.

Mise à jour (2026-01-17 15:15:40) : ajout test dummy PDF food.

Mise à jour (2026-01-17 15:10:37) : ajout test dummy PDF grant_other_documents.

Mise à jour (2026-01-17 15:05:39) : ajout test dummy PDF contracts.

Mise à jour (2026-01-17 15:00:43) : ajout test dummy PDF financial.

Mise à jour (2026-01-17 14:55:43) : ajout test dummy PDF transportation.

Mise à jour (2026-01-17 14:50:36) : doc endpoints/env producer.

Mise à jour (2026-01-17 14:46:00) : ajout script tail_rabbitmq_logs.

Mise à jour (2026-01-17 14:40:25) : doc run_modules + note EnableRabbit.

Mise à jour (2026-01-17 14:35:59) : consumers EnableRabbit.

Mise à jour (2026-01-17 14:30:36) : doc troubleshooting Maven.

Mise à jour (2026-01-17 14:25:30) : check_prereqs verifie mvn.

Mise à jour (2026-01-17 14:20:28) : tests producer bloques (mvn manquant).

Mise à jour (2026-01-17 14:15:33) : doc run/env consumers index.

Mise à jour (2026-01-17 14:10:53) : consumer grant_other_documents genere PDF dummy.

Mise à jour (2026-01-17 14:05:44) : consumer contracts genere PDF dummy.

Mise à jour (2026-01-17 14:00:44) : consumer transportation genere PDF dummy.

Mise à jour (2026-01-17 13:55:43) : consumer financial genere PDF dummy.

Mise à jour (2026-01-17 13:50:55) : consumer food genere PDF dummy.

Mise à jour (2026-01-17 13:45:35) : doc tests producer.

Mise à jour (2026-01-17 13:40:38) : ajout test routing producer (MockBean).

Mise à jour (2026-01-17 13:35:51) : ajout script test_producer.

Mise à jour (2026-01-17 13:30:41) : ajout test endpoint health.

Mise à jour (2026-01-17 13:25:48) : ajout tests producer (MockMvc).

Mise à jour (2026-01-17 13:20:34) : ajout doc run_modules.

Mise à jour (2026-01-17 13:15:37) : producer retourne JSON (status,routingKey).

Mise à jour (2026-01-17 13:10:34) : producer health + validation champs requis.

Mise à jour (2026-01-17 13:05:51) : ajout script build_modules.

Mise à jour (2026-01-17 13:00:49) : ajout stub consumer grant_other_documents.

Mise à jour (2026-01-17 12:55:46) : ajout stub consumer contracts.

Mise à jour (2026-01-17 12:50:45) : ajout stub consumer transportation_costs.

Mise à jour (2026-01-17 12:45:59) : ajout stub consumer financial_assistance.

Mise à jour (2026-01-17 12:41:05) : ajout stub consumer food_application.

Mise à jour (2026-01-17 12:36:22) : ajout stub Spring Boot producer.

Mise à jour (2026-01-17 12:30:47) : ajout script run_checks.

Mise à jour (2026-01-17 12:25:42) : doc variables scripts.

Mise à jour (2026-01-17 12:20:40) : ajout recap usage local.

Mise à jour (2026-01-17 12:15:57) : ajout script simulate_consumer.

Mise à jour (2026-01-17 12:10:25) : ajout todo_next.

Mise à jour (2026-01-17 12:05:26) : ajout service matrix.

Mise à jour (2026-01-17 12:00:33) : ajout stub grant_other_documents.

Mise à jour (2026-01-17 11:55:29) : index consumers.

Mise à jour (2026-01-17 11:50:45) : ajout README stubs services.

Mise à jour (2026-01-17 11:46:15) : ajout script generate_dummy_pdf.

Mise à jour (2026-01-17 11:40:44) : ajout script doctor.

Mise à jour (2026-01-17 11:35:56) : ajout script validate_payload.

Mise à jour (2026-01-17 11:30:36) : ajout script run_local_flow.

Mise à jour (2026-01-17 11:25:38) : ajout script reset_local.

Mise à jour (2026-01-17 11:20:54) : ajout script post_sample.

Mise à jour (2026-01-17 11:15:44) : doc troubleshooting env.

Mise à jour (2026-01-17 11:10:40) : ajout script publish_sample_keys.

Mise à jour (2026-01-17 11:06:03) : ajout script test_routing_matrix.

Mise à jour (2026-01-17 11:00:37) : ajout runbook local.

Mise à jour (2026-01-17 10:55:33) : ajout script status_report.

Mise à jour (2026-01-17 10:50:27) : ajout script setup_env.

Mise à jour (2026-01-17 10:45:23) : doc outils de test (scripts ajout).

Mise à jour (2026-01-17 10:40:29) : ajout script load_env.

Mise à jour (2026-01-17 10:35:26) : doc scripts overview.

Mise à jour (2026-01-17 10:30:23) : smoke plan mentionne check_prereqs + smoke_local.

Mise à jour (2026-01-17 10:25:28) : ajout script check_prereqs.

Mise à jour (2026-01-17 10:21:08) : ajout script smoke_local.

Mise à jour (2026-01-17 10:16:27) : doc plan d'implementation.

Mise à jour (2026-01-17 10:10:34) : purge_queues trim espaces CSV.

Mise à jour (2026-01-17 10:05:17) : purge_queues supporte QUEUES CSV.

Mise à jour (2026-01-17 10:00:47) : ajout script purge_queues.sh.

Mise à jour (2026-01-17 09:55:38) : exemple variables .env pour credentials.

Mise à jour (2026-01-17 09:50:24) : ajout usage fichier .env.

Mise à jour (2026-01-17 09:45:33) : ajout .env.example RabbitMQ.

Mise à jour (2026-01-17 09:40:25) : doc vhost par defaut pour scripts RabbitMQ.

Mise à jour (2026-01-17 09:35:23) : precision payload par defaut (sample_student.json).

Mise à jour (2026-01-17 09:30:24) : doc PAYLOAD_FILE pour publish_test_message.

Mise à jour (2026-01-17 09:25:21) : ajout commande nettoyage shared/pdfs.

Mise à jour (2026-01-17 09:20:22) : ajout TODO tests e2e.

Mise à jour (2026-01-17 09:15:15) : ajout doc troubleshooting.

Mise à jour (2026-01-17 09:10:47) : bootstrap_all inclut test_routing.

Mise à jour (2026-01-17 09:05:40) : precision permissions dossier PDFs.

Mise à jour (2026-01-17 09:01:02) : note permissions ecriture dossier shared/pdfs.

Mise à jour (2026-01-17 08:55:21) : note API management pour scripts de listing.

Mise à jour (2026-01-17 08:50:13) : ajout script count_queue_messages.sh.

Mise à jour (2026-01-17 08:45:19) : ajout lien UI RabbitMQ.

Mise à jour (2026-01-17 08:40:30) : ajout doc outils de test.

Mise à jour (2026-01-17 08:35:28) : test matrix coche pre-requis RabbitMQ.

Mise à jour (2026-01-17 08:30:44) : nettoyage test_routing (suppression code mort).

Mise à jour (2026-01-17 08:25:39) : publish_test_message default EXCHANGE=GRANT_EXCHANGE.

Mise à jour (2026-01-17 08:20:39) : ajout script list_bindings.sh.

Mise à jour (2026-01-17 08:15:31) : ajout script bootstrap_all.sh.

Mise à jour (2026-01-17 08:10:34) : ajout script wait_rabbitmq.sh.

Mise à jour (2026-01-17 08:05:23) : doc schema payload.

Mise à jour (2026-01-17 08:00:24) : doc endpoints producer proposes.

Mise à jour (2026-01-17 07:55:17) : fix test_routing.sh purge queue (DELETE).

Mise à jour (2026-01-17 07:50:19) : fix test_routing.sh (env passe au python).

Mise à jour (2026-01-17 07:45:45) : ajout script test_routing.sh.

Mise à jour (2026-01-17 07:40:15) : ajout note de statut IN_PROGRESS.

Mise à jour (2026-01-17 07:35:26) : ajout test matrix.

Mise à jour (2026-01-17 07:30:23) : publish_test_message routing key par defaut + metadata grantType.

Mise à jour (2026-01-17 07:25:15) : sample_student.json inclut grantType.

Mise à jour (2026-01-17 07:20:24) : doc policy ACK consumers.

Mise à jour (2026-01-17 07:15:15) : list_exchanges ignore exchange vide.

Mise à jour (2026-01-17 07:10:33) : ajout script list_exchanges.sh.

Mise à jour (2026-01-17 07:05:32) : ajout script list_queues.sh.

Mise à jour (2026-01-17 07:00:20) : consume_test_message supporte TRUNCATE.

Mise à jour (2026-01-18 08:56:23) : test_e2e_local verifie contraintes output=all dans JSON.

Mise à jour (2026-01-18 08:51:15) : test_e2e_local verifie override purge_queue=1.

Mise à jour (2026-01-18 08:46:24) : test_e2e_local verifie routing_key vide pour SOCIAL_ASSISTANCE_EXCHANGE.

Mise à jour (2026-01-18 08:41:16) : test_e2e_local valide pdf_output_dir en JSON.

Mise à jour (2026-01-18 08:36:12) : test_e2e_local valide exchange/routing_key en JSON.

Mise à jour (2026-01-18 08:31:15) : test_e2e_local valide doc_type en JSON.

Mise à jour (2026-01-18 08:26:13) : test_e2e_local valide purge_queue en JSON.

Mise à jour (2026-01-18 08:21:16) : test_e2e_local valide ack_mode dans JSON dry-run.

Mise à jour (2026-01-18 08:16:18) : test_e2e_local verifie override validate_payload/check_rabbitmq.

Mise à jour (2026-01-18 08:11:22) : doc e2e_local ajoute contraintes validations.

Mise à jour (2026-01-18 08:06:19) : test_e2e_local verifie validate_payload/check_rabbitmq en JSON.

Mise à jour (2026-01-18 08:01:16) : e2e_local autorise COUNT>1 en OUTPUT=single (suppression contrainte).

Mise à jour (2026-01-18 07:56:19) : e2e_local impose COUNT=1 pour OUTPUT=single + test negatif.

Mise à jour (2026-01-18 07:51:20) : e2e_local exige PAYLOAD_FILE lisible + test negatif.

Mise à jour (2026-01-18 07:46:19) : e2e_local exige PAYLOAD_FILE non vide + test negatif.

Mise à jour (2026-01-18 07:41:38) : e2e_local exige PAYLOAD_FILE .json + test negatif.

Mise à jour (2026-01-18 07:36:47) : e2e_local impose INDEX=0 pour OUTPUT=all + tests ajustes.

Mise à jour (2026-01-18 07:31:09) : test_e2e_local refuse OUTPUT=all COUNT=1 meme avec --json.

Mise à jour (2026-01-18 07:26:29) : e2e_local impose COUNT>=2 pour OUTPUT=all + test negatif.

Mise à jour (2026-01-18 07:21:19) : e2e_local interdit ROUTING_KEY avec SOCIAL_ASSISTANCE_EXCHANGE + test negatif.

Mise à jour (2026-01-18 07:16:16) : e2e_local limite longueur DOC_TYPE + test negatif.

Mise à jour (2026-01-18 07:11:23) : e2e_local valide PDF_OUTPUT_DIR writable + test negatif.

Mise à jour (2026-01-18 07:06:56) : e2e_local verifie PAYLOAD_FILE existant en dry-run + test negatif.

Mise à jour (2026-01-18 07:01:55) : e2e_local valide PDF_OUTPUT_DIR + test negatif.

Mise à jour (2026-01-18 06:56:14) : e2e_local limite longueur QUEUE + test negatif.

Mise à jour (2026-01-18 06:51:14) : e2e_local limite longueur EXCHANGE + test negatif.

Mise à jour (2026-01-18 06:46:46) : e2e_local limite longueur ROUTING_KEY + test negatif.

Mise à jour (2026-01-18 06:41:13) : e2e_local valide format ROUTING_KEY + test negatif.

Mise à jour (2026-01-18 06:36:11) : e2e_local valide format EXCHANGE + test negatif.

Mise à jour (2026-01-18 06:31:32) : e2e_local valide format QUEUE + test negatif.

Mise à jour (2026-01-18 06:26:28) : e2e_local valide format DOC_TYPE + test negatif.

Mise à jour (2026-01-18 06:21:12) : e2e_local valide VALIDATE_PAYLOAD/CHECK_RABBITMQ + tests negatifs.

Mise à jour (2026-01-18 06:16:09) : e2e_local valide PURGE_QUEUE + test negatif.

Mise à jour (2026-01-18 06:11:15) : e2e_local valide ACK_MODE + test negatif.

Mise à jour (2026-01-18 06:06:05) : test_e2e_local verifie COUNT negatif en dry-run.

Mise à jour (2026-01-18 06:01:04) : test_e2e_local verifie INDEX non numerique en dry-run.

Mise à jour (2026-01-18 05:56:05) : test_e2e_local verifie COUNT non numerique en dry-run.

Mise à jour (2026-01-18 05:51:05) : test_e2e_local verifie OUTPUT invalide en dry-run.

Mise à jour (2026-01-18 05:46:01) : test_e2e_local verifie INDEX=-1 en dry-run.

Mise à jour (2026-01-18 05:41:04) : test_e2e_local verifie COUNT=0 en dry-run.

Mise à jour (2026-01-18 05:36:03) : test_e2e_local verifie INDEX>=COUNT en mode OUTPUT=single.

Mise à jour (2026-01-18 05:32:47) : e2e_local valide OUTPUT/COUNT/INDEX en dry-run + test negatif OUTPUT=all sans --json.

Mise à jour (2026-01-17 06:55:23) : publish_test_message ajoute message_id auto.

Mise à jour (2026-01-17 06:50:22) : publish_test_message ajoute content_type JSON.

Mise à jour (2026-01-17 06:46:11) : ajout scripts publish/consume message test.

Mise à jour (2026-01-17 06:40:12) : ajout TODO implementation.

Mise à jour (2026-01-17 06:35:20) : ajout smoke plan local.

Mise à jour (2026-01-17 06:30:23) : doc contenu minimal des PDFs.

Mise à jour (2026-01-17 06:25:31) : ajout doc variables d'environnement services.

Mise à jour (2026-01-17 06:20:11) : mention modules stubs dans services/.

Mise à jour (2026-01-17 06:15:33) : ajout layout modules + dossiers services.

Mise à jour (2026-01-17 06:10:28) : plan MAJ (scripts setup/quickstart coches).

Mise à jour (2026-01-17 06:05:16) : ajout quickstart local.

Mise à jour (2026-01-17 06:00:25) : ajout script bootstrap_and_validate.sh.

Mise à jour (2026-01-17 05:55:11) : note sur requirement API management pour validation.

Mise à jour (2026-01-17 05:50:17) : validation RabbitMQ verifie aussi les bindings.

Mise à jour (2026-01-17 05:45:51) : ajout script validate_rabbitmq.sh.

Mise à jour (2026-01-17 05:40:11) : ajout sequence bootstrap complete.

Mise à jour (2026-01-17 05:35:23) : ajout script check_rabbitmq.sh + doc usage.

Mise à jour (2026-01-17 05:30:17) : doc convention nommage PDF.

Mise à jour (2026-01-17 05:25:15) : doc variables env pour bootstrap RabbitMQ.

Mise à jour (2026-01-17 05:20:40) : ajout script bootstrap RabbitMQ (exchanges/queues/bindings).

Mise à jour (2026-01-17 05:15:13) : plan MAJ (arborescence projet clarifiee).

Mise à jour (2026-01-17 05:10:18) : doc services producteurs/consommateurs + PDF attendus.

Mise à jour (2026-01-17 05:05:09) : ajout commandes stop/start docker compose.

Mise à jour (2026-01-17 05:00:13) : ajout exemples routing keys.

Mise à jour (2026-01-17 04:55:14) : ajout exemple payload etudiant (JSON).

Mise à jour (2026-01-17 04:50:16) : ajout dossier shared/pdfs + doc de depot.

Mise à jour (2026-01-17 04:45:36) : ajout topologie exchanges/queues/bindings + MAJ plan.

Mise à jour (2026-01-17 04:40:16) : ajout docker-compose RabbitMQ pour lever le blocage broker.

## Synthèse
Suite de projets RabbitMQ : un producteur web (Spring Boot) StudentsDataProducer publie les données JSON des étudiants vers deux exchanges :
- `SOCIAL_ASSISTANCE_EXCHANGE` (FANOUT) vers trois queues et consommateurs : FoodApplicationGenerator, FinancialAssistanceApplicationGenerator, TransportationCostsApplicationGenerator.
- `GRANT_EXCHANGE` (TOPIC) vers `grant_other_documents` (binding `grant.#` pour Consent/GuaranteeLetter/GrantApplication) et `grant_contracts` (binding `grant.1.*` pour ContractGenerator).
Chaque message déclenche la génération de PDF (noms distinctifs) déposés dans un dossier partagé. Chaque producteur/consommateur est un projet Java séparé. Broker RabbitMQ requis en local.

## Avancement
- [x] Copie du sujet (`docs/MessageQueue.pdf`).
- [x] Lecture rapide du sujet et exigences (exchanges, queues, bindings, PDF à générer).
- [ ] Planification détaillée (modules Maven/Gradle, schéma exchanges/queues).
- [ ] Implémentation (web producer + 4 consommateurs).

Mise à jour (2025-12-06 11:35:31) : Lecture rapide faite ; blocage : RabbitMQ non présent sur l’environnement (installation requise). Projet en attente jusqu’à disposition d’un broker ou conteneur RabbitMQ.

## RabbitMQ local (Docker)
```bash
docker compose up -d
```
Accès UI : http://localhost:15672 (guest/guest). Port AMQP : 5672.

Pour stop/start :
```bash
docker compose stop
docker compose start
```

Bootstrap exchanges/queues/bindings (API management) :
```bash
./scripts/bootstrap_rabbitmq.sh
```
Variables d'environnement : voir `docs/bootstrap_env.md`.

Verifier l'API management :
```bash
./scripts/check_rabbitmq.sh
```
Par defaut, le vhost est `/` (surcharge via `RABBITMQ_VHOST`).
Exemple de variables : voir `.env.example`.

Pour utiliser un fichier `.env` :
```bash
set -a; source .env; set +a
```
Exemple: definir `RABBITMQ_USER` et `RABBITMQ_PASS` pour surcharger les identifiants.
Alternative (avec verif rapide des variables) :
```bash
./scripts/load_env.sh
```
Creer un `.env` a partir de l'exemple :
```bash
./scripts/setup_env.sh
```

Attendre que RabbitMQ soit pret :
```bash
./scripts/wait_rabbitmq.sh
```
Verifier les prerequis locaux :
```bash
./scripts/check_prereqs.sh
```

Bootstrap complet (docker + check + init exchanges/queues) :
```bash
docker compose up -d
./scripts/check_rabbitmq.sh
./scripts/bootstrap_rabbitmq.sh
```
Version en une commande :
```bash
./scripts/bootstrap_and_validate.sh
```
Ou avec docker compose inclus :
```bash
./scripts/bootstrap_all.sh
```
(Cela inclut aussi test_routing.)

Quickstart local : voir `docs/quickstart.md`.
Runbook local : `docs/local_runbook.md`.
Usage local : `docs/local_usage.md`.

Validation topologie (exchanges/queues) :
```bash
./scripts/validate_rabbitmq.sh
```
Note : necessite l'API management activee sur RabbitMQ.

Publier/consommer un message test (API management) :
```bash
./scripts/publish_test_message.sh
QUEUE=food_application ./scripts/consume_test_message.sh
```
Par defaut, le message publie a `content_type=application/json` depuis `docs/sample_student.json`.
Un `message_id` est ajoute automatiquement (surcharge via `MESSAGE_ID`).
Pour limiter la taille de sortie, utiliser `TRUNCATE` (en octets).
La routing key par defaut est `grant.1.contract` sur `GRANT_EXCHANGE` (surcharge via `ROUTING_KEY`/`EXCHANGE`).
Le payload peut etre surcharge via `PAYLOAD_FILE`.
En mode `--json`, les erreurs de validation retournent `{status:"error", error:"..."}`.

Lister les queues :
```bash
./scripts/list_queues.sh
```

Lister les exchanges :
```bash
./scripts/list_exchanges.sh
```

Lister les bindings :
```bash
./scripts/list_bindings.sh
```

Compter les messages par queue :
```bash
./scripts/count_queue_messages.sh
```

Purger les queues (topologie standard) :
```bash
./scripts/purge_queues.sh
```
Surcharger la liste via `QUEUES` (CSV, espaces tolérés).

Tester le routage (grant.1.contract -> 2 queues) :
```bash
./scripts/test_routing.sh
```
Note : ces scripts utilisent l'API management.

## Topologie
Voir `docs/topology.md` pour la liste des exchanges, queues et bindings attendus.

## Dossier PDF partage
Les consommateurs doivent deposer les PDF dans `shared/pdfs/` (volume local). Un `.gitkeep` maintient le dossier dans le repo.
Assurer des droits d'ecriture pour l'utilisateur du consumer (ex: chmod ou volume docker).
Pour nettoyer rapidement :
```bash
rm -f shared/pdfs/*
```

## Exemple de payload
Un exemple de JSON etudiant est disponible dans `docs/sample_student.json`.

## Routing keys exemples
Voir `docs/sample_routing_keys.md`.

## Services
Voir `docs/services.md` pour la liste des producteurs/consommateurs et des PDF generes.
Matrice : `docs/service_matrix.md`.
Run modules : `docs/run_modules.md`.
Logging : `docs/logging.md`.

## Nommage PDF
Voir `docs/pdf_naming.md`.

## Contenu PDF
Voir `docs/pdf_contents.md`.
Generation dummy :
```bash
./scripts/generate_dummy_pdf.py
```
Simulation consumer :
```bash
DOC_TYPE=food_application ./scripts/simulate_consumer.py
```

## But des queues
Voir `docs/queue_purpose.md`.

## Layout modules
Structure proposee : `docs/module_layout.md`.

## Plan d'implementation
Voir `docs/implementation_plan.md`.

## Modules (stubs)
Des dossiers vides existent deja dans `services/` pour accueillir les projets Java.
Guides stubs : `services/producer/README.md` et `services/consumers/*/README.md`.
Index consumers : `services/consumers/README.md`.
Bindings queues/exchanges : voir chaque README consumer (social fanout, grant topic + routing keys).
Producer Spring Boot (stub) : `services/producer/pom.xml`.
Consumer Spring Boot (stub) : `services/consumers/food_application/pom.xml`.
Consumer Spring Boot (stub) : `services/consumers/financial_assistance/pom.xml`.
Consumer Spring Boot (stub) : `services/consumers/transportation_costs/pom.xml`.
Consumer Spring Boot (stub) : `services/consumers/contracts/pom.xml`.
Consumer Spring Boot (stub) : `services/consumers/grant_other_documents/pom.xml`.
Etat des modules : `docs/module_status.md`.

## Variables d'environnement
Voir `docs/service_env.md`.

## Smoke plan
Voir `docs/smoke_plan.md`.
Script local : `./scripts/smoke_local.sh`.

## ACK policy
Voir `docs/consumer_ack.md`.

## Test matrix
Voir `docs/test_matrix.md`.

## Statut
Ce projet reste IN_PROGRESS tant que le producer et les consumers ne sont pas implementes.
TODO next : `docs/todo_next.md`.

## Endpoints producer
Voir `docs/http_endpoints.md`.
Contrat API : `docs/api_contract.md`.

## Payload schema
Voir `docs/payload_schema.md`.

## Outils de test
Voir `docs/test_tools.md`.
Scripts : `docs/scripts_overview.md`.
Variables scripts : `docs/script_env.md`.
Index docs : `docs/docs_index.md`.
Etat RabbitMQ (resume) :
```bash
./scripts/status_report.sh
```
Test routage complet :
```bash
./scripts/test_routing_matrix.sh
```
Publier les routing keys d'exemple :
```bash
./scripts/publish_sample_keys.sh
```
Override CSV :
```bash
ROUTING_KEYS="grant.foo,grant.2.contract" ./scripts/publish_sample_keys.sh
```
Envoyer un payload au producer HTTP :
```bash
./scripts/post_sample.sh
```
Valider un payload JSON :
```bash
./scripts/validate_payload.py
```
Doctor check (prerequis + payload + topologie) :
```bash
./scripts/doctor.sh
```
Checks complets :
```bash
./scripts/run_checks.sh
```
Build modules (Maven) :
```bash
./scripts/build_modules.sh
```
Tests producer :
```bash
./scripts/test_producer.sh
```
Doc tests : `docs/tests_producer.md`.
Logs RabbitMQ :
```bash
./scripts/tail_rabbitmq_logs.sh
```
Doc tests consumers : `docs/tests_consumers.md`.
Tests consumers :
```bash
./scripts/test_consumers.sh
```
Tests summary : `docs/tests_summary.md`.
Sommaire README :
```bash
./scripts/readme_toc.sh
```
Log automatique :
```bash
./scripts/append_log.sh "YYYY-MM-DD HH:MM:SS" "Messagequeue/MessageQueue" "IN_PROGRESS" "action"
```
Run producer :
```bash
./scripts/run_producer.sh
```
Run consumer :
```bash
./scripts/run_consumer.sh food_application
```
Nettoyer l'environnement local :
```bash
./scripts/reset_local.sh
```
Lancer un flow local complet :
```bash
./scripts/run_local_flow.sh
```

## Liens utiles
- UI RabbitMQ : http://localhost:15672
Ports : `docs/ports.md`.
Security : `docs/security_notes.md`.

## Troubleshooting
Voir `docs/troubleshooting.md`.
Env : `docs/troubleshooting_env.md`.

## TODO implementation
- Implementer le producer web + consumers.
- Ajouter generation PDF minimale par consumer.
 - Ajouter tests e2e (producer->queues->PDF).

Derniere mise a jour (2026-01-18 13:58:09) : tests e2e_local rejettent DOC_TYPE avec point.
Derniere mise a jour (2026-01-18 14:01:25) : tests e2e_local rejettent PAYLOAD_FILE dossier.
Derniere mise a jour (2026-01-18 14:06:30) : tests e2e_local acceptent PAYLOAD_FILE relatif.
Derniere mise a jour (2026-01-18 14:11:22) : tests e2e_local rejettent COUNT decimal.
Derniere mise a jour (2026-01-18 14:16:22) : tests e2e_local rejettent INDEX decimal.
Derniere mise a jour (2026-01-18 14:21:29) : tests e2e_local acceptent EXCHANGE avec point.
Derniere mise a jour (2026-01-18 14:26:38) : tests e2e_local acceptent ROUTING_KEY avec point (GRANT_EXCHANGE).
Derniere mise a jour (2026-01-18 14:31:24) : tests e2e_local acceptent ROUTING_KEY avec tiret (GRANT_EXCHANGE).
Derniere mise a jour (2026-01-18 14:36:31) : tests e2e_local valident OUTPUT=all COUNT=2 INDEX=0.
Derniere mise a jour (2026-01-18 14:41:27) : tests e2e_local acceptent ROUTING_KEY avec underscore (GRANT_EXCHANGE).
Derniere mise a jour (2026-01-18 14:46:44) : PDF_OUTPUT_DIR doit etre un chemin absolu.
Derniere mise a jour (2026-01-18 14:51:44) : tests e2e_local acceptent QUEUE avec point/underscore.
Derniere mise a jour (2026-01-18 14:56:37) : DOC_TYPE accepte le point.
Derniere mise a jour (2026-01-18 15:03:28) : e2e_local derive ROUTING_KEY grantType du payload.
Derniere mise a jour (2026-01-18 15:06:44) : tests e2e_local default ROUTING_KEY sans grantType.
Derniere mise a jour (2026-01-18 15:11:58) : tests e2e_local valident DOC_TYPE avec point en JSON.
Derniere mise a jour (2026-01-18 15:16:28) : tests e2e_local rejettent PDF_OUTPUT_DIR absent.
Derniere mise a jour (2026-01-18 15:21:27) : tests e2e_local acceptent OUTPUT vide (default).
Derniere mise a jour (2026-01-18 15:26:54) : tests e2e_local derivent routing_key grantType custom.
Derniere mise a jour (2026-01-18 15:31:44) : tests e2e_local acceptent EXCHANGE avec underscore.
Derniere mise a jour (2026-01-18 15:36:31) : tests e2e_local acceptent ACK_MODE ack_requeue_true.
Derniere mise a jour (2026-01-18 15:41:30) : tests e2e_local acceptent PURGE_QUEUE=1.
Derniere mise a jour (2026-01-18 15:46:31) : tests e2e_local acceptent VALIDATE_PAYLOAD=0.
Derniere mise a jour (2026-01-18 15:51:31) : tests e2e_local acceptent CHECK_RABBITMQ=0.
Derniere mise a jour (2026-01-18 15:56:30) : tests e2e_local acceptent DOC_TYPE longueur 255.
Derniere mise a jour (2026-01-18 16:01:33) : tests e2e_local acceptent QUEUE longueur 255.
Derniere mise a jour (2026-01-18 16:06:31) : tests e2e_local acceptent EXCHANGE longueur 255.
Derniere mise a jour (2026-01-18 16:11:30) : tests e2e_local acceptent ROUTING_KEY longueur 255.
Derniere mise a jour (2026-01-18 16:16:33) : tests e2e_local acceptent PDF_OUTPUT_DIR writable.
Derniere mise a jour (2026-01-18 16:21:32) : tests e2e_local acceptent OUTPUT=single.
Derniere mise a jour (2026-01-18 16:26:31) : tests e2e_local acceptent COUNT=1 INDEX=0 OUTPUT=single.
Derniere mise a jour (2026-01-18 16:31:36) : tests e2e_local acceptent COUNT=2 INDEX=1 OUTPUT=single.
Derniere mise a jour (2026-01-18 16:36:48) : tests e2e_local acceptent COUNT avec zeros en tete.
Derniere mise a jour (2026-01-18 16:41:34) : tests e2e_local acceptent INDEX avec zeros en tete.
Derniere mise a jour (2026-01-18 16:46:42) : tests e2e_local acceptent QUEUE avec tiret.
Derniere mise a jour (2026-01-18 16:51:37) : tests e2e_local acceptent EXCHANGE avec tiret.
Derniere mise a jour (2026-01-18 16:56:37) : tests e2e_local acceptent ROUTING_KEY mixte.
Derniere mise a jour (2026-01-18 17:01:39) : tests e2e_local valident DOC_TYPE mixte.
Derniere mise a jour (2026-01-18 17:06:37) : tests e2e_local acceptent ROUTING_KEY avec point/underscore/tiret.
Derniere mise a jour (2026-01-18 17:11:39) : tests e2e_local acceptent ROUTING_KEY vide pour SOCIAL_ASSISTANCE_EXCHANGE.
Derniere mise a jour (2026-01-18 17:16:41) : tests e2e_local rejettent OUTPUT=all avec INDEX=1.
Derniere mise a jour (2026-01-18 17:21:37) : tests e2e_local acceptent COUNT=3 INDEX=0 OUTPUT=single.
Derniere mise a jour (2026-01-18 17:28:03) : ajout du document racine PROJECTS_OVERVIEW.md.
Derniere mise a jour (2026-01-18 17:30:35) : PROJECTS_OVERVIEW.md detaille en francais.
Derniere mise a jour (2026-01-18 19:48:37) : PROJECTS_OVERVIEW.md section \"Comment lire\" ajoutee.
Derniere mise a jour (2026-01-18 19:49:17) : PROJECTS_OVERVIEW.md section \"Conventions\" ajoutee.
Derniere mise a jour (2026-01-18 19:50:12) : PROJECTS_OVERVIEW.md section \"Glossaire\" ajoutee.
Derniere mise a jour (2026-01-18 19:53:58) : PROJECTS_OVERVIEW.md section \"Utilisation du panorama\" ajoutee.
Derniere mise a jour (2026-01-18 19:58:58) : PROJECTS_OVERVIEW.md section \"Structure du depot\" ajoutee.
Derniere mise a jour (2026-01-18 20:03:59) : PROJECTS_OVERVIEW.md section \"Comment verifier\" ajoutee.
Derniere mise a jour (2026-01-18 20:08:32) : ajout --dry-run + tests pour publish_test_message.
Derniere mise a jour (2026-01-18 20:09:47) : doctor integre tests publish_test_message.
Derniere mise a jour (2026-01-18 20:14:06) : doc usage publish_test_message --dry-run.
Derniere mise a jour (2026-01-18 20:19:49) : test_publish_test_message supporte --json.
Derniere mise a jour (2026-01-18 20:24:11) : test_publish_test_message --json n'affiche que du JSON.
Derniere mise a jour (2026-01-18 20:29:18) : test_publish_test_message --json supprime la ligne ok.
Derniere mise a jour (2026-01-18 20:34:10) : doc doctor --json mentionne publish_tests.
Derniere mise a jour (2026-01-18 20:39:09) : test_matrix mentionne test_publish_test_message.
Derniere mise a jour (2026-01-18 20:44:07) : runbook mentionne publish_test_message --dry-run.
Derniere mise a jour (2026-01-18 20:49:13) : quickstart inclut publish_test_message --dry-run.
Derniere mise a jour (2026-01-18 20:54:08) : docs_index reference quickstart.
Derniere mise a jour (2026-01-18 20:59:12) : troubleshooting_env mentionne doctor --json.
Derniere mise a jour (2026-01-18 21:04:26) : tests publish_test_message couvrent payload illisible/dossier.
Derniere mise a jour (2026-01-18 21:09:07) : tests_summary detaille erreurs payload publish_test_message.
Derniere mise a jour (2026-01-18 21:14:18) : publish_test_message verifie payload lisible/dossier.
Derniere mise a jour (2026-01-18 21:19:07) : script_env precise PAYLOAD_FILE lisible.
Derniere mise a jour (2026-01-18 21:25:20) : publish_test_message valide exchange/routing key + tests.
Derniere mise a jour (2026-01-18 21:29:23) : tests publish_test_message couvrent longueurs exchange/routing key.
Derniere mise a jour (2026-01-18 21:34:05) : tests_summary mentionne longueurs invalides publish_test_message.
Derniere mise a jour (2026-01-18 21:39:04) : test_matrix mentionne longueurs exchange/routing key.
Derniere mise a jour (2026-01-18 21:44:35) : help publish_test_message enrichi + test help.
Derniere mise a jour (2026-01-18 21:49:05) : tests_summary mentionne test help publish_test_message.
Derniere mise a jour (2026-01-18 21:55:31) : tests publish_test_message couvrent CONTENT_TYPE trop long.
Derniere mise a jour (2026-01-18 21:59:38) : publish_test_message valide MESSAGE_ID trop long + tests.
Derniere mise a jour (2026-01-18 22:04:10) : test_matrix mentionne MESSAGE_ID trop long.
Derniere mise a jour (2026-01-18 22:09:06) : tests_summary mentionne content_type/message_id.
Derniere mise a jour (2026-01-18 22:14:15) : troubleshooting_env couvre erreurs publish_test_message.
Derniere mise a jour (2026-01-18 22:19:10) : test_tools mentionne validations publish_test_message.
Derniere mise a jour (2026-01-18 22:24:22) : e2e_local mentionne content_type/message_id.
Derniere mise a jour (2026-01-18 22:29:13) : local_usage montre MESSAGE_ID/CONTENT_TYPE override.
Derniere mise a jour (2026-01-18 22:34:10) : scripts_overview mentionne validations publish_test_message.
Derniere mise a jour (2026-01-18 22:39:58) : test_publish_test_message verifie message_id non vide.
Derniere mise a jour (2026-01-18 22:44:07) : tests_summary mentionne message_id non vide.
Derniere mise a jour (2026-01-18 22:49:07) : test_matrix mentionne MESSAGE_ID vide/trop long.
Derniere mise a jour (2026-01-18 22:54:41) : publish_test_message refuse MESSAGE_ID avec espaces + tests.
Derniere mise a jour (2026-01-18 22:59:10) : tests_summary mentionne message_id sans espaces.
Derniere mise a jour (2026-01-18 23:04:09) : test_matrix mentionne MESSAGE_ID avec espaces.
Derniere mise a jour (2026-01-18 23:09:11) : test_tools mentionne message_id sans espaces.
Derniere mise a jour (2026-01-18 23:14:12) : local_usage rappelle message_id sans espaces.
Derniere mise a jour (2026-01-18 23:20:08) : publish_test_message refuse CONTENT_TYPE espaces + tests.
Derniere mise a jour (2026-01-18 23:24:11) : tests_summary mentionne content_type non blanc.
Derniere mise a jour (2026-01-18 23:29:11) : test_matrix mentionne CONTENT_TYPE blanc.
Derniere mise a jour (2026-01-18 23:34:11) : runbook rappelle contraintes message_id/content_type.
Derniere mise a jour (2026-01-18 23:39:35) : help publish_test_message mentionne message_id/content_type.
Derniere mise a jour (2026-01-18 23:44:11) : tests_summary mentionne help detaille publish_test_message.
Derniere mise a jour (2026-01-18 23:49:15) : test_tools mentionne content_type blanc et message_id avec espaces.
Derniere mise a jour (2026-01-18 23:55:17) : test_publish_test_message couvre CONTENT_TYPE vide.
Derniere mise a jour (2026-01-18 23:59:14) : tests_summary mentionne content_type vide/blanc.
Derniere mise a jour (2026-01-19 00:04:17) : test_matrix mentionne CONTENT_TYPE vide.
Derniere mise a jour (2026-01-19 00:09:15) : test_tools mentionne content_type vide/blanc.
Derniere mise a jour (2026-01-19 00:14:23) : test_publish_test_message couvre MESSAGE_ID vide.
Derniere mise a jour (2026-01-19 00:19:11) : test_tools mentionne message_id vide.
Derniere mise a jour (2026-01-19 00:24:12) : tests_summary mentionne message_id vide/espaces.
Derniere mise a jour (2026-01-19 00:29:42) : test_tools detaille tests content_type/message_id.
Derniere mise a jour (2026-01-19 00:34:39) : tests_summary note champs JSON empty_message_id/whitespace_content_type.
Derniere mise a jour (2026-01-19 00:39:14) : scripts_overview detaille tests content_type/message_id.
Derniere mise a jour (2026-01-19 00:44:15) : scripts_overview note champs JSON empty_message_id/whitespace_content_type.
Derniere mise a jour (2026-01-19 00:49:21) : test_publish_test_message exige champs JSON empty_message_id/whitespace_content_type.
Derniere mise a jour (2026-01-19 00:54:14) : test_matrix note champs JSON empty_message_id/whitespace_content_type.
Derniere mise a jour (2026-01-19 00:59:12) : test_tools note champs JSON empty_message_id/whitespace_content_type.
Derniere mise a jour (2026-01-19 01:04:19) : corrige champs requis JSON publish_test_message.
Derniere mise a jour (2026-01-19 01:10:23) : tests maj defaults message_id/content_type + test ok.
Derniere mise a jour (2026-01-19 01:14:19) : script_env clarifie defaults content_type/message_id.
Derniere mise a jour (2026-01-19 01:19:14) : troubleshooting_env clarifie defaults content_type/message_id.
Derniere mise a jour (2026-01-19 01:24:18) : local_runbook clarifie defaults content_type/message_id.
Derniere mise a jour (2026-01-19 01:29:33) : local_usage note defaults message_id/content_type.
Derniere mise a jour (2026-01-19 01:34:17) : e2e_local clarifie defaults content_type/message_id.
Derniere mise a jour (2026-01-19 01:39:24) : quickstart note defaults content_type/message_id.
Derniere mise a jour (2026-01-19 01:44:36) : troubleshooting rappelle defaults content_type/message_id.
Derniere mise a jour (2026-01-19 01:49:20) : scripts_overview note defaults publish_test_message.
Derniere mise a jour (2026-01-19 01:54:37) : test_publish_test_message couvre content_type whitespace tab.
Derniere mise a jour (2026-01-19 01:59:19) : test_publish_test_message --json ok apres whitespace tab.
Derniere mise a jour (2026-01-19 02:04:14) : test_matrix mentionne content_type blanc espaces/tabs.
Derniere mise a jour (2026-01-19 02:09:26) : tests_summary mentionne content_type blanc espaces/tabs.
Derniere mise a jour (2026-01-19 02:14:28) : docs mentionnent content_type blanc espaces/tabs.
Derniere mise a jour (2026-01-19 02:19:16) : quickstart precise content_type blanc espaces/tabs.
Derniere mise a jour (2026-01-19 02:24:14) : local_usage precise content_type blanc espaces/tabs.
Derniere mise a jour (2026-01-19 02:29:15) : e2e_local precise content_type blanc espaces/tabs.
Derniere mise a jour (2026-01-19 02:34:15) : script_env precise content_type blanc espaces/tabs.
Derniere mise a jour (2026-01-19 02:39:14) : troubleshooting_env precise content_type blanc espaces/tabs.
Derniere mise a jour (2026-01-19 02:44:14) : local_runbook precise content_type blanc espaces/tabs.
Derniere mise a jour (2026-01-19 02:49:21) : troubleshooting precise content_type blanc espaces/tabs.
Derniere mise a jour (2026-01-19 02:54:27) : test_tools precise content_type blanc espaces/tabs.
Derniere mise a jour (2026-01-19 03:00:03) : test_publish_test_message verifie message_id tab + docs.
Derniere mise a jour (2026-01-19 03:04:16) : script_env precise message_id sans espaces/tabs.
Derniere mise a jour (2026-01-19 03:09:19) : troubleshooting_env precise message_id sans espaces/tabs.
Derniere mise a jour (2026-01-19 03:14:18) : local_runbook precise message_id sans espaces/tabs.
Derniere mise a jour (2026-01-19 03:19:17) : local_usage precise message_id sans espaces/tabs.
Derniere mise a jour (2026-01-19 03:24:17) : quickstart precise message_id sans espaces/tabs.
Derniere mise a jour (2026-01-19 03:29:17) : troubleshooting precise message_id sans espaces/tabs.
Derniere mise a jour (2026-01-19 03:34:22) : e2e_local precise message_id sans espaces/tabs.
Derniere mise a jour (2026-01-19 03:39:35) : test_publish_test_message couvre content_type whitespace newline.
Derniere mise a jour (2026-01-19 03:44:43) : docs precisent content_type blanc espaces/tabs/newlines.
Derniere mise a jour (2026-01-19 03:49:53) : docs precisent content_type blanc espaces/tabs/newlines partout.
Derniere mise a jour (2026-01-19 03:54:33) : test_publish_test_message couvre message_id whitespace newline.
Derniere mise a jour (2026-01-19 03:59:41) : docs precisent message_id espaces/tabs/newlines.
Derniere mise a jour (2026-01-19 04:04:58) : docs precisent message_id sans espaces/tabs/newlines.
Derniere mise a jour (2026-01-19 04:09:33) : scripts_overview detaille refus content_type/message_id.
Derniere mise a jour (2026-01-19 04:14:30) : local_runbook/local_usage mentionnent message_id newlines.
Derniere mise a jour (2026-01-19 04:19:39) : troubleshooting_env ajoute mention whitespace.
Derniere mise a jour (2026-01-19 04:24:28) : local_usage mentionne message_id sans espaces/tabs/newlines.
Derniere mise a jour (2026-01-19 04:31:19) : documentation racine enrichie (PROJETS_EXPLICATIONS.md).
Derniere mise a jour (2026-01-19 04:35:36) : publish_test_message refuse JSON invalide + test associe.
Derniere mise a jour (2026-01-19 04:39:48) : docs tests_* mentionnent payload JSON invalide.
Derniere mise a jour (2026-01-19 04:44:39) : troubleshooting mentionne payload JSON invalide.
Derniere mise a jour (2026-01-19 04:49:36) : local_usage mentionne erreur JSON invalide.
Derniere mise a jour (2026-01-19 04:54:27) : script_env mentionne JSON valide pour publish_test_message.
Derniere mise a jour (2026-01-19 04:59:30) : quickstart note JSON invalide pour publish_test_message.
Derniere mise a jour (2026-01-19 05:04:49) : test_publish_test_message verifie message erreur JSON invalide.
Derniere mise a jour (2026-01-19 05:09:30) : troubleshooting_env ajoute JSON invalide publish_test_message.
Derniere mise a jour (2026-01-19 05:14:29) : local_runbook note JSON invalide publish_test_message.
Derniere mise a jour (2026-01-19 05:19:41) : help publish_test_message mentionne JSON valide + test.
Derniere mise a jour (2026-01-19 05:24:29) : tests_summary detaille message erreur JSON invalide.
Derniere mise a jour (2026-01-19 05:29:25) : troubleshooting_env precise message JSON invalide.
Derniere mise a jour (2026-01-19 05:34:28) : http_endpoints mentionne JSON invalide pour POST /students.
Derniere mise a jour (2026-01-19 05:39:29) : e2e_local precise PAYLOAD_FILE JSON valide.
Derniere mise a jour (2026-01-19 05:44:37) : test_publish_test_message verifie chemin JSON invalide.
Derniere mise a jour (2026-01-19 05:50:21) : publish_test_message JSON error en mode --json + test.
Derniere mise a jour (2026-01-19 05:54:25) : scripts_overview mentionne sortie JSON d'erreur.
Derniere mise a jour (2026-01-19 05:59:22) : test_matrix mentionne JSON erreur publish_test_message.
Derniere mise a jour (2026-01-19 06:04:24) : test_tools mentionne sortie JSON d'erreur.
Derniere mise a jour (2026-01-19 06:09:28) : tests_summary precise status=error JSON invalide.
Derniere mise a jour (2026-01-19 06:15:37) : publish_test_message JSON error payload manquant + docs/tests.
Derniere mise a jour (2026-01-19 06:20:42) : erreurs JSON en --json pour validations publish_test_message.
Derniere mise a jour (2026-01-19 06:24:49) : test_publish_test_message JSON erreur content_type trop long.
Derniere mise a jour (2026-01-19 06:30:15) : tests JSON erreurs longueurs exchange/routing/message_id.
Derniere mise a jour (2026-01-19 06:34:23) : test_matrix mentionne erreurs JSON longueurs.
Derniere mise a jour (2026-01-19 06:39:25) : script_env mentionne erreurs JSON en --json.
Derniere mise a jour (2026-01-19 06:44:36) : README mentionne erreurs JSON en --json.
Derniere mise a jour (2026-01-19 06:49:54) : help mentionne status=error en --json + test.
Derniere mise a jour (2026-01-19 06:54:27) : local_usage mentionne status=error en --json.
Derniere mise a jour (2026-01-19 06:59:26) : local_runbook mentionne status=error en --json.
Derniere mise a jour (2026-01-19 07:04:24) : quickstart mentionne status=error en --json.
Derniere mise a jour (2026-01-19 07:09:27) : http_endpoints mentionne status=error pour POST /students.
Derniere mise a jour (2026-01-19 07:14:24) : troubleshooting mentionne status=error en --json.
Derniere mise a jour (2026-01-19 07:20:46) : publish_test_message JSON erreurs payload directory+readable + tests.
Derniere mise a jour (2026-01-19 07:24:46) : test_matrix/tests_summary ajoutent erreurs JSON payload.
Derniere mise a jour (2026-01-19 07:29:28) : troubleshooting_env ajoute payload not found/directory.
Derniere mise a jour (2026-01-19 07:34:30) : troubleshooting ajoute payload not found/directory.
Derniere mise a jour (2026-01-19 07:39:34) : test_tools detaille erreurs JSON payload manquant/illisible/dossier.
Derniere mise a jour (2026-01-19 07:44:32) : local_usage mentionne erreurs JSON payload manquant/illisible/dossier.
Derniere mise a jour (2026-01-19 07:49:27) : local_runbook mentionne erreurs JSON payload manquant/illisible/dossier.
Derniere mise a jour (2026-01-19 07:54:27) : quickstart mentionne erreurs JSON payload manquant/illisible/dossier.
Derniere mise a jour (2026-01-19 07:59:37) : json_error verifie python3 avant JSON.
Derniere mise a jour (2026-01-19 08:04:28) : scripts_overview note JSON errors si python3 dispo.
Derniere mise a jour (2026-01-19 08:09:24) : troubleshooting_env note --json sans python3.

## Contrat JSON
Voir docs/api_contract.md pour les contraintes du payload publish_test_message et les validations attendues par test_matrix/test_publish_test_message/test_e2e_local.

## Vérification locale

Utilisez `scripts/check_publish_payload.py --payload docs/sample_student.json` avant d'appeler `publish_test_message` pour valider les champs (longueurs, regex, absence d'espaces, payload directory lisible). Le flag `--json` facilite l'intégration à `test_publish_test_message`/`test_matrix` dans les CI et reproduit les erreurs documentées dans `docs/api_contract.md`.

## Exemple payload

Un exemple complet est disponible dans `docs/sample_publish_payload.json` ; il contient Exchange, routing key, doc type, content type, ID de message et payload référencé. Pour reproduire un run local ou alimenter des tests, utilisez ce fichier avec `scripts/check_publish_payload.py --payload docs/sample_publish_payload.json --json`, puis lancez `publish_test_message` pour confirmer que la requête passe la batterie de validations (`test_matrix`, `tests_summary`, etc.).

## Workflow complet

Le fichier `docs/publish_workflow.md` décrit l’ordre recommandé : préparer/valider le payload, exécuter `publish_test_message`, vérifier les PDF dans `PDF_OUTPUT_DIR`, et nettoyer les artefacts avant de relancer les scripts. Il s’appuie sur `check_publish_payload.py`, `publish_test_message --json`, et les exports CSV/JSON attendus par `tests_summary`/`logs_metrics`.

## Script de vérification rapide

`scripts/verify_publish_payload.sh` encapsule la validation (`check_publish_payload.py`) et accepte un payload et le dossier de ressources. Il peut être invoqué avec `--json` comme troisième argument pour intégrer la vérification dans un pipeline ou une check-list. Exemple : `./scripts/verify_publish_payload.sh docs/sample_publish_payload.json docs --json`.
