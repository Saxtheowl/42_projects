module CurrentCart
  extend ActiveSupport::Concern

  private

  def set_cart
    @cart = Cart.find_by(session_id: session[:cart_id])

    if @cart.nil?
      @cart = Cart.create!(session_id: session.id.to_s)
      session[:cart_id] = @cart.session_id
    end
  end

  def current_cart
    @cart ||= set_cart
  end
end
