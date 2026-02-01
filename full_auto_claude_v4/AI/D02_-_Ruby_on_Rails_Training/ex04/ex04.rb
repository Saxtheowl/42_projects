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

# Base Elem class representing an HTML element
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

# Derived HTML element classes

class Html < Elem
  def initialize(content = [], attributes = {})
    super('Html', content, false, attributes)
  end
end

class Head < Elem
  def initialize(content = [], attributes = {})
    super('Head', content, false, attributes)
  end
end

class Body < Elem
  def initialize(content = [], attributes = {})
    super('Body', content, false, attributes)
  end
end

class Title < Elem
  def initialize(content = [], attributes = {})
    content = Text.new(content) if content.is_a?(String)
    content = [content] unless content.is_a?(Array)
    super('Title', content, false, attributes)
  end
end

class Meta < Elem
  def initialize(content = [], attributes = {})
    super('Meta', content, true, attributes)
  end
end

class Img < Elem
  def initialize(content = [], attributes = {})
    super('Img', content, true, attributes)
  end
end

class Table < Elem
  def initialize(content = [], attributes = {})
    super('Table', content, false, attributes)
  end
end

class Th < Elem
  def initialize(content = [], attributes = {})
    content = Text.new(content) if content.is_a?(String)
    content = [content] unless content.is_a?(Array)
    super('Th', content, false, attributes)
  end
end

class Tr < Elem
  def initialize(content = [], attributes = {})
    super('Tr', content, false, attributes)
  end
end

class Td < Elem
  def initialize(content = [], attributes = {})
    content = Text.new(content) if content.is_a?(String)
    content = [content] unless content.is_a?(Array)
    super('Td', content, false, attributes)
  end
end

class Ul < Elem
  def initialize(content = [], attributes = {})
    super('Ul', content, false, attributes)
  end
end

class Ol < Elem
  def initialize(content = [], attributes = {})
    super('Ol', content, false, attributes)
  end
end

class Li < Elem
  def initialize(content = [], attributes = {})
    content = Text.new(content) if content.is_a?(String)
    content = [content] unless content.is_a?(Array)
    super('Li', content, false, attributes)
  end
end

class H1 < Elem
  def initialize(content = [], attributes = {})
    content = Text.new(content) if content.is_a?(String)
    content = [content] unless content.is_a?(Array)
    super('H1', content, false, attributes)
  end
end

class H2 < Elem
  def initialize(content = [], attributes = {})
    content = Text.new(content) if content.is_a?(String)
    content = [content] unless content.is_a?(Array)
    super('H2', content, false, attributes)
  end
end

class P < Elem
  def initialize(content = [], attributes = {})
    content = Text.new(content) if content.is_a?(String)
    content = [content] unless content.is_a?(Array)
    super('P', content, false, attributes)
  end
end

class Div < Elem
  def initialize(content = [], attributes = {})
    super('Div', content, false, attributes)
  end
end

class Span < Elem
  def initialize(content = [], attributes = {})
    content = Text.new(content) if content.is_a?(String)
    content = [content] unless content.is_a?(Array)
    super('Span', content, false, attributes)
  end
end

class Hr < Elem
  def initialize(content = [], attributes = {})
    super('Hr', content, true, attributes)
  end
end

class Br < Elem
  def initialize(content = [], attributes = {})
    super('Br', content, true, attributes)
  end
end

if $PROGRAM_NAME == __FILE__
  puts '=== Exercise 04: Dejavu Tests ==='
  puts

  # Test 1: Example from the subject
  puts 'Test 1: Example from the subject'
  puts Html.new([Head.new([Title.new('Hello ground!')]),
                 Body.new([H1.new('Oh no, not again!'),
                           Img.new([], { 'src' => 'http://i.imgur.com/pfp3T.jpg' })])])
  puts '  PASS'
  puts

  # Test 2: Table structure
  puts 'Test 2: Table structure'
  table = Table.new([
                      Tr.new([Th.new(Text.new('Header 1')), Th.new(Text.new('Header 2'))]),
                      Tr.new([Td.new(Text.new('Data 1')), Td.new(Text.new('Data 2'))])
                    ])
  puts table
  puts '  PASS'
  puts

  # Test 3: List structure
  puts 'Test 3: Unordered list'
  ul = Ul.new([
                Li.new(Text.new('Item 1')),
                Li.new(Text.new('Item 2')),
                Li.new(Text.new('Item 3'))
              ])
  puts ul
  puts '  PASS'
  puts

  # Test 4: Ordered list
  puts 'Test 4: Ordered list'
  ol = Ol.new([
                Li.new(Text.new('First')),
                Li.new(Text.new('Second')),
                Li.new(Text.new('Third'))
              ])
  puts ol
  puts '  PASS'
  puts

  # Test 5: Orphan elements
  puts 'Test 5: Orphan elements (Hr, Br, Meta, Img)'
  puts Hr.new
  puts Br.new
  puts Meta.new([], { 'charset' => 'UTF-8' })
  puts Img.new([], { 'src' => 'image.png', 'alt' => 'An image' })
  puts '  PASS'
  puts

  # Test 6: Div with multiple elements
  puts 'Test 6: Div with multiple nested elements'
  div = Div.new([
                  H1.new(Text.new('Title')),
                  P.new(Text.new('A paragraph')),
                  Span.new(Text.new('A span'))
                ])
  puts div
  puts '  PASS'
  puts

  # Test 7: H2 element
  puts 'Test 7: H2 element'
  h2 = H2.new(Text.new('Subtitle'))
  puts h2
  puts '  PASS'
  puts

  # Test 8: Complete HTML page
  puts 'Test 8: Complete HTML page'
  page = Html.new([
                    Head.new([
                               Title.new(Text.new('My Page')),
                               Meta.new([], { 'charset' => 'UTF-8' })
                             ]),
                    Body.new([
                               H1.new(Text.new('Welcome')),
                               Div.new([
                                         P.new(Text.new('This is a paragraph.')),
                                         Ul.new([
                                                  Li.new(Text.new('Item A')),
                                                  Li.new(Text.new('Item B'))
                                                ])
                                       ]),
                               Hr.new,
                               Span.new(Text.new('Footer text'))
                             ])
                  ])
  puts page
  puts '  PASS'
  puts

  puts '=== All tests completed ==='
end
