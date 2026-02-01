#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true

# Text class for holding simple text content
class Text
  attr_reader :content

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
    content = [content] unless content.is_a?(Array)
    super('Li', content, false, attributes)
  end
end

class H1 < Elem
  def initialize(content = [], attributes = {})
    content = [content] unless content.is_a?(Array)
    super('H1', content, false, attributes)
  end
end

class H2 < Elem
  def initialize(content = [], attributes = {})
    content = [content] unless content.is_a?(Array)
    super('H2', content, false, attributes)
  end
end

class P < Elem
  def initialize(content = [], attributes = {})
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

# Page class for HTML validation
class Page
  VALID_TYPES = [Html, Head, Body, Title, Meta, Img, Table, Th, Tr, Td,
                 Ul, Ol, Li, H1, H2, P, Div, Span, Hr, Br, Text].freeze

  BODY_DIV_ALLOWED = [H1, H2, Div, Table, Ul, Ol, Span, Text, P, Img, Hr, Br].freeze

  SINGLE_TEXT_ONLY = [Title, H1, H2, Li, Th, Td].freeze

  def initialize(elem)
    @root = elem
  end

  def is_valid?
    result = validate_node(@root, true)
    puts result ? '            FILE IS OK' : '            FILE IS NOT VALID'
    result
  end

  private

  def validate_node(node, is_root = false)
    unless valid_type?(node)
      puts "Invalid type: #{node.class}"
      return false
    end

    puts "Currently evaluating a #{node.class} :"

    case node
    when Html
      validate_html(node, is_root)
    when Head
      validate_head(node)
    when Body, Div
      validate_body_or_div(node)
    when Title, H1, H2, Li, Th, Td
      validate_single_text(node)
    when P
      validate_p(node)
    when Span
      validate_span(node)
    when Ul, Ol
      validate_list(node)
    when Tr
      validate_tr(node)
    when Table
      validate_table(node)
    when Img
      validate_img(node)
    when Text
      validate_text(node)
    when Meta, Hr, Br
      true
    else
      true
    end
  end

  def valid_type?(node)
    VALID_TYPES.any? { |type| node.is_a?(type) }
  end

  def validate_html(node, is_root)
    if is_root
      puts '- root element of type "html"'
    end
    puts '- Html -> Must contains a Head AND a Body after it'

    content = node.content
    unless content.length == 2 && content[0].is_a?(Head) && content[1].is_a?(Body)
      puts 'Html must contain exactly one Head followed by one Body'
      return false
    end

    puts 'Head is OK'
    puts 'Evaluating a multiple node'

    validate_node(content[0]) && validate_node(content[1])
  end

  def validate_head(node)
    content = node.content.reject { |c| c.is_a?(Meta) }

    unless content.length == 1 && content[0].is_a?(Title)
      puts 'Head must contain exactly one Title'
      return false
    end

    validate_node(content[0])
  end

  def validate_body_or_div(node)
    node.content.each do |child|
      unless BODY_DIV_ALLOWED.any? { |type| child.is_a?(type) }
        puts "Body/Div contains invalid element: #{child.class}"
        return false
      end

      puts 'Evaluating a multiple node' if node.content.length > 1
      return false unless validate_node(child)
    end
    true
  end

  def validate_single_text(node)
    content = node.content

    unless content.length == 1 && content[0].is_a?(Text)
      puts "#{node.class} must contain exactly one Text element"
      return false
    end

    validate_node(content[0])
  end

  def validate_p(node)
    node.content.each do |child|
      unless child.is_a?(Text)
        puts 'P must contain only Text'
        return false
      end
    end
    true
  end

  def validate_span(node)
    node.content.each do |child|
      unless child.is_a?(Text) || child.is_a?(P)
        puts 'Span must contain only Text or P'
        return false
      end

      return false unless validate_node(child) if child.is_a?(P)
    end
    true
  end

  def validate_list(node)
    if node.content.empty?
      puts "#{node.class} must contain at least one Li"
      return false
    end

    node.content.each do |child|
      unless child.is_a?(Li)
        puts "#{node.class} must contain only Li elements"
        return false
      end

      return false unless validate_node(child)
    end
    true
  end

  def validate_tr(node)
    if node.content.empty?
      puts 'Tr must contain at least one Th or Td'
      return false
    end

    has_th = node.content.any? { |c| c.is_a?(Th) }
    has_td = node.content.any? { |c| c.is_a?(Td) }

    if has_th && has_td
      puts 'Tr cannot contain both Th and Td (mutually exclusive)'
      return false
    end

    node.content.each do |child|
      unless child.is_a?(Th) || child.is_a?(Td)
        puts 'Tr must contain only Th or Td'
        return false
      end

      return false unless validate_node(child)
    end
    true
  end

  def validate_table(node)
    if node.content.empty?
      puts 'Table must contain Tr elements'
      return false
    end

    node.content.each do |child|
      unless child.is_a?(Tr)
        puts 'Table must contain only Tr elements'
        return false
      end

      return false unless validate_node(child)
    end
    true
  end

  def validate_img(node)
    unless node.attributes.key?(:src) || node.attributes.key?('src')
      puts 'Img must have a src attribute'
      return false
    end

    src_value = node.attributes[:src] || node.attributes['src']
    unless src_value.is_a?(Text) || src_value.is_a?(String)
      puts 'Img src must be a Text or String'
      return false
    end

    puts 'Img content is OK'
    true
  end

  def validate_text(node)
    puts '-Text -> Must contains a simple string'

    unless node.content.is_a?(String)
      puts 'Text must contain a simple string'
      return false
    end

    puts 'Text content is OK'
    true
  end
