# Run modules (local)

## Producer
```bash
cd services/producer
mvn spring-boot:run
```

## Consumers
```bash
cd services/consumers/food_application
mvn spring-boot:run
```

Assurer que RabbitMQ est demarre avant de lancer un consumer.

Remplacer par le consumer voulu :
- financial_assistance
- transportation_costs
- contracts
- grant_other_documents

## Env vars utiles
Voir `docs/service_env.md` et `docs/script_env.md`.
