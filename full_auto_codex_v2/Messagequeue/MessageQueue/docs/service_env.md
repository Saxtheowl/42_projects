# Variables d'environnement par service

## Commun
- `RABBITMQ_HOST` (ex: `localhost`)
- `RABBITMQ_PORT` (ex: `5672`)
- `RABBITMQ_USER` / `RABBITMQ_PASS`
- `RABBITMQ_VHOST` (ex: `/`)
- `PDF_OUTPUT_DIR` (ex: `shared/pdfs`)
- `PDF_DISABLED` (defaut: 0, desactive generation PDF dummy)
- `pdf.disabled` (system property, defaut: 0, equivalent a PDF_DISABLED)
Note: `PDF_OUTPUT_DIR` doit etre accessible en ecriture par les consumers.

## Producer (StudentsDataProducer)
- `SOCIAL_EXCHANGE` (defaut: `SOCIAL_ASSISTANCE_EXCHANGE`)
- `GRANT_EXCHANGE` (defaut: `GRANT_EXCHANGE`)
- `PRODUCER_PORT` (defaut: `8080`)

## Consumers (social assistance)
- `CONSUMER_QUEUE` (ex: `food_application`)
- `SOCIAL_EXCHANGE` (defaut: `SOCIAL_ASSISTANCE_EXCHANGE`)

## Consumers (grants)
- `CONSUMER_QUEUE` (ex: `grant_contracts`)
- `GRANT_EXCHANGE` (defaut: `GRANT_EXCHANGE`)
- `CONSUMER_ROUTING_KEY` (ex: `grant.*.contract`)
