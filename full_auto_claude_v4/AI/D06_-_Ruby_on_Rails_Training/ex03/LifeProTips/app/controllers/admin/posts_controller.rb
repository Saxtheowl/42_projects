class Admin::PostsController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :set_post, only: [:edit, :update, :destroy]

  def index
    @posts = Post.includes(:user).all
  end

  def edit; end

  def update
    @post.edited_by_id = current_user.id
    @post.edited_at = Time.current

    if @post.update(post_params)
      flash[:notice] = 'Post updated successfully'
      redirect_to admin_posts_path
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = 'Post deleted successfully'
    redirect_to admin_posts_path
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
