#!/usr/bin/env ruby -w
# frozen_string_literal: true

class Dup_file < StandardError
  def initialize(filename, file_path)
    @filename = filename
    @file_path = file_path
    @new_path = nil
    super("A file named #{@file_path} already exist!")
  end

  def show_state
    pwd = Dir.pwd
    puts "A file named #{@filename} was already there: #{pwd}/#{@file_path}"
  end

  def correct
    base = @filename
    ext = '.html'
    new_name = base

    new_name = "#{new_name}.new" while File.exist?("#{new_name}#{ext}")

    @new_path = "#{new_name}#{ext}"
    @new_path
  end

  def explain
    pwd = Dir.pwd
    puts "Appended .new in order to create requested file: #{pwd}/#{@new_path}"
    @new_path
  end
end

class Body_closed < StandardError
  def initialize(filename, file_path, text)
    @filename = filename
    @file_path = file_path
    @text = text
    @line_number = nil
    super("Body has already been closed in #{@file_path}")
  end

  def show_state
    puts "In #{@filename} body was closed :"
    lines = File.readlines(@file_path)
    lines.each_with_index do |line, idx|
      next unless line.strip == '</body>'

      @line_number = idx + 1
      puts "  > ln :#{@line_number} #{line.strip}"
    end
  end

  def correct
    lines = File.readlines(@file_path)
    new_lines = []
    lines.each do |line|
      if line.strip == '</body>'
        new_lines << "  <p>#{@text}</p>\n"
        new_lines << line
      else
        new_lines << line
      end
    end
    File.write(@file_path, new_lines.join)
  end

  def explain
    puts "  : text has been inserted and tag moved at the end of it."
  end
end

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
    if File.exist?(@file_path)
      error = Dup_file.new(@page_name, @file_path)
      begin
        raise error
      rescue Dup_file => e
        e.show_state
        new_path = e.correct
        new_name = new_path.sub(/\.html$/, '')
        @page_name = new_name
        @file_path = new_path
        e.explain
      end
    end

    File.open(@file_path, 'w') do |file|
      file.puts '<!DOCTYPE html>'
      file.puts '<html>'
      file.puts '<head>'
      file.puts "<title>#{@page_name}</title>"
      file.puts '</head>'
      file.puts '<body>'
    end
    @body_opened = true
    @body_closed = false
  end

  def dump(content)
    raise "There is no body tag in #{@file_path}" unless @body_opened

    if @body_closed
      error = Body_closed.new(@page_name, @file_path, content)
      begin
        raise error
      rescue Body_closed => e
        e.show_state
        e.correct
        e.explain
      end
      return
    end

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
  puts '=== Test Ex02: Rescue HTML ==='

  # Clean up any existing test files
  Dir.glob('test*.html').each { |f| File.delete(f) }

  # Test 1: Create first file
  puts "\n--- Test 1: Create first file ---"
  a = Html.new('test')
  puts "Created: #{a.page_name}"
  a.dump('Hello World')
  a.finish
  puts "File content:\n#{File.read('test.html')}"

  # Test 2: Try to create duplicate - should auto-rename
  puts "\n--- Test 2: Duplicate file handling ---"
  b = Html.new('test')
  puts "New file created: #{b.page_name}"
  b.dump('Content in new file')
  b.finish

  # Test 3: Create another duplicate
  puts "\n--- Test 3: Another duplicate ---"
  c = Html.new('test')
  puts "Another new file: #{c.page_name}"
  c.finish

  # Test 4: Try to write after body closed
  puts "\n--- Test 4: Write after body closed ---"
  d = Html.new('test_closed')
  d.dump('Before close')
  d.finish
  d.dump('After close - should be rescued')
  puts "File content after rescue:\n#{File.read('test_closed.html')}"

  # Show all created files
  puts "\n--- Created files ---"
  Dir.glob('test*.html').each do |f|
    puts "\n=== #{f} ==="
    puts File.read(f)
  end

  # Clean up
  Dir.glob('test*.html').each { |f| File.delete(f) }
  puts "\nAll tests completed!"
end
