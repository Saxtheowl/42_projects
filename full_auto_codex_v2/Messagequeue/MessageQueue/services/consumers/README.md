# Consumers (index)

Mapping des consumers vers les queues :
- food_application -> FoodApplicationGenerator
- financial_assistance_application -> FinancialAssistanceApplicationGenerator
- transportation_costs_application -> TransportationCostsApplicationGenerator
- grant_contracts -> ContractGenerator
- grant_other_documents -> GrantOtherDocumentsGenerator

Voir les README de chaque consumer dans les sous-dossiers.

## Run local
```bash
cd services/consumers/food_application
mvn spring-boot:run
```

Les consumers activent l'annotation `@EnableRabbit` par defaut.

## Env vars utiles
- `CONSUMER_QUEUE` (override queue name)
- `RABBITMQ_HOST` / `RABBITMQ_PORT`
- `RABBITMQ_USER` / `RABBITMQ_PASS`
- `RABBITMQ_VHOST`
