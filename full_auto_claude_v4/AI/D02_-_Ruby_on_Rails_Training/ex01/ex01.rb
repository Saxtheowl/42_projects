#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true

# Html class with exception handling
class Html
  attr_reader :page_name

  def initialize(file_name)
    @page_name = file_name
    @file_path = "#{file_name}.html"
    @body_opened = false
    @body_closed = false
    head
  end

  def head
    raise "#{@file_path} already exist!" if File.exist?(@file_path)

    File.open(@file_path, 'w') do |file|
      file.puts '<!DOCTYPE html>'
      file.puts '<html>'
      file.puts '<head>'
      file.puts "<title>#{@page_name}</title>"
      file.puts '</head>'
      file.puts '<body>'
    end
    @body_opened = true
  end

  def dump(text)
    raise "There is no body tag in #{@file_path}" unless @body_opened
    raise "Body has already been closed in #{@file_path}" if @body_closed

    File.open(@file_path, 'a') do |file|
      file.puts "  <p>#{text}</p>"
    end
  end

  def finish
    raise "#{@file_path} has already been closed" if @body_closed

    File.open(@file_path, 'a') do |file|
      file.puts '</body>'
    end
    @body_closed = true
  end
end

if $PROGRAM_NAME == __FILE__
  puts '=== Exercise 01: Raise HTML Tests ==='
  puts

  # Cleanup from previous runs
  File.delete('test.html') if File.exist?('test.html')

  # Test 1: Create Html instance
  puts 'Test 1: Creating Html instance with "test"'
  a = Html.new('test')
  puts "  page_name: #{a.page_name}"
  puts a.page_name == 'test' ? '  PASS' : '  FAIL'
  puts

  # Test 2: Try to create file with same name (should raise)
  puts 'Test 2: Creating another Html instance with "test" (should raise)'
  begin
    Html.new('test')
    puts '  FAIL (no exception raised)'
  rescue RuntimeError => e
    puts "  Exception raised: #{e.message}"
    puts e.message.include?('already exist') ? '  PASS' : '  FAIL'
  end
  puts

  # Test 3: dump method works normally
  puts 'Test 3: Calling dump method'
  a.dump('Lorem_ipsum')
  puts '  PASS (no error)'
  puts

  # Test 4: finish method works
  puts 'Test 4: Calling finish method'
  a.finish
  puts '  PASS (no error)'
  puts

  # Test 5: Calling finish again should raise
  puts 'Test 5: Calling finish again (should raise)'
  begin
    a.finish
    puts '  FAIL (no exception raised)'
  rescue RuntimeError => e
    puts "  Exception raised: #{e.message}"
    puts e.message.include?('already been closed') ? '  PASS' : '  FAIL'
  end
  puts

  # Test 6: Calling dump after finish should raise
  puts 'Test 6: Calling dump after finish (should raise)'
  begin
    a.dump('test')
    puts '  FAIL (no exception raised)'
  rescue RuntimeError => e
    puts "  Exception raised: #{e.message}"
    puts e.message.include?('already been closed') ? '  PASS' : '  FAIL'
  end
  puts

  # Cleanup
  File.delete('test.html') if File.exist?('test.html')
  puts '=== All tests completed ==='
end
