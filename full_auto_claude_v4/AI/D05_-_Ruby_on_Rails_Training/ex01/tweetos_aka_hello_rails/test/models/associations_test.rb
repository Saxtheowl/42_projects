# frozen_string_literal: true

require 'test_helper'

class AssociationsTest < ActiveSupport::TestCase
  def setup
    setup_test_data
  end

  # Exercise 03: User's relations methods
  test "User's relations methods" do
    assert_respond_to @alice, :cuicuis
    assert_respond_to @alice, :comments
    assert_respond_to @alice, :likes

    assert_includes @alice.cuicuis, @tweet1
    assert_includes @alice.cuicuis, @tweet2
    assert_includes @alice.comments, @comment3
  end

  # Exercise 03: Tweet's relations methods (Cuicui)
  test "Tweet's relations methods" do
    assert_respond_to @tweet1, :user
    assert_respond_to @tweet1, :comments
    assert_respond_to @tweet1, :likes

    assert_equal @alice, @tweet1.user
    assert_includes @tweet1.comments, @comment1
    assert_includes @tweet1.likes, @like1
  end

  # Exercise 03: Comment's relations methods
  test "Comment's relations methods" do
    assert_respond_to @comment1, :user
    assert_respond_to @comment1, :cuicui

    assert_equal @bob, @comment1.user
    assert_equal @tweet1, @comment1.cuicui
  end

  # Exercise 03: Like's relations methods
  test "Like's relations methods" do
    assert_respond_to @like1, :user
    assert_respond_to @like1, :cuicui

    assert_equal @bob, @like1.user
    assert_equal @tweet1, @like1.cuicui
  end
end
