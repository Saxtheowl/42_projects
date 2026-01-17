# Configuration bootstrap RabbitMQ

Le script `scripts/bootstrap_rabbitmq.sh` utilise l'API management de RabbitMQ.
Variables d'environnement disponibles :

- `RABBITMQ_HOST` (defaut: `localhost`)
- `RABBITMQ_PORT` (defaut: `15672`)
- `RABBITMQ_USER` (defaut: `guest`)
- `RABBITMQ_PASS` (defaut: `guest`)
- `RABBITMQ_VHOST` (defaut: `/`)

Exemple :
```bash
RABBITMQ_HOST=127.0.0.1 RABBITMQ_USER=admin RABBITMQ_PASS=secret \
  ./scripts/bootstrap_rabbitmq.sh
```
