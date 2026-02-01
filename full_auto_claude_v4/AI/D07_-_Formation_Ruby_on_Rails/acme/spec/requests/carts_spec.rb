require 'rails_helper'

RSpec.describe "Carts", type: :request do
  let(:brand) { create(:brand) }
  let(:product) { create(:product, brand: brand, price: 25.00) }

  describe "GET /cart" do
    it "returns http success" do
      get cart_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /cart/add/:id" do
    it "adds a product to cart" do
      post add_to_cart_path(product)
      expect(response).to redirect_to(products_path)
    end

    it "creates a cart item" do
      expect {
        post add_to_cart_path(product)
      }.to change(CartItem, :count).by(1)
    end
  end

  describe "POST /cart/increment/:id" do
    before do
      post add_to_cart_path(product)
    end

    it "increments the quantity" do
      cart_item = CartItem.last
      expect {
        post increment_cart_path(cart_item)
        cart_item.reload
      }.to change(cart_item, :quantity).by(1)
    end
  end

  describe "POST /cart/decrement/:id" do
    before do
      post add_to_cart_path(product)
      post add_to_cart_path(product)
    end

    it "decrements the quantity" do
      cart_item = CartItem.last
      expect {
        post decrement_cart_path(cart_item)
        cart_item.reload
      }.to change(cart_item, :quantity).by(-1)
    end
  end

  describe "DELETE /cart/remove/:id" do
    before do
      post add_to_cart_path(product)
    end

    it "removes the item from cart" do
      cart_item = CartItem.last
      expect {
        delete remove_from_cart_path(cart_item)
      }.to change(CartItem, :count).by(-1)
    end
  end

  describe "DELETE /cart/clear" do
    before do
      post add_to_cart_path(product)
      post add_to_cart_path(create(:product, brand: brand))
    end

    it "removes all items from cart" do
      delete clear_cart_path
      expect(CartItem.count).to eq(0)
    end
  end

  describe "POST /cart/checkout" do
    let(:user) { create(:user) }

    context "when not logged in" do
      before { post add_to_cart_path(product) }

      it "redirects to login" do
        post checkout_cart_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in with items in cart" do
      before do
        sign_in user
        post add_to_cart_path(product)
      end

      it "creates an order" do
        expect {
          post checkout_cart_path
        }.to change(Order, :count).by(1)
      end

      it "clears the cart" do
        post checkout_cart_path
        follow_redirect!
        get cart_path
        expect(CartItem.count).to eq(0)
      end
    end
  end
end
