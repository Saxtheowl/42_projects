class PostsController < ApplicationController
  before_action :require_login, except: [:index]
  before_action :set_post, only: [:show, :edit, :update, :destroy, :upvote, :downvote]
  before_action :authorize_edit, only: [:edit, :update]
  before_action :authorize_upvote, only: [:upvote]
  before_action :authorize_downvote, only: [:downvote]

  def index
    @posts = Post.includes(:user).all
  end

  def show; end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      flash[:notice] = 'Post created successfully'
      redirect_to @post
    else
      render :new
    end
  end

  def edit; end

  def update
    @post.edited_by_id = current_user.id
    @post.edited_at = Time.current

    if @post.update(post_params)
      flash[:notice] = 'Post updated successfully'
      redirect_to @post
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = 'Post deleted successfully'
    redirect_to posts_path
  end

  def upvote
    vote = @post.votes.find_or_initialize_by(user: current_user)
    vote.value = 1

    if vote.save
      flash[:notice] = 'Upvoted!'
    else
      flash[:alert] = vote.errors.full_messages.join(', ')
    end
    redirect_to @post
  end

  def downvote
    vote = @post.votes.find_or_initialize_by(user: current_user)
    vote.value = -1

    if vote.save
      flash[:notice] = 'Downvoted!'
    else
      flash[:alert] = vote.errors.full_messages.join(', ')
    end
    redirect_to @post
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_edit
    can_edit = current_user == @post.user || current_user.can_edit_posts? || current_user.admin?
    return if can_edit

    flash[:alert] = 'You are not authorized to edit this post'
    redirect_to @post
  end

  def authorize_upvote
    return if current_user.can_upvote? || current_user.admin?

    flash[:alert] = 'You need at least 3 votes to upvote'
    redirect_to @post
  end

  def authorize_downvote
    return if current_user.can_downvote? || current_user.admin?

    flash[:alert] = 'You need at least 6 votes to downvote'
    redirect_to @post
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
