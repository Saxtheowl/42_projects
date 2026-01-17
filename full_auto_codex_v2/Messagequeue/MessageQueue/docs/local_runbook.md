# Runbook local

Sequence rapide pour valider RabbitMQ et les scripts sans code Java.

1) Preparer l'environnement :
```bash
./scripts/setup_env.sh
./scripts/load_env.sh
```

2) Verifier les prerequis :
```bash
./scripts/check_prereqs.sh
```

3) Demarrer RabbitMQ et initialiser la topologie :
```bash
docker compose up -d
./scripts/bootstrap_rabbitmq.sh
./scripts/validate_rabbitmq.sh
```

4) Publier et consommer un message de test :
```bash
./scripts/publish_test_message.sh
QUEUE="grant_contracts" ./scripts/consume_test_message.sh
```

5) Verifier le routage grant.1.contract :
```bash
./scripts/test_routing.sh
```

6) Rapport rapide :
```bash
./scripts/status_report.sh
```

7) Nettoyage (PDFs locaux) :
```bash
rm -f shared/pdfs/*
```
