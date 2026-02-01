require 'test_helper'

class Admin::VotesControllerTest < ActionController::TestCase
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

  test 'admin can delete vote' do
    login_as(users(:admin))
    assert_difference('Vote.count', -1) do
      delete :destroy, id: votes(:vote_one)
    end
    assert_redirected_to admin_votes_path
  end
end
