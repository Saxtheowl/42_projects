# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @users = User.order(:last_name, :first_name)
    end

    def show
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        log_activity('admin_created_user', @user, @user.full_name)
        redirect_to admin_user_path(@user), notice: 'User created successfully.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      user_update_params = user_params.reject { |k, v| k == 'password' && v.blank? }

      if @user.update(user_update_params)
        log_activity('admin_updated_user', @user, @user.full_name)
        redirect_to admin_user_path(@user), notice: 'User updated successfully.'
      else
        render :edit
      end
    end

    def destroy
      @user.destroy
      log_activity('admin_deleted_user', nil, @user.full_name)
      redirect_to admin_users_path, notice: 'User deleted successfully.'
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation,
                                   :first_name, :last_name, :role, :operator_group)
    end
  end
end
