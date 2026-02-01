class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show]

  def index
    @orders = current_user.orders.order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: 'Order not found.'
  end
end
