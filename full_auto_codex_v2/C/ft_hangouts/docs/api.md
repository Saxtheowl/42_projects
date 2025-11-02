# API / Endpoints (Proposition)

## Authentification
- OAuth 2.0 via 42 Intra (Authorization Code flow).
- Jeton d'accès renvoyé à l'app mobile, refresh token stocké côté backend.

## Base URL
`https://api.ft-hangouts.example.com/v1`

## Ressources principales

### Contacts
- `GET /contacts` → liste paginée (query `search`, `tags`, `page`).
- `POST /contacts` → création (payload JSON : prénom, nom, tel, email, tags, notes).
- `GET /contacts/{id}` → détails + dernières interactions.
- `PUT /contacts/{id}` → mise à jour.
- `DELETE /contacts/{id}` → suppression logique (flag `archived`).

### Messages
- `GET /contacts/{id}/messages` → historique ordonné (support `since` timestamp).
- `POST /contacts/{id}/messages` → envoi message (backend push via provider SMS).
- `POST /webhooks/messages` → endpoint recevant SMS entrants (webhook opérateur) -> push vers client via WebSocket.

### Hangouts
- `GET /hangouts` → explore public/private (avec rôle).
- `POST /hangouts` → création (nom, description, visibility, tags).
- `POST /hangouts/{id}/members` → invite contact.
- `DELETE /hangouts/{id}/members/{contactId}` → retire.

### Notifications
- `POST /devices/register` → associer token push (Firebase).
- `POST /notifications/test` → (staff) tester message broadcast.

## WebSocket (temps réel)
- URI : `wss://api.ft-hangouts.example.com/ws`
- Auth : Bearer token.
- Événements : `message:new`, `hangout:updated`, `contact:created`.

## Sécurité
- Ratelimiting 100 req/min.
- Logs audit pour actions staff.
- Données chiffrées en transit (TLS).

## Roadmap implémentation
1. MVP mobile + backend mock (JSON server / CLI).
2. Backend Node.js + PostgreSQL + Prisma.
3. Intégration push notifications (FCM).
4. Monitoring (Grafana) + CI/CD GitHub Actions.
