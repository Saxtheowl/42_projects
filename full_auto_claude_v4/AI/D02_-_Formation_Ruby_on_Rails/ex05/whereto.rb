#!/usr/bin/env ruby -w
# frozen_string_literal: true

class Text
  attr_reader :content

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
    @tag_type = tag_type
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

# Define HTML element classes
%w[Html Head Body Title Table Th Tr Td Ul Ol Li H1 H2 P Div Span].each do |tag_name|
  klass = Class.new(Elem) do
    define_method(:initialize) do |content = [], attributes = {}|
      super(tag_name, content, 'double', attributes)
    end
  end
  Object.const_set(tag_name, klass)
end

%w[Meta Img Hr Br].each do |tag_name|
  klass = Class.new(Elem) do
    define_method(:initialize) do |content = [], attributes = {}|
      super(tag_name, content, 'simple', attributes)
    end
  end
  Object.const_set(tag_name, klass)
end

# Validation class
class Page
  VALID_TYPES = [Html, Head, Body, Title, Meta, Img, Table, Th, Tr, Td, Ul, Ol, Li, H1, H2, P, Div, Span, Hr, Br, Text].freeze
  BODY_DIV_ALLOWED = [H1, H2, Div, Table, Ul, Ol, Span, Text, P, Img, Hr, Br].freeze
  TEXT_ONLY = [Title, H1, H2, Li, Th, Td].freeze
  SPAN_ALLOWED = [Text, P].freeze
  LIST_ITEMS = [Li].freeze
  TABLE_ROW_ALLOWED = [Th, Td].freeze
  TABLE_ALLOWED = [Tr].freeze
  P_ALLOWED = [Text].freeze

  def initialize(elem)
    @root = elem
    @valid = true
  end

  def is_valid?
    @valid = true
    validate_node(@root, nil)

    puts @valid ? '            FILE IS OK' : '            FILE IS INVALID'
    @valid
  end

  private

  def validate_node(node, parent)
    return @valid unless @valid

    puts "Currently evaluating a #{node.class} :"

    # Check if node type is valid
    unless VALID_TYPES.include?(node.class)
      puts "- Invalid node type: #{node.class}"
      @valid = false
      return @valid
    end

    case node
    when Html
      validate_html(node)
    when Head
      validate_head(node)
    when Body, Div
      validate_body_or_div(node)
    when Title, H1, H2, Li, Th, Td
      validate_text_only(node)
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
      # These are valid without content
      puts "#{node.class} content is OK"
    end

    @valid
  end

  def validate_html(node)
    puts '- root element of type "html"'
    puts '- Html -> Must contains a Head AND a Body after it'

    content = node.content.reject { |c| c.is_a?(Text) && c.content.to_s.strip.empty? }

    if content.length != 2 || !content[0].is_a?(Head) || !content[1].is_a?(Body)
      puts 'Html must contain exactly one Head followed by one Body'
      @valid = false
      return
    end

    puts 'Head is OK'
    puts 'Evaluating a multiple node'
    content.each { |child| validate_node(child, node) }
  end

  def validate_head(node)
    puts '- Head -> Must contain only one Title'

    content = node.content.reject { |c| c.is_a?(Text) && c.content.to_s.strip.empty? }

    if content.length != 1 || !content[0].is_a?(Title)
      puts 'Head must contain exactly one Title'
      @valid = false
      return
    end

    validate_node(content[0], node)
  end

  def validate_body_or_div(node)
    puts "- #{node.class} -> Must contain only H1, H2, Div, Table, Ul, Ol, Span, or Text"

    node.content.each do |child|
      next if child.is_a?(Text) && child.content.to_s.strip.empty?

      unless BODY_DIV_ALLOWED.include?(child.class)
        puts "Invalid child #{child.class} in #{node.class}"
        @valid = false
        return
      end
    end

    puts "#{node.class} content is OK"
    puts 'Evaluating a multiple node'
    node.content.each { |child| validate_node(child, node) }
  end

  def validate_text_only(node)
    puts "-#{node.class} -> Must contains a simple string"

    content = node.content.reject { |c| c.is_a?(Text) && c.content.to_s.strip.empty? }

    if content.length != 1 || !content[0].is_a?(Text)
      puts "#{node.class} must contain exactly one Text"
      @valid = false
      return
    end

    puts "#{node.class} content is OK"
    validate_node(content[0], node)
  end

  def validate_p(node)
    puts '- P -> Must contain only Text'

    node.content.each do |child|
      unless child.is_a?(Text)
        puts "P can only contain Text, found #{child.class}"
        @valid = false
        return
      end
    end

    puts 'P content is OK'
    node.content.each { |child| validate_node(child, node) }
  end

  def validate_span(node)
    puts '- Span -> Must contain only Text or P'

    node.content.each do |child|
      unless SPAN_ALLOWED.include?(child.class)
        puts "Span can only contain Text or P, found #{child.class}"
        @valid = false
        return
      end
    end

    puts 'Span content is OK'
    node.content.each { |child| validate_node(child, node) }
  end

  def validate_list(node)
    puts "- #{node.class} -> Must contain at least one Li and only Li"

    content = node.content.reject { |c| c.is_a?(Text) && c.content.to_s.strip.empty? }

    if content.empty?
      puts "#{node.class} must contain at least one Li"
      @valid = false
      return
    end

    content.each do |child|
      unless child.is_a?(Li)
        puts "#{node.class} can only contain Li, found #{child.class}"
        @valid = false
        return
      end
    end

    puts "#{node.class} content is OK"
    content.each { |child| validate_node(child, node) }
  end

  def validate_tr(node)
    puts '- Tr -> Must contain at least one Th or Td (mutually exclusive)'

    content = node.content.reject { |c| c.is_a?(Text) && c.content.to_s.strip.empty? }

    if content.empty?
      puts 'Tr must contain at least one Th or Td'
      @valid = false
      return
    end

    has_th = content.any? { |c| c.is_a?(Th) }
    has_td = content.any? { |c| c.is_a?(Td) }

    if has_th && has_td
      puts 'Tr cannot contain both Th and Td (mutually exclusive)'
      @valid = false
      return
    end

    content.each do |child|
      unless TABLE_ROW_ALLOWED.include?(child.class)
        puts "Tr can only contain Th or Td, found #{child.class}"
        @valid = false
        return
      end
    end

    puts 'Tr content is OK'
    content.each { |child| validate_node(child, node) }
  end

  def validate_table(node)
    puts '- Table -> Must contain only Tr'

    content = node.content.reject { |c| c.is_a?(Text) && c.content.to_s.strip.empty? }

    content.each do |child|
      unless child.is_a?(Tr)
        puts "Table can only contain Tr, found #{child.class}"
        @valid = false
        return
      end
    end

    puts 'Table content is OK'
    content.each { |child| validate_node(child, node) }
  end

  def validate_img(node)
    src = node.attributes[:src] || node.attributes['src']

    unless src && src.is_a?(Text)
      puts 'Img must have a src attribute with Text value'
      @valid = false
      return
    end

    puts 'Img content is OK'
  end

  def validate_text(node)
    puts '-Text -> Must contains a simple string'

    unless node.content.is_a?(String)
      puts 'Text content must be a string'
      @valid = false
      return
    end

    puts 'Text content is OK'
  end
