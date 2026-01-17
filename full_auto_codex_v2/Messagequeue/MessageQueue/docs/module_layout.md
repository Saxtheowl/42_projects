# Module layout (propose)

```
services/
  producer/
  consumers/
    food_application/
    financial_assistance/
    transportation_costs/
    grant_contracts/
    grant_other_documents/
```

Chaque dossier contiendra un projet Java (Spring Boot ou console) avec :
- build tool (Maven/Gradle)
- config RabbitMQ (host, exchanges/queues)
- sortie PDF vers `shared/pdfs/`
