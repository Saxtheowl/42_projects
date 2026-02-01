# CRM Pro - Ruby on Rails Rush 01

Application CRM (Customer Relationship Management) complète developpee avec Ruby on Rails.

## Fonctionnalites

### Iteration 1 - Fonctionnalites Non Commerciales

#### Sprint 1: User Accounts
- Authentification avec Devise (pas de mot de passe en clair)
- Formulaires de connexion / deconnexion
- Notifications flash des evenements
- Modification des informations utilisateur
- Gestion des roles:
  - **Admin**: acces complet au back-office admin, CRUD total
  - **Manager**: acces au backoffice, lecture des donnees, assignation des groupes
  - **Operator**: fonctionnalites basiques, appartient a un groupe (Production, International, Commercial)
  - **Non enregistre**: acces aux parties publiques uniquement

#### Sprint 2: Admin Back-office
- CRUD complet pour toutes les entites (Users, Clients, Companies, Projects, Surveys)
- Gestion des privileges et roles
- Acces reserve a l'administrateur

#### Sprint 3: Site Vitrine
- Page d'accueil publique
- Presentation de l'entreprise
- Photos et videos
- Liens vers connexion/inscription

#### Sprint 4: In-mail (Messagerie Interne)
- Inbox: messages recus avec statut lu/nouveau
- Outbox: messages envoyes avec mention si lu par destinataire
- Envoi de messages individuels
- Liste de contacts avec groupe
- Generation PDF des messages
- Back-office: envoi aux groupes, envoi a tous, historique d'activite

### Iteration 2 - Fonctionnalites Commerciales

#### Sprint 1: Client Database
- Liste de clients (nom, prenom, email, tel, company, fonction)
- Tri alphabetique et par company
- Import CSV (gem roo)
- Export CSV
- Historique d'activite par client/company
- Assignation de clients aux operateurs

#### Sprint 2: Project Suite
- Projets avec nom, client, quotes, orders, invoices
- Quotes (devis): entete, items, intro rich text, total en euros
- Orders (commandes): entete, items, intro rich text, total en euros
- Invoices: incoming (depenses) et outgoing (facturation client)
- Generation PDF avec Prawn
- Back-office: graphiques Highcharts par semaine (profit, orders)
- Filtrage par client, company, ou global avec date picker

#### Sprint 3: Survey (Sondages)
- Creation de sondages par les operateurs
- Sondages publics avec questions oui/non
- Collecte des emails des repondants
- Rich text pour intro et remerciements
- Back-office: publication, import/export CSV des sondages et resultats

## Installation

```bash
# Cloner le projet
cd Formation_Ruby_on_Rails_-_Rush_01

# Installer les dependances
bundle install

# Creer et populer la base de donnees
rails db:create db:migrate db:seed

# Lancer le serveur
rails server
```

## Identifiants de connexion

| Role | Email | Mot de passe |
|------|-------|--------------|
| Admin | admin@example.com | password123 |
| Manager | manager@example.com | password123 |
| Operator (Production) | operator1@example.com | password123 |
| Operator (International) | operator2@example.com | password123 |
| Operator (Commercial) | operator3@example.com | password123 |

## Technologies utilisees

- Ruby 2.7.8
- Rails 5.2.8
- SQLite3
- Bootstrap 3 (bootstrap-sass)
- Devise (authentification)
- Prawn (generation PDF)
- Roo (import CSV)
- Highcharts (graphiques)
- jQuery UI (date picker)

## Gems autorisees utilisees

- **Devise** - Authentification
- **Bootstrap-sass** - Styling
- **Bootstrap_form** - Formulaires
- **Prawn / Prawn-table** - Generation PDF
- **Roo** - Import CSV
- **Lazy_high_charts** - Graphiques
- **jQuery-ui-rails** - Date picker

## Structure du projet

```
app/
├── controllers/
│   ├── admin/           # Back-office admin
│   ├── backoffice/      # Back-office manager
│   ├── clients_controller.rb
│   ├── in_mails_controller.rb
│   ├── invoices_controller.rb
│   ├── orders_controller.rb
│   ├── projects_controller.rb
│   ├── quotes_controller.rb
│   └── surveys_controller.rb
├── models/
│   ├── user.rb          # Roles: admin, manager, operator
│   ├── client.rb
│   ├── company.rb
│   ├── project.rb
│   ├── quote.rb
│   ├── order.rb
│   ├── invoice.rb       # Types: incoming, outgoing
│   ├── line_item.rb     # Polymorphic
│   ├── in_mail.rb
│   ├── survey.rb
│   ├── survey_question.rb
│   ├── survey_response.rb
│   ├── survey_answer.rb
│   └── activity_log.rb
└── views/
    ├── admin/           # Vues admin
    ├── backoffice/      # Vues manager
    └── ...              # Vues publiques
```

## Contraintes respectees

- Pas de mots-cles interdits (while, for, redo, break, retry, loop, until)
- Pas de gems interdites (rolify, cancan, rails-admin, active-admin)
- Seed complete pour demonstration
- Mise en page avec Bootstrap
- Structure claire et lisible

## Auteur

Formation Ruby on Rails - Piscine 42
