# frozen_string_literal: true

require 'test_helper'

class AssociationsTest < ActiveSupport::TestCase
  # Ex03: Test Active Record Associations

  # User's relations methods
  test "User's relations methods" do
    assert @user1.respond_to?(:cuicuis), 'User should have cuicuis association'
    assert @user1.respond_to?(:comments), 'User should have comments association'
    assert @user1.respond_to?(:likes), 'User should have likes association'

    assert_equal 2, @user1.cuicuis.count, 'User1 should have 2 cuicuis'
    assert_equal 0, @user1.comments.count, 'User1 should have 0 comments'
    assert_equal 1, @user1.likes.count, 'User1 should have 1 like'
  end

  # Cuicui's relations methods
  test "Cuicui's relations methods" do
    assert @cuicui1.respond_to?(:user), 'Cuicui should have user association'
    assert @cuicui1.respond_to?(:comments), 'Cuicui should have comments association'
    assert @cuicui1.respond_to?(:likes), 'Cuicui should have likes association'

    assert_equal @user1, @cuicui1.user, 'Cuicui1 should belong to User1'
    assert_equal 2, @cuicui1.comments.count, 'Cuicui1 should have 2 comments'
    assert_equal 2, @cuicui1.likes.count, 'Cuicui1 should have 2 likes'
  end

  # Comment's relations methods
  test "Comment's relations methods" do
    assert @comment1.respond_to?(:user), 'Comment should have user association'
    assert @comment1.respond_to?(:cuicui), 'Comment should have cuicui association'

    assert_equal @user2, @comment1.user, 'Comment1 should belong to User2'
    assert_equal @cuicui1, @comment1.cuicui, 'Comment1 should belong to Cuicui1'
  end

  # Like's relations methods
  test "Like's relations methods" do
    assert @like1.respond_to?(:user), 'Like should have user association'
    assert @like1.respond_to?(:cuicui), 'Like should have cuicui association'

    assert_equal @user2, @like1.user, 'Like1 should belong to User2'
    assert_equal @cuicui1, @like1.cuicui, 'Like1 should belong to Cuicui1'
  end
end
