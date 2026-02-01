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

# Define HTML element classes using metaprogramming to avoid repetition
# Double tags (with opening and closing)
%w[Html Head Body Title Table Th Tr Td Ul Ol Li H1 H2 P Div Span].each do |tag_name|
  klass = Class.new(Elem) do
    define_method(:initialize) do |content = [], attributes = {}|
      super(tag_name, content, 'double', attributes)
    end
  end
  Object.const_set(tag_name, klass)
end

# Single tags (self-closing / orphan)
%w[Meta Img Hr Br].each do |tag_name|
  klass = Class.new(Elem) do
    define_method(:initialize) do |content = [], attributes = {}|
      super(tag_name, content, 'simple', attributes)
    end
  end
  Object.const_set(tag_name, klass)
end

if $PROGRAM_NAME == __FILE__
  puts '=== Test Ex04: Dejavu (HTML Element Classes) ==='

  # Test 1: Example from subject
  puts "\n--- Test 1: Subject example ---"
  puts Html.new([Head.new([Title.new([Text.new('Hello ground!')])]),
                 Body.new([H1.new([Text.new('Oh no, not again!')]),
                           Img.new([], { 'src' => 'http://i.imgur.com/pfp3T.jpg' })])])

  # Test 2: Table structure
  puts "\n--- Test 2: Table structure ---"
  table = Table.new([
                      Tr.new([
                               Th.new([Text.new('Name')]),
                               Th.new([Text.new('Age')])
                             ]),
                      Tr.new([
                               Td.new([Text.new('Alice')]),
                               Td.new([Text.new('25')])
                             ]),
                      Tr.new([
                               Td.new([Text.new('Bob')]),
                               Td.new([Text.new('30')])
                             ])
                    ])
  puts table.to_s

  # Test 3: Lists
  puts "\n--- Test 3: Unordered list ---"
  ul = Ul.new([
                Li.new([Text.new('Item 1')]),
                Li.new([Text.new('Item 2')]),
                Li.new([Text.new('Item 3')])
              ])
  puts ul.to_s

  puts "\n--- Test 4: Ordered list ---"
  ol = Ol.new([
                Li.new([Text.new('First')]),
                Li.new([Text.new('Second')]),
                Li.new([Text.new('Third')])
              ])
  puts ol.to_s

  # Test 5: Div and Span
  puts "\n--- Test 5: Div and Span ---"
  div = Div.new([
                  H1.new([Text.new('Title')]),
                  P.new([Text.new('Paragraph with '),
                         Span.new([Text.new('highlighted')]),
                         Text.new(' text.')])
                ])
  puts div.to_s

  # Test 6: Self-closing tags
  puts "\n--- Test 6: Self-closing tags ---"
  puts Hr.new.to_s
  puts Br.new.to_s
  puts Meta.new([], { 'charset' => 'UTF-8' }).to_s
  puts Img.new([], { 'src' => 'test.jpg', 'alt' => 'Test image' }).to_s

  # Test 7: Complete HTML page
  puts "\n--- Test 7: Complete HTML page ---"
  page = Html.new([
                    Head.new([
                               Meta.new([], { 'charset' => 'UTF-8' }),
                               Title.new([Text.new('My Page')])
                             ]),
                    Body.new([
                               H1.new([Text.new('Welcome')]),
                               H2.new([Text.new('Subtitle')]),
                               P.new([Text.new('This is a paragraph.')]),
                               Hr.new,
                               Div.new([
                                         Ul.new([
                                                  Li.new([Text.new('Item A')]),
                                                  Li.new([Text.new('Item B')])
                                                ])
                                       ])
                             ])
                  ])
  puts page.to_s

  puts "\nAll tests completed!"
end
