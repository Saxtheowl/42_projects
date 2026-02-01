# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :set_like, only: %i[show edit update destroy]

  def index
    @likes = Like.all
    @top_cuicuis = Cuicui.top
  end

  def show; end

  def new
    @like = Like.new
  end

  def edit; end

  def create
    @like = Like.new(like_params)
    if @like.save
      redirect_to @like, notice: 'Like was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @like.update(like_params)
      redirect_to @like, notice: 'Like was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @like.destroy
    redirect_to likes_url, notice: 'Like was successfully destroyed.'
  end

  private

  def set_like
    @like = Like.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to likes_url, alert: 'Like not found.'
  end

  def like_params
    params.require(:like).permit(:user_id, :cuicui_id)
  end
end
