require 'test_helper'

class Admin::PostsControllerTest < ActionController::TestCase
  test 'should redirect non-admin from index' do
    login_as(users(:bob))
    get :index
    assert_redirected_to root_path
  end

  test 'admin can access index' do
    login_as(users(:admin))
    get :index
    assert_response :success
  end

  test 'admin can edit post' do
    login_as(users(:admin))
    get :edit, id: posts(:post_one)
    assert_response :success
  end

  test 'admin can update post' do
    login_as(users(:admin))
    patch :update, id: posts(:post_one), post: { title: 'Admin Updated Title', content: 'Admin content' }
    assert_redirected_to admin_posts_path
    posts(:post_one).reload
    assert_equal 'Admin Updated Title', posts(:post_one).title
    assert_equal users(:admin).id, posts(:post_one).edited_by_id
  end

  test 'admin can delete post' do
    login_as(users(:admin))
    assert_difference('Post.count', -1) do
      delete :destroy, id: posts(:post_one)
    end
    assert_redirected_to admin_posts_path
  end
end
