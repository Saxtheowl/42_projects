# StudentsDataProducer (stub)

Objectif : exposer un endpoint HTTP et publier le payload JSON vers les exchanges RabbitMQ.

Endpoints proposes : voir `docs/http_endpoints.md`.
Payload : `docs/sample_student.json`.

Publie vers :
- `SOCIAL_ASSISTANCE_EXCHANGE` (fanout)
- `GRANT_EXCHANGE` (topic)

## Run local (stub)
```bash
mvn spring-boot:run
```
Ou via script :
```bash
../../scripts/run_producer.sh
```

## Endpoints
- `POST /students` (payload JSON, retourne `{status,routingKey}`)
- `GET /health`

## Env vars utiles
- `RABBITMQ_HOST` / `RABBITMQ_PORT`
- `RABBITMQ_USER` / `RABBITMQ_PASS`
- `RABBITMQ_VHOST`
- `PRODUCER_PORT`
- `SOCIAL_EXCHANGE` / `GRANT_EXCHANGE`

## Config exchanges
Les noms des exchanges sont centralises dans `ExchangeNames`.
