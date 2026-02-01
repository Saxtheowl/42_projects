# frozen_string_literal: true

require 'test_helper'

class MigrationsTest < ActiveSupport::TestCase
  # Ex01: Test migrations
  test 'users table exists with correct columns' do
    assert User.table_exists?, 'users table should exist'
    assert User.column_names.include?('name'), 'users should have name column'
    assert User.column_names.include?('email'), 'users should have email column'
    assert User.column_names.include?('since'), 'users should have since column'
    assert User.column_names.include?('admin'), 'users should have admin column'
    assert User.column_names.include?('country'), 'users should have country column'
    assert User.column_names.include?('created_at'), 'users should have created_at column'
    assert User.column_names.include?('updated_at'), 'users should have updated_at column'
  end

  test 'cuicuis table exists with correct columns' do
    assert Cuicui.table_exists?, 'cuicuis table should exist'
    assert Cuicui.column_names.include?('content'), 'cuicuis should have content column'
    assert Cuicui.column_names.include?('user_id'), 'cuicuis should have user_id column'
    assert Cuicui.column_names.include?('created_at'), 'cuicuis should have created_at column'
    assert Cuicui.column_names.include?('updated_at'), 'cuicuis should have updated_at column'
  end

  test 'comments table exists with correct columns' do
    assert Comment.table_exists?, 'comments table should exist'
    assert Comment.column_names.include?('content'), 'comments should have content column'
    assert Comment.column_names.include?('cuicui_id'), 'comments should have cuicui_id column'
    assert Comment.column_names.include?('user_id'), 'comments should have user_id column'
    assert Comment.column_names.include?('created_at'), 'comments should have created_at column'
    assert Comment.column_names.include?('updated_at'), 'comments should have updated_at column'
  end

  test 'likes table exists with correct columns' do
    assert Like.table_exists?, 'likes table should exist'
    assert Like.column_names.include?('user_id'), 'likes should have user_id column'
    assert Like.column_names.include?('cuicui_id'), 'likes should have cuicui_id column'
    assert Like.column_names.include?('created_at'), 'likes should have created_at column'
    assert Like.column_names.include?('updated_at'), 'likes should have updated_at column'
  end
end