end

if $PROGRAM_NAME == __FILE__
  puts '=== Test Ex05: Validation (Page class) ==='

  # Test from subject
  puts "\n--- Test 1: Valid HTML (subject example) ---"
  toto = Html.new([Head.new([Title.new([Text.new('Hello ground!')])]),
                   Body.new([H1.new([Text.new('Oh no, not again!')]),
                             Img.new([], { src: Text.new('http://i.imgur.com/pfp3T.jpg') })])])
  test = Page.new(toto)
  test.is_valid?

  # Test 2: Another valid HTML
  puts "\n--- Test 2: Another valid HTML ---"
  tata = Html.new([Head.new([Title.new([Text.new('Hello ground!')])]),
                   Body.new([H1.new([Text.new('Oh no, not again!')]),
                             Img.new([], { src: Text.new('http://i.imgur.com/pfp3T.jpg') })])])
  test2 = Page.new(tata)
  test2.is_valid?

  # Test 3: Invalid - missing Head
  puts "\n--- Test 3: Invalid - Body without Head ---"
  invalid1 = Html.new([Body.new([H1.new([Text.new('Title')])])])
  Page.new(invalid1).is_valid?

  # Test 4: Invalid - wrong content in Body
  puts "\n--- Test 4: Invalid - wrong content in Body ---"
  invalid2 = Html.new([Head.new([Title.new([Text.new('Test')])]),
                       Body.new([Title.new([Text.new('Wrong!')])])])
  Page.new(invalid2).is_valid?

  # Test 5: Valid with Table
  puts "\n--- Test 5: Valid with Table ---"
  valid_table = Html.new([
                           Head.new([Title.new([Text.new('Table Test')])]),
                           Body.new([
                                      Table.new([
                                                  Tr.new([Th.new([Text.new('Header 1')]), Th.new([Text.new('Header 2')])]),
                                                  Tr.new([Td.new([Text.new('Data 1')]), Td.new([Text.new('Data 2')])])
                                                ])
                                    ])
                         ])
  Page.new(valid_table).is_valid?

  # Test 6: Invalid - Th and Td in same Tr
  puts "\n--- Test 6: Invalid - Th and Td in same Tr ---"
  invalid_tr = Html.new([
                          Head.new([Title.new([Text.new('Test')])]),
                          Body.new([
                                     Table.new([
                                                 Tr.new([Th.new([Text.new('Header')]), Td.new([Text.new('Data')])])
                                               ])
                                   ])
                        ])
  Page.new(invalid_tr).is_valid?

  # Test 7: Valid with List
  puts "\n--- Test 7: Valid with List ---"
  valid_list = Html.new([
                          Head.new([Title.new([Text.new('List Test')])]),
                          Body.new([
                                     Ul.new([
                                              Li.new([Text.new('Item 1')]),
                                              Li.new([Text.new('Item 2')])
                                            ])
                                   ])
                        ])
  Page.new(valid_list).is_valid?

  # Test 8: Invalid - Empty list
  puts "\n--- Test 8: Invalid - Empty Ul ---"
  invalid_list = Html.new([
                            Head.new([Title.new([Text.new('Test')])]),
                            Body.new([Ul.new([])])
                          ])
  Page.new(invalid_list).is_valid?

  # Test 9: Invalid - Img without src Text
  puts "\n--- Test 9: Invalid - Img without Text src ---"
  invalid_img = Html.new([
                           Head.new([Title.new([Text.new('Test')])]),
                           Body.new([Img.new([], { src: 'not_a_text_object' })])
                         ])
  Page.new(invalid_img).is_valid?

  # Test 10: Valid with Div and Span
  puts "\n--- Test 10: Valid with Div and Span ---"
  valid_div = Html.new([
                         Head.new([Title.new([Text.new('Div Test')])]),
                         Body.new([
                                    Div.new([
                                              H1.new([Text.new('Title')]),
                                              Span.new([Text.new('Some text'), P.new([Text.new('Paragraph')])])
                                            ])
                                  ])
                       ])
  Page.new(valid_div).is_valid?

  puts "\n=== All tests completed! ==="
end
