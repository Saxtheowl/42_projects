# Quickstart local

```bash
docker compose up -d
./scripts/check_rabbitmq.sh
./scripts/bootstrap_rabbitmq.sh
./scripts/validate_rabbitmq.sh
```

Option tout-en-un :
```bash
./scripts/bootstrap_and_validate.sh
```
