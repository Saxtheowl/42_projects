# frozen_string_literal: true

require 'test_helper'

class MigrationsTest < ActiveSupport::TestCase
  # Exercise 01: Migrations test
  test 'users table has correct columns' do
    columns = User.column_names
    assert_includes columns, 'id'
    assert_includes columns, 'name'
    assert_includes columns, 'email'
    assert_includes columns, 'since'
    assert_includes columns, 'admin'
    assert_includes columns, 'country'
    assert_includes columns, 'created_at'
    assert_includes columns, 'updated_at'
  end

  test 'cuicuis table has correct columns' do
    columns = Cuicui.column_names
    assert_includes columns, 'id'
    assert_includes columns, 'content'
    assert_includes columns, 'user_id'
    assert_includes columns, 'created_at'
    assert_includes columns, 'updated_at'
  end

  test 'comments table has correct columns' do
    columns = Comment.column_names
    assert_includes columns, 'id'
    assert_includes columns, 'content'
    assert_includes columns, 'cuicui_id'
    assert_includes columns, 'user_id'
    assert_includes columns, 'created_at'
    assert_includes columns, 'updated_at'
  end

  test 'likes table has correct columns' do
    columns = Like.column_names
    assert_includes columns, 'id'
    assert_includes columns, 'user_id'
    assert_includes columns, 'cuicui_id'
    assert_includes columns, 'created_at'
    assert_includes columns, 'updated_at'
  end
end
