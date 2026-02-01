#!/usr/bin/env python3
"""
ft_transcendence - Full-stack Web Application with Pong Game
42 School Project - Final Project of the Common Core
"""

import os
import sys
import json
import hashlib
import secrets
import sqlite3
import asyncio
import threading
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse
import socketserver


# =============================================================================
# Database Setup
# =============================================================================

DB_PATH = "transcendence.db"


def init_db():
    """Initialize the SQLite database."""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()

    c.execute('''CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        avatar TEXT DEFAULT 'default.png',
        wins INTEGER DEFAULT 0,
        losses INTEGER DEFAULT 0,
        status TEXT DEFAULT 'offline',
        two_factor_enabled INTEGER DEFAULT 0,
        two_factor_secret TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''')

    c.execute('''CREATE TABLE IF NOT EXISTS friendships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        friend_id INTEGER NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, friend_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (friend_id) REFERENCES users(id)
    )''')

    c.execute('''CREATE TABLE IF NOT EXISTS games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player1_id INTEGER NOT NULL,
        player2_id INTEGER,
        player1_score INTEGER DEFAULT 0,
        player2_score INTEGER DEFAULT 0,
        status TEXT DEFAULT 'waiting',
        winner_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        ended_at TIMESTAMP,
        FOREIGN KEY (player1_id) REFERENCES users(id),
        FOREIGN KEY (player2_id) REFERENCES users(id)
    )''')

    c.execute('''CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_id INTEGER NOT NULL,
        receiver_id INTEGER,
        channel TEXT,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sender_id) REFERENCES users(id)
    )''')

    c.execute('''CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        token TEXT UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )''')

    c.execute('''CREATE TABLE IF NOT EXISTS blocked_users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        blocked_id INTEGER NOT NULL,
        UNIQUE(user_id, blocked_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (blocked_id) REFERENCES users(id)
    )''')

    conn.commit()
    conn.close()


# =============================================================================
# Security Functions
# =============================================================================

def hash_password(password):
    salt = secrets.token_hex(16)
    hashed = hashlib.sha256((salt + password).encode()).hexdigest()
    return f"{salt}:{hashed}"


def verify_password(stored_hash, password):
    try:
        salt, hashed = stored_hash.split(':')
        return hashlib.sha256((salt + password).encode()).hexdigest() == hashed
    except:
        return False


def generate_token():
    return secrets.token_urlsafe(32)


def escape_html(text):
    if text is None:
        return ""
    return (str(text)
            .replace('&', '&amp;')
            .replace('<', '&lt;')
            .replace('>', '&gt;')
            .replace('"', '&quot;')
            .replace("'", '&#x27;'))


# =============================================================================
# Database Operations
# =============================================================================

