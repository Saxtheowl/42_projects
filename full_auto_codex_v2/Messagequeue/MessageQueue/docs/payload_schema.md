# Payload schema (propose)

Champs minimaux :
- `studentId` (string)
- `firstName` (string)
- `lastName` (string)
- `email` (string)

Champs utiles :
- `program` (string)
- `year` (int)
- `incomeBracket` (string)
- `needsTransportationAssistance` (bool)
- `grantType` (string)
- `metadata` (object)

Exemple : voir `docs/sample_student.json`.
Validation locale :
```bash
./scripts/validate_payload.py
```
