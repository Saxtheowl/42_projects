require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  test 'should redirect non-admin from index' do
    login_as(users(:bob))
    get :index
    assert_redirected_to root_path
  end

  test 'should redirect visitor from index' do
    get :index
    assert_redirected_to root_path
  end

  test 'admin can access index' do
    login_as(users(:admin))
    get :index
    assert_response :success
  end

  test 'admin can edit user' do
    login_as(users(:admin))
    get :edit, id: users(:bob)
    assert_response :success
  end

  test 'admin can update user' do
    login_as(users(:admin))
    patch :update, id: users(:bob), user: { name: 'bob_admin_updated', email: 'bob_admin@example.com' }
    assert_redirected_to admin_users_path
    users(:bob).reload
    assert_equal 'bob_admin_updated', users(:bob).name
  end

  test 'admin can delete user' do
    login_as(users(:admin))
    assert_difference('User.count', -1) do
      delete :destroy, id: users(:bob)
    end
    assert_redirected_to admin_users_path
  end

  test 'non-admin cannot delete user' do
    login_as(users(:bob))
    assert_no_difference('User.count') do
      delete :destroy, id: users(:alice)
    end
    assert_redirected_to root_path
  end
end
