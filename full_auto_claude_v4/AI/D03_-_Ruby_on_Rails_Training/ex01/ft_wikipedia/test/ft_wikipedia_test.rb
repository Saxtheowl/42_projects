#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true

require "test_helper"

class FtWikipediaTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::FtWikipedia::VERSION
    assert_equal "0.0.1", ::FtWikipedia::VERSION
  end

  def test_philosophy_page_returns_zero
    result = Ft_wikipedia.search("Philosophy")
    assert_equal 0, result
  end

  def test_search_kiss_reaches_philosophy
    result = Ft_wikipedia.search("Kiss")
    assert result.is_a?(Integer)
    assert result > 0
    assert result < 50
  end

  def test_search_einstein_reaches_philosophy
    result = Ft_wikipedia.search("Albert_Einstein")
    assert result.is_a?(Integer)
    assert result > 0
    assert result < 50
  end

  def test_dead_end_page_raises_error
    assert_raises(StandardError) do
      Ft_wikipedia.search("Effects_of_blue_lights_technology_nonexistent_page_xyz")
    end
  end

  def test_search_directory_reaches_philosophy
    result = Ft_wikipedia.search("Directory")
    assert result.is_a?(Integer)
    assert result >= 0
  end

  def test_ft_wikipedia_alias_works
    assert_equal FtWikipedia, Ft_wikipedia
  end
end
