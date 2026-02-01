require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  test 'should get index without login' do
    get :index
    assert_response :success
  end

  test 'should redirect to root when visitor tries to view post' do
    get :show, id: posts(:post_one)
    assert_redirected_to root_path
    assert_equal 'You need an account to see this', flash[:alert]
  end

  test 'logged in user can view post' do
    login_as(users(:bob))
    get :show, id: posts(:post_one)
    assert_response :success
  end

  test 'should get new for logged in user' do
    login_as(users(:bob))
    get :new
    assert_response :success
  end

  test 'should redirect new for visitor' do
    get :new
    assert_redirected_to root_path
  end

  test 'should create post' do
    login_as(users(:bob))
    assert_difference('Post.count') do
      post :create, post: { title: 'Brand New Post', content: 'Great content here' }
    end
    new_post = Post.find_by(title: 'Brand New Post')
    assert_redirected_to post_path(new_post)
  end

  test 'should not create invalid post' do
    login_as(users(:bob))
    assert_no_difference('Post.count') do
      post :create, post: { title: '', content: '' }
    end
    assert_template :new
  end

  test 'user can edit own post' do
    login_as(users(:bob))
    get :edit, id: posts(:post_one)
    assert_response :success
  end

  test 'user cannot edit other user post without privilege' do
    login_as(users(:alice))
    get :edit, id: posts(:post_one)
    assert_redirected_to post_path(posts(:post_one))
  end

  test 'admin can edit any post' do
    login_as(users(:admin))
    get :edit, id: posts(:post_one)
    assert_response :success
  end

  test 'should update post and track editor' do
    login_as(users(:bob))
    patch :update, id: posts(:post_one), post: { title: 'Updated Title', content: 'Updated content' }
    assert_redirected_to post_path(posts(:post_one))
    posts(:post_one).reload
    assert_equal 'Updated Title', posts(:post_one).title
    assert_equal users(:bob).id, posts(:post_one).edited_by_id
  end
end
