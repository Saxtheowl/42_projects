# D02 - Formation Ruby on Rails

This project covers Object-Oriented Programming (OOP) in Ruby, focusing on classes, exceptions, inheritance, and metaprogramming.

## Requirements

- Ruby >= 2.3.0
- Docker (optional, for running tests)

## Constraints

- **Forbidden keywords**: `while`, `for`, `redo`, `break`, `retry`, `loop`, `until`
- All files must have a shebang (`#!/usr/bin/env ruby -w`) and warning flag
- No code in global scope - use classes or functions
- Each file includes tests in `if $PROGRAM_NAME == __FILE__` block

## Exercises

### Exercise 00: HTML (`ex00/`)

Basic HTML file generator class.

**Features:**
- Constructor takes a filename (without extension)
- `head` method creates HTML header
- `dump(content)` adds paragraphs to body
- `finish` closes the body tag
- `attr_reader` for `@page_name`

**Usage:**
```ruby
a = Html.new("test")
10.times { |x| a.dump("titi_number#{x}") }
a.finish
```

### Exercise 01: Raise HTML (`ex01/`)

HTML generator with exception handling.

**Exceptions raised:**
- Duplicate filename: `"A file named <filename> already exist!"`
- No body tag: `"There is no body tag in <filename>"`
- Body already closed: `"Body has already been closed in <filename>"`
- File already closed: `"<filename> has already been closed"`

### Exercise 02: Rescue HTML (`ex02/`)

Custom exception classes with recovery mechanisms.

**Classes:**
- `Dup_file` - Handles duplicate file creation by appending `.new`
- `Body_closed` - Handles writing after body close by reopening

**Methods on exceptions:**
- `show_state` - Display current state
- `correct` - Fix the error
- `explain` - Display state after correction

### Exercise 03: Elem (`ex03/`)

Generic HTML element class with nested content support.

**Classes:**
- `Elem` - Represents any HTML element
- `Text` - Represents text content

**Features:**
- Constructor: `Elem.new(tag, content, tag_type, attributes)`
- `add_content` - Add nested elements
- `to_s` - Generate HTML string

### Exercise 04: Dejavu (`ex04/`)

Derived HTML element classes using inheritance and metaprogramming.

**Double tags (opening/closing):**
Html, Head, Body, Title, Table, Th, Tr, Td, Ul, Ol, Li, H1, H2, P, Div, Span

**Self-closing tags:**
Meta, Img, Hr, Br

**Usage:**
```ruby
puts Html.new([
  Head.new([Title.new([Text.new("Hello!")])]),
  Body.new([H1.new([Text.new("Welcome")])])
])
```

### Exercise 05: Validation (`ex05/`)

HTML structure validator with strict rules.

**Class:**
- `Page` - Validates HTML structure with `is_valid?` method

**Validation rules:**
- `Html` must contain exactly one `Head` then one `Body`
- `Head` must contain only one `Title`
- `Body`/`Div` can contain: H1, H2, Div, Table, Ul, Ol, Span, Text, P, Img, Hr, Br
- `Title`, `H1`, `H2`, `Li`, `Th`, `Td` must contain exactly one `Text`
- `P` must contain only `Text`
- `Span` must contain only `Text` or `P`
- `Ul`/`Ol` must contain at least one `Li`
- `Tr` must contain `Th` OR `Td` (mutually exclusive)
- `Table` must contain only `Tr`
- `Img` must have a `src` attribute with `Text` value

## Running Tests

### With Docker:
```bash
# Exercise 00
cd ex00 && docker run --rm -v "$(pwd):/app" -w /app ruby:3.2 ruby ex00.rb

# Exercise 01
cd ex01 && docker run --rm -v "$(pwd):/app" -w /app ruby:3.2 ruby ex01.rb

# Exercise 02
cd ex02 && docker run --rm -v "$(pwd):/app" -w /app ruby:3.2 ruby ex02.rb

# Exercise 03
cd ex03 && docker run --rm -v "$(pwd):/app" -w /app ruby:3.2 ruby ex03.rb

# Exercise 04
cd ex04 && docker run --rm -v "$(pwd):/app" -w /app ruby:3.2 ruby ex04.rb

# Exercise 05
cd ex05 && docker run --rm -v "$(pwd):/app" -w /app ruby:3.2 ruby whereto.rb
```

### With local Ruby:
```bash
ruby ex00/ex00.rb
ruby ex01/ex01.rb
ruby ex02/ex02.rb
ruby ex03/ex03.rb
ruby ex04/ex04.rb
ruby ex05/whereto.rb
```

### Interactive testing (IRB):
```ruby
require_relative "ex00/ex00.rb"
a = Html.new("test")
a.dump("content")
a.finish
```

## Project Structure

```
D02_-_Formation_Ruby_on_Rails/
├── README.md
├── ex00/
│   └── ex00.rb      # Basic HTML class
├── ex01/
│   └── ex01.rb      # HTML with exceptions
├── ex02/
│   └── ex02.rb      # HTML with rescue/recovery
├── ex03/
│   └── ex03.rb      # Elem class
├── ex04/
│   └── ex04.rb      # HTML element classes
└── ex05/
    └── whereto.rb   # Page validator
```
