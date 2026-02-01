#!/usr/bin/env ruby -w
# frozen_string_literal: true

require "test_helper"

class FtWikipediaTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::FtWikipedia::VERSION
  end

  def test_search_philosophy_directly
    result = Ft_wikipedia.search("Philosophy")
    assert_equal 0, result
  end

  def test_search_returns_integer_or_nil
    result = Ft_wikipedia.search("Kiss")
    assert(result.nil? || result.is_a?(Integer))
  end

  def test_search_directory
    result = Ft_wikipedia.search("Directory")
    assert(result.nil? || result.is_a?(Integer))
  end

  def test_search_problem
    result = Ft_wikipedia.search("Problem")
    assert(result.nil? || result.is_a?(Integer))
  end

  def test_search_einstein
    result = Ft_wikipedia.search("Albert_Einstein")
    assert(result.nil? || result.is_a?(Integer))
  end

  def test_search_knowledge
    result = Ft_wikipedia.search("Knowledge")
    assert(result.nil? || (result.is_a?(Integer) && result >= 0))
  end
end
