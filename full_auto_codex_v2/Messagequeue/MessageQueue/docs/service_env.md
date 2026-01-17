# Variables d'environnement par service

## Commun
- `RABBITMQ_HOST` (ex: `localhost`)
- `RABBITMQ_PORT` (ex: `5672`)
- `RABBITMQ_USER` / `RABBITMQ_PASS`
- `RABBITMQ_VHOST` (ex: `/`)
- `PDF_OUTPUT_DIR` (ex: `shared/pdfs`)

## Producer (StudentsDataProducer)
- `SOCIAL_ASSISTANCE_EXCHANGE`
- `GRANT_EXCHANGE`
- `DEFAULT_GRANT_ROUTING_KEY` (ex: `grant.application`)

## Consumers (social assistance)
- `QUEUE_NAME` (ex: `food_application`)
- `EXCHANGE_NAME` (ex: `SOCIAL_ASSISTANCE_EXCHANGE`)

## Consumers (grants)
- `QUEUE_NAME` (ex: `grant_contracts`)
- `EXCHANGE_NAME` (ex: `GRANT_EXCHANGE`)
- `ROUTING_KEY` (ex: `grant.1.*`)
