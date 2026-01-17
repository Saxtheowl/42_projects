# Plan Message Queue

## Étapes
- [x] Lire le sujet (`docs/MessageQueue.pdf`) et identifier les livrables.
- [x] Définir arborescence (modules Maven/Gradle séparés : producer web + 4 consumers), dossier partagé pour PDF.
- [x] Déployer/accéder à un broker RabbitMQ local (docker-compose ajouté).
- [x] Ecrire scripts setup (check/bootstrap/validate) et doc quickstart.
- [ ] Implémentation incrémentale : producer (Spring Boot REST form + publish JSON) ; consumers (console Java, génération PDF).
- [ ] Tests end-to-end avec RabbitMQ et vérification des PDF générés.
- [ ] Documentation (README, instructions de déploiement).

Blocage (2025-12-06 11:35:31) : Broker RabbitMQ absent sur l’environnement; reprendre après installation/disponibilité d’un RabbitMQ local (ou conteneur).
