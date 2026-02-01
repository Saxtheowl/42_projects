#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true

require "test_helper"

class DeepthoughtTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Deepthought::VERSION
    assert_equal "0.0.1", ::Deepthought::VERSION
  end

  def test_new_returns_deepthought_object
    dt = Deepthought.new
    assert_instance_of Deepthought, dt
  end

  def test_respond_to_ultimate_question
    dt = Deepthought.new
    result = dt.respond("The Ultimate Question of Life, the Universe and Everything")
    assert_equal "42", result
  end

  def test_respond_to_other_question
    dt = Deepthought.new
    result = dt.respond("What is the meaning of life?")
    assert_equal "Mmmm i'm bored", result
  end

  def test_respond_to_empty_question
    dt = Deepthought.new
    result = dt.respond("")
    assert_equal "Mmmm i'm bored", result
  end

  def test_respond_to_nil_like_string
    dt = Deepthought.new
    result = dt.respond("nil")
    assert_equal "Mmmm i'm bored", result
  end
end
