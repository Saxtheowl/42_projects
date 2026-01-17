# Test matrix

## RabbitMQ
- [x] API management reachable (`check_rabbitmq.sh`)
- [x] Topologie creee (`bootstrap_rabbitmq.sh` + `validate_rabbitmq.sh`)
- [x] Routing grants (`grant.1.contract` va vers 2 queues)

## Producer
- [ ] Publie vers `SOCIAL_ASSISTANCE_EXCHANGE` (fanout)
- [ ] Publie vers `GRANT_EXCHANGE` (topic)
- [ ] Payload JSON valide (schema)

## Consumers
- [ ] Generent un PDF par message
- [ ] Nommage conforme (`pdf_naming.md`)
- [ ] Contenu minimal (`pdf_contents.md`)
- [ ] ACK policy respectee (`consumer_ack.md`)

## Smoke
- [ ] Un message test traverse tout le pipeline
- [ ] PDFs visibles dans `shared/pdfs/`
