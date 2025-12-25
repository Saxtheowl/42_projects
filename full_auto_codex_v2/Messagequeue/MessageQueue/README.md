# Message Queue

## Synthèse
Suite de projets RabbitMQ : un producteur web (Spring Boot) StudentsDataProducer publie les données JSON des étudiants vers deux exchanges :
- `SOCIAL_ASSISTANCE_EXCHANGE` (FANOUT) vers trois queues et consommateurs : FoodApplicationGenerator, FinancialAssistanceApplicationGenerator, TransportationCostsApplicationGenerator.
- `GRANT_EXCHANGE` (TOPIC) vers `grant_other_documents` (binding `grant.#` pour Consent/GuaranteeLetter/GrantApplication) et `grant_contracts` (binding `grant.1.*` pour ContractGenerator).
Chaque message déclenche la génération de PDF (noms distinctifs) déposés dans un dossier partagé. Chaque producteur/consommateur est un projet Java séparé. Broker RabbitMQ requis en local.

## Avancement
- [x] Copie du sujet (`docs/MessageQueue.pdf`).
- [x] Lecture rapide du sujet et exigences (exchanges, queues, bindings, PDF à générer).
- [ ] Planification détaillée (modules Maven/Gradle, schéma exchanges/queues).
- [ ] Implémentation (web producer + 4 consommateurs).

Mise à jour (2025-12-06 11:35:31) : Lecture rapide faite ; blocage : RabbitMQ non présent sur l’environnement (installation requise). Projet en attente jusqu’à disposition d’un broker ou conteneur RabbitMQ.
