# Logging

- Producer: logs requests + routing key.
- Consumers: logs payload recu et generation PDF dummy.
- Les logs indiquent le chemin du PDF genere (par defaut `shared/pdfs/`, override via `PDF_OUTPUT_DIR`).

Logs utilises : SLF4J (par defaut Spring Boot).
