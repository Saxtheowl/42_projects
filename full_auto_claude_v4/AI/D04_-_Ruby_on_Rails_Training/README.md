# D04 - Ruby on Rails Training

This project contains 4 Ruby on Rails training exercises.

## Project Structure

```
D04_-_Ruby_on_Rails_Training/
├── ex00/CheatSheet/       # Exercise 00 - Single page CheatSheet
├── ex01/NewCheatSheet/    # Exercise 01 - Multi-page with navbar
├── ex02/CheatSheet/       # Exercise 02 - Quick search with DataTables
├── ex03/CheatSheet/       # Exercise 03 - Log Book with form
├── Dockerfile             # Docker configuration
├── docker-compose.yml     # Docker Compose
└── README.md
```

## Exercise 00 - CheatSheet

Simple Rails application with a single page displaying a Ruby on Rails cheatsheet.

**Features:**
- Application named "CheatSheet"
- Single custom controller (`cheatsheet_controller.rb`)
- Main page with title "CheatSheet"
- No navbar
- Bootstrap layout

## Exercise 01 - Moar CheatSheet

Multi-page Rails application with navigation.

**Features:**
- Application named "NewCheatSheet"
- Shared navbar (partial `_navbar.html.erb`)
- 13 distinct pages:
  - convention (root)
  - console
  - ruby
  - ruby-concepts
  - ruby-numbers
  - ruby-strings
  - ruby-arrays
  - ruby-hashes
  - rails-folder-structure
  - rails-commands
  - rails-erb
  - editor
  - help
- Each page has its own title tag

## Exercise 02 - Quick Search

Extension of exercise 01 with search functionality.

**Features:**
- New "Quick Search" tab
- Summary table of all commands
- jQuery DataTables integration for:
  - Dynamic search
  - Pagination
  - Column sorting

## Exercise 03 - Diary

Extension of exercise 02 with technical journal.

**Features:**
- New "Log Book" tab
- Form to add entries
- Storage in `entry_log.txt` at root
- Format: `DD/MM/YYYY HH:MM:SS : text`
- Display entries from newest to oldest

## Prerequisites

- Docker
- Ruby 3.2.x
- Rails 7.1.x

## Installation and Running

### With Docker

```bash
# Build the image
docker build -t rails-cheatsheet .

# Run an application (example: ex00)
cd ex00/CheatSheet
docker run --rm -v $(pwd):/app -w /app -p 3000:3000 ruby:3.2 bash -c "
  gem install bundler
  bundle install
  rails server -b 0.0.0.0
"
```

### Without Docker (Ruby installed locally)

```bash
cd ex00/CheatSheet
bundle install
rails server
```

Access the application: http://localhost:3000

## Gems Used

- `bootstrap` - CSS Framework
- `rubycritic` - Code quality analysis
- `jquery-datatables-rails` - Interactive tables (ex02, ex03)
- `jquery-rails` - jQuery for Rails

## Tests

To verify code quality:

```bash
cd exXX/AppName
bundle exec rubycritic
```

The report will be generated in `tmp/rubycritic/`.

## Notes

- Rails 7.1.5 used (modern version, same concepts as Rails 4.2.7)
- Bootstrap 5.3 via CDN for simplicity
- DataTables via CDN for ex02 and ex03
- No use of forbidden keywords (while, for, redo, break, retry, loop, until)

## Author

Project completed as part of 42 training.
