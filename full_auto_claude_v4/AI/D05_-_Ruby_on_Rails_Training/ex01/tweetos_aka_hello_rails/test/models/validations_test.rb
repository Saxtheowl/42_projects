# frozen_string_literal: true

require 'test_helper'

class ValidationsTest < ActiveSupport::TestCase
  def setup
    setup_test_data
  end

  # Exercise 05: User validations

  test 'user name uniqueness' do
    duplicate = User.new(name: 'Alice', email: 'other@test.com', since: 2020, country: 'UK')
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], 'has already been taken'
  end

  test 'user email uniqueness' do
    duplicate = User.new(name: 'Other', email: 'alice@test.com', since: 2020, country: 'UK')
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], 'has already been taken'
  end

  test 'user name minimum length' do
    short_name = User.new(name: 'A', email: 'short@test.com', since: 2020, country: 'UK')
    assert_not short_name.valid?
    assert short_name.errors[:name].any? { |e| e.include?('too short') }
  end

  test 'user banned names' do
    %w[42 Ruby].each do |banned|
      user = User.new(name: banned, email: "#{banned}@test.com", since: 2020, country: 'UK')
      assert_not user.valid?
      assert user.errors[:name].any? { |e| e.include?('is banished') }
    end

    lancelot = User.new(name: 'lancelot du lac', email: 'lancelot@test.com', since: 2020, country: 'UK')
    assert_not lancelot.valid?
    assert lancelot.errors[:name].any? { |e| e.include?('is banished') }
  end

  test 'user required fields' do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
    assert_includes user.errors[:email], "can't be blank"
    assert_includes user.errors[:since], "can't be blank"
    assert_includes user.errors[:country], "can't be blank"
  end

  test 'user email format' do
    invalid = User.new(name: 'Test', email: 'invalid', since: 2020, country: 'UK')
    assert_not invalid.valid?
    assert invalid.errors[:email].any?
  end

  # Exercise 05: Cuicui validations

  test 'cuicui content uniqueness' do
    duplicate = Cuicui.new(content: 'First tweet', user: @bob)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:content], 'has already been taken'
  end

  test 'cuicui content presence' do
    empty = Cuicui.new(user: @alice)
    assert_not empty.valid?
    assert_includes empty.errors[:content], "can't be blank"
  end

  test 'cuicui user_id presence' do
    no_user = Cuicui.new(content: 'No user')
    assert_not no_user.valid?
    assert_includes no_user.errors[:user_id], "can't be blank"
  end

  test 'cuicui user_id must be numeric' do
    cuicui = Cuicui.new(content: 'Test', user_id: 'abc')
    assert_not cuicui.valid?
    assert cuicui.errors[:user_id].any?
  end

  test 'cuicui user_id must exist' do
    cuicui = Cuicui.new(content: 'Test content unique', user_id: 99_999)
    assert_not cuicui.valid?
    assert cuicui.errors[:user_id].any? { |e| e.include?('valid') }
  end

  # Exercise 05: Comment validations

  test 'comment content uniqueness' do
    duplicate = Comment.new(content: 'Nice!', user: @alice, cuicui: @tweet2)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:content], 'has already been taken'
  end

  test 'comment content presence' do
    empty = Comment.new(user: @alice, cuicui: @tweet1)
    assert_not empty.valid?
    assert_includes empty.errors[:content], "can't be blank"
  end

  test 'comment user_id presence' do
    no_user = Comment.new(content: 'New comment', cuicui: @tweet1)
    assert_not no_user.valid?
    assert_includes no_user.errors[:user_id], "can't be blank"
  end

  test 'comment cuicui_id presence' do
    no_cuicui = Comment.new(content: 'New comment 2', user: @alice)
    assert_not no_cuicui.valid?
    assert_includes no_cuicui.errors[:cuicui_id], "can't be blank"
  end

  test 'comment user_id must exist' do
    comment = Comment.new(content: 'Test comment', user_id: 99_999, cuicui: @tweet1)
    assert_not comment.valid?
    assert comment.errors[:user_id].any? { |e| e.include?('valid') }
  end

  test 'comment cuicui_id must exist' do
    comment = Comment.new(content: 'Test comment 2', user: @alice, cuicui_id: 99_999)
    assert_not comment.valid?
    assert comment.errors[:cuicui_id].any? { |e| e.include?('valid') }
  end

  # Exercise 05: Like validations

  test 'like user_id and cuicui_id uniqueness together' do
    duplicate = Like.new(user: @bob, cuicui: @tweet1)
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any? { |e| e.include?('like') || e.include?('taken') }
  end

  test 'like user_id presence' do
    no_user = Like.new(cuicui: @tweet1)
    assert_not no_user.valid?
    assert_includes no_user.errors[:user_id], "can't be blank"
  end

  test 'like cuicui_id presence' do
    no_cuicui = Like.new(user: @alice)
    assert_not no_cuicui.valid?
    assert_includes no_cuicui.errors[:cuicui_id], "can't be blank"
  end

  test 'like user_id must be numeric' do
    like = Like.new(user_id: 'abc', cuicui: @tweet2)
    assert_not like.valid?
    assert like.errors[:user_id].any?
  end

  test 'like cuicui_id must be numeric' do
    like = Like.new(user: @alice, cuicui_id: 'abc')
    assert_not like.valid?
    assert like.errors[:cuicui_id].any?
  end

  test 'like user_id must exist' do
    like = Like.new(user_id: 99_999, cuicui: @tweet2)
    assert_not like.valid?
    assert like.errors[:user_id].any? { |e| e.include?('valid') }
  end

  test 'like cuicui_id must exist' do
    like = Like.new(user: @alice, cuicui_id: 99_999)
    assert_not like.valid?
    assert like.errors[:cuicui_id].any? { |e| e.include?('valid') }
  end
end
