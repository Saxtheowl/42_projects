# Endpoints du producer (propose)

- `POST /students` : payload JSON etudiant (grantType requis, routing key). Publie vers exchanges si valide. Retour JSON `{status,routingKey}`. En cas de JSON invalide, reponse d'erreur explicite attendue (ex: `status=error`).
- `GET /health` : status ok.
- `GET /docs` : swagger/openapi (optionnel).
Note: l'API ne renvoie pas le PDF; la generation est faite par les consumers dans `shared/pdfs/`.
Note: `PDF_OUTPUT_DIR` permet d'override le dossier de sortie.

Payload : voir `docs/sample_student.json`.
Test rapide :
```bash
./scripts/post_sample.sh
```
