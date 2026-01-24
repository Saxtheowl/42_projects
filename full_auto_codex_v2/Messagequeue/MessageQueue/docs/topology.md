# Topologie RabbitMQ

## Exchanges
- `SOCIAL_ASSISTANCE_EXCHANGE` (fanout)
- `GRANT_EXCHANGE` (topic)

## Queues et bindings
### Social assistance (fanout)
- Queue `food_application` -> bind `SOCIAL_ASSISTANCE_EXCHANGE`
- Queue `financial_assistance_application` -> bind `SOCIAL_ASSISTANCE_EXCHANGE`
- Queue `transportation_costs_application` -> bind `SOCIAL_ASSISTANCE_EXCHANGE`

### Grants (topic)
- Queue `grant_other_documents` -> bind `GRANT_EXCHANGE` avec `grant.#`
- Queue `grant_contracts` -> bind `GRANT_EXCHANGE` avec `grant.1.*`

## Routage attendu (exemples)
- `grant.application` -> `grant_other_documents`
- `grant.guarantee` -> `grant_other_documents`
- `grant.1.contract` -> `grant_contracts` + `grant_other_documents`
- `grant.2.contract` -> `grant_other_documents` seulement

## Dossier PDF
Chemin cible commun (a definir dans la config de chaque service) :
- `./shared/pdfs/`
Note: override via `PDF_OUTPUT_DIR` si besoin.

Chaque consumer doit ecrire des noms uniques, ex :
`food_application_<timestamp>.pdf`
`grant_contract_<studentId>_<timestamp>.pdf`
