# frozen_string_literal: true

module Backoffice
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update]

    def index
      @users = User.order(:last_name, :first_name)
    end

    def show
    end

    def edit
    end

    def update
      if @user.update(user_params)
        log_activity('manager_updated_user_group', @user, "Group: #{@user.operator_group}")
        redirect_to backoffice_user_path(@user), notice: 'User group updated successfully.'
      else
        render :edit
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:operator_group)
    end
  end
end
