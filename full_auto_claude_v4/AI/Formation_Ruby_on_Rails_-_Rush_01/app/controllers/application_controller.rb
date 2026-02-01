# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_user_admin?, :current_user_manager?, :current_user_operator?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role, :operator_group])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :operator_group])
  end

  def authenticate_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end

  def authenticate_manager!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.manager? || current_user&.admin?
  end

  def authenticate_registered!
    redirect_to root_path, alert: 'Please sign in to access this page.' unless user_signed_in?
  end

  def current_user_admin?
    current_user&.admin?
  end

  def current_user_manager?
    current_user&.manager?
  end

  def current_user_operator?
    current_user&.operator?
  end

  def log_activity(action, trackable = nil, details = nil)
    ActivityLog.log(current_user, action, trackable, details) if current_user
  end
end
