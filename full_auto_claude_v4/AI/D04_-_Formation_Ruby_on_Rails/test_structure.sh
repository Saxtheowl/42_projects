#!/bin/bash
# Test script for D04 - Formation Ruby on Rails

echo "=== Testing D04 - Formation Ruby on Rails ==="
echo ""

PASSED=0
FAILED=0

check_file() {
    if [ -f "$1" ]; then
        echo "[PASS] $1 exists"
        ((PASSED++))
    else
        echo "[FAIL] $1 missing"
        ((FAILED++))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo "[PASS] $1 exists"
        ((PASSED++))
    else
        echo "[FAIL] $1 missing"
        ((FAILED++))
    fi
}

check_content() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo "[PASS] $1 contains '$2'"
        ((PASSED++))
    else
        echo "[FAIL] $1 does not contain '$2'"
        ((FAILED++))
    fi
}

echo "=== Exercise 00 - CheatSheet ==="
check_dir "ex00/CheatSheet"
check_file "ex00/CheatSheet/Gemfile"
check_file "ex00/CheatSheet/config/routes.rb"
check_file "ex00/CheatSheet/app/controllers/cheatsheet_controller.rb"
check_file "ex00/CheatSheet/app/views/cheatsheet/index.html.erb"
check_file "ex00/CheatSheet/app/views/layouts/application.html.erb"
check_content "ex00/CheatSheet/Gemfile" "rubycritic"
check_content "ex00/CheatSheet/app/views/layouts/application.html.erb" "CheatSheet"
echo ""

echo "=== Exercise 01 - NewCheatSheet ==="
check_dir "ex01/NewCheatSheet"
check_file "ex01/NewCheatSheet/Gemfile"
check_file "ex01/NewCheatSheet/config/routes.rb"
check_file "ex01/NewCheatSheet/app/controllers/cheatsheet_controller.rb"
check_file "ex01/NewCheatSheet/app/views/shared/_navbar.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/convention.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/console.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/ruby.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/ruby_concepts.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/ruby_numbers.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/ruby_strings.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/ruby_arrays.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/ruby_hashes.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/rails_folder_structure.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/rails_commands.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/rails_erb.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/editor.html.erb"
check_file "ex01/NewCheatSheet/app/views/cheatsheet/help.html.erb"
check_content "ex01/NewCheatSheet/Gemfile" "rubycritic"
check_content "ex01/NewCheatSheet/app/views/layouts/application.html.erb" "render \"shared/navbar\""
echo ""

echo "=== Exercise 02 - CheatSheet with Quick Search ==="
check_dir "ex02/CheatSheet"
check_file "ex02/CheatSheet/Gemfile"
check_file "ex02/CheatSheet/app/views/cheatsheet/quick_search.html.erb"
check_file "ex02/CheatSheet/app/assets/javascripts/datatables_init.js"
check_content "ex02/CheatSheet/Gemfile" "jquery-datatables-rails"
check_content "ex02/CheatSheet/config/routes.rb" "quick_search"
check_content "ex02/CheatSheet/app/views/shared/_navbar.html.erb" "Quick Search"
echo ""

echo "=== Exercise 03 - CheatSheet with Log Book ==="
check_dir "ex03/CheatSheet"
check_file "ex03/CheatSheet/Gemfile"
check_file "ex03/CheatSheet/app/views/cheatsheet/log_book.html.erb"
check_file "ex03/CheatSheet/entry_log.txt"
check_content "ex03/CheatSheet/config/routes.rb" "log_book"
check_content "ex03/CheatSheet/config/routes.rb" "write_entry"
check_content "ex03/CheatSheet/app/controllers/cheatsheet_controller.rb" "entry_log.txt"
check_content "ex03/CheatSheet/app/views/shared/_navbar.html.erb" "Log Book"
echo ""

echo "=== Checking for forbidden keywords ==="
FORBIDDEN="while|for|redo|break|retry|loop|until"
FOUND_FORBIDDEN=0
find . -name "*.rb" -type f | while read file; do
    if grep -qE "\b($FORBIDDEN)\b" "$file" 2>/dev/null; then
        echo "[WARN] $file may contain forbidden keywords"
        FOUND_FORBIDDEN=1
    fi
done
if [ $FOUND_FORBIDDEN -eq 0 ]; then
    echo "[PASS] No forbidden keywords found in Ruby files"
    ((PASSED++))
fi
echo ""

echo "=== Summary ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed."
    exit 1
fi
