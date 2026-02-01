# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'

class ActiveSupport::TestCase
  def setup
    cleanup_database
    create_test_users
    create_test_cuicuis
    create_test_comments_and_likes
  end

  private

  def cleanup_database
    Like.delete_all
    Comment.delete_all
    Cuicui.delete_all
    User.delete_all
  end

  def create_test_users
    @user1 = User.create!(name: 'TestUser1', email: 'test1@example.com', since: 2010, country: 'France')
    @user2 = User.create!(name: 'TestUser2', email: 'test2@example.com', since: 2020, country: 'USA')
    @user3 = User.create!(name: 'Senior', email: 'senior@example.com', since: 2005, country: 'UK')
  end

  def create_test_cuicuis
    @cuicui1 = Cuicui.create!(content: 'Test cuicui 1', user_id: @user1.id)
    @cuicui2 = Cuicui.create!(content: 'Test cuicui 2', user_id: @user1.id)
    @cuicui3 = Cuicui.create!(content: 'Test cuicui 3', user_id: @user2.id)
  end

  def create_test_comments_and_likes
    @comment1 = Comment.create!(content: 'Test comment 1', user_id: @user2.id, cuicui_id: @cuicui1.id)
    @comment2 = Comment.create!(content: 'Test comment 2', user_id: @user3.id, cuicui_id: @cuicui1.id)
    @like1 = Like.create!(user_id: @user2.id, cuicui_id: @cuicui1.id)
    @like2 = Like.create!(user_id: @user3.id, cuicui_id: @cuicui1.id)
    @like3 = Like.create!(user_id: @user1.id, cuicui_id: @cuicui2.id)
  end
end
