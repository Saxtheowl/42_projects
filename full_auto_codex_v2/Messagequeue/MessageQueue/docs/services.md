# Services et responsabilites

## Producer
- **StudentsDataProducer (Spring Boot)** : expose un endpoint HTTP (formulaire ou REST) et publie le JSON etudiant vers :
  - `SOCIAL_ASSISTANCE_EXCHANGE` (fanout)
  - `GRANT_EXCHANGE` (topic) avec une routing key `grant.<type>`

## Consumers (social assistance)
- **FoodApplicationGenerator** : consomme `food_application`, genere un PDF `food_application_<studentId>_<timestamp>.pdf`.
- **FinancialAssistanceApplicationGenerator** : consomme `financial_assistance_application`, genere un PDF `financial_assistance_<studentId>_<timestamp>.pdf`.
- **TransportationCostsApplicationGenerator** : consomme `transportation_costs_application`, genere un PDF `transportation_costs_<studentId>_<timestamp>.pdf`.

## Consumers (grants)
- **ConsentGenerator / GuaranteeLetter / GrantApplication** : consomment `grant_other_documents`.
- **ContractGenerator** : consomme `grant_contracts`.

## Fichier de sortie
Tous les PDF doivent etre ecrits dans `shared/pdfs/` avec des noms uniques (prefixe type + studentId + timestamp).
Le dossier peut etre override via `PDF_OUTPUT_DIR`.
