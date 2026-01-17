# Contenu minimal des PDFs

Chaque PDF genere doit contenir au minimum :
- Identifiant etudiant (`studentId`)
- Nom + prenom
- Type de document (ex: `food_application`, `grant_contract`)
- Date de generation

Optionnel (si disponible dans le payload) :
- Programme / annee
- Email
- Informations specifiques (ex: justification, montant)

## PDF dummy (test local)
Script pour generer un PDF minimal :
```bash
./scripts/generate_dummy_pdf.py
```
Simulation consumer (PDF nomme + studentId) :
```bash
DOC_TYPE=food_application ./scripts/simulate_consumer.py
```
