#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true

# Html class that creates and fills an HTML file
class Html
  attr_reader :page_name

  def initialize(file_name)
    @page_name = file_name
    @file_path = "#{file_name}.html"
    head
  end

  def head
    File.open(@file_path, 'w') do |file|
      file.puts '<!DOCTYPE html>'
      file.puts '<html>'
      file.puts '<head>'
      file.puts "<title>#{@page_name}</title>"
      file.puts '</head>'
      file.puts '<body>'
    end
  end

  def dump(text)
    File.open(@file_path, 'a') do |file|
      file.puts "  <p>#{text}</p>"
    end
  end

  def finish
    File.open(@file_path, 'a') do |file|
      file.puts '</body>'
    end
  end
end

if $PROGRAM_NAME == __FILE__
  puts '=== Exercise 00: HTML Tests ==='
  puts

  # Test 1: Create Html instance
  puts 'Test 1: Creating Html instance with "test"'
  a = Html.new('test')
  puts "  page_name: #{a.page_name}"
  puts "  Expected: test"
  puts a.page_name == 'test' ? '  PASS' : '  FAIL'
  puts

  # Test 2: dump method with loop
  puts 'Test 2: Using dump method in a loop (10.times)'
  10.times { |x| a.dump("titi_number#{x}") }
  puts '  PASS (no error)'
  puts

  # Test 3: finish method
  puts 'Test 3: Calling finish method'
  a.finish
  puts '  PASS (no error)'
  puts

  # Test 4: Verify file content
  puts 'Test 4: Verifying file content'
  expected_content = <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
    <title>test</title>
    </head>
    <body>
      <p>titi_number0</p>
      <p>titi_number1</p>
      <p>titi_number2</p>
      <p>titi_number3</p>
      <p>titi_number4</p>
      <p>titi_number5</p>
      <p>titi_number6</p>
      <p>titi_number7</p>
      <p>titi_number8</p>
      <p>titi_number9</p>
    </body>
  HTML

  actual_content = File.read('test.html')
  puts '  Generated file content:'
  puts actual_content
  puts
  puts actual_content == expected_content ? '  PASS' : '  FAIL (content mismatch)'
  puts

  # Cleanup
  File.delete('test.html') if File.exist?('test.html')
  puts '=== All tests completed ==='
end
