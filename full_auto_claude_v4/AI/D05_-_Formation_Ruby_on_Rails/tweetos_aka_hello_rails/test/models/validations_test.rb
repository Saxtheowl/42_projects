# frozen_string_literal: true

require 'test_helper'

class ValidationsTest < ActiveSupport::TestCase
  # Ex05: Test Validations

  # User validations
  test 'user name uniqueness' do
    user = User.new(name: 'TestUser1', email: 'unique@example.com', since: 2020, country: 'France')
    assert_not user.valid?, 'User with duplicate name should be invalid'
  end

  test 'user email uniqueness' do
    user = User.new(name: 'UniqueUser', email: 'test1@example.com', since: 2020, country: 'France')
    assert_not user.valid?, 'User with duplicate email should be invalid'
  end

  test 'user name minimum length' do
    user = User.new(name: 'A', email: 'short@example.com', since: 2020, country: 'France')
    assert_not user.valid?, 'User with name less than 2 chars should be invalid'
  end

  test 'user banished names' do
    %w[42 Ruby].each do |banished_name|
      user = User.new(name: banished_name, email: "#{banished_name}@example.com", since: 2020, country: 'France')
      assert_not user.valid?, "User with name '#{banished_name}' should be invalid"
      assert(user.errors.full_messages.any? { |m| m.include?('is banished') })
    end
  end

  test 'user banished name lancelot du lac' do
    user = User.new(name: 'lancelot du lac', email: 'lancelot@example.com', since: 2020, country: 'France')
    assert_not user.valid?, "User with name 'lancelot du lac' should be invalid"
  end

  test 'user presence validations' do
    user = User.new
    assert_not user.valid?
    assert user.errors[:name].any?, 'Name should be required'
    assert user.errors[:email].any?, 'Email should be required'
    assert user.errors[:since].any?, 'Since should be required'
    assert user.errors[:country].any?, 'Country should be required'
  end

  test 'user email format validation' do
    user = User.new(name: 'ValidUser', email: 'invalid-email', since: 2020, country: 'France')
    assert_not user.valid?, 'User with invalid email format should be invalid'
  end

  # Like validations
  test 'like uniqueness by user and cuicui' do
    like = Like.new(user_id: @user2.id, cuicui_id: @cuicui1.id)
    assert_not like.valid?, 'Duplicate like should be invalid'
  end

  # Cuicui validations
  test 'cuicui user_id presence' do
    cuicui = Cuicui.new(content: 'Test content')
    assert_not cuicui.valid?, 'Cuicui without user_id should be invalid'
  end

  test 'cuicui content presence' do
    cuicui = Cuicui.new(user_id: @user1.id)
    assert_not cuicui.valid?, 'Cuicui without content should be invalid'
  end

  test 'cuicui content uniqueness' do
    cuicui = Cuicui.new(content: 'Test cuicui 1', user_id: @user1.id)
    assert_not cuicui.valid?, 'Cuicui with duplicate content should be invalid'
  end

  # Comment validations
  test 'comment user_id presence' do
    comment = Comment.new(content: 'Test', cuicui_id: @cuicui1.id)
    assert_not comment.valid?, 'Comment without user_id should be invalid'
  end

  test 'comment content presence' do
    comment = Comment.new(user_id: @user1.id, cuicui_id: @cuicui1.id)
    assert_not comment.valid?, 'Comment without content should be invalid'
  end

  test 'comment content uniqueness' do
    comment = Comment.new(content: 'Test comment 1', user_id: @user1.id, cuicui_id: @cuicui2.id)
    assert_not comment.valid?, 'Comment with duplicate content should be invalid'
  end

  # ID validations
  test 'all IDs must be numeric' do
    cuicui = Cuicui.new(content: 'Test', user_id: 'abc')
    assert_not cuicui.valid?, 'Cuicui with non-numeric user_id should be invalid'

    comment = Comment.new(content: 'Test', user_id: 'abc', cuicui_id: 1)
    assert_not comment.valid?, 'Comment with non-numeric user_id should be invalid'

    like = Like.new(user_id: 'abc', cuicui_id: 1)
    assert_not like.valid?, 'Like with non-numeric user_id should be invalid'
  end

  # ID existence validations
  test 'cuicui user_id must exist' do
    cuicui = Cuicui.new(content: 'Test unique content', user_id: 999_999)
    assert_not cuicui.valid?, 'Cuicui with non-existent user_id should be invalid'
  end

  test 'comment user_id and cuicui_id must exist' do
    comment = Comment.new(content: 'Unique comment', user_id: 999_999, cuicui_id: @cuicui1.id)
    assert_not comment.valid?, 'Comment with non-existent user_id should be invalid'

    comment2 = Comment.new(content: 'Another unique', user_id: @user1.id, cuicui_id: 999_999)
    assert_not comment2.valid?, 'Comment with non-existent cuicui_id should be invalid'
  end

  test 'like user_id and cuicui_id must exist' do
    like = Like.new(user_id: 999_999, cuicui_id: @cuicui1.id)
    assert_not like.valid?, 'Like with non-existent user_id should be invalid'

    like2 = Like.new(user_id: @user1.id, cuicui_id: 999_999)
    assert_not like2.valid?, 'Like with non-existent cuicui_id should be invalid'
  end
end
