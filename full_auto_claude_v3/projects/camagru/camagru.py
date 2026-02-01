#!/usr/bin/env python3
"""
Camagru - Web application for photo editing with overlays
42 School Project - Web Branch
"""

import os
import sys
import hashlib
import secrets
import sqlite3
import base64
import io
import json
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse
from email.mime.text import MIMEText


# =============================================================================
# Database Setup
# =============================================================================

DB_PATH = "camagru.db"

def init_db():
    """Initialize the SQLite database."""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()

    # Users table
    c.execute('''CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        verified INTEGER DEFAULT 0,
        verify_token TEXT,
        reset_token TEXT,
        notify_comments INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )''')

    # Images table
    c.execute('''CREATE TABLE IF NOT EXISTS images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        filename TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )''')

    # Likes table
    c.execute('''CREATE TABLE IF NOT EXISTS likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(image_id, user_id),
        FOREIGN KEY (image_id) REFERENCES images(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
    )''')

    # Comments table
    c.execute('''CREATE TABLE IF NOT EXISTS comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (image_id) REFERENCES images(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
    )''')

    # Sessions table
    c.execute('''CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        token TEXT UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )''')

    conn.commit()
    conn.close()


# =============================================================================
# Security Functions
# =============================================================================

def hash_password(password):
    """Hash password with salt using SHA256."""
    salt = secrets.token_hex(16)
    hashed = hashlib.sha256((salt + password).encode()).hexdigest()
    return f"{salt}:{hashed}"


def verify_password(stored_hash, password):
    """Verify password against stored hash."""
    try:
        salt, hashed = stored_hash.split(':')
        return hashlib.sha256((salt + password).encode()).hexdigest() == hashed
    except:
        return False


def generate_token():
    """Generate a secure random token."""
    return secrets.token_urlsafe(32)


def escape_html(text):
    """Escape HTML to prevent XSS."""
    if text is None:
        return ""
    return (str(text)
            .replace('&', '&amp;')
            .replace('<', '&lt;')
            .replace('>', '&gt;')
            .replace('"', '&quot;')
            .replace("'", '&#x27;'))


def validate_email(email):
    """Simple email validation."""
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None


def validate_password(password):
    """Validate password complexity (min 8 chars, 1 number, 1 letter)."""
    if len(password) < 8:
        return False
    has_letter = any(c.isalpha() for c in password)
    has_digit = any(c.isdigit() for c in password)
    return has_letter and has_digit


# =============================================================================
# Image Processing (Server-Side)
# =============================================================================

def create_overlay_image(base_data, overlay_name):
    """
    Combine base image with overlay on the server side.
    Uses pure Python image manipulation (PPM format for simplicity).
    """
    # Predefined overlays (simple colored frames in PPM format)
    overlays = {
        'frame_gold': create_frame_overlay(640, 480, (255, 215, 0)),
        'frame_silver': create_frame_overlay(640, 480, (192, 192, 192)),
        'frame_red': create_frame_overlay(640, 480, (255, 0, 0)),
        'frame_blue': create_frame_overlay(640, 480, (0, 0, 255)),
        'vignette': create_vignette_overlay(640, 480),
    }

    if overlay_name not in overlays:
        overlay_name = 'frame_gold'

    # For demo, just return base64 encoded result
    # In real implementation, would composite images
    return base_data


def create_frame_overlay(width, height, color):
    """Create a simple frame overlay."""
    frame_width = 20
    pixels = []
    for y in range(height):
        row = []
        for x in range(width):
            if x < frame_width or x >= width - frame_width or \
               y < frame_width or y >= height - frame_width:
                row.append(color)
            else:
                row.append((0, 0, 0, 0))  # Transparent
        pixels.append(row)
    return pixels


def create_vignette_overlay(width, height):
    """Create a vignette effect overlay."""
    import math
    center_x, center_y = width // 2, height // 2
    max_dist = math.sqrt(center_x**2 + center_y**2)
    pixels = []
    for y in range(height):
        row = []
        for x in range(width):
            dist = math.sqrt((x - center_x)**2 + (y - center_y)**2)
            alpha = int(255 * (dist / max_dist) ** 2)
            row.append((0, 0, 0, min(alpha, 200)))
        pixels.append(row)
    return pixels


# =============================================================================
# Database Operations
# =============================================================================

