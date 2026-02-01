require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test 'should get login page' do
    get :new
    assert_response :success
  end

  test 'should redirect logged in user from login page' do
    login_as(users(:bob))
    get :new
    assert_redirected_to root_path
  end

  test 'should login with valid credentials using name' do
    post :create, login: 'bob', password: 'password123'
    assert_redirected_to root_path
    assert_equal users(:bob).id, session[:user_id]
  end

  test 'should login with valid credentials using email' do
    post :create, login: 'bob@example.com', password: 'password123'
    assert_redirected_to root_path
    assert_equal users(:bob).id, session[:user_id]
  end

  test 'should not login with invalid password' do
    post :create, login: 'bob', password: 'wrongpassword'
    assert_template :new
    assert_nil session[:user_id]
  end

  test 'should not login with invalid username' do
    post :create, login: 'nonexistent', password: 'password123'
    assert_template :new
    assert_nil session[:user_id]
  end

  test 'should logout' do
    login_as(users(:bob))
    delete :destroy
    assert_redirected_to root_path
    assert_nil session[:user_id]
  end
end
