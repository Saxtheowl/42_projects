# D09 - Formation Ruby on Rails

Ce projet couvre l'utilisation d'AJAX et d'Action Cable (WebSockets) dans Rails 5.

## Structure

```
D09_-_Formation_Ruby_on_Rails/
├── ex00/Xnote/    # Francis_1 - AJAX Create
├── ex01/Xnote/    # Francis_2 - AJAX Destroy
├── ex02/Xnote/    # Francis_3 - AJAX Edit
├── ex03/Xnote/    # Francis_4 - Compteur de livres
├── ex04/Chat/     # ChatOne - Chat temps reel
├── ex05/Chat/     # ChatTwo - ChatRooms
└── ex06/Chat/     # ChatThree - Notifications
```

## Exercices

### Ex00-03: Xnote (AJAX CRUD)

Application de gestion de livres avec CRUD en AJAX.

**Installation:**
```bash
cd ex00/Xnote
bundle install
rails db:migrate
rails server
```

**Fonctionnalites:**
- Ajout de livres en AJAX (formulaire apparait sans rechargement)
- Suppression en AJAX avec confirmation
- Edition en AJAX avec gestion des erreurs
- Compteur de livres mis a jour dynamiquement
- Variable $refresh reste a 1 (pas de rechargement de page)

**Fichiers cles:**
- `app/assets/javascripts/application.js` - jquery, jquery_ujs, turbolinks uniquement
- `app/views/books/*.js.erb` - Templates JS pour AJAX
- `app/models/book.rb` - Validation d'unicite sur name

### Ex04: ChatOne (Chat temps reel)

Application de chat avec ActionCable et Devise.

**Installation:**
```bash
cd ex04/Chat
bundle install
rails db:migrate
rails server
```

**Fonctionnalites:**
- Authentification avec Devise
- Messages en temps reel via WebSockets
- ActiveJob pour le broadcast des messages

**Architecture:**
- `ChatChannel` - Canal ActionCable
- `MessageBroadcastJob` - Job pour broadcaster les messages
- Partial `_message.html.erb` pour le rendu

### Ex05: ChatTwo (ChatRooms)

Extension de ChatOne avec des salons de discussion.

**Fonctionnalites:**
- Creation de ChatRooms par les utilisateurs authentifies
- Messages isoles par salon
- Suppression en cascade (user -> chatrooms -> messages)

**Modeles:**
- User has_many :chatrooms, :messages
- Chatroom belongs_to :user, has_many :messages
- Message belongs_to :user, :chatroom

### Ex06: ChatThree (Notifications)

Extension de ChatTwo avec notifications temps reel.

**Fonctionnalites:**
- Notifications pour les messages des autres utilisateurs
- Compteur de notifications
- Son de notification

**Composants:**
- `NotificationsChannel` - Canal pour les notifications
- `NotificationBroadcastJob` - Job pour envoyer les notifications
- Audio HTML5 pour le son

## Contraintes Respectees

- Rails 5+
- Seuls jquery, jquery_ujs, turbolinks en JavaScript
- Pas de gems AJAX externes (best_in_place, etc.)
- Pas de while, for, redo, break, retry, loop, until en Ruby

## Tests

Pour tester les applications:

1. Lancer le serveur: `rails server -p 3000`
2. Ouvrir plusieurs fenetres en navigation privee
3. S'authentifier avec differents comptes
4. Verifier les fonctionnalites temps reel

## Technologies

- Ruby 2.7+
- Rails 5.2+
- SQLite3
- jQuery
- ActionCable
- Devise
- ActiveJob
