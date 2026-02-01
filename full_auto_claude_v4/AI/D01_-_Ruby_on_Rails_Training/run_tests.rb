#!/usr/bin/env ruby -w

require 'fileutils'

def run_test(name, command, expected_pattern = nil)
  puts "\n#{'=' * 60}"
  puts "Testing: #{name}"
  puts "Command: #{command}"
  puts "-" * 60

  output = `#{command} 2>&1`
  status = $?.exitstatus

  puts "Output:"
  puts output
  puts "-" * 60
  puts "Exit status: #{status}"

  if expected_pattern && output.include?(expected_pattern)
    puts "PASS: Expected pattern found"
  elsif expected_pattern
    puts "FAIL: Expected pattern not found"
  end

  puts "=" * 60
end

puts "Ruby on Rails Training - D01 Tests"
puts "Ruby version: #{RUBY_VERSION}"

# Test ex00
run_test("ex00 - Classy not classy", "ruby /app/ex00/var.rb", "my variables")

# Test ex01
run_test("ex01 - Breakfast", "ruby /app/ex01/croissant.rb | head -10", "1")

# Test ex02
run_test("ex02 - With Hash browns", "ruby /app/ex02/H2o.rb", "24 : Caleb")

# Test ex03
run_test("ex03 - Where am I? (Oregon)", "ruby /app/ex03/Where.rb Oregon", "Salem")
run_test("ex03 - Where am I? (toto)", "ruby /app/ex03/Where.rb toto", "Unknown state")
run_test("ex03 - Where am I? (no args)", "ruby /app/ex03/Where.rb", "")

# Test ex04
run_test("ex04 - Backward (Salem)", "ruby /app/ex04/erehW.rb Salem", "Oregon")
run_test("ex04 - Backward (toto)", "ruby /app/ex04/erehW.rb toto", "Unknown capital city")

# Test ex05
run_test("ex05 - Hal", 'ruby /app/ex05/whereto.rb "Salem, Alabama, Toto, MontGOmery"', "is the capital of")

# Test ex06
run_test("ex06 - Wait a minute", "ruby /app/ex06/CoffeeCroissant.rb", "Stacy")

# Test ex07
run_test("ex07 - elm", "ruby /app/ex07/elm.rb && head -30 /app/ex07/periodic_table.html", "Hydrogen")

puts "\n\nAll tests completed!"
