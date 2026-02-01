#!/usr/bin/env ruby -w
# frozen_string_literal: true

class Html
  attr_reader :page_name

  def initialize(page_name)
    @page_name = page_name
    @file_path = "#{@page_name}.html"
    @body_opened = false
    @body_closed = false
    head
  end

  def head
    raise "A file named #{@file_path} already exist!" if File.exist?(@file_path)

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

  def dump(content)
    raise "There is no body tag in #{@file_path}" unless @body_opened
    raise "Body has already been closed in #{@file_path}" if @body_closed

    File.open(@file_path, 'a') do |file|
      file.puts "  <p>#{content}</p>"
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
  puts '=== Test Ex01: Raise HTML ==='

  # Clean up any existing test files
  File.delete('test.html') if File.exist?('test.html')

  # Test 1: Normal creation
  puts "\n--- Test 1: Normal creation ---"
  a = Html.new('test')
  puts "Created: #{a.inspect}"

  # Test 2: Duplicate file error
  puts "\n--- Test 2: Duplicate file error ---"
  begin
    Html.new('test')
    puts 'ERROR: Should have raised an exception!'
  rescue RuntimeError => e
    puts "Caught expected error: #{e.message}"
  end

  # Test 3: Normal dump
  puts "\n--- Test 3: Normal dump ---"
  a.dump('Lorem_ipsum')
  puts 'Dump successful'

  # Test 4: Normal finish
  puts "\n--- Test 4: Normal finish ---"
  a.finish
  puts 'Finish successful'

  # Test 5: Double finish error
  puts "\n--- Test 5: Double finish error ---"
  begin
    a.finish
    puts 'ERROR: Should have raised an exception!'
  rescue RuntimeError => e
    puts "Caught expected error: #{e.message}"
  end

  # Test 6: Dump after finish error
  puts "\n--- Test 6: Dump after finish error ---"
  begin
    a.dump('Should fail')
    puts 'ERROR: Should have raised an exception!'
  rescue RuntimeError => e
    puts "Caught expected error: #{e.message}"
  end

  # Test 7: Verify file content
  puts "\n--- Test 7: Verify file content ---"
  puts File.read('test.html')

  # Clean up
  File.delete('test.html') if File.exist?('test.html')
  puts "\nAll tests completed!"
end
