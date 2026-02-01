require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test 'should get signup page' do
    get :new
    assert_response :success
  end

  test 'should redirect logged in user from signup page' do
    login_as(users(:bob))
    get :new
    assert_redirected_to root_path
  end

  test 'should create user and auto login' do
    assert_difference('User.count') do
      post :create, user: {
        name: 'newuser',
        email: 'newuser@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end
    assert_redirected_to root_path
    assert_not_nil session[:user_id]
  end

  test 'should not create user with invalid data' do
    assert_no_difference('User.count') do
      post :create, user: {
        name: '',
        email: 'invalid',
        password: 'short'
      }
    end
    assert_template :new
  end

  test 'should show user' do
    login_as(users(:bob))
    get :show, id: users(:bob)
    assert_response :success
  end

  test 'should get edit for own profile' do
    login_as(users(:bob))
    get :edit, id: users(:bob)
    assert_response :success
  end

  test 'should not get edit for other user profile' do
    login_as(users(:bob))
    get :edit, id: users(:alice)
    assert_redirected_to root_path
  end

  test 'admin can edit any user profile' do
    login_as(users(:admin))
    get :edit, id: users(:bob)
    assert_response :success
  end

  test 'should update own profile' do
    login_as(users(:bob))
    patch :update, id: users(:bob), user: { name: 'bob_updated', email: 'bob_updated@example.com' }
    assert_redirected_to user_path(users(:bob))
    users(:bob).reload
    assert_equal 'bob_updated', users(:bob).name
  end

  test 'should require login to edit' do
    get :edit, id: users(:bob)
    assert_redirected_to root_path
  end
end
