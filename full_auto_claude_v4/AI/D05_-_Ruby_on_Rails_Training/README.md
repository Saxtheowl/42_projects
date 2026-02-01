# D05 - Ruby on Rails Training: SQL

This project covers SQL concepts in Ruby on Rails, including raw SQL with SQLite3 and Active Record ORM.

## Project Structure

The project contains two Rails applications shared across multiple exercises:

### 1. Seek_well (Exercises 00, 02, 04, 06, 08, 10)
A Rails application demonstrating raw SQL operations using SQLite3.

**Location:** `ex00/Seek_well/` (referenced by ex02, ex04, ex06, ex08, ex10)

### 2. tweetos_aka_hello_rails (Exercises 01, 03, 05, 07, 09)
A Rails application demonstrating Active Record patterns.

**Location:** `ex01/tweetos_aka_hello_rails/` (referenced by ex03, ex05, ex07, ex09)

## Exercises Overview

### Exercise 00: CRUD Starts Here (ex00)
- Create database file (`create_db`)
- Create tables `clock_watch` and `race` (`create_table`)
- Drop tables (`drop_table`)

**Files:** `app/controllers/ft_query_controller.rb`

### Exercise 01: Seeds and Migrations (ex01)
- Create migrations for User, Cuicui (Tweet), Comment, and Like tables
- Configure routes with root path

**Files:** `db/migrate/`, `config/routes.rb`, `db/seeds.rb`

### Exercise 02: Create and Read (ex02)
- Implement `start_race` method to create race entries
- Insert 4 runners with timestamps

### Exercise 03: Active Record Associations (ex03)
- User has_many cuicuis, comments, likes
- Cuicui belongs_to user, has_many comments, likes
- Comment belongs_to user, cuicui
- Like belongs_to user, cuicui

**Files:** `app/models/*.rb`

### Exercise 04: Dynamic Creation (ex04)
- Implement `insert_time_stamp` for lap tracking
- Increment lap counter for each runner

### Exercise 05: Validation (ex05)
- User: unique name/email, min length 2, banned names, presence validations
- Cuicui: unique content, user_id presence
- Comment: unique content, user_id/cuicui_id presence
- Like: unique user_id/cuicui_id combination

**Validations include:**
- Email format validation
- Numeric ID validation
- Foreign key existence validation

**Files:** `app/models/*.rb`

### Exercise 06: 3D (Delete) (ex06)
- Implement `delete_all` to remove all clock_watch entries
- Implement `delete_last` to remove the most recent entry

### Exercise 07: Model Methods (ex07)
User model methods:
- `fame`: Sum of likes on all user's tweets
- `senior?`: Returns true if registered > 10 years ago
- `junior?`: Returns true if registered < 10 years ago
- `responses`: Last 5 comments on user's tweets
- `top_tweet`: User's tweets sorted by likes (descending)

**Files:** `app/models/user.rb`

### Exercise 08: Select (ex08)
- Implement `all_by_name` to sort clock_watch by runner name
- Implement `all_by_race` to sort clock_watch by race ID

### Exercise 09: Scope (ex09)
- Implement `scope :top` on Cuicui model
- Returns tweets sorted by number of likes (descending)

**Files:** `app/models/cuicui.rb`

### Exercise 10: CRUD End Here (Update) (ex10)
- Implement `update_name` to change runner names
- Anonymous runners cannot be renamed

## Running the Applications

### Prerequisites
- Docker (recommended)
- Or Ruby 3.2+ with Rails 7.2+

### Using Docker (Recommended)

```bash
cd AI/D05_-_Ruby_on_Rails_Training

# Run Seek_well tests
docker run --rm -v "$(pwd)/ex00/Seek_well:/app" -w /app ruby:3.2 bash -c "
  bundle config set --local path 'vendor/bundle'
  bundle install
  bundle exec ruby -Ilib:test test/controllers/ft_query_controller_test.rb
"

# Run tweetos tests
docker run --rm -v "$(pwd)/ex01/tweetos_aka_hello_rails:/app" -w /app ruby:3.2 bash -c "
  bundle config set --local path 'vendor/bundle'
  bundle install
  bundle exec rails db:migrate RAILS_ENV=test
  bundle exec rake test
"
```

### Running the Rails Server

```bash
# Seek_well
docker run --rm -p 3000:3000 -v "$(pwd)/ex00/Seek_well:/app" -w /app ruby:3.2 bash -c "
  bundle config set --local path 'vendor/bundle'
  bundle install
  bundle exec rails server -b 0.0.0.0
"

# tweetos_aka_hello_rails
docker run --rm -p 3000:3000 -v "$(pwd)/ex01/tweetos_aka_hello_rails:/app" -w /app ruby:3.2 bash -c "
  bundle config set --local path 'vendor/bundle'
  bundle install
  bundle exec rails db:migrate
  bundle exec rails db:seed
  bundle exec rails server -b 0.0.0.0
"
```

Then visit http://localhost:3000

## Test Results

### Seek_well Tests (ex00, ex02, ex04, ex06, ex08, ex10)
- 11 tests, 91 assertions, 0 failures

### tweetos_aka_hello_rails Tests (ex01, ex03, ex05, ex07, ex09)
- 41 tests, 162 assertions, 0 failures

## Database Schema

### Seek_well (SQLite3 raw)

**clock_watch:**
| Column | Type |
|--------|------|
| ts_id | INTEGER PRIMARY KEY |
| day | INTEGER |
| month | INTEGER |
| year | INTEGER |
| hour | INTEGER |
| min | INTEGER |
| sec | INTEGER |
| race | INTEGER |
| name | VARCHAR(50) |
| lap | INTEGER |

**race:**
| Column | Type |
|--------|------|
| r_id | INTEGER PRIMARY KEY |
| start | VARCHAR(50) |

### tweetos_aka_hello_rails (Active Record)

**users:**
| Column | Type |
|--------|------|
| id | integer |
| name | string |
| email | string |
| since | integer |
| admin | boolean |
| country | string |
| created_at | datetime |
| updated_at | datetime |

**cuicuis:**
| Column | Type |
|--------|------|
| id | integer |
| content | text |
| user_id | integer |
| created_at | datetime |
| updated_at | datetime |

**comments:**
| Column | Type |
|--------|------|
| id | integer |
| content | text |
| cuicui_id | integer |
| user_id | integer |
| created_at | datetime |
| updated_at | datetime |

**likes:**
| Column | Type |
|--------|------|
| id | integer |
| user_id | integer |
| cuicui_id | integer |
| created_at | datetime |
| updated_at | datetime |

## Global Variables (Seek_well)

- `$db`: SQLite3::Database instance
- `$runner_1`, `$runner_2`, `$runner_3`, `$runner_4`: Runner names
- `$time_stamps`: Clock watch table contents
- `$all`: Sorted results

## Author

Generated for 42 Ruby on Rails Training - Day 05
