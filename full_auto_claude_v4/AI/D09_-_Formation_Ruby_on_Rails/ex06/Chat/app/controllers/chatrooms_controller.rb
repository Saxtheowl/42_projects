class ChatroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chatroom, only: [:show, :destroy]

  def index
    @chatrooms = Chatroom.all
  end

  def show
    @messages = @chatroom.messages.includes(:user)
    @message = Message.new
  end

  def new
    @chatroom = Chatroom.new
  end

  def create
    @chatroom = current_user.chatrooms.build(chatroom_params)
    if @chatroom.save
      redirect_to @chatroom, notice: 'Chatroom created.'
    else
      render :new
    end
  end

  def destroy
    if @chatroom.user == current_user
      @chatroom.destroy
      redirect_to chatrooms_path, notice: 'Chatroom deleted.'
    else
      redirect_to chatrooms_path, alert: 'Not authorized.'
    end
  end

  private

  def set_chatroom
    @chatroom = Chatroom.find(params[:id])
  end

  def chatroom_params
    params.require(:chatroom).permit(:name)
  end
end
