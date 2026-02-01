ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all
end

class ActionController::TestCase
  def login_as(user)
    session[:user_id] = user.id
  end

  def logout
    session.delete(:user_id)
  end
end
