# Queues - but et contenu

- `food_application` : demande d'aide alimentaire.
- `financial_assistance_application` : demande d'aide financiere.
- `transportation_costs_application` : prise en charge des transports.
- `grant_other_documents` : consent/guarantee/GrantApplication (routing `grant.#`).
- `grant_contracts` : contrats niveau 1 (routing `grant.1.*`).
Les consumers ecrivent les PDFs dans `shared/pdfs/` (override via `PDF_OUTPUT_DIR`).
