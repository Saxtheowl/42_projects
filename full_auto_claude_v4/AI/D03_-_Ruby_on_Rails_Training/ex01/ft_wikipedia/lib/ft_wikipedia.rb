#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true

require "nokogiri"
require "open-uri"
require_relative "ft_wikipedia/version"

module FtWikipedia
  PHILOSOPHY_URL = "https://en.wikipedia.org/wiki/Philosophy"
  BASE_URL = "https://en.wikipedia.org"
  MAX_ITERATIONS = 100

  class << self
    def search(term)
      start_url = "#{BASE_URL}/wiki/#{term}"
      puts "First search @ :#{start_url}"

      visited = []
      current_url = start_url
      count = 0

      while count < MAX_ITERATIONS
        return count if current_url == PHILOSOPHY_URL

        if visited.include?(current_url)
          puts "Loop detected there is no way to philosophy here"
          raise StandardError, "Loop detected there is no way to philosophy here"
          return nil
        end

        visited << current_url

        begin
          next_url = get_first_link(current_url)
        rescue OpenURI::HTTPError
          puts "Dead end page reached"
          raise StandardError, "Dead end page reached"
          return nil
        end

        if next_url.nil?
          puts "Dead end page reached"
          raise StandardError, "Dead end page reached"
          return nil
        end

        current_url = next_url
        puts current_url
        count += 1
      end

      puts "Max iterations reached"
      nil
    end

    private

    def get_first_link(url)
      doc = Nokogiri::HTML(URI.open(url))
      content = doc.css("#mw-content-text .mw-parser-output")

      return nil if content.empty?

      content.children.each do |element|
        next unless element.name == "p"

        link = find_valid_link_in_paragraph(element)
        return link if link
      end

      nil
    end

    def find_valid_link_in_paragraph(paragraph)
      text = paragraph.inner_html
      paren_depth = 0
      current_pos = 0

      while current_pos < text.length
        char = text[current_pos]

        if char == "("
          paren_depth += 1
        elsif char == ")"
          paren_depth -= 1
          paren_depth = 0 if paren_depth < 0
        elsif char == "<"
          if text[current_pos..-1] =~ /\A<a\s/i
            if paren_depth == 0
              link_end = text.index(">", current_pos)
              if link_end
                link_tag = text[current_pos..link_end]
                href = extract_href(link_tag)
                if valid_wiki_link?(href)
                  closing_tag = text.index("</a>", link_end)
                  if closing_tag
                    link_text = text[(link_end + 1)...closing_tag]
                    unless link_text =~ /\A<i>.*<\/i>\z/
                      return "#{BASE_URL}#{href}"
                    end
                  end
                end
              end
            end
            close_pos = text.index("</a>", current_pos)
            current_pos = close_pos ? close_pos + 4 : current_pos + 1
            next
          elsif text[current_pos..-1] =~ /\A<i>/i
            close_pos = text.index("</i>", current_pos)
            current_pos = close_pos ? close_pos + 4 : current_pos + 1
            next
          end
        end

        current_pos += 1
      end

      nil
    end

    def extract_href(link_tag)
      match = link_tag.match(/href=["']([^"']+)["']/)
      match ? match[1] : nil
    end

    def valid_wiki_link?(href)
      return false if href.nil?
      return false unless href.start_with?("/wiki/")
      return false if href.include?(":")
      return false if href.start_with?("/wiki/Main_Page")
      return false if href.include?("#")
      true
    end
  end
end

Ft_wikipedia = FtWikipedia
