# D02 - Ruby on Rails Training

## Inheritance and Exception Classes

This project implements a series of Ruby exercises focused on Object-Oriented Programming (OOP) concepts including inheritance, exception handling, and class design.

## Project Structure

```
D02_-_Ruby_on_Rails_Training/
├── ex00/          # Basic HTML file generator class
│   └── ex00.rb
├── ex01/          # HTML class with exception handling (raise)
│   └── ex01.rb
├── ex02/          # HTML class with auto-correction (rescue)
│   └── ex02.rb
├── ex03/          # Elem and Text classes for HTML generation
│   └── ex03.rb
├── ex04/          # Derived HTML element classes (inheritance)
│   └── ex04.rb
├── ex05/          # HTML validation with Page class
│   └── whereto.rb
└── README.md
```

## Exercises

### Exercise 00: HTML

Basic `Html` class that creates and fills HTML files.

**Features:**
- Constructor takes a filename (without extension)
- `head` method: creates valid HTML structure with body opening tag
- `dump` method: adds text wrapped in `<p>` tags
- `finish` method: closes the body tag
- `attr_reader` for `@page_name`

**Usage:**
```ruby
a = Html.new("test")
10.times { |x| a.dump("titi_number#{x}") }
a.finish
```

### Exercise 01: Raise HTML

Enhanced `Html` class with exception management.

**Exceptions raised:**
- Creating a file that already exists: `"<filename> already exist!"`
- Calling `dump` without body tag: `"There is no body tag in <filename>"`
- Calling `dump` after body closed: `"Body has already been closed in <filename>"`
- Calling `finish` twice: `"<filename> has already been closed"`

### Exercise 02: Rescue HTML

Auto-correcting `Html` class with custom exception classes.

**Custom Exception Classes:**
- `Dup_file < StandardError`: Handles duplicate file creation
- `Body_closed < StandardError`: Handles writing after body closed

**Methods for each exception:**
- `show_state`: Shows state before correction
- `correct`: Fixes the error
- `explain`: Shows state after correction

**Auto-correction behaviors:**
- Duplicate files: Appends `.new` before extension (test.html -> test.new.html)
- Closed body: Removes closing tag, inserts text, re-adds closing tag

### Exercise 03: Elem

Object-oriented HTML representation with `Elem` and `Text` classes.

**Classes:**
- `Text`: Holds simple text content
- `Elem`: Represents HTML elements with:
  - Tag type
  - Content array
  - Orphan flag (self-closing tags)
  - Attributes hash

**Features:**
- `to_s` method for HTML output
- `add_content` for nesting elements
- Support for attributes (src, style, data, etc.)

### Exercise 04: Dejavu

Derived classes inheriting from `Elem`.

**Implemented Classes:**
- Structure: `Html`, `Head`, `Body`
- Content: `Title`, `P`, `Span`, `Div`
- Headings: `H1`, `H2`
- Tables: `Table`, `Tr`, `Th`, `Td`
- Lists: `Ul`, `Ol`, `Li`
- Media: `Img`, `Meta`
- Formatting: `Hr`, `Br`

**Usage:**
```ruby
puts Html.new([Head.new([Title.new("Hello ground!")]),
  Body.new([H1.new("Oh no, not again!"),
    Img.new([], {'src' => 'http://example.com/img.jpg'})])])
```

### Exercise 05: Validation

`Page` class for validating HTML structure.

**Validation Rules:**
- `Html` must contain exactly one `Head` followed by one `Body`
- `Head` must contain exactly one `Title`
- `Body`/`Div` may contain: `H1`, `H2`, `Div`, `Table`, `Ul`, `Ol`, `Span`, `Text`, `P`, `Img`, `Hr`, `Br`
- `Title`, `H1`, `H2`, `Li`, `Th`, `Td` must contain exactly one `Text`
- `P` must contain only `Text`
- `Span` may contain `Text` or `P`
- `Ul`/`Ol` must contain at least one `Li`
- `Tr` must contain `Th` or `Td` (mutually exclusive)
- `Table` must contain only `Tr` elements
- `Img` must have a `src` attribute

## Running Tests

Each file contains tests in the `if $PROGRAM_NAME == __FILE__` block.

### Using Docker (recommended):

```bash
cd D02_-_Ruby_on_Rails_Training
docker run --rm -v "$(pwd):/app" -w /app ruby:3.3 ruby ex00/ex00.rb
docker run --rm -v "$(pwd):/app" -w /app ruby:3.3 ruby ex01/ex01.rb
docker run --rm -v "$(pwd):/app" -w /app ruby:3.3 ruby ex02/ex02.rb
docker run --rm -v "$(pwd):/app" -w /app ruby:3.3 ruby ex03/ex03.rb
docker run --rm -v "$(pwd):/app" -w /app ruby:3.3 ruby ex04/ex04.rb
docker run --rm -v "$(pwd):/app" -w /app ruby:3.3 ruby ex05/whereto.rb
```

### Using local Ruby:

```bash
ruby ex00/ex00.rb
ruby ex01/ex01.rb
# ... etc
```

### Interactive Testing (irb):

```ruby
require_relative "ex00/ex00.rb"
a = Html.new("mypage")
a.dump("Hello World")
a.finish
```

## Requirements

- Ruby 3.x
- No external dependencies

## Technical Details

- All files include shebang (`#!/usr/bin/env ruby`)
- Warning flag enabled (`# warn_indent: true`)
- No global scope code - everything in classes/methods
- Tests included in each file
