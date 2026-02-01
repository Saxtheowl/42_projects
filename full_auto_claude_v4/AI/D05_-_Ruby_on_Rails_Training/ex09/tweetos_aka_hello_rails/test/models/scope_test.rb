# frozen_string_literal: true

require 'test_helper'

class ScopeTest < ActiveSupport::TestCase
  def setup
    setup_test_data
  end

  # Exercise 09: Scope :top
  test 'Cuicui.top returns tweets sorted by number of likes descending' do
    top = Cuicui.top
    assert top.is_a?(ActiveRecord::Relation)

    # tweet1 has 2 likes, tweet3 has 1 like, tweet2 has 0 likes
    like_counts = top.map { |t| t.likes.count }
    assert_equal like_counts.sort.reverse, like_counts, 'Tweets should be sorted by likes descending'
  end

  test 'Cuicui.top first element has most likes' do
    top = Cuicui.top
    assert_equal @tweet1, top.first, 'First tweet should have most likes'
  end
end
