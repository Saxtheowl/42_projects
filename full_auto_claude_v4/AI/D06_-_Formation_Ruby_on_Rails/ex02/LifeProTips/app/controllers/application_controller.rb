class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?, :visitor_name

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::RoutingError, with: :routing_error

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    flash[:alert] = 'You need an account to see this'
    redirect_to root_path
  end

  def require_admin
    return if current_user&.admin?

    flash[:alert] = 'Admin access required'
    redirect_to root_path
  end

  def visitor_name
    return current_user.name if logged_in?

    if cookies[:visitor_name].blank? || cookies_expired?
      cookies[:visitor_name] = {
        value: fetch_random_animal_name,
        expires: 1.minute.from_now
      }
    end
    "#{cookies[:visitor_name]}_visitor"
  end

  def fetch_random_animal_name
    require 'open-uri'
    url = 'https://www.randomlists.com/random-animals'
    doc = Nokogiri::HTML(open(url))
    doc.css('li').first.css('span').text
  rescue StandardError
    %w[Cat Dog Bird Fish Lion Tiger Bear Wolf Fox Deer].sample
  end

  def cookies_expired?
    false
  end

  def record_not_found
    flash[:alert] = 'Record not found'
    redirect_to root_path
  end

  def routing_error
    flash[:alert] = 'Page not found'
    redirect_to root_path
  end
end
