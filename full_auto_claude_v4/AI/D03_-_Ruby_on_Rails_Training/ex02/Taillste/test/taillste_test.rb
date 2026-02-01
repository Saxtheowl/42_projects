#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true

require "test_helper"

class TaillsteTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Taillste::VERSION
    assert_equal "0.0.1", ::Taillste::VERSION
  end

  def test_list_can_be_created_empty
    list = Taillste::List.new
    assert_instance_of Taillste::List, list
    assert list.empty?
  end

  def test_list_can_be_created_with_items
    list = Taillste::List.new([1, 2, 3])
    assert_equal 3, list.length
    assert_equal [1, 2, 3], list.to_a
  end

  def test_first_returns_first_element
    list = Taillste::List.new([1, 2, 3])
    assert_equal 1, list.first
  end

  def test_last_returns_last_element
    list = Taillste::List.new([1, 2, 3])
    assert_equal 3, list.last
  end

  def test_head_returns_first_element
    list = Taillste::List.new([1, 2, 3])
    assert_equal 1, list.head
  end

  def test_tail_returns_list_without_first_element
    list = Taillste::List.new([1, 2, 3])
    tail = list.tail
    assert_instance_of Taillste::List, tail
    assert_equal [2, 3], tail.to_a
  end

  def test_tail_of_empty_list_returns_nil
    list = Taillste::List.new
    assert_nil list.tail
  end

  def test_push_adds_element_to_end
    list = Taillste::List.new([1, 2])
    list.push(3)
    assert_equal [1, 2, 3], list.to_a
  end

  def test_pop_removes_last_element
    list = Taillste::List.new([1, 2, 3])
    popped = list.pop
    assert_equal 3, popped
    assert_equal [1, 2], list.to_a
  end

  def test_shift_removes_first_element
    list = Taillste::List.new([1, 2, 3])
    shifted = list.shift
    assert_equal 1, shifted
    assert_equal [2, 3], list.to_a
  end

  def test_unshift_adds_element_to_beginning
    list = Taillste::List.new([2, 3])
    list.unshift(1)
    assert_equal [1, 2, 3], list.to_a
  end

  def test_reverse_returns_new_reversed_list
    list = Taillste::List.new([1, 2, 3])
    reversed = list.reverse
    assert_equal [3, 2, 1], reversed.to_a
    assert_equal [1, 2, 3], list.to_a
  end

  def test_reverse_bang_reverses_in_place
    list = Taillste::List.new([1, 2, 3])
    list.reverse!
    assert_equal [3, 2, 1], list.to_a
  end

  def test_map_transforms_elements
    list = Taillste::List.new([1, 2, 3])
    mapped = list.map { |x| x * 2 }
    assert_equal [2, 4, 6], mapped.to_a
  end

  def test_select_filters_elements
    list = Taillste::List.new([1, 2, 3, 4, 5])
    selected = list.select { |x| x.even? }
    assert_equal [2, 4], selected.to_a
  end

  def test_reject_removes_matching_elements
    list = Taillste::List.new([1, 2, 3, 4, 5])
    rejected = list.reject { |x| x.even? }
    assert_equal [1, 3, 5], rejected.to_a
  end

  def test_reduce_accumulates_values
    list = Taillste::List.new([1, 2, 3, 4])
    sum = list.reduce(0) { |acc, x| acc + x }
    assert_equal 10, sum
  end

  def test_include_checks_membership
    list = Taillste::List.new([1, 2, 3])
    assert list.include?(2)
    refute list.include?(4)
  end

  def test_bracket_accessor
    list = Taillste::List.new([1, 2, 3])
    assert_equal 2, list[1]
  end

  def test_bracket_setter
    list = Taillste::List.new([1, 2, 3])
    list[1] = 5
    assert_equal [1, 5, 3], list.to_a
  end

  def test_equality
    list1 = Taillste::List.new([1, 2, 3])
    list2 = Taillste::List.new([1, 2, 3])
    list3 = Taillste::List.new([1, 2])
    assert_equal list1, list2
    refute_equal list1, list3
  end

  def test_sort_returns_sorted_list
    list = Taillste::List.new([3, 1, 2])
    sorted = list.sort
    assert_equal [1, 2, 3], sorted.to_a
    assert_equal [3, 1, 2], list.to_a
  end

  def test_uniq_removes_duplicates
    list = Taillste::List.new([1, 2, 2, 3, 3, 3])
    unique = list.uniq
    assert_equal [1, 2, 3], unique.to_a
  end

  def test_compact_removes_nils
    list = Taillste::List.new([1, nil, 2, nil, 3])
    compacted = list.compact
    assert_equal [1, 2, 3], compacted.to_a
  end

  def test_take_returns_first_n_elements
    list = Taillste::List.new([1, 2, 3, 4, 5])
    taken = list.take(3)
    assert_equal [1, 2, 3], taken.to_a
  end

  def test_drop_removes_first_n_elements
    list = Taillste::List.new([1, 2, 3, 4, 5])
    dropped = list.drop(2)
    assert_equal [3, 4, 5], dropped.to_a
  end

  def test_concat_combines_lists
    list1 = Taillste::List.new([1, 2])
    list2 = Taillste::List.new([3, 4])
    concatenated = list1.concat(list2)
    assert_equal [1, 2, 3, 4], concatenated.to_a
  end

  def test_plus_operator_combines_lists
    list1 = Taillste::List.new([1, 2])
    list2 = Taillste::List.new([3, 4])
    combined = list1 + list2
    assert_equal [1, 2, 3, 4], combined.to_a
  end

  def test_each_iterates_over_elements
    list = Taillste::List.new([1, 2, 3])
    result = []
    list.each { |x| result << x * 2 }
    assert_equal [2, 4, 6], result
  end

  def test_flatten_flattens_nested_arrays
    list = Taillste::List.new([[1, 2], [3, [4, 5]]])
    flattened = list.flatten
    assert_equal [1, 2, 3, 4, 5], flattened.to_a
  end
end
