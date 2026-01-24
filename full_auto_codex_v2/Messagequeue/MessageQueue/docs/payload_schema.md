# Payload schema (propose)

Champs minimaux :
- `studentId` (string)
- `firstName` (string)
- `lastName` (string)
- `email` (string)
- `grantType` (string, routing key `grant.*.*`)

Champs utiles :
- `program` (string)
- `year` (int)
- `incomeBracket` (string)
- `needsTransportationAssistance` (bool)
- `metadata` (object)

Exemple : voir `docs/sample_student.json`.
Note: les consumers generent des PDFs dans `shared/pdfs/` (override via `PDF_OUTPUT_DIR`).
Validation locale :
```bash
./scripts/validate_payload.py
```
Note: `PAYLOAD_FILE` est resolu depuis la racine du repo si besoin.
Validation JSON :
```bash
./scripts/validate_payload.py --json
```
