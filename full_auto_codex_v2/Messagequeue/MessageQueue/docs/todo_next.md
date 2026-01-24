# TODO next

Prochaines etapes proposees :
1) Ajouter tests e2e (publish -> consume -> PDF) avec RabbitMQ local.
2) Remplacer la generation PDF dummy par une generation reelle.
3) Ajouter un job CI simple (tests producer + consumers) si besoin.

Details proposes :
- Tests e2e:
  - Lancer RabbitMQ via docker compose.
  - Publier un payload connu par type de document.
  - Verifier reception, ack, creation du PDF et nommage attendu.
  - Nettoyer les fichiers et queues apres test.
  - Documenter le repertoire de sortie et l'override `PDF_OUTPUT_DIR`.
- PDF reel:
  - Choisir une librairie PDF commune aux consumers.
  - Definir un template minimal (titre, date, identifiant).
  - Mapper les champs JSON vers le template et gerer les champs manquants.
  - Ajouter un test qui verifie contenu et taille > 0.
- CI:
  - Job unique: build + tests unitaires producer/consumers.
  - Optionnel: job e2e derriere un flag (si RabbitMQ dispo).
