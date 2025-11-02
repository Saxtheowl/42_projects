# ft_hangouts — Notes d'analyse

## Objectifs clés (d’après `Sujet_ft_hangouts.pdf`)
- Proposer un service centralisant la communication entre 42 students (équivalent Slack).
- Permettre la création de « hangouts » thématiques, de notifications, de relay d’événements.
- Côté utilisateur : interface simple, modération, gestion des rôles.
- Côté technique : API REST ou WebSocket, base de données et authentification.
- L’évaluation se concentre sur la clarté de l’analyse, les parcours utilisateurs et la cohérence produit.

## Conseils du sujet
- Ne pas coder un MVP complet si non nécessaire ; privilégier la conception.
- Rédiger documentation claire : objectifs, cibles, maquettes, backlog priorisé.
- Présenter un pitch et un plan d’implémentation (technos, organisation).

## Périmètre retenu (proposition initiale)
1. **Personas** : étudiant primo arrivant, mentor, modérateur.
2. **User journeys** :
   - créer un hangout (salon) public/privé,
   - rechercher un salon par thème,
   - poster un message (texte, liens, PDF),
   - recevoir notifications (push/email),
   - modération (archivage, bannissement).
3. **Architecture** :
   - API REST JSON + WebSocket pour temps réel,
   - BDD relationnelle (PostgreSQL) ou NoSQL,
   - Auth via OAuth intra 42 (ou mock).
4. **Prototype** :
   - CLI ou interface web simple (React + API mock),
   - scripts démonstration (`scripts/demo.sh`).

## Livrables envisagés
- Dossier fonctionnel (personas, parcours, maquettes).
- Plan technique (diagrammes, endpoints, schéma BDD).
- Prototype (optionnel mais recommandé).
- Tests/documentation (`tests_realisation/`).
