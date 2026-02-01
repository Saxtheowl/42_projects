class Admin::VotesController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :set_vote, only: [:destroy]

  def index
    @votes_by_post = Vote.includes(:user, :post).group_by(&:post)
  end

  def destroy
    @vote.destroy
    flash[:notice] = 'Vote deleted successfully'
    redirect_to admin_votes_path
  end

  private

  def set_vote
    @vote = Vote.find(params[:id])
  end
end