class DB:
    @staticmethod
    def conn():
        return sqlite3.connect(DB_PATH)

    @staticmethod
    def create_user(username, email, password):
        conn = DB.conn()
        c = conn.cursor()
        try:
            c.execute('''INSERT INTO users (username, email, password_hash)
                        VALUES (?, ?, ?)''',
                     (username, email, hash_password(password)))
            conn.commit()
            user_id = c.lastrowid
            conn.close()
            return user_id
        except sqlite3.IntegrityError:
            conn.close()
            return None

    @staticmethod
    def login(username, password):
        conn = DB.conn()
        c = conn.cursor()
        c.execute('SELECT id, password_hash FROM users WHERE username = ?', (username,))
        row = c.fetchone()
        if row and verify_password(row[1], password):
            token = generate_token()
            c.execute('INSERT INTO sessions (user_id, token) VALUES (?, ?)', (row[0], token))
            c.execute('UPDATE users SET status = ? WHERE id = ?', ('online', row[0]))
            conn.commit()
            conn.close()
            return token
        conn.close()
        return None

    @staticmethod
    def get_user_by_token(token):
        conn = DB.conn()
        c = conn.cursor()
        c.execute('''SELECT u.id, u.username, u.email, u.avatar, u.wins, u.losses, u.status
                    FROM users u JOIN sessions s ON u.id = s.user_id
                    WHERE s.token = ?''', (token,))
        row = c.fetchone()
        conn.close()
        if row:
            return {'id': row[0], 'username': row[1], 'email': row[2],
                    'avatar': row[3], 'wins': row[4], 'losses': row[5], 'status': row[6]}
        return None

    @staticmethod
    def logout(token):
        conn = DB.conn()
        c = conn.cursor()
        c.execute('SELECT user_id FROM sessions WHERE token = ?', (token,))
        row = c.fetchone()
        if row:
            c.execute('UPDATE users SET status = ? WHERE id = ?', ('offline', row[0]))
        c.execute('DELETE FROM sessions WHERE token = ?', (token,))
        conn.commit()
        conn.close()

    @staticmethod
    def get_users():
        conn = DB.conn()
        c = conn.cursor()
        c.execute('SELECT id, username, avatar, wins, losses, status FROM users ORDER BY wins DESC')
        users = [{'id': r[0], 'username': r[1], 'avatar': r[2],
                 'wins': r[3], 'losses': r[4], 'status': r[5]} for r in c.fetchall()]
        conn.close()
        return users

    @staticmethod
    def get_user(user_id):
        conn = DB.conn()
        c = conn.cursor()
        c.execute('SELECT id, username, email, avatar, wins, losses, status FROM users WHERE id = ?',
                 (user_id,))
        row = c.fetchone()
        conn.close()
        if row:
            return {'id': row[0], 'username': row[1], 'email': row[2],
                    'avatar': row[3], 'wins': row[4], 'losses': row[5], 'status': row[6]}
        return None

    @staticmethod
    def get_match_history(user_id):
        conn = DB.conn()
        c = conn.cursor()
        c.execute('''SELECT g.id, g.player1_id, g.player2_id, g.player1_score, g.player2_score,
                    g.winner_id, g.created_at, u1.username, u2.username
                    FROM games g
                    JOIN users u1 ON g.player1_id = u1.id
                    LEFT JOIN users u2 ON g.player2_id = u2.id
                    WHERE (g.player1_id = ? OR g.player2_id = ?) AND g.status = 'finished'
                    ORDER BY g.created_at DESC LIMIT 20''', (user_id, user_id))
        games = []
        for r in c.fetchall():
            games.append({
                'id': r[0], 'player1_id': r[1], 'player2_id': r[2],
                'player1_score': r[3], 'player2_score': r[4],
                'winner_id': r[5], 'created_at': r[6],
                'player1_name': r[7], 'player2_name': r[8] or 'AI'
            })
        conn.close()
        return games

    @staticmethod
    def create_game(player1_id):
        conn = DB.conn()
        c = conn.cursor()
        c.execute('INSERT INTO games (player1_id) VALUES (?)', (player1_id,))
        game_id = c.lastrowid
        conn.commit()
        conn.close()
        return game_id

    @staticmethod
    def join_game(game_id, player2_id):
        conn = DB.conn()
        c = conn.cursor()
        c.execute('UPDATE games SET player2_id = ?, status = ? WHERE id = ? AND status = ?',
                 (player2_id, 'playing', game_id, 'waiting'))
        success = c.rowcount > 0
        conn.commit()
        conn.close()
        return success

    @staticmethod
    def end_game(game_id, player1_score, player2_score):
        conn = DB.conn()
        c = conn.cursor()
        c.execute('SELECT player1_id, player2_id FROM games WHERE id = ?', (game_id,))
        row = c.fetchone()
        if row:
            winner_id = row[0] if player1_score > player2_score else row[1]
            loser_id = row[1] if player1_score > player2_score else row[0]
            c.execute('''UPDATE games SET player1_score = ?, player2_score = ?,
                        winner_id = ?, status = ?, ended_at = CURRENT_TIMESTAMP
                        WHERE id = ?''', (player1_score, player2_score, winner_id, 'finished', game_id))
            c.execute('UPDATE users SET wins = wins + 1 WHERE id = ?', (winner_id,))
            if loser_id:
                c.execute('UPDATE users SET losses = losses + 1 WHERE id = ?', (loser_id,))
        conn.commit()
        conn.close()

    @staticmethod
    def get_waiting_games():
        conn = DB.conn()
        c = conn.cursor()
        c.execute('''SELECT g.id, u.username FROM games g
                    JOIN users u ON g.player1_id = u.id
                    WHERE g.status = 'waiting' ORDER BY g.created_at DESC''')
        games = [{'id': r[0], 'player': r[1]} for r in c.fetchall()]
        conn.close()
        return games

    @staticmethod
    def add_friend(user_id, friend_id):
        conn = DB.conn()
        c = conn.cursor()
        try:
            c.execute('INSERT INTO friendships (user_id, friend_id) VALUES (?, ?)',
                     (user_id, friend_id))
            conn.commit()
            conn.close()
            return True
        except:
            conn.close()
            return False

    @staticmethod
    def get_friends(user_id):
        conn = DB.conn()
        c = conn.cursor()
        c.execute('''SELECT u.id, u.username, u.status FROM users u
                    JOIN friendships f ON (f.friend_id = u.id AND f.user_id = ?)
                    WHERE f.status = 'accepted'
                    UNION
                    SELECT u.id, u.username, u.status FROM users u
                    JOIN friendships f ON (f.user_id = u.id AND f.friend_id = ?)
                    WHERE f.status = 'accepted' ''', (user_id, user_id))
        friends = [{'id': r[0], 'username': r[1], 'status': r[2]} for r in c.fetchall()]
        conn.close()
        return friends

    @staticmethod
    def send_message(sender_id, receiver_id, content):
        conn = DB.conn()
        c = conn.cursor()
        c.execute('INSERT INTO messages (sender_id, receiver_id, content) VALUES (?, ?, ?)',
                 (sender_id, receiver_id, content))
        conn.commit()
        conn.close()

    @staticmethod
    def get_messages(user_id, other_id):
        conn = DB.conn()
        c = conn.cursor()
        c.execute('''SELECT m.id, m.sender_id, m.content, m.created_at, u.username
                    FROM messages m JOIN users u ON m.sender_id = u.id
                    WHERE (m.sender_id = ? AND m.receiver_id = ?)
                    OR (m.sender_id = ? AND m.receiver_id = ?)
                    ORDER BY m.created_at ASC LIMIT 100''',
                 (user_id, other_id, other_id, user_id))
        messages = [{'id': r[0], 'sender_id': r[1], 'content': r[2],
                    'created_at': r[3], 'username': r[4]} for r in c.fetchall()]
        conn.close()
        return messages


