# frozen_string_literal: true

require 'test_helper'

class ModelMethodsTest < ActiveSupport::TestCase
  def setup
    setup_test_data
  end

  # Exercise 07: fame method
  test 'fame returns sum of likes on all user tweets' do
    assert_equal 2, @alice.fame # tweet1 has 2 likes
    assert_equal 1, @bob.fame # tweet3 has 1 like
    assert_equal 0, @senior.fame # no tweets
  end

  # Exercise 07: senior? method
  test 'senior? returns true if since is more than 10 years ago' do
    assert @senior.senior? # since 2005
    assert @alice.senior? # since 2010 (depends on current year)
  end

  test 'senior? returns false if since is less than 10 years' do
    assert_not @bob.senior? # since 2020
  end

  # Exercise 07: junior? method
  test 'junior? returns true if since is less than 10 years' do
    assert @bob.junior? # since 2020
  end

  test 'junior? returns false if since is more than 10 years' do
    assert_not @senior.junior? # since 2005
  end

  # Exercise 07: responses method
  test 'responses returns last 5 comments on user tweets' do
    responses = @alice.responses
    assert responses.is_a?(ActiveRecord::Relation)
    assert responses.count <= 5
    assert_includes responses, @comment1
    assert_includes responses, @comment2
  end

  # Exercise 07: top_tweet method
  test 'top_tweet returns user tweets sorted by likes descending' do
    top = @alice.top_tweet
    assert top.is_a?(ActiveRecord::Relation)
    assert_equal @tweet1, top.first # tweet1 has 2 likes
  end
end
