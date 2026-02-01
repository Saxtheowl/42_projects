#!/usr/bin/env ruby -w
# frozen_string_literal: true

require "test_helper"

class TaillsteTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Taillste::VERSION
  end

  def test_new_creates_empty_list
    list = Taillste.new
    assert_equal 0, list.size
  end

  def test_add_increases_size
    list = Taillste.new
    list.add(1)
    assert_equal 1, list.size
  end

  def test_add_multiple_elements
    list = Taillste.new
    list.add(1).add(2).add(3)
    assert_equal 3, list.size
  end

  def test_get_returns_element
    list = Taillste.new
    list.add("hello")
    assert_equal "hello", list.get(0)
  end

  def test_get_invalid_index_returns_nil
    list = Taillste.new
    assert_nil list.get(0)
  end

  def test_remove_decreases_size
    list = Taillste.new
    list.add(1).add(2)
    list.remove(0)
    assert_equal 1, list.size
  end

  def test_first_returns_first_element
    list = Taillste.new
    list.add(1).add(2)
    assert_equal 1, list.first
  end

  def test_last_returns_last_element
    list = Taillste.new
    list.add(1).add(2)
    assert_equal 2, list.last
  end

  def test_empty_on_new_list
    list = Taillste.new
    assert list.empty?
  end

  def test_not_empty_after_add
    list = Taillste.new
    list.add(1)
    refute list.empty?
  end

  def test_clear_empties_list
    list = Taillste.new
    list.add(1).add(2)
    list.clear
    assert_equal 0, list.size
  end

  def test_to_a_returns_array
    list = Taillste.new
    list.add(1).add(2)
    assert_equal [1, 2], list.to_a
  end

  def test_include_returns_true
    list = Taillste.new
    list.add("test")
    assert list.include?("test")
  end

  def test_include_returns_false
    list = Taillste.new
    refute list.include?("test")
  end

  def test_reverse_returns_reversed_array
    list = Taillste.new
    list.add(1).add(2).add(3)
    assert_equal [3, 2, 1], list.reverse
  end
end
