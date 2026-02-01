require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test 'should not save post without user_id' do
    post = Post.new(title: 'Test Title', content: 'Test content')
    assert_not post.save
  end

  test 'should not save post without title' do
    post = Post.new(user: users(:bob), content: 'Test content')
    assert_not post.save
  end

  test 'should not save post with duplicate title' do
    post = Post.new(user: users(:bob), title: posts(:post_one).title, content: 'Test content')
    assert_not post.save
  end

  test 'should not save post with title less than 3 characters' do
    post = Post.new(user: users(:bob), title: 'AB', content: 'Test content')
    assert_not post.save
  end

  test 'should not save post without content' do
    post = Post.new(user: users(:bob), title: 'New Test Title')
    assert_not post.save
  end

  test 'should save valid post' do
    post = Post.new(user: users(:bob), title: 'Brand New Title', content: 'Great content here')
    assert post.save
  end

  test 'total_votes returns correct sum' do
    assert_equal 3, posts(:post_one).total_votes
  end

  test 'author_name returns user name' do
    assert_equal 'bob', posts(:post_one).author_name
  end

  test 'posts are ordered by created_at descending' do
    posts = Post.all
    assert posts.first.created_at >= posts.last.created_at
  end
end
