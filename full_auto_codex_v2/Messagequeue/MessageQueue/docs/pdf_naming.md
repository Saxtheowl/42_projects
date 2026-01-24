# Convention de nommage PDF

Objectif : noms uniques, triables par temps et faciles a tracer.

Format recommande :
```
<type>_<studentId>_<YYYYMMDD-HHMMSS>.pdf
```

Exemples :
- `food_application_S-0001_20260117-120000.pdf`
- `grant_contract_S-0420_20260117-120005.pdf`
- `transportation_costs_S-0001_20260117-120010.pdf`

Notes :
- Toujours inclure `studentId` si disponible.
- Le timestamp doit etre en UTC ou l'heure locale mais stable (format 24h).
- Les PDFs sont ecrits dans `shared/pdfs/` (override via `PDF_OUTPUT_DIR`).