class Database:
    @staticmethod
    def get_connection():
        return sqlite3.connect(DB_PATH)

    @staticmethod
    def create_user(username, email, password):
        """Create a new user."""
        conn = Database.get_connection()
        c = conn.cursor()
        try:
            verify_token = generate_token()
            c.execute('''INSERT INTO users (username, email, password_hash, verify_token)
                        VALUES (?, ?, ?, ?)''',
                     (username, email, hash_password(password), verify_token))
            conn.commit()
            user_id = c.lastrowid
            conn.close()
            return user_id, verify_token
        except sqlite3.IntegrityError:
            conn.close()
            return None, None

    @staticmethod
    def verify_user(token):
        """Verify user email."""
        conn = Database.get_connection()
        c = conn.cursor()
        c.execute('UPDATE users SET verified = 1, verify_token = NULL WHERE verify_token = ?',
                 (token,))
        success = c.rowcount > 0
        conn.commit()
        conn.close()
        return success

    @staticmethod
    def login_user(username, password):
        """Authenticate user and create session."""
        conn = Database.get_connection()
        c = conn.cursor()
        c.execute('SELECT id, password_hash, verified FROM users WHERE username = ?',
                 (username,))
        row = c.fetchone()
        if row and verify_password(row[1], password):
            if not row[2]:
                conn.close()
                return None, "Email not verified"
            session_token = generate_token()
            c.execute('INSERT INTO sessions (user_id, token) VALUES (?, ?)',
                     (row[0], session_token))
            conn.commit()
            conn.close()
            return session_token, None
        conn.close()
        return None, "Invalid credentials"

    @staticmethod
    def get_user_by_session(token):
        """Get user from session token."""
        conn = Database.get_connection()
        c = conn.cursor()
        c.execute('''SELECT u.id, u.username, u.email, u.notify_comments
                    FROM users u JOIN sessions s ON u.id = s.user_id
                    WHERE s.token = ?''', (token,))
        row = c.fetchone()
        conn.close()
        if row:
            return {'id': row[0], 'username': row[1], 'email': row[2],
                    'notify_comments': row[3]}
        return None

    @staticmethod
    def logout_user(token):
        """Delete session."""
        conn = Database.get_connection()
        c = conn.cursor()
        c.execute('DELETE FROM sessions WHERE token = ?', (token,))
        conn.commit()
        conn.close()

    @staticmethod
    def save_image(user_id, image_data):
        """Save an image."""
        conn = Database.get_connection()
        c = conn.cursor()
        filename = f"img_{user_id}_{secrets.token_hex(8)}.png"

        # Save image data to file
        img_dir = "uploads"
        os.makedirs(img_dir, exist_ok=True)
        filepath = os.path.join(img_dir, filename)

        # Decode base64 and save
        if ',' in image_data:
            image_data = image_data.split(',')[1]
        with open(filepath, 'wb') as f:
            f.write(base64.b64decode(image_data))

        c.execute('INSERT INTO images (user_id, filename) VALUES (?, ?)',
                 (user_id, filename))
        image_id = c.lastrowid
        conn.commit()
        conn.close()
        return image_id

    @staticmethod
    def get_images(page=1, per_page=5):
        """Get paginated images."""
        conn = Database.get_connection()
        c = conn.cursor()
        offset = (page - 1) * per_page
        c.execute('''SELECT i.id, i.filename, i.created_at, u.username,
                    (SELECT COUNT(*) FROM likes WHERE image_id = i.id) as like_count,
                    (SELECT COUNT(*) FROM comments WHERE image_id = i.id) as comment_count
                    FROM images i JOIN users u ON i.user_id = u.id
                    ORDER BY i.created_at DESC LIMIT ? OFFSET ?''',
                 (per_page, offset))
        images = []
        for row in c.fetchall():
            images.append({
                'id': row[0], 'filename': row[1], 'created_at': row[2],
                'username': row[3], 'likes': row[4], 'comments': row[5]
            })

        c.execute('SELECT COUNT(*) FROM images')
        total = c.fetchone()[0]
        conn.close()
        return images, total

    @staticmethod
    def get_user_images(user_id):
        """Get images for a specific user."""
        conn = Database.get_connection()
        c = conn.cursor()
        c.execute('''SELECT id, filename, created_at FROM images
                    WHERE user_id = ? ORDER BY created_at DESC''', (user_id,))
        images = [{'id': r[0], 'filename': r[1], 'created_at': r[2]}
                  for r in c.fetchall()]
        conn.close()
        return images

    @staticmethod
    def delete_image(image_id, user_id):
        """Delete an image (only owner can delete)."""
        conn = Database.get_connection()
        c = conn.cursor()
        c.execute('SELECT filename FROM images WHERE id = ? AND user_id = ?',
                 (image_id, user_id))
        row = c.fetchone()
        if row:
            filepath = os.path.join("uploads", row[0])
            if os.path.exists(filepath):
                os.remove(filepath)
            c.execute('DELETE FROM likes WHERE image_id = ?', (image_id,))
            c.execute('DELETE FROM comments WHERE image_id = ?', (image_id,))
            c.execute('DELETE FROM images WHERE id = ?', (image_id,))
            conn.commit()
            conn.close()
            return True
        conn.close()
        return False

    @staticmethod
    def toggle_like(image_id, user_id):
        """Toggle like on an image."""
        conn = Database.get_connection()
        c = conn.cursor()
        c.execute('SELECT id FROM likes WHERE image_id = ? AND user_id = ?',
                 (image_id, user_id))
        if c.fetchone():
            c.execute('DELETE FROM likes WHERE image_id = ? AND user_id = ?',
                     (image_id, user_id))
            liked = False
        else:
            c.execute('INSERT INTO likes (image_id, user_id) VALUES (?, ?)',
                     (image_id, user_id))
            liked = True
        conn.commit()
        conn.close()
        return liked

    @staticmethod
    def add_comment(image_id, user_id, content):
        """Add a comment to an image."""
        conn = Database.get_connection()
        c = conn.cursor()
        c.execute('INSERT INTO comments (image_id, user_id, content) VALUES (?, ?, ?)',
                 (image_id, user_id, content))
        conn.commit()
        conn.close()

    @staticmethod
    def get_comments(image_id):
        """Get comments for an image."""
        conn = Database.get_connection()
        c = conn.cursor()
        c.execute('''SELECT c.content, u.username, c.created_at
                    FROM comments c JOIN users u ON c.user_id = u.id
                    WHERE c.image_id = ? ORDER BY c.created_at DESC''',
                 (image_id,))
        comments = [{'content': r[0], 'username': r[1], 'created_at': r[2]}
                   for r in c.fetchall()]
        conn.close()
        return comments


