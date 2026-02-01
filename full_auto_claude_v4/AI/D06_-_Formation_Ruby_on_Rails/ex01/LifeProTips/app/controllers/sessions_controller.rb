class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(name: params[:login]) || User.find_by(email: params[:login])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = 'Successfully logged in'
      redirect_to root_path
    else
      flash.now[:alert] = 'Invalid login credentials'
      render :new
    end
  end

  def destroy
    session.delete(:user_id)
    @current_user = nil
    flash[:notice] = 'Successfully logged out'
    redirect_to root_path
  end
end
