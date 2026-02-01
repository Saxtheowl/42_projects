class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_user, only: [:edit, :update]

  def new
    redirect_to root_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = 'Successfully signed up'
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit; end

  def update
    if @user.update(user_update_params)
      flash[:notice] = 'Profile updated successfully'
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user
    return if current_user == @user || current_user&.admin?

    flash[:alert] = 'You can only edit your own profile'
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_update_params
    params.require(:user).permit(:name, :email)
  end
end
