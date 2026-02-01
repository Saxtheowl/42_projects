# D05 - Formation Ruby on Rails: SQL and Active Record

This project covers SQL and Active Record in Ruby on Rails 4.2.7.

## Projects

### Seek_well (SQL Exercises)
Raw SQL operations using SQLite3 for race timing functionality.

**Exercises:**
- Ex00: CRUD operations - create database, tables (clock_watch, race), drop tables
- Ex02: Start race - insert timestamps for 4 runners
- Ex04: Insert timestamp - add lap times during race
- Ex06: Delete operations - delete last record, delete all records
- Ex08: Select operations - order by name, order by race
- Ex10: Update operation - rename runner (except anonymous)

### tweetos_aka_hello_rails (Active Record Exercises)
Active Record ORM operations for a Twitter-like application.

**Exercises:**
- Ex01: Migrations - create users, cuicuis, comments, likes tables
- Ex03: Associations - has_many/belongs_to relationships
- Ex05: Validations - presence, uniqueness, format, custom validators
- Ex07: Model methods - fame, senior?, junior?, responses, top_cuicui
- Ex09: Scopes - Cuicui.top scope

## Requirements
- Ruby >= 2.3.0
- Rails 4.2.7
- SQLite3
- No while, for, redo, break, retry, loop, until keywords
- Rubocop with no offenses

## Docker Setup

Build the Docker image:
```bash
docker build -t rails427 .
```

Run tests:
```bash
# Seek_well
docker run --rm -v "$(pwd)/Seek_well:/app" -w /app rails427 bash -c "BUNDLE_PATH=vendor/bundle bundle exec rake test RAILS_ENV=test"

# tweetos_aka_hello_rails
docker run --rm -v "$(pwd)/tweetos_aka_hello_rails:/app" -w /app rails427 bash -c "BUNDLE_PATH=vendor/bundle bundle exec rake test RAILS_ENV=test"
```

Run rubocop:
```bash
# Seek_well
docker run --rm -v "$(pwd)/Seek_well:/app" -w /app rails427 bash -c "BUNDLE_PATH=vendor/bundle bundle exec rubocop"

# tweetos_aka_hello_rails
docker run --rm -v "$(pwd)/tweetos_aka_hello_rails:/app" -w /app rails427 bash -c "BUNDLE_PATH=vendor/bundle bundle exec rubocop"
```

## Test Results

### Seek_well
- 11 tests, 28 assertions, 0 failures, 0 errors
- Rubocop: 6 files inspected, no offenses detected

### tweetos_aka_hello_rails
- 35 tests, 91 assertions, 0 failures, 0 errors
- Rubocop: 18 files inspected, no offenses detected

## Database Schema

### Seek_well
**clock_watch table:**
- ts_id (INTEGER PRIMARY KEY)
- day, month, year (INTEGER)
- hour, min, sec (INTEGER)
- race (INTEGER)
- name (VARCHAR(50))
- lap (INTEGER)

**race table:**
- r_id (INTEGER PRIMARY KEY)
- start (VARCHAR(50))

### tweetos_aka_hello_rails
**users table:**
- id, name, email, since, country, created_at, updated_at

**cuicuis table:**
- id, content, user_id, created_at, updated_at

**comments table:**
- id, content, user_id, cuicui_id, created_at, updated_at

**likes table:**
- id, user_id, cuicui_id, created_at, updated_at

## Validation Rules (Ex05)
- User name: required, unique, min 2 chars, banished names (42, Ruby, lancelot du lac)
- User email: required, unique, valid format
- Cuicui content: required, unique
- Like: unique per user/cuicui combination
- All IDs must be numeric and reference existing records

## Model Methods (Ex07)
- `fame`: Total likes on all user's cuicuis
- `senior?`: User registered 10+ years ago
- `junior?`: User registered less than 10 years ago
- `responses`: 5 most recent comments on user's cuicuis
- `top_cuicui`: User's cuicuis sorted by likes count

## Scope (Ex09)
- `Cuicui.top`: All cuicuis ordered by likes count (descending)