# =============================================================================
# Pong Game Engine
# =============================================================================

class PongGame:
    """Server-side Pong game logic."""

    WIDTH = 800
    HEIGHT = 600
    PADDLE_HEIGHT = 100
    PADDLE_WIDTH = 10
    BALL_SIZE = 10
    PADDLE_SPEED = 8
    BALL_SPEED = 6
    WIN_SCORE = 5

    def __init__(self, game_id):
        self.game_id = game_id
        self.reset()

    def reset(self):
        self.ball_x = self.WIDTH // 2
        self.ball_y = self.HEIGHT // 2
        self.ball_vx = self.BALL_SPEED
        self.ball_vy = self.BALL_SPEED
        self.paddle1_y = self.HEIGHT // 2 - self.PADDLE_HEIGHT // 2
        self.paddle2_y = self.HEIGHT // 2 - self.PADDLE_HEIGHT // 2
        self.score1 = 0
        self.score2 = 0
        self.running = False

    def update(self, p1_input=0, p2_input=0):
        """Update game state. Input: -1=up, 0=stay, 1=down"""
        if not self.running:
            return

        # Move paddles
        self.paddle1_y += p1_input * self.PADDLE_SPEED
        self.paddle2_y += p2_input * self.PADDLE_SPEED

        # Clamp paddles
        self.paddle1_y = max(0, min(self.HEIGHT - self.PADDLE_HEIGHT, self.paddle1_y))
        self.paddle2_y = max(0, min(self.HEIGHT - self.PADDLE_HEIGHT, self.paddle2_y))

        # Move ball
        self.ball_x += self.ball_vx
        self.ball_y += self.ball_vy

        # Wall collision (top/bottom)
        if self.ball_y <= 0 or self.ball_y >= self.HEIGHT - self.BALL_SIZE:
            self.ball_vy = -self.ball_vy

        # Paddle collision (left)
        if (self.ball_x <= self.PADDLE_WIDTH and
            self.paddle1_y <= self.ball_y <= self.paddle1_y + self.PADDLE_HEIGHT):
            self.ball_vx = abs(self.ball_vx)
            # Add angle based on hit position
            hit_pos = (self.ball_y - self.paddle1_y) / self.PADDLE_HEIGHT - 0.5
            self.ball_vy += hit_pos * 4

        # Paddle collision (right)
        if (self.ball_x >= self.WIDTH - self.PADDLE_WIDTH - self.BALL_SIZE and
            self.paddle2_y <= self.ball_y <= self.paddle2_y + self.PADDLE_HEIGHT):
            self.ball_vx = -abs(self.ball_vx)
            hit_pos = (self.ball_y - self.paddle2_y) / self.PADDLE_HEIGHT - 0.5
            self.ball_vy += hit_pos * 4

        # Scoring
        if self.ball_x < 0:
            self.score2 += 1
            self.reset_ball()
        elif self.ball_x > self.WIDTH:
            self.score1 += 1
            self.reset_ball()

        # Check win
        if self.score1 >= self.WIN_SCORE or self.score2 >= self.WIN_SCORE:
            self.running = False
            return True  # Game over
        return False

    def reset_ball(self):
        self.ball_x = self.WIDTH // 2
        self.ball_y = self.HEIGHT // 2
        self.ball_vx = -self.ball_vx
        self.ball_vy = self.BALL_SPEED if self.ball_vy > 0 else -self.BALL_SPEED

    def get_state(self):
        return {
            'ball': {'x': self.ball_x, 'y': self.ball_y},
            'paddle1': {'y': self.paddle1_y},
            'paddle2': {'y': self.paddle2_y},
            'score1': self.score1,
            'score2': self.score2,
            'running': self.running
        }


