#!/bin/bash
set -e

echo "=== D05 Ruby on Rails Training - Test Runner ==="
echo ""

# Test Seek_well (ex00, ex02, ex04, ex06, ex08, ex10)
echo "=== Testing Seek_well ==="
docker run --rm -v "$(pwd)/ex00/Seek_well:/app" -w /app ruby:3.2 bash -c "
  bundle install --quiet
  bundle exec rails db:migrate RAILS_ENV=test
  bundle exec rake test
"

echo ""
echo "=== Testing tweetos_aka_hello_rails ==="
# Test tweetos (ex01, ex03, ex05, ex07, ex09)
docker run --rm -v "$(pwd)/ex01/tweetos_aka_hello_rails:/app" -w /app ruby:3.2 bash -c "
  bundle install --quiet
  bundle exec rails db:migrate RAILS_ENV=test
  bundle exec rake test
"

echo ""
echo "=== All tests completed ==="
