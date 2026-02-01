# D03 - Ruby on Rails Training: Gems

This project contains exercises for learning Ruby Gems and Ruby on Rails.

## Requirements

- Ruby >= 3.0.0
- Bundler
- Rails >= 7.1 (for ex03)

Alternatively, use Docker (recommended).

## Exercises

### Exercise 00: deepthought (ex00/)

A simple gem that answers "The Ultimate Question of Life, the Universe and Everything".

**Features:**
- Uses the `colorize` gem for colored output
- Returns "42" (in green) for the ultimate question
- Returns "Mmmm i'm bored" (in red) for other questions

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
bundle exec rake test
```

### Exercise 01: ft_wikipedia (ex01/)

A gem that implements the "Getting to Philosophy" Wikipedia game.

**Features:**
- Follows the first valid link on each Wikipedia page
- Continues until reaching the Philosophy page
- Handles loops and dead ends with StandardError exceptions

**Usage:**
```ruby
require 'ft_wikipedia'

Ft_wikipedia.search("Kiss")
# Prints each URL visited and returns the number of steps
```

**Run tests:**
```bash
cd ex01/ft_wikipedia
bundle install
bundle exec rake test
```

### Exercise 02: Taillste (ex02/)

A TDD exercise implementing a List class with various manipulation methods.

**Features:**
- List creation and manipulation
- head/tail operations (functional programming style)
- map, select, reject, reduce
- Sorting, reversing, flattening
- Concatenation and equality comparison

**Usage:**
```ruby
require 'taillste'

list = Taillste::List.new([1, 2, 3, 4, 5])
list.head      # => 1
list.tail.to_a # => [2, 3, 4, 5]
list.map { |x| x * 2 }.to_a # => [2, 4, 6, 8, 10]
```

**Run tests:**
```bash
cd ex02/Taillste
bundle install
bundle exec rake test
```

### Exercise 03: HelloWorld (ex03/)

A minimal Ruby on Rails application displaying "Hello World!".

**Run:**
```bash
cd ex03/HelloWorld
bundle install
bundle exec rails db:create db:migrate
bundle exec rails server
# Visit http://localhost:3000/
```

## Testing with Docker

Build and test all exercises:
```bash
docker build -t d03-rails .
```

Run the Rails server:
```bash
docker run -p 3000:3000 d03-rails
# Visit http://localhost:3000/
```

Or use docker-compose:
```bash
docker-compose up --build
```

## Gem Specifications

All gems follow these requirements:
- MIT License
- Version 0.0.1
- Tests with minitest
- No TODO comments in code
- No conduct code

## Project Structure

```
.
├── ex00/
│   └── deepthought/      # Deepthought gem
├── ex01/
│   └── ft_wikipedia/     # Wikipedia Philosophy game
├── ex02/
│   └── Taillste/         # TDD List manipulation gem
├── ex03/
│   └── HelloWorld/       # Rails Hello World app
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## License

MIT License