end

if $PROGRAM_NAME == __FILE__
  puts '=== Exercise 05: Validation Tests ==='
  puts

  # Test 1: Valid HTML from the subject example
  puts 'Test 1: Valid HTML structure (subject example)'
  puts '-' * 50
  toto = Html.new([Head.new([Title.new(Text.new('Hello ground!'))]),
                   Body.new([H1.new(Text.new('Oh no, not again!')),
                             Img.new([], { src: Text.new('http://i.imgur.com/pfp3T.jpg') })])])
  test = Page.new(toto)
  result1 = test.is_valid?
  puts result1 ? '  PASS' : '  FAIL'
  puts

  # Test 2: Same structure (second example from subject)
  puts 'Test 2: Same valid HTML structure'
  puts '-' * 50
  tata = Html.new([Head.new([Title.new(Text.new('Hello ground!'))]),
                   Body.new([H1.new(Text.new('Oh no, not again!')),
                             Img.new([], { src: Text.new('http://i.imgur.com/pfp3T.jpg') })])])
  test2 = Page.new(tata)
  result2 = test2.is_valid?
  puts result2 ? '  PASS' : '  FAIL'
  puts

  # Test 3: Invalid - Html without Head
  puts 'Test 3: Invalid - Html without proper structure'
  puts '-' * 50
  invalid1 = Html.new([Body.new([H1.new(Text.new('Title'))])])
  test3 = Page.new(invalid1)
  result3 = !test3.is_valid?
  puts result3 ? '  PASS (correctly rejected)' : '  FAIL'
  puts

  # Test 4: Invalid - Body with wrong content type
  puts 'Test 4: Valid HTML with table'
  puts '-' * 50
  valid_table = Html.new([
                           Head.new([Title.new(Text.new('Table Test'))]),
                           Body.new([
                                      Table.new([
                                                  Tr.new([Th.new(Text.new('Col1')), Th.new(Text.new('Col2'))]),
                                                  Tr.new([Td.new(Text.new('A')), Td.new(Text.new('B'))])
                                                ])
                                    ])
                         ])
  test4 = Page.new(valid_table)
  result4 = test4.is_valid?
  puts result4 ? '  PASS' : '  FAIL'
  puts

  # Test 5: Valid HTML with lists
  puts 'Test 5: Valid HTML with lists'
  puts '-' * 50
  valid_list = Html.new([
                          Head.new([Title.new(Text.new('List Test'))]),
                          Body.new([
                                     Ul.new([Li.new(Text.new('Item 1')), Li.new(Text.new('Item 2'))]),
                                     Ol.new([Li.new(Text.new('First')), Li.new(Text.new('Second'))])
                                   ])
                        ])
  test5 = Page.new(valid_list)
  result5 = test5.is_valid?
  puts result5 ? '  PASS' : '  FAIL'
  puts

  # Test 6: Invalid - Tr with both Th and Td
  puts 'Test 6: Invalid - Tr with both Th and Td'
  puts '-' * 50
  invalid_tr = Html.new([
                          Head.new([Title.new(Text.new('Test'))]),
                          Body.new([
                                     Table.new([
                                                 Tr.new([Th.new(Text.new('Header')), Td.new(Text.new('Data'))])
                                               ])
                                   ])
                        ])
  test6 = Page.new(invalid_tr)
  result6 = !test6.is_valid?
  puts result6 ? '  PASS (correctly rejected)' : '  FAIL'
  puts

  # Test 7: Valid HTML with Div and Span
  puts 'Test 7: Valid HTML with Div and Span'
  puts '-' * 50
  valid_div = Html.new([
                         Head.new([Title.new(Text.new('Div Test'))]),
                         Body.new([
                                    Div.new([
                                              H1.new(Text.new('Main Title')),
                                              H2.new(Text.new('Subtitle')),
                                              Span.new(Text.new('Some text'))
                                            ])
                                  ])
                       ])
  test7 = Page.new(valid_div)
  result7 = test7.is_valid?
  puts result7 ? '  PASS' : '  FAIL'
  puts

  # Test 8: Invalid - Empty Ul
  puts 'Test 8: Invalid - Empty Ul'
  puts '-' * 50
  invalid_ul = Html.new([
                          Head.new([Title.new(Text.new('Test'))]),
                          Body.new([Ul.new([])])
                        ])
  test8 = Page.new(invalid_ul)
  result8 = !test8.is_valid?
  puts result8 ? '  PASS (correctly rejected)' : '  FAIL'
  puts

  # Test 9: Invalid - Img without src
  puts 'Test 9: Invalid - Img without src attribute'
  puts '-' * 50
  invalid_img = Html.new([
                           Head.new([Title.new(Text.new('Test'))]),
                           Body.new([H1.new(Text.new('Title'))])
                         ])
  # Create img without src and add to body manually
  body_with_bad_img = Html.new([
                                 Head.new([Title.new(Text.new('Test'))]),
                                 Body.new([Img.new([], { alt: 'no src' })])
                               ])
  test9 = Page.new(body_with_bad_img)
  result9 = !test9.is_valid?
  puts result9 ? '  PASS (correctly rejected)' : '  FAIL'
  puts

  # Test 10: Valid - Span with P containing Text
  puts 'Test 10: Valid - Span with P'
  puts '-' * 50
  valid_span = Html.new([
                          Head.new([Title.new(Text.new('Test'))]),
                          Body.new([
                                     Span.new([Text.new('Direct text'), P.new(Text.new('Paragraph'))])
                                   ])
                        ])
  test10 = Page.new(valid_span)
  result10 = test10.is_valid?
  puts result10 ? '  PASS' : '  FAIL'
  puts

  puts '=== All tests completed ==='

  # Summary
  puts
  puts 'Summary:'
  all_pass = result1 && result2 && result3 && result4 && result5 &&
             result6 && result7 && result8 && result9 && result10
  puts all_pass ? 'All tests PASSED!' : 'Some tests FAILED!'
end
