# frozen_string_literal: true

# CommentsController handles CRUD operations for comments
class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show edit update destroy]

  def index
    @comments = Comment.all
  end

  def show; end

  def new
    @comment = Comment.new
  end

  def edit; end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      redirect_to @comment, notice: 'Comment was successfully created.'
    else
      render :new
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to @comment, notice: 'Comment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @comment.destroy
    redirect_to comments_url, notice: 'Comment was successfully destroyed.'
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to comments_path, alert: 'Comment not found'
  end

  def comment_params
    params.require(:comment).permit(:content, :user_id, :cuicui_id)
  end
end
