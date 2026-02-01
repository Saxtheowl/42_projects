# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    def setup_test_data
      @alice = User.create!(name: 'Alice', email: 'alice@test.com', since: 2010, admin: true, country: 'France')
      @bob = User.create!(name: 'Bob', email: 'bob@test.com', since: 2020, admin: false, country: 'USA')
      @senior = User.create!(name: 'Senior', email: 'senior@test.com', since: 2005, admin: false, country: 'UK')

      @tweet1 = Cuicui.create!(content: 'First tweet', user: @alice)
      @tweet2 = Cuicui.create!(content: 'Second tweet', user: @alice)
      @tweet3 = Cuicui.create!(content: 'Third tweet', user: @bob)

      @comment1 = Comment.create!(content: 'Nice!', user: @bob, cuicui: @tweet1)
      @comment2 = Comment.create!(content: 'Great!', user: @senior, cuicui: @tweet1)
      @comment3 = Comment.create!(content: 'Awesome!', user: @alice, cuicui: @tweet3)

      @like1 = Like.create!(user: @bob, cuicui: @tweet1)
      @like2 = Like.create!(user: @senior, cuicui: @tweet1)
      @like3 = Like.create!(user: @alice, cuicui: @tweet3)
    end

    def teardown
      Like.destroy_all
      Comment.destroy_all
      Cuicui.destroy_all
      User.destroy_all
    end
  end
end
