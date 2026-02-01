# D03 - Formation Ruby on Rails

This project contains 4 exercises for Ruby on Rails training.

## Requirements

- Ruby >= 2.3.0
- Rails 4.2.7 (for exercises, Rails 8+ for ex03)
- Bundler

## Exercises

### Exercise 00: deepthought (ex00/)

A simple Ruby Gem that answers "The Ultimate Question of Life, the Universe and Everything".

**Features:**
- Returns "42" (green) for the ultimate question
- Returns "Mmmm i'm bored" (red) for any other question

**Usage:**
```ruby
require 'deepthought'
dt = Deepthought.new
dt.respond("The Ultimate Question of Life, the Universe and Everything")
# => "42"
```

**Run tests:**
```bash
cd ex00/deepthought
bundle install
bundle exec rake
```

### Exercise 01: ft_wikipedia (ex01/)

A Gem that implements the "Wikipedia Philosophy Route" algorithm - clicking the first link in each Wikipedia article eventually leads to the Philosophy page.

**Features:**
- Follows the first valid link in each Wikipedia article
- Detects loops and dead ends
- Returns the number of hops to reach Philosophy

**Usage:**
```ruby
require 'ft_wikipedia'
Ft_wikipedia.search("Kiss")
# => 19 (approximately)
```

**Run tests:**
```bash
cd ex01/ft_wikipedia
bundle install
bundle exec rake
```

### Exercise 02: Taillste (ex02/)

A list data structure with size tracking, implemented using TDD approach.

**Features:**
- add, get, remove elements
- first, last, empty?, clear
- to_a, include?, each, map, select, reverse

**Usage:**
```ruby
require 'Taillste'
list = Taillste.new
list.add(1).add(2).add(3)
list.size  # => 3
list.first # => 1
```

**Run tests (must show "16 runs, 16 assertions, 0 failures, 0 errors, 0 skips"):**
```bash
cd ex02/Taillste
bundle install
bundle exec rake
```

### Exercise 03: HelloWorld (ex03/)

A basic Rails application displaying "Hello World!" on the homepage.

**Features:**
- Displays `<h1>Hello World!</h1>` at http://localhost:3000/

**Run server:**
```bash
cd ex03/HelloWorld
bundle install
rails server
```

Then visit http://localhost:3000/

## Testing with Docker

All exercises can be tested with Docker:

```bash
# Ex00
docker run --rm -v $(pwd)/ex00/deepthought:/app -w /app ruby:3.2 bash -c "bundle install && bundle exec rake"

# Ex01
docker run --rm -v $(pwd)/ex01/ft_wikipedia:/app -w /app ruby:3.2 bash -c "bundle install && bundle exec rake"

# Ex02
docker run --rm -v $(pwd)/ex02/Taillste:/app -w /app ruby:3.2 bash -c "bundle install && bundle exec rake"

# Ex03
docker run --rm -p 3000:3000 -v $(pwd)/ex03/HelloWorld:/app -w /app ruby:3.2 bash -c "bundle install && rails s -b 0.0.0.0"
```

## Project Rules

- No `while`, `for`, `redo`, `break`, `retry`, `loop`, `until` keywords
- Each Gem uses minitest
- MIT License
- No code of conduct
- Shebang `#!/usr/bin/env ruby -w` on all Ruby files

## Author

Student @ 42
