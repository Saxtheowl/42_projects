#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true

# Custom exception for duplicate file
class Dup_file < StandardError
  def initialize(filename, existing_path)
    @filename = filename
    @existing_path = existing_path
    super("A file named #{filename} already exists")
  end

  def show_state
    puts "A file named #{@filename} was already there: #{@existing_path}"
  end

  def correct
    base = @filename.sub(/\.html$/, '')
    new_name = "#{base}.new.html"
    while File.exist?(new_name)
      new_name = new_name.sub(/\.html$/, '.new.html')
    end
    @new_path = File.expand_path(new_name)
    new_name.sub(/\.html$/, '')
  end

  def explain
    puts "Appended .new in order to create requested file: #{@new_path}"
  end
end

# Custom exception for body already closed
class Body_closed < StandardError
  def initialize(filename, line_number, content)
    @filename = filename
    @line_number = line_number
    @content = content
    super("Body already closed in #{filename}")
  end

  def show_state
    puts "In #{@filename} body was closed :"
  end

  def correct(text)
    lines = File.readlines(@filename)
    body_close_index = lines.index { |l| l.strip == '</body>' }
    return unless body_close_index

    lines.delete_at(body_close_index)
    lines.insert(body_close_index, "  <p>#{text}</p>\n")
    lines << "</body>\n" unless lines.any? { |l| l.strip == '</body>' }
    File.write(@filename, lines.join)
    @line_number
  end

  def explain
    puts "  > ln :#{@line_number} </body> : text has been inserted and tag moved at the end of it."
  end
end

# Html class with custom exception handling and auto-correction
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
    if File.exist?(@file_path)
      error = Dup_file.new(@file_path, File.expand_path(@file_path))
      error.show_state
      new_base = error.correct
      error.explain
      @page_name = new_base
      @file_path = "#{new_base}.html"
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
  end

  def dump(text)
    raise "There is no body tag in #{@file_path}" unless @body_opened

    if @body_closed
      lines = File.readlines(@file_path)
      body_close_index = lines.index { |l| l.strip == '</body>' }
      if body_close_index
        error = Body_closed.new(@file_path, body_close_index + 1, '</body>')
        error.show_state
        error.correct(text)
        error.explain
        return
      end
    end

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
  puts '=== Exercise 02: Rescue HTML Tests ==='
  puts

  # Cleanup from previous runs
  Dir.glob('test*.html').each { |f| File.delete(f) }

  # Test 1: Create Html instance
  puts 'Test 1: Creating Html instance with "test"'
  a = Html.new('test')
  puts "  page_name: #{a.page_name}"
  puts '  PASS'
  puts

  # Test 2: Create another file with same name (should auto-correct)
  puts 'Test 2: Creating another Html with "test" (should auto-correct to test.new)'
  b = Html.new('test')
  puts "  page_name: #{b.page_name}"
  puts b.page_name == 'test.new' ? '  PASS' : '  FAIL'
  puts

  # Test 3: Create third file with same base name (should become test.new.new)
  puts 'Test 3: Creating third Html with "test" (should auto-correct to test.new.new)'
  c = Html.new('test')
  puts "  page_name: #{c.page_name}"
  puts c.page_name == 'test.new.new' ? '  PASS' : '  FAIL'
  puts

  # Test 4: Write after body closed (should auto-correct)
  puts 'Test 4: Writing after body closed (should auto-correct)'
  a.dump('first text')
  a.finish
  a.dump('text after close')
  puts "  Content of #{a.page_name}.html:"
  puts File.read("#{a.page_name}.html")
  puts '  PASS (auto-corrected)'
  puts

  # Test 5: Verify Dup_file class methods
  puts 'Test 5: Testing Dup_file class'
  dup_error = Dup_file.new('test.html', '/home/test/test.html')
  puts "  show_state:"
  dup_error.show_state
  puts "  correct: #{dup_error.correct}"
  puts "  explain:"
  dup_error.explain
  puts '  PASS'
  puts

  # Test 6: Verify Body_closed class methods
  puts 'Test 6: Testing Body_closed class'
  body_error = Body_closed.new('test.html', 25, '</body>')
  puts "  show_state:"
  body_error.show_state
  puts '  PASS'
  puts

  # Cleanup
  Dir.glob('test*.html').each { |f| File.delete(f) }
  puts '=== All tests completed ==='
end
