class Admin::UsersController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = User.all
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:notice] = 'User updated successfully'
      redirect_to admin_users_path
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:notice] = 'User deleted successfully'
    redirect_to admin_users_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
