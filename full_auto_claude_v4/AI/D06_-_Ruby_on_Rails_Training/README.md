# D06 - Ruby on Rails Training: Permissions & Privileges

This project implements a Rails 4.2.11 application called "LifeProTips" demonstrating authentication, authorization, and privilege-based access control.

## Project Structure

Each exercise folder contains the complete application with cumulative features:

- **ex00**: Basic authentication (signup, login, logout, random animal visitor names)
- **ex01**: Admin namespace for user management
- **ex02**: Posts CRUD with visitor restrictions
- **ex03**: Post edit tracking (edited_by, date)
- **ex04**: Upvote/Downvote system
- **ex05**: Vote-based privileges

## Features Implemented

### Exercise 00: Authentication (It's me)
- User model with name, email, encrypted password
- Unique name and email validation
- Password minimum 8 characters
- Session-based authentication
- Random animal name for visitors (1 minute cookie expiry)
- Auto-login after registration

### Exercise 01: Admin Namespace (Add me in)
- Admin::UsersController with namespace routing
- Admin users can list, edit, delete all users
- Admin link in header for admin users
- Users can edit their own profile

### Exercise 02: Posts (Need an account)
- Post scaffold with user_id, title (unique, min 3 chars), content
- Posts ordered by date descending
- Visitors can only see index, redirected with message for other actions
- Root page is posts index

### Exercise 03: Edit Tracking (Peer edit)
- Posts track edited_by_id and edited_at
- Post show displays editor name and modification date

### Exercise 04: Voting (UvDv)
- Vote model (ActiveRecord) with user_id, post_id, value (+1/-1)
- Unique constraint on user + post combination
- Upvote and downvote buttons on post show
- Admin vote management interface

### Exercise 05: Privileges (Can you?)
- Vote-based privilege system:
  - 0-2 votes: No special privileges
  - 3-5 votes: Can upvote
  - 6-9 votes: Can downvote
  - 10+ votes: Can edit any post
- User show displays privileges
- Admin users page shows privileges

## Running the Application

### Prerequisites
- Docker (recommended)
- Or Ruby 2.5+ with Rails 4.2.11

### Using Docker

```bash
cd AI/D06_-_Formation_Ruby_on_Rails/ex05/LifeProTips

# Install dependencies
docker run --rm -e BUNDLE_APP_CONFIG=/app/.bundle -v "$(pwd):/app" -w /app ruby:2.5 bash -c "
  gem install bundler -v '1.17.3' --no-document
  bundle install --path vendor/bundle
"

# Setup database
docker run --rm -e BUNDLE_APP_CONFIG=/app/.bundle -v "$(pwd):/app" -w /app ruby:2.5 bash -c "
  gem install bundler -v '1.17.3' --no-document
  bundle exec rake db:create db:migrate db:seed
"

# Run server
docker run --rm -p 3000:3000 -e BUNDLE_APP_CONFIG=/app/.bundle -v "$(pwd):/app" -w /app ruby:2.5 bash -c "
  gem install bundler -v '1.17.3' --no-document
  bundle exec rails server -b 0.0.0.0
"
```

Then visit http://localhost:3000

### Running Tests

```bash
docker run --rm -e BUNDLE_APP_CONFIG=/app/.bundle -v "$(pwd):/app" -w /app ruby:2.5 bash -c "
  gem install bundler -v '1.17.3' --no-document
  bundle exec rake db:migrate RAILS_ENV=test
  bundle exec rake test
"
```

## Test Results

- 74 tests, 120 assertions
- 0 failures, 0 errors

## Seed Data

The seed creates:
- **Admin**: admin@example.com / password123
- **Users**: bob, alice, charlie, diana (password: password123)

User privileges after seeding:
- bob: 9 votes (can upvote, downvote)
- alice: 4 votes (can upvote)
- charlie: 7 votes (can upvote, downvote)
- diana: 0 votes (no special privileges)

## Database Schema

### Users
| Column | Type |
|--------|------|
| id | integer |
| name | string (unique) |
| email | string (unique) |
| password_digest | string |
| admin | boolean (default: false) |

### Posts
| Column | Type |
|--------|------|
| id | integer |
| user_id | integer |
| title | string (unique, min 3 chars) |
| content | text |
| edited_by_id | integer |
| edited_at | datetime |

### Votes
| Column | Type |
|--------|------|
| id | integer |
| user_id | integer |
| post_id | integer |
| value | integer (+1 or -1) |

## Routes

```
Root: posts#index

Sessions:
  GET  /login     -> sessions#new
  POST /login     -> sessions#create
  DELETE /logout  -> sessions#destroy

Users:
  GET  /signup        -> users#new
  POST /users         -> users#create
  GET  /users/:id     -> users#show
  GET  /users/:id/edit -> users#edit
  PATCH /users/:id    -> users#update

Posts:
  GET    /posts          -> posts#index
  GET    /posts/new      -> posts#new
  POST   /posts          -> posts#create
  GET    /posts/:id      -> posts#show
  GET    /posts/:id/edit -> posts#edit
  PATCH  /posts/:id      -> posts#update
  DELETE /posts/:id      -> posts#destroy
  POST   /posts/:id/upvote   -> posts#upvote
  POST   /posts/:id/downvote -> posts#downvote

Admin (namespace):
  /admin/users   -> CRUD for users
  /admin/posts   -> CRUD for posts
  /admin/votes   -> index, destroy
```

## Constraints

- No while, for, redo, break, retry, loop, until keywords
- No global variables
- No additions to provided Gemfile
- rails_best_practices must report no warnings
- rubycritic score >= 90

## Author

Generated for 42 Ruby on Rails Training - Day 06
