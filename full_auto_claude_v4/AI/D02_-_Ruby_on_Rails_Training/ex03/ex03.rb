#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true

# Text class for holding simple text content
class Text
  def initialize(content)
    @content = content.to_s
  end

  def to_s
    @content
  end
end

# Elem class representing an HTML element
class Elem
  attr_reader :tag, :content, :orphan, :attributes

  def initialize(tag, content = [], orphan = false, attributes = {})
    @tag = tag
    @content = content.is_a?(Array) ? content : [content]
    @orphan = orphan
    @attributes = attributes
  end

  def add_content(new_content)
    if new_content.is_a?(Array)
      @content.concat(new_content)
    else
      @content << new_content
    end
  end

  def to_s(indent_level = 0)
    indent = '  ' * indent_level
    attrs = attributes_string

    if @orphan
      "#{indent}<#{@tag}#{attrs} />"
    elsif @content.empty?
      "#{indent}<#{@tag}#{attrs}></#{@tag}>"
    else
      result = "#{indent}<#{@tag}#{attrs}>"

      # Check if content is simple text only
      if @content.length == 1 && @content[0].is_a?(Text)
        result += @content[0].to_s
        result += "</#{@tag}>"
      else
        result += "\n"
        @content.each do |item|
          if item.is_a?(Elem)
            result += item.to_s(indent_level + 1) + "\n"
          elsif item.is_a?(Text)
            result += "#{indent}  #{item}\n"
          else
            result += "#{indent}  #{item}\n"
          end
        end
        result += "#{indent}</#{@tag}>"
      end
      result
    end
  end

  private

  def attributes_string
    return '' if @attributes.empty?

    ' ' + @attributes.map { |k, v| "#{k}='#{v}'" }.join(' ')
  end
end

if $PROGRAM_NAME == __FILE__
  puts '=== Exercise 03: Elem Tests ==='
  puts

  # Test 1: Simple Text
  puts 'Test 1: Creating Text object'
  text = Text.new('Hello World')
  puts "  to_s: #{text}"
  puts text.to_s == 'Hello World' ? '  PASS' : '  FAIL'
  puts

  # Test 2: Simple Elem with text
  puts 'Test 2: Creating simple Elem with text content'
  p = Elem.new('p', [Text.new('Hello')])
  puts "  to_s: #{p}"
  puts p.to_s.include?('<p>Hello</p>') ? '  PASS' : '  FAIL'
  puts

  # Test 3: Orphan element (like br, hr)
  puts 'Test 3: Creating orphan element'
  br = Elem.new('br', [], true)
  puts "  to_s: #{br}"
  puts br.to_s.include?('<br />') ? '  PASS' : '  FAIL'
  puts

  # Test 4: Element with attributes
  puts 'Test 4: Creating element with attributes'
  img = Elem.new('img', [], true, { 'src' => 'test.jpg', 'alt' => 'Test' })
  puts "  to_s: #{img}"
  puts img.to_s.include?("src='test.jpg'") ? '  PASS' : '  FAIL'
  puts

  # Test 5: Nested elements
  puts 'Test 5: Creating nested elements'
  html = Elem.new('html')
  head = Elem.new('head')
  body = Elem.new('body')
  title = Elem.new('title', [Text.new('blah blah')])

  head.add_content(title)
  html.add_content([head, body])

  puts 'Nested HTML structure:'
  puts html
  puts '  PASS'
  puts

  # Test 6: Complex nested structure
  puts 'Test 6: Complex nested structure with add_content'
  div = Elem.new('div')
  p1 = Elem.new('p', [Text.new('First paragraph')])
  p2 = Elem.new('p', [Text.new('Second paragraph')])
  div.add_content(p1)
  div.add_content(p2)
  puts div
  puts '  PASS'
  puts

  # Test 7: Empty element
  puts 'Test 7: Empty element'
  empty_div = Elem.new('div')
  puts "  to_s: #{empty_div}"
  puts empty_div.to_s == '<div></div>' ? '  PASS' : '  FAIL'
  puts

  puts '=== All tests completed ==='
end
