# frozen_string_literal: true

require 'test_helper'

class ScopeTest < ActiveSupport::TestCase
  # Ex09: Test Cuicui scope

  test 'Cuicui.top returns cuicuis ordered by likes count' do
    top_cuicuis = Cuicui.top

    assert top_cuicuis.is_a?(ActiveRecord::Relation), 'top scope should return an ActiveRecord relation'

    # cuicui1 has 2 likes (most), cuicui2 has 1 like, cuicui3 has 0 likes
    like_counts = top_cuicuis.map { |c| c.likes.count }

    # Should be in descending order
    assert_equal like_counts, like_counts.sort.reverse, 'Cuicuis should be sorted by likes in descending order'
    assert_equal @cuicui1, top_cuicuis.first, 'Cuicui with most likes should be first'
  end

  test 'Cuicui.top includes cuicuis with no likes' do
    top_cuicuis = Cuicui.top
    assert top_cuicuis.include?(@cuicui3), 'Cuicui with no likes should be included'
  end
end
