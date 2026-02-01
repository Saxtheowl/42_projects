class CartsController < ApplicationController
  include CurrentCart
  before_action :set_cart

  def show
  end

  def add
    product = Product.find(params[:id])
    @cart.add_product(product)
    redirect_to products_path, notice: "#{product.name} added to cart."
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: 'Product not found.'
  end

  def increment
    item = @cart.cart_items.find(params[:id])
    item.increment_quantity
    redirect_to cart_path
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: 'Item not found.'
  end

  def decrement
    item = @cart.cart_items.find(params[:id])
    item.decrement_quantity
    redirect_to cart_path
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: 'Item not found.'
  end

  def remove
    item = @cart.cart_items.find(params[:id])
    item.destroy
    redirect_to cart_path, notice: 'Item removed from cart.'
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: 'Item not found.'
  end

  def clear
    @cart.clear!
    redirect_to cart_path, notice: 'Cart has been emptied.'
  end

  def checkout
    if @cart.empty?
      redirect_to cart_path, alert: 'Your cart is empty.'
      return
    end

    if user_signed_in?
      @order = Order.create_from_cart(@cart, current_user)
      redirect_to order_path(@order), notice: 'Order placed successfully!'
    else
      redirect_to new_user_session_path, alert: 'Please sign in to complete your order.'
    end
  end
end
