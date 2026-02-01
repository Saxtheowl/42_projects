require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  test 'should not save vote without user' do
    vote = Vote.new(post: posts(:post_one), value: 1)
    assert_not vote.save
  end

  test 'should not save vote without post' do
    vote = Vote.new(user: users(:bob), value: 1)
    assert_not vote.save
  end

  test 'should not save vote without value' do
    vote = Vote.new(user: users(:bob), post: posts(:post_two))
    assert_not vote.save
  end

  test 'should not allow duplicate votes from same user on same post' do
    vote = Vote.new(user: users(:alice), post: posts(:post_one), value: -1)
    assert_not vote.save
  end

  test 'should only allow values of 1 or -1' do
    vote = Vote.new(user: users(:bob), post: posts(:post_two), value: 2)
    assert_not vote.save
  end

  test 'should save valid upvote' do
    vote = Vote.new(user: users(:bob), post: posts(:post_two), value: 1)
    assert vote.save
  end

  test 'should save valid downvote' do
    vote = Vote.new(user: users(:bob), post: posts(:post_three), value: -1)
    assert vote.save
  end

  test 'voter_name returns user name' do
    assert_equal 'alice', votes(:vote_one).voter_name
  end

  test 'post_title returns post title' do
    assert_equal 'First Life Pro Tip', votes(:vote_one).post_title
  end
end
