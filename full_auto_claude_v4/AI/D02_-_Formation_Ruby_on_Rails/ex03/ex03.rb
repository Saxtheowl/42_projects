#!/usr/bin/env ruby -w
# frozen_string_literal: true

class Text
  def initialize(content)
    @content = content
  end

  def to_s
    @content.to_s
  end
end

class Elem
  attr_accessor :tag, :content, :tag_type, :attributes

  def initialize(tag, content = [], tag_type = 'double', attributes = {})
    @tag = tag
    @content = content.is_a?(Array) ? content : [content]
    @tag_type = tag_type # 'double' or 'simple' (orphan)
    @attributes = attributes
  end

  def add_content(new_content)
    if new_content.is_a?(Array)
      new_content.each { |item| @content << item }
    else
      @content << new_content
    end
  end

  def to_s
    build_html
  end

  private

  def build_html
    attr_str = build_attributes

    if @tag_type == 'simple'
      "<#{@tag}#{attr_str} />"
    else
      inner = @content.map(&:to_s).join("\n")
      if inner.empty?
        "<#{@tag}#{attr_str}></#{@tag}>"
      elsif inner.include?("\n")
        "<#{@tag}#{attr_str}>\n#{inner}\n</#{@tag}>"
      else
        "<#{@tag}#{attr_str}>#{inner}</#{@tag}>"
      end
    end
  end

  def build_attributes
    return '' if @attributes.empty?

    ' ' + @attributes.map { |k, v| "#{k}='#{v}'" }.join(' ')
  end
end

if $PROGRAM_NAME == __FILE__
  puts '=== Test Ex03: Elem Class ==='

  # Test 1: Simple Text
  puts "\n--- Test 1: Simple Text ---"
  text = Text.new('Hello World')
  puts text.to_s

  # Test 2: Simple Elem with Text
  puts "\n--- Test 2: Simple Elem with Text ---"
  p_elem = Elem.new('p', [Text.new('This is a paragraph')])
  puts p_elem.to_s

  # Test 3: Elem with attributes
  puts "\n--- Test 3: Elem with attributes ---"
  img = Elem.new('img', [], 'simple', { 'src' => 'image.jpg', 'alt' => 'An image' })
  puts img.to_s

  # Test 4: Nested Elems
  puts "\n--- Test 4: Nested Elems ---"
  html = Elem.new('html')
  head = Elem.new('head')
  body = Elem.new('body')
  title = Elem.new('title', [Text.new('blah blah')])

  head.add_content(title)
  html.add_content([head, body])
  puts html.to_s

  # Test 5: Complex nested structure
  puts "\n--- Test 5: Complex nested structure ---"
  html2 = Elem.new('html', [
    Elem.new('head', [
      Elem.new('title', [Text.new('My Page')])
    ]),
    Elem.new('body', [
      Elem.new('h1', [Text.new('Welcome')]),
      Elem.new('p', [Text.new('This is content')]),
      Elem.new('img', [], 'simple', { 'src' => 'photo.jpg' })
    ])
  ])
  puts html2.to_s

  # Test 6: Add content method
  puts "\n--- Test 6: Add content method ---"
  div = Elem.new('div')
  div.add_content(Elem.new('p', [Text.new('First paragraph')]))
  div.add_content(Elem.new('p', [Text.new('Second paragraph')]))
  puts div.to_s

  # Test 7: Empty element
  puts "\n--- Test 7: Empty element ---"
  empty_div = Elem.new('div')
  puts empty_div.to_s

  # Test 8: Self-closing tags
  puts "\n--- Test 8: Self-closing tags ---"
  br = Elem.new('br', [], 'simple')
  hr = Elem.new('hr', [], 'simple')
  puts br.to_s
  puts hr.to_s

  puts "\nAll tests completed!"
end
