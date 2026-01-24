# Run modules (local)

## Producer
```bash
cd services/producer
mvn spring-boot:run
```
Ou via script :
```bash
./scripts/run_producer.sh
```

## Consumers
```bash
cd services/consumers/food_application
mvn spring-boot:run
```
Ou via script :
```bash
./scripts/run_consumer.sh food_application
```

Assurer que RabbitMQ est demarre avant de lancer un consumer.

Remplacer par le consumer voulu :
- financial_assistance
- transportation_costs
- contracts
- grant_other_documents

## PDFs generes
Les consumers ecrivent des PDFs de test dans `shared/pdfs/`.
Override possible via `PDF_OUTPUT_DIR`.
Nettoyage rapide :
```bash
rm -f shared/pdfs/*
```

## Env vars utiles
Voir `docs/service_env.md` et `docs/script_env.md`.
