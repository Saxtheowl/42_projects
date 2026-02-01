# D01 - Ruby on Rails Training

## Syntactic and Semantic Basics

This project covers the fundamental syntactic and semantic concepts of the Ruby programming language through 8 exercises.

## Project Structure

```
D01_-_Ruby_on_Rails_Training/
├── ex00/
│   └── var.rb          # Variable types demonstration
├── ex01/
│   ├── croissant.rb    # File reading and sorting
│   └── numbers.txt     # Sample data file
├── ex02/
│   └── H2o.rb          # Array to Hash conversion
├── ex03/
│   └── Where.rb        # State to capital lookup
├── ex04/
│   └── erehW.rb        # Capital to state lookup (reverse)
├── ex05/
│   └── whereto.rb      # Multi-word state/capital detection
├── ex06/
│   └── CoffeeCroissant.rb  # Sorting by multiple criteria
├── ex07/
│   ├── elm.rb              # Periodic table HTML generator
│   ├── periodic_table.txt  # Element data
│   └── periodic_table.html # Generated output
├── tests/
│   └── test_all.rb     # Unit tests
├── run_tests.rb        # Integration test runner
└── README.md
```

## Requirements

- Ruby 3.x (tested with Ruby 3.2)
- Docker (optional, for running without local Ruby installation)

## Running the Exercises

### With Docker (recommended)

```bash
# Run all tests
docker run --rm -v "$(pwd):/app" ruby:3.2 ruby /app/run_tests.rb

# Run unit tests
docker run --rm -v "$(pwd):/app" ruby:3.2 ruby /app/tests/test_all.rb

# Run individual exercises
docker run --rm -v "$(pwd):/app" ruby:3.2 ruby /app/ex00/var.rb
docker run --rm -v "$(pwd):/app" ruby:3.2 ruby /app/ex01/croissant.rb
docker run --rm -v "$(pwd):/app" ruby:3.2 ruby /app/ex02/H2o.rb
docker run --rm -v "$(pwd):/app" ruby:3.2 ruby /app/ex03/Where.rb Oregon
docker run --rm -v "$(pwd):/app" ruby:3.2 ruby /app/ex04/erehW.rb Salem
docker run --rm -v "$(pwd):/app" ruby:3.2 ruby '/app/ex05/whereto.rb' "Salem, Alabama, Toto"
docker run --rm -v "$(pwd):/app" ruby:3.2 ruby /app/ex06/CoffeeCroissant.rb
docker run --rm -v "$(pwd):/app" ruby:3.2 ruby /app/ex07/elm.rb
```

### With Local Ruby

```bash
./ex00/var.rb
./ex01/croissant.rb
./ex02/H2o.rb
./ex03/Where.rb Oregon
./ex04/erehW.rb Salem
./ex05/whereto.rb "Salem, Alabama, Toto"
./ex06/CoffeeCroissant.rb
./ex07/elm.rb
```

## Exercise Descriptions

### Ex00 - Classy not classy
Demonstrates Ruby's dynamic typing by creating variables of different types (Integer, String, NilClass, Float) and displaying their values and types.

### Ex01 - Breakfast
Reads numbers from a file, parses them, and displays them in ascending order.

### Ex02 - With Hash browns
Converts an array of name-number pairs into a hash and displays the result.

### Ex03 - Where am I?
Takes a US state name as argument and returns its capital city.

### Ex04 - Backward
Reverse of Ex03 - takes a capital city and returns the state name.

### Ex05 - Hal
Takes a comma-separated string of words and identifies each as either a state, capital city, or unknown.

### Ex06 - Wait a minute
Sorts people by age (ascending) and alphabetically when ages are equal.

### Ex07 - elm
Parses a periodic table data file and generates a W3C-compliant HTML representation.

## Test Results

```
19 runs, 80 assertions, 0 failures, 0 errors, 0 skips
```

All exercises pass their respective tests.

## Notes

- All Ruby files include the `-w` flag for warnings
- All code is wrapped in functions (no global scope code except function calls)
- Each file ends with a function call as per requirements
- Ruby 3.x uses `Integer` instead of `Fixnum` (deprecated in Ruby 2.4+)
