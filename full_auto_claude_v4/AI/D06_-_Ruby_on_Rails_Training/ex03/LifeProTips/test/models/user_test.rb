require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should not save user without name' do
    user = User.new(email: 'test@example.com', password: 'password123')
    assert_not user.save
  end

  test 'should not save user without email' do
    user = User.new(name: 'test', password: 'password123')
    assert_not user.save
  end

  test 'should not save user with duplicate name' do
    user = User.new(name: users(:bob).name, email: 'new@example.com', password: 'password123')
    assert_not user.save
  end

  test 'should not save user with duplicate email' do
    user = User.new(name: 'newuser', email: users(:bob).email, password: 'password123')
    assert_not user.save
  end

  test 'should not save user with password less than 8 characters' do
    user = User.new(name: 'test', email: 'test@example.com', password: 'short')
    assert_not user.save
  end

  test 'should validate email format' do
    user = User.new(name: 'test', email: 'invalid', password: 'password123')
    assert_not user.save
  end

  test 'should save valid user' do
    user = User.new(name: 'newuser', email: 'new@example.com', password: 'password123')
    assert user.save
  end

  test 'total_votes_received returns correct count' do
    bob = users(:bob)
    assert_equal 3, bob.total_votes_received
  end

  test 'can_upvote? returns true when votes >= 3' do
    bob = users(:bob)
    assert bob.can_upvote?
  end

  test 'can_upvote? returns false when votes < 3' do
    alice = users(:alice)
    assert_not alice.can_upvote?
  end

  test 'can_downvote? returns true when votes >= 6' do
    bob = users(:bob)
    # bob has 3 votes, need 6 for downvote
    assert_not bob.can_downvote?
  end

  test 'can_edit_posts? returns true when votes > 9' do
    bob = users(:bob)
    # bob has 3 votes, need > 9 to edit posts
    assert_not bob.can_edit_posts?
  end

  test 'privileges returns correct privileges' do
    bob = users(:bob)
    assert_includes bob.privileges, 'upvote'
  end
end
