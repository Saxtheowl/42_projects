# Troubleshooting

## API management 401/403
- Verifier `RABBITMQ_USER`/`RABBITMQ_PASS`.
- Si un vhost custom est utilise, definir `RABBITMQ_VHOST`.

## API management not reachable
- S'assurer que RabbitMQ est demarre (`docker compose ps`).
- Verifier le port 15672.

## Bindings manquants
- Relancer `./scripts/bootstrap_rabbitmq.sh`.
- Valider via `./scripts/validate_rabbitmq.sh`.

## Environnement
Voir `docs/troubleshooting_env.md`.
