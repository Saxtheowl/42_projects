# Tests consumers

Chaque consumer contient un test simple pour la generation PDF dummy.

Exemple :
```bash
cd services/consumers/food_application
mvn test
```
Option (desactiver PDF dummy via property) :
```bash
mvn test -Dpdf.disabled=1
```

Ou via le script :
```bash
./scripts/test_consumers.sh
```
Nettoyage des PDFs de test :
```bash
rm -f shared/pdfs/*
```
Note: `PDF_OUTPUT_DIR` permet d'override le dossier de sortie.

Voir les autres modules :
- financial_assistance
- transportation_costs
- contracts
- grant_other_documents
