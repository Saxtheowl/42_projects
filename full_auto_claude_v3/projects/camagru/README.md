# Camagru - Photo Editing Web Application

Web application for photo editing with overlays, webcam capture, and social features.

## Features

- User registration with email verification
- Secure login/logout with session management
- Webcam capture with live preview
- Image upload support
- Overlay effects (frames, vignette)
- Server-side image processing
- Public gallery with pagination
- Like and comment system
- User profile management
- Responsive design

## Usage

```bash
python3 camagru.py [port]
```

Default port: 8080

Then open http://localhost:8080 in your browser.

## Testing

1. **Registration**:
   - Go to /register
   - Fill in username, email, password
   - Check console for verification link
   - Click verification link

2. **Login**:
   - Go to /login
   - Enter credentials
   - Should redirect to gallery

3. **Create Image**:
   - Click "Create" in navigation
   - Allow webcam access (or use upload)
   - Select an overlay effect
   - Click "Capture" or upload an image
   - Image appears in sidebar

4. **Gallery**:
   - Public gallery shows all images
   - Pagination with 5 images per page
   - Logged in users can view details

5. **Profile**:
   - Update username, email, password
   - Toggle comment notifications

## Architecture

```
camagru.py          # Main application
camagru.db          # SQLite database (created automatically)
uploads/            # Uploaded images directory
```

## Security Features

- Password hashing with salt (SHA256)
- Session tokens (secure random)
- HTML escaping (XSS prevention)
- SQL parameterized queries (injection prevention)
- CSRF protection (session-based)
- Input validation
- HttpOnly cookies

## Database Schema

```sql
-- Users
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    password_hash TEXT,
    verified INTEGER,
    verify_token TEXT,
    notify_comments INTEGER
);

-- Images
CREATE TABLE images (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    filename TEXT,
    created_at TIMESTAMP
);

-- Likes
CREATE TABLE likes (
    id INTEGER PRIMARY KEY,
    image_id INTEGER,
    user_id INTEGER,
    UNIQUE(image_id, user_id)
);

-- Comments
CREATE TABLE comments (
    id INTEGER PRIMARY KEY,
    image_id INTEGER,
    user_id INTEGER,
    content TEXT,
    created_at TIMESTAMP
);
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | / | Gallery page |
| GET | /login | Login page |
| POST | /login | Authenticate |
| GET | /register | Registration page |
| POST | /register | Create account |
| GET | /logout | Logout |
| GET | /edit | Image editor |
| GET | /profile | User settings |
| POST | /api/save-image | Save captured image |
| POST | /api/delete-image | Delete user's image |
| GET | /api/my-images | Get user's images |
| POST | /api/like | Toggle like |
| POST | /api/comment | Add comment |

## Overlay Effects

- **Gold Frame**: Golden border
- **Silver Frame**: Silver border
- **Red Frame**: Red border
- **Blue Frame**: Blue border
- **Vignette**: Dark corners effect

## Requirements

- Python 3.6+
- No external dependencies (uses standard library)

## Browser Compatibility

- Firefox 41+
- Chrome 46+
- Safari 10+
- Edge 14+

## Author

Implementation for 42 curriculum (web track).
