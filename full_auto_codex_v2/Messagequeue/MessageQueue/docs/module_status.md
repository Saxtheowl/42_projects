# Module status

| Module | Status | Notes |
| --- | --- | --- |
| producer | stub + tests | validation champs requis + health + routing tests |
| food_application consumer | stub + dummy PDF + test | appelle generate_dummy_pdf.py |
| financial_assistance consumer | stub + dummy PDF + test | appelle generate_dummy_pdf.py |
| transportation_costs consumer | stub + dummy PDF + test | appelle generate_dummy_pdf.py |
| contracts consumer | stub + dummy PDF + test | appelle generate_dummy_pdf.py |
| grant_other_documents consumer | stub + dummy PDF + test | appelle generate_dummy_pdf.py |

TODO: remplacer les dummy PDF par generation PDF reelle.
- Les PDFs sont ecrits dans `shared/pdfs/` (override via `PDF_OUTPUT_DIR`).
- Choisir une lib PDF (ex: OpenPDF, iText, Apache PDFBox) et documenter la dependance par module.
- Definir un template PDF par type de dossier (champs requis, ordre, libelles).
- Mapper les champs JSON du payload vers les sections du PDF (validation des valeurs manquantes).
- Mettre a jour les tests pour valider la creation du fichier et des metadonnees minimales.
- Ajouter un echantillon de sortie par module pour verification manuelle.
