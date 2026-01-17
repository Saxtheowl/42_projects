# Endpoints du producer (propose)

- `POST /students` : payload JSON etudiant, publie vers exchanges. Retour JSON `{status,routingKey}`.
- `GET /health` : status ok.
- `GET /docs` : swagger/openapi (optionnel).

Payload : voir `docs/sample_student.json`.
Test rapide :
```bash
./scripts/post_sample.sh
```
