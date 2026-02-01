# ft_transcendence - Full-stack Web Application

The final project of the 42 Common Core. A full-stack web application featuring a multiplayer Pong game.

## Features

- User authentication (register/login/logout)
- Real-time Pong game (Canvas-based)
- Play vs AI or other players
- Matchmaking system (create/join games)
- Global leaderboard
- User profiles with match history
- Friends system
- Direct messaging chat
- Responsive dark theme UI

## Usage

```bash
python3 ft_transcendence.py [port]
```

Default port: 8080

Open http://localhost:8080 in your browser.

## Testing

1. **Registration**:
   - Go to /register
   - Create an account
   - Login with credentials

2. **Play Pong**:
   - Click "Play" in navigation
   - Choose "Play vs AI" for single player
   - Or "Create Game" and wait for opponent

3. **Game Controls**:
   - Player 1: W (up), S (down)
   - Player 2: Arrow Up/Down

4. **Leaderboard**:
   - View rankings at /leaderboard
   - Based on wins/losses

5. **Chat**:
   - Add friends via profile
   - Chat with online friends

## Architecture

```
ft_transcendence.py    # Main application
transcendence.db       # SQLite database (auto-created)
```

### Database Schema

```sql
-- Users
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    password_hash TEXT,
    avatar TEXT,
    wins INTEGER,
    losses INTEGER,
    status TEXT  -- online/offline
);

-- Games
CREATE TABLE games (
    id INTEGER PRIMARY KEY,
    player1_id INTEGER,
    player2_id INTEGER,
    player1_score INTEGER,
    player2_score INTEGER,
    status TEXT,  -- waiting/playing/finished
    winner_id INTEGER
);

-- Friendships
CREATE TABLE friendships (
    user_id INTEGER,
    friend_id INTEGER,
    status TEXT  -- pending/accepted
);

-- Messages
CREATE TABLE messages (
    sender_id INTEGER,
    receiver_id INTEGER,
    content TEXT,
    created_at TIMESTAMP
);
```

## Game Mechanics

### Pong Rules
- First to 5 points wins
- Ball bounces off top/bottom walls
- Ball angle changes based on paddle hit position
- AI opponent tracks ball with slight delay

### Scoring
- Win: +1 to wins counter
- Loss: +1 to losses counter
- Win rate calculated automatically

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | / | Home page |
| GET | /play | Game lobby |
| GET | /game/new | Create new game |
| GET | /game/ai | Play vs AI |
| GET | /game/:id | Join/view game |
| GET | /leaderboard | Rankings |
| GET | /profile | User profile |
| GET | /chat | Messaging |
| POST | /login | Authenticate |
| POST | /register | Create account |
| POST | /api/end-game | Save game result |

## Security Features

- Password hashing with salt
- Session-based authentication
- HttpOnly cookies
- XSS prevention (HTML escaping)
- SQL injection prevention (parameterized queries)

## Technologies

- Python 3.6+ (no external dependencies)
- SQLite database
- HTML5 Canvas for game rendering
- Vanilla JavaScript
- CSS3 with Flexbox/Grid

## Future Enhancements

The 42 project typically requires:
- OAuth 2.0 (42 API integration)
- WebSocket for real-time gameplay
- Two-factor authentication
- User avatars upload
- Game spectating
- Tournament mode
- Channel-based chat

## Browser Compatibility

- Chrome 50+
- Firefox 45+
- Safari 10+
- Edge 14+

## Author

Implementation for 42 curriculum (final common core project).
