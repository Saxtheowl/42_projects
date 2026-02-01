#!/usr/bin/env ruby -w
# frozen_string_literal: true

require_relative "ft_wikipedia/version"
require "nokogiri"
require "open-uri"

module Ft_wikipedia
  PHILOSOPHY_URL = "https://en.wikipedia.org/wiki/Philosophy"
  BASE_URL = "https://en.wikipedia.org"
  MAX_DEPTH = 100

  class << self
    def search(term)
      start_url = "#{BASE_URL}/wiki/#{term}"
      puts "First search @ :#{start_url}"

      visited = []
      current_url = start_url
      count = 0

      find_philosophy(current_url, visited, count)
    end

    private

    def find_philosophy(current_url, visited, count)
      return count if current_url == PHILOSOPHY_URL
      return nil if count > MAX_DEPTH

      if visited.include?(current_url)
        puts "Loop detected there is no way to philosophy here"
        return nil
      end

      visited << current_url

      next_url = get_first_link(current_url)

      if next_url.nil?
        puts "Dead end page reached"
        return nil
      end

      puts next_url
      find_philosophy(next_url, visited, count + 1)
    end

    def get_first_link(url)
      doc = Nokogiri::HTML(URI.open(url, "User-Agent" => "Mozilla/5.0 (compatible)"))

      content_div = doc.css("div.mw-parser-output").first
      return nil if content_div.nil?

      content_div.css("table, div.toc, div.navbox, div.mw-editsection, sup.reference, span.mw-editsection, .infobox, .sidebar, .ambox, .hatnote, .shortdescription, style, script").each(&:remove)

      elements = content_div.css("> p, > ul > li, > div > p")

      elements.each do |element|
        next if element.text.strip.empty?
        link = find_valid_link_in_element(element.to_html)
        return link if link
      end

      nil
    rescue OpenURI::HTTPError
      nil
    rescue StandardError
      nil
    end

    def find_valid_link_in_element(html)
      clean_html = remove_parentheses_and_brackets(html)
      element = Nokogiri::HTML.fragment(clean_html)

      element.css("a").each do |link|
        href = link["href"]
        next if href.nil?
        next unless valid_wiki_link?(href, link)

        full_url = "#{BASE_URL}#{href}"
        return full_url
      end

      nil
    end

    def remove_parentheses_and_brackets(html)
      depth_paren = 0
      depth_bracket = 0
      result = []
      in_tag = false

      html.chars.each do |char|
        if char == "<"
          in_tag = true
          result << char
        elsif char == ">"
          in_tag = false
          result << char
        elsif in_tag
          result << char
        elsif char == "("
          depth_paren += 1
        elsif char == ")"
          depth_paren -= 1 if depth_paren > 0
        elsif char == "["
          depth_bracket += 1
        elsif char == "]"
          depth_bracket -= 1 if depth_bracket > 0
        elsif depth_paren == 0 && depth_bracket == 0
          result << char
        end
      end

      result.join
    end

    def valid_wiki_link?(href, link)
      return false unless href.start_with?("/wiki/")

      invalid_prefixes = %w[
        /wiki/Help: /wiki/File: /wiki/Wikipedia: /wiki/Special:
        /wiki/Talk: /wiki/Portal: /wiki/Category: /wiki/Template:
        /wiki/Template_talk: /wiki/Module: /wiki/Draft: /wiki/Main_Page
        /wiki/Book: /wiki/MediaWiki: /wiki/User: /wiki/User_talk:
      ]

      invalid_prefixes.each do |prefix|
        return false if href.start_with?(prefix)
      end

      return false if href.include?("#")
      return false if link.text.strip.empty?

      return false if link.ancestors("i").any?
      return false if link.ancestors("em").any?
      return false if link.ancestors("sup").any?
      return false if link.ancestors("small").any?
      return false if link.ancestors("span.IPA").any?
      return false if link["class"]&.include?("image")
      return false if link["class"]&.include?("mw-file-description")

      link_title = href.sub("/wiki/", "")
      return false if link_title.include?(":")

      true
    end
  end
end
