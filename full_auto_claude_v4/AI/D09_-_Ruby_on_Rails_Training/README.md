# D09 - Ruby on Rails Training

This project covers the use of AJAX and Action Cable (WebSockets) in Rails 5.

## Structure

```
D09_-_Ruby_on_Rails_Training/
├── ex00/Xnote/    # Francis_1 - AJAX Create
├── ex01/Xnote/    # Francis_2 - AJAX Destroy
├── ex02/Xnote/    # Francis_3 - AJAX Edit
├── ex03/Xnote/    # Francis_4 - Book counter
├── ex04/Chat/     # ChatOne - Real-time chat
├── ex05/Chat/     # ChatTwo - ChatRooms
└── ex06/Chat/     # ChatThree - Notifications
```

## Exercises

### Ex00-03: Xnote (AJAX CRUD)

Book management application with AJAX CRUD.

**Installation:**
```bash
cd ex00/Xnote
bundle install
rails db:migrate
rails server
```

**Features:**
- Add books via AJAX (form appears without page reload)
- Delete via AJAX with confirmation
- Edit via AJAX with error handling
- Dynamic book counter
- $refresh variable stays at 1 (no page reload)

**Key files:**
- `app/assets/javascripts/application.js` - jquery, jquery_ujs, turbolinks only
- `app/views/books/*.js.erb` - JS templates for AJAX
- `app/models/book.rb` - Uniqueness validation on name

### Ex04: ChatOne (Real-time chat)

Chat application with ActionCable and Devise.

**Installation:**
```bash
cd ex04/Chat
bundle install
rails db:migrate
rails server
```

**Features:**
- Authentication with Devise
- Real-time messages via WebSockets
- ActiveJob for message broadcasting

**Architecture:**
- `ChatChannel` - ActionCable channel
- `MessageBroadcastJob` - Job for broadcasting messages
- `_message.html.erb` partial for rendering

### Ex05: ChatTwo (ChatRooms)

Extension of ChatOne with chat rooms.

**Features:**
- ChatRoom creation by authenticated users
- Messages isolated per room
- Cascade delete (user -> chatrooms -> messages)

**Models:**
- User has_many :chatrooms, :messages
- Chatroom belongs_to :user, has_many :messages
- Message belongs_to :user, :chatroom

### Ex06: ChatThree (Notifications)

Extension of ChatTwo with real-time notifications.

**Features:**
- Notifications for messages from other users
- Notification counter
- Notification sound

**Components:**
- `NotificationsChannel` - Channel for notifications
- `NotificationBroadcastJob` - Job to send notifications
- HTML5 Audio for sound

## Constraints Respected

- Rails 5+
- Only jquery, jquery_ujs, turbolinks in JavaScript
- No external AJAX gems (best_in_place, etc.)
- No while, for, redo, break, retry, loop, until in Ruby

## Testing

To test the applications:

1. Start the server: `rails server -p 3000`
2. Open multiple private browsing windows
3. Authenticate with different accounts
4. Verify real-time features

## Technologies

- Ruby 2.7+
- Rails 5.2+
- SQLite3
- jQuery
- ActionCable
- Devise
- ActiveJob