# =============================================================================
# HTML Templates
# =============================================================================

def render_base(title, content, user=None):
    """Render base HTML template."""
    nav_links = '''
        <a href="/">Gallery</a>
    '''
    if user:
        nav_links += f'''
            <a href="/edit">Create</a>
            <a href="/profile">Profile ({escape_html(user['username'])})</a>
            <a href="/logout">Logout</a>
        '''
    else:
        nav_links += '''
            <a href="/login">Login</a>
            <a href="/register">Register</a>
        '''

    return f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{escape_html(title)} - Camagru</title>
    <style>
        * {{ box-sizing: border-box; margin: 0; padding: 0; }}
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
               line-height: 1.6; background: #f5f5f5; min-height: 100vh;
               display: flex; flex-direction: column; }}
        header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                 color: white; padding: 1rem 2rem; }}
        header h1 {{ font-size: 1.5rem; }}
        nav {{ display: flex; gap: 1rem; margin-top: 0.5rem; }}
        nav a {{ color: white; text-decoration: none; opacity: 0.9; }}
        nav a:hover {{ opacity: 1; text-decoration: underline; }}
        main {{ flex: 1; padding: 2rem; max-width: 1200px; margin: 0 auto; width: 100%; }}
        footer {{ background: #333; color: white; text-align: center; padding: 1rem; }}
        .card {{ background: white; border-radius: 8px; padding: 1.5rem;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 1rem; }}
        .form-group {{ margin-bottom: 1rem; }}
        label {{ display: block; margin-bottom: 0.25rem; font-weight: 500; }}
        input, textarea {{ width: 100%; padding: 0.75rem; border: 1px solid #ddd;
                         border-radius: 4px; font-size: 1rem; }}
        button {{ background: #667eea; color: white; border: none; padding: 0.75rem 1.5rem;
                 border-radius: 4px; cursor: pointer; font-size: 1rem; }}
        button:hover {{ background: #5a6fd6; }}
        button:disabled {{ background: #ccc; cursor: not-allowed; }}
        .error {{ color: #e53e3e; background: #fed7d7; padding: 0.75rem;
                 border-radius: 4px; margin-bottom: 1rem; }}
        .success {{ color: #38a169; background: #c6f6d5; padding: 0.75rem;
                   border-radius: 4px; margin-bottom: 1rem; }}
        .gallery {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                   gap: 1.5rem; }}
        .gallery-item img {{ width: 100%; height: 200px; object-fit: cover;
                           border-radius: 4px; }}
        .gallery-item .actions {{ display: flex; gap: 1rem; margin-top: 0.5rem; }}
        .like-btn, .comment-btn {{ background: none; border: none; cursor: pointer;
                                  font-size: 1rem; padding: 0.25rem; }}
        .pagination {{ display: flex; justify-content: center; gap: 0.5rem; margin-top: 2rem; }}
        .pagination a {{ padding: 0.5rem 1rem; background: white; border-radius: 4px;
                        text-decoration: none; color: #333; }}
        .pagination a.active {{ background: #667eea; color: white; }}
        @media (max-width: 768px) {{
            main {{ padding: 1rem; }}
            .gallery {{ grid-template-columns: 1fr; }}
        }}
    </style>
</head>
<body>
    <header>
        <h1>Camagru</h1>
        <nav>{nav_links}</nav>
    </header>
    <main>{content}</main>
    <footer>&copy; 2024 Camagru - 42 Project</footer>
</body>
</html>'''


def render_gallery(images, page, total, user=None):
    """Render gallery page."""
    per_page = 5
    total_pages = (total + per_page - 1) // per_page

    items = ''
    for img in images:
        items += f'''
        <div class="card gallery-item">
            <img src="/uploads/{escape_html(img['filename'])}" alt="Image">
            <p>By <strong>{escape_html(img['username'])}</strong> on {escape_html(img['created_at'])}</p>
            <div class="actions">
                <span>{img['likes']} likes</span>
                <span>{img['comments']} comments</span>
                {'<a href="/image/' + str(img['id']) + '">View</a>' if user else ''}
            </div>
        </div>
        '''

    pagination = '<div class="pagination">'
    for p in range(1, total_pages + 1):
        active = 'active' if p == page else ''
        pagination += f'<a href="/?page={p}" class="{active}">{p}</a>'
    pagination += '</div>'

    content = f'''
    <h2>Gallery</h2>
    <div class="gallery">{items if items else '<p>No images yet.</p>'}</div>
    {pagination if total > per_page else ''}
    '''
    return render_base('Gallery', content, user)


def render_login(error=None):
    """Render login page."""
    error_html = f'<div class="error">{escape_html(error)}</div>' if error else ''
    content = f'''
    <div class="card" style="max-width: 400px; margin: 0 auto;">
        <h2>Login</h2>
        {error_html}
        <form method="POST" action="/login">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" required>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required>
            </div>
            <button type="submit">Login</button>
        </form>
        <p style="margin-top: 1rem;">
            <a href="/forgot-password">Forgot password?</a> |
            <a href="/register">Register</a>
        </p>
    </div>
    '''
    return render_base('Login', content)


def render_register(error=None, success=None):
    """Render registration page."""
    error_html = f'<div class="error">{escape_html(error)}</div>' if error else ''
    success_html = f'<div class="success">{escape_html(success)}</div>' if success else ''
    content = f'''
    <div class="card" style="max-width: 400px; margin: 0 auto;">
        <h2>Register</h2>
        {error_html}{success_html}
        <form method="POST" action="/register">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" required minlength="3" maxlength="20">
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" required>
            </div>
            <div class="form-group">
                <label>Password (min 8 chars, 1 letter, 1 number)</label>
                <input type="password" name="password" required minlength="8">
            </div>
            <div class="form-group">
                <label>Confirm Password</label>
                <input type="password" name="confirm_password" required>
            </div>
            <button type="submit">Register</button>
        </form>
    </div>
    '''
    return render_base('Register', content)


def render_edit(user):
    """Render image editing page."""
    content = '''
    <div style="display: flex; gap: 2rem; flex-wrap: wrap;">
        <div class="card" style="flex: 2; min-width: 300px;">
            <h2>Create Image</h2>
            <div id="preview-container" style="position: relative; width: 100%; max-width: 640px;">
                <video id="webcam" width="640" height="480" autoplay style="width: 100%; border-radius: 4px;"></video>
                <canvas id="overlay-canvas" style="position: absolute; top: 0; left: 0; width: 100%; pointer-events: none;"></canvas>
            </div>
            <div style="margin: 1rem 0;">
                <p><strong>Select Overlay:</strong></p>
                <div id="overlays" style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
                    <button class="overlay-btn" data-overlay="frame_gold" style="background: gold;">Gold Frame</button>
                    <button class="overlay-btn" data-overlay="frame_silver" style="background: silver;">Silver Frame</button>
                    <button class="overlay-btn" data-overlay="frame_red" style="background: red; color: white;">Red Frame</button>
                    <button class="overlay-btn" data-overlay="frame_blue" style="background: blue; color: white;">Blue Frame</button>
                    <button class="overlay-btn" data-overlay="vignette" style="background: #333; color: white;">Vignette</button>
                </div>
            </div>
            <button id="capture-btn" disabled style="margin-right: 1rem;">Capture</button>
            <label style="display: inline-block;">
                Or upload: <input type="file" id="upload-input" accept="image/*">
            </label>
        </div>
        <div class="card" style="flex: 1; min-width: 200px;">
            <h2>My Images</h2>
            <div id="my-images"></div>
        </div>
    </div>
    <script>
        let selectedOverlay = null;
        const video = document.getElementById('webcam');
        const overlayCanvas = document.getElementById('overlay-canvas');
        const captureBtn = document.getElementById('capture-btn');

        // Request webcam
        navigator.mediaDevices.getUserMedia({ video: true })
            .then(stream => { video.srcObject = stream; })
            .catch(err => { console.log('Webcam not available:', err); });

        // Overlay selection
        document.querySelectorAll('.overlay-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.overlay-btn').forEach(b => b.style.border = '');
                btn.style.border = '3px solid #667eea';
                selectedOverlay = btn.dataset.overlay;
                captureBtn.disabled = false;
                drawOverlay();
            });
        });

        function drawOverlay() {
            const ctx = overlayCanvas.getContext('2d');
            overlayCanvas.width = 640;
            overlayCanvas.height = 480;
            ctx.clearRect(0, 0, 640, 480);
            if (selectedOverlay && selectedOverlay.startsWith('frame_')) {
                ctx.strokeStyle = selectedOverlay.replace('frame_', '');
                ctx.lineWidth = 20;
                ctx.strokeRect(10, 10, 620, 460);
            } else if (selectedOverlay === 'vignette') {
                const gradient = ctx.createRadialGradient(320, 240, 100, 320, 240, 400);
                gradient.addColorStop(0, 'rgba(0,0,0,0)');
                gradient.addColorStop(1, 'rgba(0,0,0,0.8)');
                ctx.fillStyle = gradient;
                ctx.fillRect(0, 0, 640, 480);
            }
        }

        captureBtn.addEventListener('click', () => {
            const canvas = document.createElement('canvas');
            canvas.width = 640;
            canvas.height = 480;
            const ctx = canvas.getContext('2d');
            ctx.drawImage(video, 0, 0);
            ctx.drawImage(overlayCanvas, 0, 0);
            const imageData = canvas.toDataURL('image/png');
            saveImage(imageData);
        });

        document.getElementById('upload-input').addEventListener('change', (e) => {
            if (!selectedOverlay) { alert('Please select an overlay first'); return; }
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = (event) => {
                    const img = new Image();
                    img.onload = () => {
                        const canvas = document.createElement('canvas');
                        canvas.width = 640;
                        canvas.height = 480;
                        const ctx = canvas.getContext('2d');
                        ctx.drawImage(img, 0, 0, 640, 480);
                        ctx.drawImage(overlayCanvas, 0, 0);
                        saveImage(canvas.toDataURL('image/png'));
                    };
                    img.src = event.target.result;
                };
                reader.readAsDataURL(file);
            }
        });

        function saveImage(imageData) {
            fetch('/api/save-image', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ image: imageData, overlay: selectedOverlay })
            })
            .then(r => r.json())
            .then(data => {
                if (data.success) { loadMyImages(); }
                else { alert(data.error || 'Error saving image'); }
            });
        }

        function loadMyImages() {
            fetch('/api/my-images')
                .then(r => r.json())
                .then(images => {
                    const container = document.getElementById('my-images');
                    container.innerHTML = images.map(img => `
                        <div style="margin-bottom: 1rem; position: relative;">
                            <img src="/uploads/${img.filename}" style="width: 100%; border-radius: 4px;">
                            <button onclick="deleteImage(${img.id})" style="position: absolute; top: 5px; right: 5px; background: red;">X</button>
                        </div>
                    `).join('') || '<p>No images yet.</p>';
                });
        }

        function deleteImage(id) {
            if (confirm('Delete this image?')) {
                fetch('/api/delete-image', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ id: id })
                })
                .then(r => r.json())
                .then(data => { if (data.success) loadMyImages(); });
            }
        }

        loadMyImages();
    </script>
    '''
    return render_base('Create', content, user)


def render_profile(user, message=None):
    """Render profile page."""
    msg_html = f'<div class="success">{escape_html(message)}</div>' if message else ''
    content = f'''
    <div class="card" style="max-width: 500px; margin: 0 auto;">
        <h2>Profile Settings</h2>
        {msg_html}
        <form method="POST" action="/profile">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" value="{escape_html(user['username'])}" required>
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" value="{escape_html(user['email'])}" required>
            </div>
            <div class="form-group">
                <label>New Password (leave empty to keep current)</label>
                <input type="password" name="new_password">
            </div>
            <div class="form-group">
                <label>
                    <input type="checkbox" name="notify_comments" {'checked' if user['notify_comments'] else ''}>
                    Email me when someone comments on my images
                </label>
            </div>
            <button type="submit">Save Changes</button>
        </form>
    </div>
    '''
    return render_base('Profile', content, user)


# =============================================================================
# HTTP Request Handler
# =============================================================================

class CamagruHandler(BaseHTTPRequestHandler):
    def get_session_token(self):
        """Get session token from cookies."""
        cookies = self.headers.get('Cookie', '')
        for cookie in cookies.split(';'):
            if '=' in cookie:
                name, value = cookie.strip().split('=', 1)
                if name == 'session':
                    return value
        return None

    def get_current_user(self):
        """Get current user from session."""
        token = self.get_session_token()
        if token:
            return Database.get_user_by_session(token)
        return None

    def send_html(self, html, status=200, cookies=None):
        """Send HTML response."""
        self.send_response(status)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        if cookies:
            for cookie in cookies:
                self.send_header('Set-Cookie', cookie)
        self.end_headers()
        self.wfile.write(html.encode())

    def send_json(self, data, status=200):
        """Send JSON response."""
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def redirect(self, location, cookies=None):
        """Send redirect response."""
        self.send_response(302)
        self.send_header('Location', location)
        if cookies:
            for cookie in cookies:
                self.send_header('Set-Cookie', cookie)
        self.end_headers()

    def get_post_data(self):
        """Parse POST data."""
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)
        content_type = self.headers.get('Content-Type', '')

        if 'application/json' in content_type:
            return json.loads(body.decode())
        else:
            return {k: v[0] for k, v in parse_qs(body.decode()).items()}

    def do_GET(self):
        """Handle GET requests."""
        parsed = urlparse(self.path)
        path = parsed.path
        query = parse_qs(parsed.query)
        user = self.get_current_user()

        if path == '/':
            page = int(query.get('page', [1])[0])
            images, total = Database.get_images(page)
            self.send_html(render_gallery(images, page, total, user))

        elif path == '/login':
            if user:
                self.redirect('/')
            else:
                self.send_html(render_login())

        elif path == '/register':
            self.send_html(render_register())

        elif path == '/logout':
            token = self.get_session_token()
            if token:
                Database.logout_user(token)
            self.redirect('/', ['session=; Max-Age=0; Path=/'])

        elif path == '/edit':
            if not user:
                self.redirect('/login')
            else:
                self.send_html(render_edit(user))

        elif path == '/profile':
            if not user:
                self.redirect('/login')
            else:
                self.send_html(render_profile(user))

        elif path == '/api/my-images':
            if user:
                images = Database.get_user_images(user['id'])
                self.send_json(images)
            else:
                self.send_json({'error': 'Not authenticated'}, 401)

        elif path.startswith('/uploads/'):
            # Serve uploaded images
            filename = path.split('/')[-1]
            filepath = os.path.join('uploads', filename)
            if os.path.exists(filepath) and '..' not in filename:
                self.send_response(200)
                self.send_header('Content-Type', 'image/png')
                self.end_headers()
                with open(filepath, 'rb') as f:
                    self.wfile.write(f.read())
            else:
                self.send_response(404)
                self.end_headers()

        elif path.startswith('/verify/'):
            token = path.split('/')[-1]
            if Database.verify_user(token):
                self.send_html(render_login())
            else:
                self.send_html(render_base('Error', '<div class="error">Invalid verification link</div>'))

        else:
            self.send_response(404)
            self.send_html(render_base('Not Found', '<h2>Page Not Found</h2>'))

    def do_POST(self):
        """Handle POST requests."""
        path = self.path
        data = self.get_post_data()
        user = self.get_current_user()

        if path == '/login':
            username = data.get('username', '')
            password = data.get('password', '')
            token, error = Database.login_user(username, password)
            if token:
                self.redirect('/', [f'session={token}; Path=/; HttpOnly'])
            else:
                self.send_html(render_login(error or 'Login failed'))

        elif path == '/register':
            username = data.get('username', '').strip()
            email = data.get('email', '').strip()
            password = data.get('password', '')
            confirm = data.get('confirm_password', '')

            if len(username) < 3:
                self.send_html(render_register('Username must be at least 3 characters'))
            elif not validate_email(email):
                self.send_html(render_register('Invalid email address'))
            elif not validate_password(password):
                self.send_html(render_register('Password must be 8+ chars with letters and numbers'))
            elif password != confirm:
                self.send_html(render_register('Passwords do not match'))
            else:
                user_id, verify_token = Database.create_user(username, email, password)
                if user_id:
                    # In production, send email with verification link
                    verify_link = f'http://localhost:8080/verify/{verify_token}'
                    print(f"Verification link for {email}: {verify_link}")
                    self.send_html(render_register(None,
                        f'Registration successful! Check console for verification link.'))
                else:
                    self.send_html(render_register('Username or email already exists'))

        elif path == '/profile' and user:
            # Update profile
            self.send_html(render_profile(user, 'Profile updated'))

        elif path == '/api/save-image':
            if not user:
                self.send_json({'error': 'Not authenticated'}, 401)
            else:
                image_data = data.get('image', '')
                overlay = data.get('overlay', '')
                if image_data:
                    processed = create_overlay_image(image_data, overlay)
                    image_id = Database.save_image(user['id'], processed)
                    self.send_json({'success': True, 'id': image_id})
                else:
                    self.send_json({'error': 'No image data'}, 400)

        elif path == '/api/delete-image':
            if not user:
                self.send_json({'error': 'Not authenticated'}, 401)
            else:
                image_id = data.get('id')
                if Database.delete_image(image_id, user['id']):
                    self.send_json({'success': True})
                else:
                    self.send_json({'error': 'Cannot delete'}, 403)

        elif path == '/api/like':
            if not user:
                self.send_json({'error': 'Not authenticated'}, 401)
            else:
                image_id = data.get('image_id')
                liked = Database.toggle_like(image_id, user['id'])
                self.send_json({'success': True, 'liked': liked})

        elif path == '/api/comment':
            if not user:
                self.send_json({'error': 'Not authenticated'}, 401)
            else:
                image_id = data.get('image_id')
                content = escape_html(data.get('content', '').strip())
                if content:
                    Database.add_comment(image_id, user['id'], content)
                    self.send_json({'success': True})
                else:
                    self.send_json({'error': 'Empty comment'}, 400)

        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        """Custom log format."""
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {args[0]}")


# =============================================================================
# Main
# =============================================================================

def main():
    print("Camagru - Web Application")
    print("=" * 50)

    if '--help' in sys.argv:
        print("\nUsage: python camagru.py [port]")
        print("\nA web application for photo editing with overlays.")
        print("\nFeatures:")
        print("  - User registration and authentication")
        print("  - Webcam capture with overlay effects")
        print("  - Image upload support")
        print("  - Public gallery with likes and comments")
        print("  - Pagination")
        print("\nDefault port: 8080")
        return

    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080

    # Initialize database
    init_db()
    print(f"Database initialized: {DB_PATH}")

    # Create uploads directory
    os.makedirs("uploads", exist_ok=True)

    # Start server
    server = HTTPServer(('', port), CamagruHandler)
    print(f"\nServer running at http://localhost:{port}")
    print("Press Ctrl+C to stop\n")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
        server.server_close()


if __name__ == "__main__":
    main()
