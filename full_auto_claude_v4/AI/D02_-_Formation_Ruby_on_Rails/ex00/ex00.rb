#!/usr/bin/env ruby -w
# frozen_string_literal: true

class Html
  attr_reader :page_name

  def initialize(page_name)
    @page_name = page_name
    @file_path = "#{@page_name}.html"
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

  def dump(content)
    File.open(@file_path, 'a') do |file|
      file.puts "  <p>#{content}</p>"
    end
  end

  def finish
    File.open(@file_path, 'a') do |file|
      file.puts '</body>'
    end
  end
end

if $PROGRAM_NAME == __FILE__
  puts '=== Test Ex00: HTML Class ==='

  # Clean up any existing test file
  File.delete('test.html') if File.exist?('test.html')

  # Create Html instance
  a = Html.new('test')
  puts "Created Html instance: #{a.inspect}"
  puts "Page name: #{a.page_name}"

  # Add content using times block
  10.times { |x| a.dump("titi_number#{x}") }
  puts 'Added 10 paragraphs'

  # Finish the file
  a.finish
  puts 'Finished the file'

  # Display the result
  puts "\n=== Content of test.html ==="
  puts File.read('test.html')

  # Verify the content
  content = File.read('test.html')
  expected_lines = [
    '<!DOCTYPE html>',
    '<html>',
    '<head>',
    '<title>test</title>',
    '</head>',
    '<body>'
  ]
  10.times { |x| expected_lines << "  <p>titi_number#{x}</p>" }
  expected_lines << '</body>'

  all_present = expected_lines.all? { |line| content.include?(line) }
  puts "\n=== Verification ==="
  puts all_present ? 'All expected content present: PASS' : 'Missing content: FAIL'

  # Clean up
  File.delete('test.html') if File.exist?('test.html')
  puts 'Cleaned up test file'
end
