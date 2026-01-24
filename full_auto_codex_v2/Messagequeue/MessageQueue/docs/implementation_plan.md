# Plan d'implementation

## Objectif
Definir un plan d'execution pour livrer le producteur web et les consommateurs RabbitMQ avec generation de PDF.

## Modules proposes (Java)
- StudentsDataProducer (Spring Boot web + AMQP)
  - REST: POST /students-data
  - Publie vers `SOCIAL_ASSISTANCE_EXCHANGE` (fanout) et `GRANT_EXCHANGE` (topic)
- FoodApplicationGenerator (consumer)
- FinancialAssistanceApplicationGenerator (consumer)
- TransportationCostsApplicationGenerator (consumer)
- ContractGenerator (consumer)

Chaque module est autonome (projet Java separe) et ecrit ses PDFs dans `shared/pdfs/`.

## Dependances recommandees
- Spring Boot 3.x (web + amqp)
- spring-boot-starter-amqp
- lombok (optionnel)
- apache-pdfbox (generation PDF simple)

## Configuration (env)
- RABBITMQ_HOST (defaut: localhost)
- RABBITMQ_PORT (defaut: 5672)
- RABBITMQ_USER / RABBITMQ_PASS
- RABBITMQ_VHOST (defaut: /)
- PDF_OUTPUT_DIR (defaut: shared/pdfs)
Note: PDF_OUTPUT_DIR doit etre accessible en ecriture par les consumers.

## Files/messages
- Payload: voir `docs/payload_schema.md`
- Sample: `docs/sample_student.json`
- Routing keys: `docs/sample_routing_keys.md`

## Etapes concretes
1) Initialiser un squelette Spring Boot pour chaque module.
2) Implementer le producer REST + publish AMQP.
3) Implementer un consumer par queue, avec ack manuel (voir `docs/consumer_ack.md`).
4) Generer un PDF minimal par message (voir `docs/pdf_contents.md`).
5) Ajouter scripts de run locaux et smoke tests.
