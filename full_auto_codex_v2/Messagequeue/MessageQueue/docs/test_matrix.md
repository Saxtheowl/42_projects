# Test matrix

## RabbitMQ
- [x] API management reachable (`check_rabbitmq.sh`)
- [x] Topologie creee (`bootstrap_rabbitmq.sh` + `validate_rabbitmq.sh`)
- [x] Routing grants (`grant.1.contract` va vers 2 queues)

## Producer
- [ ] Publie vers `SOCIAL_ASSISTANCE_EXCHANGE` (fanout)
- [ ] Publie vers `GRANT_EXCHANGE` (topic)
- [ ] Payload JSON valide (schema)

## Payload
- [x] Validation payload (schema + grantType) via `validate_payload.py`
- [x] Tests payload (cas ok/ko) via `test_validate_payload.sh`
- [x] Dry-run publish_test_message (routing key + validations) via `test_publish_test_message.sh`
- [x] publish_test_message refuse exchange/routing key trop longs (tests dry-run)
- [x] publish_test_message refuse payload JSON invalide (tests dry-run)
- [x] publish_test_message JSON d'erreur en --json (tests dry-run)
- [x] publish_test_message JSON d'erreur en --json pour longueurs invalides (tests dry-run)
- [x] publish_test_message JSON d'erreur en --json pour payload manquant/illisible/dossier (tests dry-run)
- [x] publish_test_message MESSAGE_ID vide -> default (tests dry-run)
- [x] publish_test_message refuse MESSAGE_ID trop long/avec espaces/tabs/newlines (tests dry-run)
- [x] publish_test_message refuse CONTENT_TYPE blanc (espaces/tabs/newlines, tests dry-run)
- [x] publish_test_message CONTENT_TYPE vide -> default (tests dry-run)
- [x] publish_test_message JSON expose empty_message_id/whitespace_content_type (tests dry-run)

## Consumers
- [ ] Generent un PDF par message
- [ ] Nommage conforme (`pdf_naming.md`)
- [ ] Contenu minimal (`pdf_contents.md`)
- [ ] ACK policy respectee (`consumer_ack.md`)

## Smoke
- [ ] Un message test traverse tout le pipeline (e2e_local.sh)
 - [ ] PDFs visibles dans `shared/pdfs/` (ou `PDF_OUTPUT_DIR` si override)
- [x] Dry-run e2e_local JSON valide (test_e2e_local.sh)
Note: nettoyez `shared/pdfs/` apres validation.
