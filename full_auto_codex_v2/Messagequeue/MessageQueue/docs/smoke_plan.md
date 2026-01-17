# Smoke plan (local)

Objectif : valider le broker + routage + generation PDFs avant l'integration complete.

1) Demarrer RabbitMQ et preparer la topologie :
```bash
./scripts/check_prereqs.sh
docker compose up -d
./scripts/bootstrap_and_validate.sh
```

Alternative rapide :
```bash
./scripts/smoke_local.sh
```

2) Lancer un consumer factice (ex: log simple) et publier un message test.

3) Verifier :
- messages recus par chaque queue
- PDF ou artefact genere dans `shared/pdfs/`
- routing key `grant.1.contract` duplique bien dans `grant_contracts` et `grant_other_documents`

4) Nettoyage :
```bash
rm -f shared/pdfs/*
```
