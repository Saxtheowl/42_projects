# frozen_string_literal: true

require 'test_helper'

class UserMethodsTest < ActiveSupport::TestCase
  # Ex07: Test User Model Methods

  test 'fame returns total likes on user cuicuis' do
    # User1 has cuicui1 (2 likes) and cuicui2 (1 like) = 3 total
    assert_equal 3, @user1.fame, 'User1 fame should be 3'

    # User2 has cuicui3 (0 likes) = 0 total
    assert_equal 0, @user2.fame, 'User2 fame should be 0'
  end

  test 'senior? returns true for users registered more than 10 years ago' do
    # @user3 has since=2005, which is more than 10 years ago
    assert @user3.senior?, 'User with since=2005 should be senior'
  end

  test 'junior? returns true for users registered less than 10 years ago' do
    # @user2 has since=2020, which is less than 10 years ago
    assert @user2.junior?, 'User with since=2020 should be junior'
  end

  test 'senior? and junior? are mutually exclusive' do
    assert_not_equal @user1.senior?, @user1.junior?, 'senior? and junior? should be mutually exclusive'
    assert_not_equal @user2.senior?, @user2.junior?, 'senior? and junior? should be mutually exclusive'
    assert_not_equal @user3.senior?, @user3.junior?, 'senior? and junior? should be mutually exclusive'
  end

  test 'responses returns 5 most recent comments on user cuicuis' do
    # User1 has cuicui1 which has 2 comments
    responses = @user1.responses
    assert responses.is_a?(ActiveRecord::Relation), 'responses should return an ActiveRecord relation'
    assert_equal 2, responses.count, 'User1 should have 2 responses'
    assert_equal @comment2, responses.first, 'Most recent comment should be first'
  end

  test 'responses limits to 5 comments' do
    # Create more comments
    6.times do |i|
      Comment.create!(content: "Extra comment #{i}", user_id: @user2.id, cuicui_id: @cuicui1.id)
    end

    responses = @user1.responses
    assert_equal 5, responses.count, 'responses should return max 5 comments'
  end

  test 'top_cuicui returns cuicuis sorted by likes count' do
    top = @user1.top_cuicui
    assert top.is_a?(ActiveRecord::Relation), 'top_cuicui should return an ActiveRecord relation'

    # cuicui1 has 2 likes, cuicui2 has 1 like
    assert_equal @cuicui1, top.first, 'Cuicui with most likes should be first'
    assert_equal @cuicui2, top.second, 'Cuicui with fewer likes should be second'
  end
end
