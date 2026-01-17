# StudentsDataProducer (stub)

Objectif : exposer un endpoint HTTP et publier le payload JSON vers les exchanges RabbitMQ.

Endpoints proposes : voir `docs/http_endpoints.md`.
Payload : `docs/sample_student.json`.

TODO : initialiser un projet Spring Boot (web + amqp) et publier vers :
- `SOCIAL_ASSISTANCE_EXCHANGE` (fanout)
- `GRANT_EXCHANGE` (topic)

## Run local (stub)
```bash
mvn spring-boot:run
```

## Endpoints
- `POST /students` (payload JSON, retourne `{status,routingKey}`)
- `GET /health`

## Env vars utiles
- `RABBITMQ_HOST` / `RABBITMQ_PORT`
- `RABBITMQ_USER` / `RABBITMQ_PASS`
- `RABBITMQ_VHOST`
- `PRODUCER_PORT`