# =============================================================================
# HTML Templates
# =============================================================================

def render_base(title, content, user=None):
    nav = '<a href="/">Home</a> <a href="/play">Play</a> <a href="/leaderboard">Leaderboard</a>'
    if user:
        nav += f' <a href="/profile">Profile ({escape_html(user["username"])})</a>'
        nav += ' <a href="/chat">Chat</a> <a href="/logout">Logout</a>'
    else:
        nav += ' <a href="/login">Login</a> <a href="/register">Register</a>'

    return f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{escape_html(title)} - ft_transcendence</title>
    <style>
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{ font-family: 'Segoe UI', sans-serif; background: #0a0a0a; color: #fff;
               min-height: 100vh; display: flex; flex-direction: column; }}
        header {{ background: linear-gradient(90deg, #1a1a2e 0%, #16213e 100%);
                 padding: 1rem 2rem; border-bottom: 2px solid #0f3460; }}
        header h1 {{ color: #e94560; font-size: 1.5rem; }}
        nav {{ margin-top: 0.5rem; }}
        nav a {{ color: #94a3b8; text-decoration: none; margin-right: 1.5rem; }}
        nav a:hover {{ color: #e94560; }}
        main {{ flex: 1; padding: 2rem; max-width: 1200px; margin: 0 auto; width: 100%; }}
        footer {{ background: #1a1a2e; text-align: center; padding: 1rem; color: #64748b; }}
        .card {{ background: #1a1a2e; border-radius: 8px; padding: 1.5rem;
                border: 1px solid #0f3460; margin-bottom: 1rem; }}
        .btn {{ background: #e94560; color: white; border: none; padding: 0.75rem 1.5rem;
               border-radius: 4px; cursor: pointer; font-size: 1rem; text-decoration: none;
               display: inline-block; }}
        .btn:hover {{ background: #d63850; }}
        .btn-secondary {{ background: #0f3460; }}
        input, textarea {{ width: 100%; padding: 0.75rem; background: #0a0a0a;
                         border: 1px solid #0f3460; border-radius: 4px; color: #fff;
                         margin-bottom: 1rem; }}
        .grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                gap: 1rem; }}
        canvas {{ border: 2px solid #e94560; border-radius: 4px; }}
        .online {{ color: #22c55e; }}
        .offline {{ color: #64748b; }}
        table {{ width: 100%; border-collapse: collapse; }}
        th, td {{ padding: 0.75rem; text-align: left; border-bottom: 1px solid #0f3460; }}
        th {{ color: #e94560; }}
    </style>
</head>
<body>
    <header>
        <h1>ft_transcendence</h1>
        <nav>{nav}</nav>
    </header>
    <main>{content}</main>
    <footer>42 Project - ft_transcendence</footer>
</body>
</html>'''


def render_home(user=None):
    content = '''
    <div class="card">
        <h2>Welcome to ft_transcendence</h2>
        <p style="margin: 1rem 0;">The ultimate multiplayer Pong experience!</p>
        <a href="/play" class="btn">Play Now</a>
    </div>
    <div class="grid">
        <div class="card">
            <h3>Real-time Multiplayer</h3>
            <p>Play against other players in real-time Pong matches.</p>
        </div>
        <div class="card">
            <h3>Leaderboard</h3>
            <p>Compete for the top spot on the global leaderboard.</p>
        </div>
        <div class="card">
            <h3>Chat & Friends</h3>
            <p>Connect with other players, add friends, and chat.</p>
        </div>
    </div>
    '''
    return render_base('Home', content, user)


def render_play(user, waiting_games):
    games_html = ''
    for g in waiting_games:
        games_html += f'''
        <div style="display: flex; justify-content: space-between; align-items: center;
                    padding: 0.5rem; border-bottom: 1px solid #0f3460;">
            <span>{escape_html(g['player'])} is waiting...</span>
            <a href="/game/{g['id']}" class="btn btn-secondary">Join</a>
        </div>
        '''

    content = f'''
    <div class="card">
        <h2>Play Pong</h2>
        <div style="display: flex; gap: 1rem; margin: 1rem 0;">
            <a href="/game/new" class="btn">Create Game</a>
            <a href="/game/ai" class="btn btn-secondary">Play vs AI</a>
        </div>
    </div>
    <div class="card">
        <h3>Available Games</h3>
        {games_html if games_html else '<p>No games waiting. Create one!</p>'}
    </div>
    '''
    return render_base('Play', content, user)


def render_game(user, game_id, is_ai=False):
    content = f'''
    <div class="card" style="text-align: center;">
        <h2>Pong - Game #{game_id}</h2>
        <div id="scores" style="font-size: 2rem; margin: 1rem 0;">
            <span id="score1">0</span> - <span id="score2">0</span>
        </div>
        <canvas id="pong" width="800" height="600"></canvas>
        <p style="margin-top: 1rem;">Controls: W/S or Arrow Keys</p>
    </div>
    <script>
        const canvas = document.getElementById('pong');
        const ctx = canvas.getContext('2d');
        const isAI = {'true' if is_ai else 'false'};

        // Game state
        let state = {{
            ball: {{ x: 400, y: 300 }},
            paddle1: {{ y: 250 }},
            paddle2: {{ y: 250 }},
            score1: 0,
            score2: 0,
            running: true
        }};

        // Constants
        const PADDLE_HEIGHT = 100;
        const PADDLE_WIDTH = 10;
        const BALL_SIZE = 10;
        const BALL_SPEED = 6;
        const PADDLE_SPEED = 8;

        let ballVx = BALL_SPEED;
        let ballVy = BALL_SPEED;
        let keys = {{}};

        // Input
        document.addEventListener('keydown', e => keys[e.key] = true);
        document.addEventListener('keyup', e => keys[e.key] = false);

        function update() {{
            if (!state.running) return;

            // Player 1 movement (W/S)
            if (keys['w'] || keys['W']) state.paddle1.y -= PADDLE_SPEED;
            if (keys['s'] || keys['S']) state.paddle1.y += PADDLE_SPEED;

            // Player 2 / AI
            if (isAI) {{
                // Simple AI
                const paddleCenter = state.paddle2.y + PADDLE_HEIGHT / 2;
                if (paddleCenter < state.ball.y - 20) state.paddle2.y += PADDLE_SPEED * 0.7;
                if (paddleCenter > state.ball.y + 20) state.paddle2.y -= PADDLE_SPEED * 0.7;
            }} else {{
                if (keys['ArrowUp']) state.paddle2.y -= PADDLE_SPEED;
                if (keys['ArrowDown']) state.paddle2.y += PADDLE_SPEED;
            }}

            // Clamp paddles
            state.paddle1.y = Math.max(0, Math.min(500, state.paddle1.y));
            state.paddle2.y = Math.max(0, Math.min(500, state.paddle2.y));

            // Move ball
            state.ball.x += ballVx;
            state.ball.y += ballVy;

            // Wall collision
            if (state.ball.y <= 0 || state.ball.y >= 590) ballVy = -ballVy;

            // Paddle collision
            if (state.ball.x <= PADDLE_WIDTH &&
                state.ball.y >= state.paddle1.y &&
                state.ball.y <= state.paddle1.y + PADDLE_HEIGHT) {{
                ballVx = Math.abs(ballVx);
            }}
            if (state.ball.x >= 780 &&
                state.ball.y >= state.paddle2.y &&
                state.ball.y <= state.paddle2.y + PADDLE_HEIGHT) {{
                ballVx = -Math.abs(ballVx);
            }}

            // Scoring
            if (state.ball.x < 0) {{
                state.score2++;
                resetBall();
            }} else if (state.ball.x > 800) {{
                state.score1++;
                resetBall();
            }}

            // Update display
            document.getElementById('score1').textContent = state.score1;
            document.getElementById('score2').textContent = state.score2;

            // Win condition
            if (state.score1 >= 5 || state.score2 >= 5) {{
                state.running = false;
                const winner = state.score1 >= 5 ? 'Player 1' : (isAI ? 'AI' : 'Player 2');
                alert(winner + ' wins!');

                // Save game result
                fetch('/api/end-game', {{
                    method: 'POST',
                    headers: {{ 'Content-Type': 'application/json' }},
                    body: JSON.stringify({{
                        game_id: {game_id},
                        score1: state.score1,
                        score2: state.score2
                    }})
                }}).then(() => window.location.href = '/play');
            }}
        }}

        function resetBall() {{
            state.ball.x = 400;
            state.ball.y = 300;
            ballVx = -ballVx;
        }}

        function draw() {{
            // Background
            ctx.fillStyle = '#0a0a0a';
            ctx.fillRect(0, 0, 800, 600);

            // Center line
            ctx.setLineDash([10, 10]);
            ctx.strokeStyle = '#0f3460';
            ctx.beginPath();
            ctx.moveTo(400, 0);
            ctx.lineTo(400, 600);
            ctx.stroke();
            ctx.setLineDash([]);

            // Paddles
            ctx.fillStyle = '#e94560';
            ctx.fillRect(0, state.paddle1.y, PADDLE_WIDTH, PADDLE_HEIGHT);
            ctx.fillRect(790, state.paddle2.y, PADDLE_WIDTH, PADDLE_HEIGHT);

            // Ball
            ctx.fillStyle = '#fff';
            ctx.beginPath();
            ctx.arc(state.ball.x, state.ball.y, BALL_SIZE / 2, 0, Math.PI * 2);
            ctx.fill();
        }}

        function gameLoop() {{
            update();
            draw();
            if (state.running) requestAnimationFrame(gameLoop);
        }}

        gameLoop();
    </script>
    '''
    return render_base('Game', content, user)


def render_leaderboard(users):
    rows = ''
    for i, u in enumerate(users[:20]):
        status_class = 'online' if u['status'] == 'online' else 'offline'
        rows += f'''
        <tr>
            <td>{i + 1}</td>
            <td>{escape_html(u['username'])}</td>
            <td>{u['wins']}</td>
            <td>{u['losses']}</td>
            <td>{u['wins'] - u['losses']}</td>
            <td class="{status_class}">{u['status']}</td>
        </tr>
        '''

    content = f'''
    <div class="card">
        <h2>Leaderboard</h2>
        <table>
            <thead>
                <tr>
                    <th>Rank</th>
                    <th>Player</th>
                    <th>Wins</th>
                    <th>Losses</th>
                    <th>Diff</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>{rows if rows else '<tr><td colspan="6">No players yet</td></tr>'}</tbody>
        </table>
    </div>
    '''
    return render_base('Leaderboard', content)


def render_profile(user, history):
    history_html = ''
    for g in history:
        won = g['winner_id'] == user['id']
        result = '<span style="color: #22c55e;">Won</span>' if won else '<span style="color: #ef4444;">Lost</span>'
        opponent = g['player2_name'] if g['player1_id'] == user['id'] else g['player1_name']
        score = f"{g['player1_score']} - {g['player2_score']}"
        history_html += f'<tr><td>{opponent}</td><td>{score}</td><td>{result}</td></tr>'

    content = f'''
    <div class="grid">
        <div class="card">
            <h2>Profile</h2>
            <p><strong>Username:</strong> {escape_html(user['username'])}</p>
            <p><strong>Email:</strong> {escape_html(user['email'])}</p>
            <p><strong>Wins:</strong> {user['wins']}</p>
            <p><strong>Losses:</strong> {user['losses']}</p>
            <p><strong>Win Rate:</strong> {user['wins'] / max(1, user['wins'] + user['losses']) * 100:.1f}%</p>
        </div>
        <div class="card">
            <h2>Match History</h2>
            <table>
                <thead><tr><th>Opponent</th><th>Score</th><th>Result</th></tr></thead>
                <tbody>{history_html if history_html else '<tr><td colspan="3">No matches yet</td></tr>'}</tbody>
            </table>
        </div>
    </div>
    '''
    return render_base('Profile', content, user)


def render_login(error=None):
    error_html = f'<div style="color: #ef4444; margin-bottom: 1rem;">{escape_html(error)}</div>' if error else ''
    content = f'''
    <div class="card" style="max-width: 400px; margin: 0 auto;">
        <h2>Login</h2>
        {error_html}
        <form method="POST">
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit" class="btn" style="width: 100%;">Login</button>
        </form>
        <p style="margin-top: 1rem; text-align: center;">
            <a href="/register" style="color: #e94560;">Create an account</a>
        </p>
    </div>
    '''
    return render_base('Login', content)


def render_register(error=None, success=None):
    msg = ''
    if error:
        msg = f'<div style="color: #ef4444; margin-bottom: 1rem;">{escape_html(error)}</div>'
    if success:
        msg = f'<div style="color: #22c55e; margin-bottom: 1rem;">{escape_html(success)}</div>'
    content = f'''
    <div class="card" style="max-width: 400px; margin: 0 auto;">
        <h2>Register</h2>
        {msg}
        <form method="POST">
            <input type="text" name="username" placeholder="Username" required minlength="3">
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required minlength="8">
            <button type="submit" class="btn" style="width: 100%;">Register</button>
        </form>
    </div>
    '''
    return render_base('Register', content)


def render_chat(user, friends, messages, selected_friend=None):
    friends_html = ''
    for f in friends:
        selected = 'background: #0f3460;' if selected_friend and f['id'] == selected_friend['id'] else ''
        status_class = 'online' if f['status'] == 'online' else 'offline'
        friends_html += f'''
        <a href="/chat?user={f['id']}" style="display: block; padding: 0.5rem;
           text-decoration: none; color: #fff; {selected}">
            <span class="{status_class}">●</span> {escape_html(f['username'])}
        </a>
        '''

    messages_html = ''
    for m in messages:
        is_self = m['sender_id'] == user['id']
        align = 'right' if is_self else 'left'
        bg = '#e94560' if is_self else '#0f3460'
        messages_html += f'''
        <div style="text-align: {align}; margin: 0.5rem 0;">
            <span style="background: {bg}; padding: 0.5rem 1rem; border-radius: 1rem;
                        display: inline-block; max-width: 70%;">
                {escape_html(m['content'])}
            </span>
        </div>
        '''

    chat_form = ''
    if selected_friend:
        chat_form = f'''
        <form method="POST" style="display: flex; gap: 0.5rem; margin-top: 1rem;">
            <input type="hidden" name="receiver_id" value="{selected_friend['id']}">
            <input type="text" name="message" placeholder="Type a message..." style="flex: 1; margin: 0;">
            <button type="submit" class="btn">Send</button>
        </form>
        '''

    content = f'''
    <div style="display: flex; gap: 1rem; height: calc(100vh - 200px);">
        <div class="card" style="width: 250px; overflow-y: auto;">
            <h3>Friends</h3>
            {friends_html if friends_html else '<p>No friends yet</p>'}
        </div>
        <div class="card" style="flex: 1; display: flex; flex-direction: column;">
            <h3>{escape_html(selected_friend['username']) if selected_friend else 'Select a friend'}</h3>
            <div style="flex: 1; overflow-y: auto;">
                {messages_html}
            </div>
            {chat_form}
        </div>
    </div>
    '''
    return render_base('Chat', content, user)


# =============================================================================
# HTTP Handler
# =============================================================================

class TranscendenceHandler(BaseHTTPRequestHandler):
    def get_token(self):
        cookies = self.headers.get('Cookie', '')
        for c in cookies.split(';'):
            if '=' in c:
                name, value = c.strip().split('=', 1)
                if name == 'session':
                    return value
        return None

    def get_user(self):
        token = self.get_token()
        return DB.get_user_by_token(token) if token else None

    def send_html(self, html, status=200, cookies=None):
        self.send_response(status)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        for c in (cookies or []):
            self.send_header('Set-Cookie', c)
        self.end_headers()
        self.wfile.write(html.encode())

    def send_json(self, data, status=200):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def redirect(self, url, cookies=None):
        self.send_response(302)
        self.send_header('Location', url)
        for c in (cookies or []):
            self.send_header('Set-Cookie', c)
        self.end_headers()

    def get_post_data(self):
        length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(length).decode()
        ctype = self.headers.get('Content-Type', '')
        if 'json' in ctype:
            return json.loads(body)
        return {k: v[0] for k, v in parse_qs(body).items()}

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        query = parse_qs(parsed.query)
        user = self.get_user()

        if path == '/':
            self.send_html(render_home(user))
        elif path == '/login':
            self.send_html(render_login()) if not user else self.redirect('/')
        elif path == '/register':
            self.send_html(render_register())
        elif path == '/logout':
            token = self.get_token()
            if token:
                DB.logout(token)
            self.redirect('/', ['session=; Max-Age=0; Path=/'])
        elif path == '/play':
            if not user:
                self.redirect('/login')
            else:
                games = DB.get_waiting_games()
                self.send_html(render_play(user, games))
        elif path == '/game/new':
            if user:
                game_id = DB.create_game(user['id'])
                self.redirect(f'/game/{game_id}')
            else:
                self.redirect('/login')
        elif path == '/game/ai':
            if user:
                game_id = DB.create_game(user['id'])
                self.send_html(render_game(user, game_id, is_ai=True))
            else:
                self.redirect('/login')
        elif path.startswith('/game/'):
            if user:
                game_id = int(path.split('/')[-1])
                self.send_html(render_game(user, game_id))
            else:
                self.redirect('/login')
        elif path == '/leaderboard':
            users = DB.get_users()
            self.send_html(render_leaderboard(users))
        elif path == '/profile':
            if user:
                history = DB.get_match_history(user['id'])
                self.send_html(render_profile(user, history))
            else:
                self.redirect('/login')
        elif path == '/chat':
            if user:
                friends = DB.get_friends(user['id'])
                selected = None
                messages = []
                if query.get('user'):
                    friend_id = int(query['user'][0])
                    selected = DB.get_user(friend_id)
                    if selected:
                        messages = DB.get_messages(user['id'], friend_id)
                self.send_html(render_chat(user, friends, messages, selected))
            else:
                self.redirect('/login')
        else:
            self.send_html(render_base('404', '<h2>Page Not Found</h2>'), 404)

    def do_POST(self):
        path = self.path
        data = self.get_post_data()
        user = self.get_user()

        if path == '/login':
            token = DB.login(data.get('username', ''), data.get('password', ''))
            if token:
                self.redirect('/', [f'session={token}; Path=/; HttpOnly'])
            else:
                self.send_html(render_login('Invalid credentials'))
        elif path == '/register':
            username = data.get('username', '').strip()
            email = data.get('email', '').strip()
            password = data.get('password', '')
            if len(username) < 3:
                self.send_html(render_register('Username too short'))
            elif len(password) < 8:
                self.send_html(render_register('Password too short'))
            elif DB.create_user(username, email, password):
                self.send_html(render_register(None, 'Registration successful! Please login.'))
            else:
                self.send_html(render_register('Username or email already exists'))
        elif path == '/chat' and user:
            receiver_id = int(data.get('receiver_id', 0))
            message = escape_html(data.get('message', '').strip())
            if receiver_id and message:
                DB.send_message(user['id'], receiver_id, message)
            self.redirect(f'/chat?user={receiver_id}')
        elif path == '/api/end-game':
            if user:
                game_id = data.get('game_id')
                score1 = data.get('score1', 0)
                score2 = data.get('score2', 0)
                DB.end_game(game_id, score1, score2)
                self.send_json({'success': True})
            else:
                self.send_json({'error': 'Unauthorized'}, 401)
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, fmt, *args):
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {args[0]}")


# =============================================================================
# Main
# =============================================================================

def main():
    print("ft_transcendence - Full-stack Web Application")
    print("=" * 50)

    if '--help' in sys.argv:
        print("\nUsage: python ft_transcendence.py [port]")
        print("\nFeatures:")
        print("  - User authentication")
        print("  - Real-time Pong game")
        print("  - Play vs AI or other players")
        print("  - Leaderboard")
        print("  - Friends and chat system")
        print("  - Match history")
        print("\nDefault port: 8080")
        return

    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080

    init_db()
    print(f"Database initialized: {DB_PATH}")

    server = HTTPServer(('', port), TranscendenceHandler)
    print(f"\nServer running at http://localhost:{port}")
    print("Press Ctrl+C to stop\n")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")


if __name__ == "__main__":
    main()
